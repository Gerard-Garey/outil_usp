###############################################################################
#  tests/niveau_mw_trapeze_t8.R  --  NIVEAU A T = 8 DES TESTS DE
#  MERZ-WUTHRICH SUR LES TRAPEZES 8 x 5, 8 x 6 ET 8 x 7 (issue #567,
#  branche S6, etape 5 (b))
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; parallel, utils et tools (livres avec R). Il ne modifie
#  ni R/, ni app.R, ni tests/reference/ ; ni le moteur ni l'application ne le
#  lisent (controle (m)). Le moteur (fonctions de l'etape 3, garde MW-04 en
#  place) est charge par tests/outils_tests.R, donc par charger_moteur()
#  (ADR 0016), qui porte aussi commit_depot(), motifs_non_versionnable(),
#  garde_ecrasement(), empreinte_sans_commentaires(), comparer_objets(),
#  DATE_REFERENCE_TESTS et .tri. Fichier source ASCII : libelles non ASCII
#  en echappements \u ; sortie en UTF-8, y compris sous LC_ALL=C.
#
#  Protocole : specification d'actuary
#  docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md, par. 8
#  (P1 a P8) et 9, et decisions du mainteneur du 20/11/2026 (fin du meme
#  fichier) : Q-2a-1 (c) (residus de la colonne J-1 reduits par
#  l'estimateur direct ; le 8 x 7 a les statistiques observees du 8 x 8 dont
#  il est tronque, d'ou K-T6) ; Q-2a-2 (simulation du bootstrap sur la
#  valeur de la regle de minimum) ; Q-2a-3 (H_max = 20 h d'horloge sur 4
#  processus, echelle L0 a L2, 8 x 7 reduit, niveau choisi par le pre-vol) ;
#  Q-2a-5 (CL_MSEPs lue dans l'archive CRAN ChainLadder 0.2.21, md5 fixe,
#  chemin en argument, jamais copiee dans le depot). Le critere du par. 8, P7,
#  et le statut epistemique sont reportes SANS MODIFICATION dans
#  TEXTE_CRITERE_567 et TEXTE_STATUT_567 (controle (t) : presence a
#  l'identique dans la specification versee, avant tout tirage).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack
#  ajuste a reserve2), conditionnel a l'admission ; pas un resultat general.
#  Classes et profils evalues mecaniquement, SANS CONCLURE : la lecture
#  revient a actuary, la decision (D2) au mainteneur.
#
#  Plan (P2). Geometries G = 8 x 5, 8 x 6, 8 x 7 (J = 4, 5, 6 ; g = 1, 2,
#  3) : f_j et sigma2_j de mw_ajuster(reserve2) pour j = 0..J-1 (estimateurs
#  directs du carre, J - 1 <= 5), premiere colonne de reserve2 fixee, I = 7.
#  Lois : N (rnorm) et E (tirage uniforme dans le pool redresse de reserve2,
#  27 valeurs divisees par leur ecart-type de population, #206 par. 2 ;
#  l = 1, 2). Plan emboite : sous une meme graine, le trapeze G est la
#  troncature du 8 x 8 simule (controle (g') : sur 100 graines par loi avant
#  tout tirage, et sur chaque triangle tire, colonne gp).
#  Generateur gen_triangle_h0() : copie declaree de
#  tests/calibration_mc_mw_t8.R (meme recursion que
#  .mw_simuler_triangle_etat(), controle (g)).
#  Admission (P1) : cellule a NA (cumul simule non fini ou <= 0,
#  .mw_triangle_incomplet()), puis erreurs de mw_valider_triangle() HORS le
#  seul motif MW-04 (prefixe "Triangle non carre ("), puis
#  mw_valider_ajustement() (M4 : reserve <= 0). Tout autre motif fait
#  refuser le triangle, compte, sans retirage ; une erreur R survenue avant
#  la fin de l'admission (generation, mw_valider_triangle()) est un refus de
#  motif "erreur", et seule une erreur posterieure (mw_bootstrap(),
#  mw_tests()) fait un triangle admis en echec. Comme mw_valider_triangle()
#  ne fait ses controles de cellule qu'en l'absence de motif (mesure : le
#  bloc "if (!length(err))" suit MW-04), le seul controle de cellule que
#  .mw_triangle_incomplet() ne couvre pas, le domaine numerique
#  [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] (#185), est refait ici
#  (motif "domaine") ; noms de ligne : aucun sur un triangle simule.
#  Par triangle admis (P1) : mw_ajuster() -> .mw_ensembles_figes() ->
#  mw_bootstrap(aj, B, graine, figes) -> mw_tests(aj, boot, alpha = 0,10,
#  figes), soit le chemin de .run_engine_mw().
#  Oracle (P5, K3, rho) : N0 = 20 000 triangles par (G, loi), statistiques
#  par stats_oracle() (copie declaree de tests/calibration_mc_mw_t8.R).
#
#  Graines (P3, appliquees EXACTEMENT ; toutes sous engine_sous_graine()) :
#    triangle b, loi l : 567 000 000 + 100 000 (l - 1) + b (commune aux G) ;
#    bootstrap : 568 000 000 + 1 000 000 (g - 1) + 100 000 (l - 1) + b ;
#    oracle k : 570 000 000 + 100 000 (l - 1) + k (k <= 20 000) ;
#    pre-vol : 571 000 000 + k ; sous-plages non fixees par P3 : triangle u
#    571 000 000 + u, bootstrap 571 050 000 + u (u <= 50 000).
#  CHEVAUCHEMENT INTERNE de P3 (mesure, controle (graines)) : la graine du
#  bootstrap du 8 x 7 (g = 3) vaut 570 000 000 + 100 000 (l - 1) + b, soit
#  la graine de l'oracle k = b de la meme loi : signale au T0, non bloquant
#  (P3 applique tel quel ; question pour actuary).
#  Controles (r297) : graines de #206 (b = 1, 2, lois N et E), bornes
#  declarees par les affectations PLAGE_R297_* (forme exacte de R21, #350).
#
#  Critere (P7, texte reporte ci-dessous) : K1 (13 cles, 8 x 5 et 8 x 6),
#  K-T6 (8 x 7 : classes et Fisher exact bilateral contre tau(8 x 8) du brut
#  de #297, Holm sur 13 a 0,05), K3 (temoin oracle, regle beta-binomiale du
#  05/11/2026), K4, K5, K-T4, K-T7 ; profils Theta0 a Theta5.
#
#  Controles d'integrite (P6 ; un seul echec : INTEGRITE ECHEC) : (1) md5,
#  SHA et empreinte #231 constants ; (a) reserve2 contre
#  tests/reference/reserve2.rds au seuil 0 ; (m4) run_engine() sur les trois
#  trapezes de reserve2 : ok = FALSE avec MW-04 seul ; (g) generateur ;
#  (g') troncature ; (c1) C1 (CL_MSEPs) sur les trois trapezes de reserve2
#  et sur le premier triangle admis de chaque tranche ; (r297) ; (o) ;
#  (t) ; (graines) (une declaration PLAGE_<nom> <- c(567000000, 572000000)
#  de la plage reservee par P3, dans un autre script, n'est pas comptee comme
#  graine et est citee a part) ; (m) ; et, repris de #206 et #387 : (i1) statistiques
#  observees du chemin de l'oracle identiques a boot$stats_obs (validite du
#  temoin K3, premier triangle admis de chaque tranche) ; (rep) premier et
#  dernier triangles admis de chaque (G, loi) recalcules, ligne identique
#  hors duree (reprise). Controles (t), (a), (m4), (g), (g'), (c1) sur
#  reserve2, (r297), (o), (graines) et (m) AVANT tout tirage du plan : un
#  echec arrete le script. Le controle "apres D2" de P6 (20 triangles par
#  geometrie repasses par run_engine()) releve de l'etape 6.
#
#  Modes :
#    --essai --archive-cl CHEMIN [--processus k] [--travail D]
#      [--duree-max H] : R = 4 triangles par (G, loi), N0 = 100 (au moins
#      B_MIN_DEGENERESCENCE = 50 statistiques oracle, sans quoi le temoin K3
#      n'a pas de p), B = 199 ;
#      dossier temporaire par defaut ; sortie marquee ESSAI ; --ecrire refuse.
#    --prevol [--unites 1] : couts a 1, 2, 3 et 4 processus concurrents
#      (memes unites dans chaque processus, graines du pre-vol), taux
#      d'admission, duree planifiee de L0, L1 et L2 a 4 processus, niveau
#      retenu (premier niveau dont la duree planifiee tient dans
#      H_max = 20 h d'horloge ; sous L2, retour au mainteneur), nombre de
#      segments de 2 h (M42 (b)) ; rien d'ecrit.
#    mesure : --niveau Lk --archive-cl CHEMIN [--processus k] [--travail D]
#      [--duree-max H] [--ecrire [--remplacer]] ; R ecrit au JOURNAL avant
#      tout calcul.
#  Reprise (M42 (b)) : tranches de 100 triangles consecutifs d'une (G, loi)
#  (et de l'oracle), ecrites dans le dossier de travail (hors du depot) des
#  qu'elles sont completes (temporaire puis renommage) ; une relance avec le
#  meme dossier reprend aux tranches absentes ; une tranche dont le contexte
#  (B, SHA, md5 du moteur et du script, empreinte #231, plateforme) differe
#  du contexte courant arrete le script. --duree-max H : aucun nouveau
#  groupe de tranches n'est lance si la duree ecoulee plus la duree estimee
#  du groupe depasse H heures d'horloge (estimation : cout par ligne mesure
#  sur les groupes deja calcules du meme type, triangles tires ou oracle ;
#  a defaut 16 s par triangle tire, budget du par. 8, P4, et 0,05 s par
#  triangle d'oracle) ; sortie "SEGMENT INTERROMPU", code 3 ;
#  la relance reprend. Dossier par defaut :
#  <parent de la racine>/issue567-travail-<niveau>.
#  Sorties (P8 ; dossier de travail ; avec --ecrire, copiees dans
#  docs/tableaux/ si INTEGRITE OK) : <AAAAMMJJ>-issue567-niveau-trapeze-mw.md,
#  <AAAAMMJJ>-issue567-niveau-trapeze-mw-brut.tsv (une ligne par triangle
#  tire, %.17g, sans duree), <AAAAMMJJ>-issue567-niveau-trapeze-mw-journal-mesure.md ;
#  AAAAMMJJ : date (UTC) du premier lancement, lue au JOURNAL. L'oracle reste
#  dans le dossier de travail (oracle.tsv), son md5 au T0. --ecrire exige un
#  commit propre (motifs_non_versionnable()) et garde_ecrasement().
#
#  Usage (racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/niveau_mw_trapeze_t8.R --essai --archive-cl CHEMIN
#      Rscript tests/niveau_mw_trapeze_t8.R --prevol
#      Rscript tests/niveau_mw_trapeze_t8.R --niveau L0 --archive-cl CHEMIN
#          --processus 4 [--travail DOSSIER] [--duree-max 1.8] [--ecrire]
#  Derniere ligne de la console : INTEGRITE OK, INTEGRITE ECHEC ou SEGMENT
#  INTERROMPU. Code de sortie : 0 si INTEGRITE OK, 3 si segment interrompu,
#  1 sinon (et sur tout refus).
###############################################################################

t_debut <- Sys.time()

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, critere de #242) -------------
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
CONNUES <- c("--essai", "--prevol", "--niveau", "--processus", "--travail", "--ecrire", "--remplacer",
             "--unites", "--archive-cl", "--duree-max")
AVEC_VALEUR <- c("--niveau", "--processus", "--travail", "--unites", "--archive-cl", "--duree-max")
refuser <- function(...) { message("REFUS : ", ...); quit(status = 1L) }
local({
  i <- 1L
  while (i <= length(ARGS)) {
    if (!ARGS[i] %in% CONNUES) refuser("option inconnue : ", ARGS[i])
    if (ARGS[i] %in% AVEC_VALEUR && i == length(ARGS)) refuser("option ", ARGS[i], " sans valeur")
    i <- i + if (ARGS[i] %in% AVEC_VALEUR) 2L else 1L
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) defaut else ARGS[i + 1L]
}
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_PREVOL    <- "--prevol" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_NIVEAU    <- lire_option("--niveau", NA_character_)
OPT_TRAVAIL   <- lire_option("--travail", NA_character_)
OPT_ARCHIVE   <- lire_option("--archive-cl", NA_character_)
OPT_UNITES    <- suppressWarnings(as.integer(lire_option("--unites", "1")))
OPT_DUREE_MAX <- suppressWarnings(as.numeric(lire_option("--duree-max", "Inf")))
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)
OPT_PROC <- suppressWarnings(as.integer(lire_option("--processus",
              as.character(if (.Platform$OS.type == "windows") 1L else max(1L, min(4L, COEURS, na.rm = TRUE))))))
MODE <- if (OPT_PREVOL) "prevol" else if (OPT_ESSAI) "essai" else "mesure"
if (OPT_PREVOL && OPT_ESSAI) refuser("--prevol et --essai sont exclusifs")
if (OPT_PREVOL && any(c("--niveau", "--ecrire", "--remplacer", "--travail", "--processus", "--archive-cl", "--duree-max") %in% ARGS))
  refuser("--prevol : seule l'option --unites est admise")
if (MODE != "prevol" && "--unites" %in% ARGS) refuser("--unites : reserve a --prevol")
if (OPT_ESSAI && OPT_ECRIRE) refuser("--ecrire refuse sous --essai (sorties non versionnables)")
if (OPT_ESSAI && !is.na(OPT_NIVEAU)) refuser("--niveau : reserve a la mesure")
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (MODE == "mesure" && is.na(OPT_NIVEAU)) refuser("mesure : --niveau L0, L1 ou L2 obligatoire (fixe par le pre-vol, P4)")
if (MODE == "mesure" && !OPT_NIVEAU %in% c("L0", "L1", "L2")) refuser("--niveau : L0, L1 ou L2")
if (MODE != "prevol" && is.na(OPT_ARCHIVE)) refuser("--archive-cl CHEMIN obligatoire (controle (c1), archive CRAN ChainLadder_0.2.21.tar.gz, Q-2a-5)")
if (MODE != "prevol" && !file.exists(OPT_ARCHIVE)) refuser("--archive-cl : fichier introuvable")
if (is.na(OPT_UNITES) || OPT_UNITES < 1L || OPT_UNITES > 20L) refuser("--unites : entier de 1 a 20")
if (is.na(OPT_PROC) || OPT_PROC < 1L) refuser("--processus : entier >= 1")
if (.Platform$OS.type == "windows" && OPT_PROC > 1L) refuser("--processus > 1 : fork indisponible sous Windows")
if (is.na(OPT_DUREE_MAX) || OPT_DUREE_MAX <= 0) refuser("--duree-max : nombre d'heures > 0")

# --- Protocole (constantes, P2 a P8) -----------------------------------------
# B en double, comme le B par defaut de run_engine() (mw_bootstrap() restitue
# B tel quel).
B_MESURE <- 999
B_ESSAI  <- 199
ALPHA <- 0.10                                             # alpha des verdicts (P1)
SEUILS <- c(a10 = 0.10, a05 = 0.05)                       # P7 : alpha mesures
NIVEAU_HOLM <- 0.05
SEUIL_K4 <- 0.01; SEUIL_REFUS <- 0.01                     # K4
TOL_C1 <- 1e-12                                           # par. 1.3
MD5_ARCHIVE_CL <- "2a1fc0fcc593ec99529a40399274a088"      # Q-2a-5
GEOM <- data.frame(code = c("8x5", "8x6", "8x7"), J = c(4L, 5L, 6L), g = 1:3, stringsAsFactors = FALSE)
J_G <- stats::setNames(GEOM$J, GEOM$code); IDX_G <- stats::setNames(GEOM$g, GEOM$code)
LOIS <- c(N = 1L, E = 2L)
# Niveaux (P4) : triangles TIRES par (G, loi), memes R pour N et E.
NIVEAUX <- list(L0 = c("8x5" = 2000L, "8x6" = 2000L, "8x7" = 1000L),
                L1 = c("8x5" = 1500L, "8x6" = 1500L, "8x7" = 500L),
                L2 = c("8x5" = 1000L, "8x6" = 1000L, "8x7" = 500L))
N0_MESURE <- 20000L                                       # oracle par (G, loi)
R_ESSAI <- 4L; N0_ESSAI <- 100L
R_MAX_PLAN <- 2000L                                       # b <= 2 000 (L0)
TAILLE_TRANCHE <- 100L
BUDGET_S <- 20 * 3600                                     # H_max (Q-2a-3)
K_BUDGET <- 4L                                            # sur 4 processus
SEGMENT_S <- 2 * 3600                                     # M42 (b) : segments de 2 h
# Graines (P3). Bases ecrites en entier.
GRAINE_TRI <- 567000000; GRAINE_BOOT <- 568000000; GRAINE_ORA <- 570000000
GRAINE_PV <- 571000000; GRAINE_PV_BOOT <- 571050000
graine_tri  <- function(loi, b) GRAINE_TRI + 100000 * (LOIS[[loi]] - 1L) + b
graine_boot <- function(G, loi, b) GRAINE_BOOT + 1000000 * (IDX_G[[G]] - 1L) + 100000 * (LOIS[[loi]] - 1L) + b
graine_ora  <- function(loi, k) GRAINE_ORA + 100000 * (LOIS[[loi]] - 1L) + k
graine_pv_tri  <- function(u) GRAINE_PV + u
graine_pv_boot <- function(u) GRAINE_PV_BOOT + u
# Graines de #206 (controle (r297) seulement) : triangle 20 840 000 +
# 10 000 (l - 1) + b, bootstrap 20 870 000 + 10 000 (l - 1) + b, b = 1, 2.
# Bornes declarees sous la forme PLAGE_<nom> <- c(L1, L2) (R21, #350).
PLAGE_R297_TRI_N <- c(20840001, 20840002)
PLAGE_R297_TRI_E <- c(20850001, 20850002)
PLAGE_R297_BOOT_N <- c(20870001, 20870002)
PLAGE_R297_BOOT_E <- c(20880001, 20880002)
# Plages des mesures anterieures (P3), pour la disjonction (controle (graines)).
PLAGE_EXT_206 <- c(20840001, 20960000)      # #206 et #297, Merz-Wuthrich
PLAGE_EXT_297LN <- c(20260831, 20262831)    # #297 lognormale
PLAGE_EXT_305 <- c(305000000, 305939169)    # #305
PLAGE_EXT_387 <- c(387000000, 393100000)    # #387
PLAGE_EXT_360 <- c(360380123, 360380123)    # graine 360 380 123 (P3)
# Plage reservee a #567 par P3 ("2b (#610) doit eviter 567 10^6 a 572 10^6").
# Une declaration de cette plage dans un autre script, de la forme exacte
# PLAGE_<nom> <- c(567000000, 572000000) (R21, #350), n'est pas une graine :
# le controle (graines) l'ecarte de la recherche des litteraux et la cite a
# part (tests/couverture_ic_sigma_mw_imbrique_t8.R, PLAGE_EXT_2A, #610).
PLAGE_RESERVEE_P3 <- c(567000000, 572000000)
DECALAGE_LITTERAL <- 20000                  # annotation du 10/10/2026 de #206, point 1
RHO_F <- c(a10 = 0.099, a05 = 0.049)        # reference des p de famille (Fk, par. 5.3), K-T7
PROTOCOLE <- "docs/revues/20261120-s6-trapeze/actuary-2a-specification-567.md"
SCRIPT_DEPOT <- "tests/niveau_mw_trapeze_t8.R"
BRUT_297 <- "docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv"
MOTIF_MW04 <- "Triangle non carre ("
# Valeurs vraies de sigma2_(J-1) arrondies du critere (K-T4) : comparees a
# celles du DGP au T0.
S2_VRAI_SPEC <- c("8x5" = "0.31478", "8x6" = "0.097325", "8x7" = "0.18967")

# Statut epistemique et critere (P7) du par. 8 de la specification, reportes
# SANS MODIFICATION (controle (t)).
TEXTE_STATUT_567 <- c(
  "**Statut \u00e9pist\u00e9mique**, \u00e0 \u00e9crire en t\u00eate des sorties : constat de simulation sous un plan (mod\u00e8le de Mack ajust\u00e9 \u00e0 `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel \u00e0 l'admission. Ce n'est pas un r\u00e9sultat g\u00e9n\u00e9ral ; il ne se transpose ni \u00e0 d'autres param\u00e8tres ni \u00e0 d'autres g\u00e9om\u00e9tries. Aucun th\u00e9or\u00e8me ne couvre ces tests bootstrap \u00e0 T = 8.")
TEXTE_CRITERE_567 <- c(
  "**P7. Crit\u00e8re**, \u00e0 reporter sans modification :",
  "",
  "> **Crit\u00e8re.** D = 1 si p_mc < \u03b1, \u03b1 \u2208 {0,10 ; 0,05} ; une p absente compte comme un non-rejet, compt\u00e9e \u00e0 part. \u03c4 = k/n sur les triangles admis, IC de Clopper-Pearson \u00e0 95 %. R\u00e9f\u00e9rence \u03c1(s, \u03b1, G, \u2113) : taille liss\u00e9e du test de Monte-Carlo id\u00e9al \u00e0 B = 999 sur l'oracle de (G, \u2113) (r\u00e8gle de #206 \u00a7 4). Classes de #166 et #206, bande ferm\u00e9e [\u03c1/2 ; 3\u03c1/2] : compatible ; \u00e9cart mineur ; non tranch\u00e9 ; distorsion mat\u00e9rielle lib\u00e9rale ou conservatrice ; valeurs non arrondies ; un non tranch\u00e9 reste non tranch\u00e9.",
  "> - **K1** (principal) : classe des 13 cl\u00e9s de `MW_CATALOGUE_MC` par (G, \u2113, \u03b1), G \u2208 {8\u00d75, 8\u00d76}.",
  "> - **K-T6** (contr\u00f4le d'impl\u00e9mentation, sous (c)) : pour 8\u00d77, classes K1 ; et, par cl\u00e9 et par \u03b1, test exact de Fisher bilat\u00e9ral de \u03c4(8\u00d77) contre \u03c4(8\u00d78, #297, m\u00eame loi), Holm sur 13 \u00e0 0,05.",
  "> - **K3** : t\u00e9moin oracle, r\u00e8gle b\u00eata-binomiale du 05/11/2026, Holm sur 13.",
  "> - **K4** : p absentes au plus 1 % par (G, \u2113) ; refus au plus 1 %.",
  "> - **K5** (descriptif) : B effectif, motifs ; part des lignes inop\u00e9rantes (champ `inoperant` de `mw_tests()`) et des statistiques NA par cl\u00e9 et par G.",
  "> - **K-T4** (descriptif, sans crit\u00e8re) : distribution de \u03c3\u0302\u00b2_{J\u22121} de la r\u00e8gle / \u03c3\u00b2_{J\u22121} vrai et de \u03c3\u0302\u00b2_{J\u22121,dir} / \u03c3\u00b2_{J\u22121} vrai (vrais : 0,31478 ; 0,097325 ; 0,18967 pour 8\u00d75, 8\u00d76, 8\u00d77) ; rapport des \u221aMSEP r\u00e8gle / direct ; taux de M4.",
  "> - **K-T7** (descriptif) : niveau des p de famille et de la p globale (`engine_p_famille()`).",
  ">",
  "> **Profils pour D2** (`actuary` propose, le mainteneur tranche ; ordre \u03980, \u03985, \u03984, \u03983, \u03982, \u03981) :",
  ">",
  "> | Profil | Condition | Lecture propos\u00e9e |",
  "> |---|---|---|",
  "> | \u03980 | int\u00e9grit\u00e9, K3 ou K4 en d\u00e9faut ; ou K-T6 significatif, non expliqu\u00e9 | lecture suspendue ; impl\u00e9mentation \u00e0 revoir |",
  "> | \u03985 | une cl\u00e9 en distorsion de c\u00f4t\u00e9s oppos\u00e9s entre N et E pour une G | niveau non robuste \u00e0 la loi : documenter ; d\u00e9cision du mainteneur pour la cl\u00e9 |",
  "> | \u03984 | distorsion mat\u00e9rielle lib\u00e9rale d'une cl\u00e9 sur 8\u00d75 ou 8\u00d76, pour une loi | les ALERTE et ECHEC de la cl\u00e9 sur cette g\u00e9om\u00e9trie surestiment la preuve. Options : extension avec la cl\u00e9 en diagnostic sur la g\u00e9om\u00e9trie, ou refus maintenu. Si la m\u00eame distorsion existe sur le 8\u00d78 (#297), elle n'est pas propre au trap\u00e8ze et se lit comme telle |",
  "> | \u03983 | distorsion mat\u00e9rielle conservatrice sur une cl\u00e9 | extension possible ; OK de la cl\u00e9 = preuve faible, \u00e9crit par g\u00e9om\u00e9trie |",
  "> | \u03982 | aucune distorsion, des non tranch\u00e9s | extension possible, IC document\u00e9s |",
  "> | \u03981 | 13 cl\u00e9s compatibles ou en \u00e9cart mineur sur 8\u00d75 et 8\u00d76, N et E, aux deux seuils, et K-T6 sans signal | niveau comparable au carr\u00e9 ; le volet \u00ab tests \u00bb ne s'oppose pas \u00e0 l'extension |")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
FAM <- c("M1", "M2", "M3", "M4", PREFIXE_LECTURE_CONJOINTE)
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
LIB_MOTIF <- c(o = "obs. non finie", z = "B eff. = 0", i = "B eff. < B_MIN_DEGENERESCENCE", d = "dispersion nulle",
               c = "condition du catalogue", a = "atome hors obs.", "?" = "motif inconnu")
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))
code_verdict <- function(v) if (is.null(v) || length(v) != 1L || is.na(v)) "-" else switch(v, OK = "O", ALERTE = "A", ECHEC = "E", INFO = "I", "X")

# --- Outils de forme ---------------------------------------------------------
utf8 <- function(x) {
  x <- as.character(x)
  if (!isTRUE(l10n_info()[["UTF-8"]])) { k <- Encoding(x) == "unknown"; Encoding(x)[k] <- "UTF-8"; x } else enc2utf8(x)
}
ecrire_console <- function(x) writeLines(utf8(x), useBytes = TRUE)
ecrire_fichier <- function(f, lignes, mode = "wb") {
  con <- file(f, open = mode); on.exit(close(con))
  writeLines(utf8(lignes), con, sep = "\n", useBytes = TRUE)
}
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 4) if (length(x) != 1L || is.na(x)) "\u2014" else if (is.infinite(x)) (if (x > 0) "+\u221e" else "\u2212\u221e") else
  sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
D_IC <- 5L                                                 # #242, D-e
txt_ic <- function(ci, d = D_IC) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
fmt_p <- function(p) if (length(p) != 1L || !is.finite(p)) "\u2014" else sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
secs <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
horodatage <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
nettoyer_champ <- function(s) gsub("[\t\r\n]+", " ", s)
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(basename(extSoftVersion()[["BLAS"]])), txt(basename(La_library())), txt(La_version()))
}
sha_head <- function() {
  h <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RACINE), "rev-parse", "HEAD"),
                                         stdout = TRUE, stderr = FALSE)), error = function(e) character(0))
  if (length(h) == 1L && grepl("^[0-9a-f]{40}$", h)) h else "inconnu"
}
meme_fichier <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
  identical(normalizePath(a), normalizePath(b))
empreintes_code <- function() {
  lieu <- function(f, ref) if (meme_fichier(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5_fichier(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5_fichier(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(FICHIER_SCRIPT, SCRIPT_DEPOT), md5_fichier(FICHIER_SCRIPT))),
        collapse = " ; ")
}
chemin_absolu <- function(chemin) {
  p <- chemin; reste <- character(0)
  while (!file.exists(p) && dirname(p) != p) { reste <- c(basename(p), reste); p <- dirname(p) }
  base <- normalizePath(p, winslash = "/", mustWork = TRUE)
  if (length(reste)) paste(c(sub("/$", "", base), reste), collapse = "/") else base
}
sous_depot <- function(chemin) {
  d <- chemin_absolu(chemin)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (.Platform$OS.type == "windows") { d <- tolower(d); r <- tolower(r) }
  identical(d, r) || startsWith(d, paste0(r, "/"))
}
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}
# Arguments cites (JOURNAL, T0) : valeurs de --travail et --archive-cl masquees.
args_cites <- function() {
  a <- ARGS
  i <- match("--travail", a); if (!is.na(i)) a[i + 1L] <- "(dossier hors du d\u00e9p\u00f4t)"
  i <- match("--archive-cl", a); if (!is.na(i)) a[i + 1L] <- basename(a[i + 1L])
  if (length(a)) paste(a, collapse = " ") else "(aucun)"
}
present_bloc <- function(bloc, txt) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
ecart_rel <- function(a, b) {
  if (is.null(a) || is.null(b) || length(a) != length(b) || !length(a)) return(Inf)
  if (any(!is.finite(a)) || any(!is.finite(b))) return(Inf)
  e <- abs(a - b) / pmax(abs(a), abs(b)); e[a == b] <- 0
  max(e)
}

# --- Contexte au debut du calcul (controle (1)) ------------------------------
MD5_MOTEUR_DEBUT <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_DEBUT <- sha_head()
COMMIT_DEBUT <- commit_depot(SCRIPT_DEPOT)
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
EMPREINTE_DEBUT <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
PLATEFORME <- plateforme_calcul()
EMPREINTES <- empreintes_code()
SEED_DEFAUT <- eval(formals(run_engine)$seed)

###############################################################################
#  DGP, LOIS, GENERATEUR, ADMISSION (P1, P2)
###############################################################################
AJ8 <- mw_ajuster(.tri)
JD8 <- .mw_colonnes_degenerees(AJ8)
POOL0 <- .mw_pool_residus(AJ8, JD8)
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
POOL_E <- POOL0 / SD_POP0
# DGP d'une geometrie : champs lus par gen_triangle_h0() et par
# .mw_simuler_triangle_etat() (I, J, premiere colonne, f, sigma2), j = 0..J-1.
dgp_G <- function(J) list(I = AJ8$I, J = J, tri = AJ8$tri[, seq_len(J + 1L), drop = FALSE],
                          f = AJ8$f[seq_len(J)], sigma2 = AJ8$sigma2[seq_len(J)])
DGP <- lapply(stats::setNames(GEOM$J, GEOM$code), dgp_G)
S2_VRAI <- vapply(GEOM$code, function(G) DGP[[G]]$sigma2[J_G[[G]]], 1)
TIREURS <- list(N = function(n) stats::rnorm(n), E = function(n) sample(POOL_E, n, replace = TRUE))
# Generateur : copie declaree de gen_triangle_h0() de tests/calibration_mc_mw_t8.R
# (meme recursion, meme expression, meme ordre de consommation des epsilon,
# meme arret au premier cumul simule non fini ou <= 0, #257). JAMAIS nomme
# mw_simuler_triangle. Le controle (g) en prouve l'identite (carre et
# trapezes).
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
triangle_G <- function(G, loi, graine) engine_sous_graine(graine, gen_triangle_h0(DGP[[G]], TIREURS[[loi]]))
triangle_8 <- function(loi, graine) engine_sous_graine(graine, gen_triangle_h0(AJ8, TIREURS[[loi]]))
# Admission (P1) : copie adaptee de admettre() de tests/couverture_ic_sigma_mw_t8.R
# (segment 1, annexe II), MW-04 ecarte et domaine numerique refait (en-tete).
# Codes : "cellule", "triangle", "domaine", "ajuster", "msep" (erreur), "M4"
# (refus de mw_valider_ajustement() a reserve finie <= 0), "ajustement".
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, code = "cellule", motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = 1, annexe = "II")
  autres <- v$erreurs[!startsWith(v$erreurs, MOTIF_MW04)]
  if (length(autres)) return(list(ok = FALSE, code = "triangle", motif = nettoyer_champ(paste("mw_valider_triangle :", paste(autres, collapse = " ; ")))))
  x <- tri[row(tri) + col(tri) - 2L <= nrow(tri) - 1L]
  if (any(x < DOMAINE_NUMERIQUE_MIN | x > DOMAINE_NUMERIQUE_MAX))
    return(list(ok = FALSE, code = "domaine", motif = "cumul hors du domaine num\u00e9rique (#185)"))
  aj <- tryCatch(mw_ajuster(tri), error = function(e) e)
  if (inherits(aj, "error")) return(list(ok = FALSE, code = "ajuster", motif = nettoyer_champ(paste("mw_ajuster en erreur :", conditionMessage(aj)))))
  ms <- tryCatch(mw_msep(aj), error = function(e) e)
  if (inherits(ms, "error")) return(list(ok = FALSE, code = "msep", motif = nettoyer_champ(paste("mw_msep en erreur :", conditionMessage(ms)))))
  va <- mw_valider_ajustement(aj, ms$msep)
  if (!isTRUE(va$ok)) {
    m4 <- is.finite(aj$reserve) && aj$reserve <= 0
    return(list(ok = FALSE, code = if (m4) "M4" else "ajustement",
                motif = nettoyer_champ(paste("mw_valider_ajustement :", paste(va$erreurs, collapse = " ; ")))))
  }
  list(ok = TRUE, code = "-", motif = NA_character_, aj = aj, msep = ms$msep, mw04 = any(startsWith(v$erreurs, MOTIF_MW04)))
}
# Statistiques observees par le chemin de l'oracle (copie de stats_oracle() de
# tests/calibration_mc_mw_t8.R).
stats_oracle <- function(aj) .mw_stats(aj, .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj)))
# MSEP ou sigma2_(J-1) et Q_(J-1) sont remplaces par l'estimateur direct
# (K-T4 ; mecanique de mw_sensibilite_sigma2_dernier()) ; NA sans estimateur.
msep_direct <- function(aj) {
  v <- aj$sigma2_Jm1_direct
  if (is.null(v) || !is.finite(v)) return(NA_real_)
  a <- aj; J <- aj$J
  a$sigma2[J] <- v; a$Q[J] <- v / a$f[J]^2
  tryCatch(mw_msep(a)$msep, error = function(e) NA_real_)
}

###############################################################################
#  CRITERE C1 : ARCHIVE CRAN, TRANSCRIPTION INDEPENDANTE (controle (c1))
###############################################################################
# Copies declarees de tests/msep_trapeze_mw.R (memes corps) : charger_cl(),
# transcrire(), c1_triangle(). CL_MSEPs est evaluee dans un environnement
# fils de baseenv() ; l'extraction se fait dans un dossier temporaire
# supprime ; rien n'est ecrit dans le depot (Q-2a-5).
charger_cl <- function(archive) {
  md5_a <- unname(tools::md5sum(archive))
  if (!identical(md5_a, MD5_ARCHIVE_CL)) return(list(ok = FALSE, md5_archive = md5_a, motif = "md5 de l'archive diff\u00e9rent"))
  d <- tempfile("cl567_"); dir.create(d)
  on.exit(unlink(d, recursive = TRUE), add = TRUE)
  fichiers <- c("ChainLadder/R/MWChainLadder.R", "ChainLadder/data/GenIns.RData", "ChainLadder/DESCRIPTION")
  r <- tryCatch(utils::untar(archive, files = fichiers, exdir = d), error = function(e) 1L)
  if (!identical(as.integer(r), 0L) || !all(file.exists(file.path(d, fichiers))))
    return(list(ok = FALSE, md5_archive = md5_a, motif = "extraction impossible"))
  f_src <- file.path(d, "ChainLadder", "R", "MWChainLadder.R")
  src <- readLines(f_src, warn = FALSE)
  i1 <- grep("^CL_MSEPs <- function", src); i2 <- grep("^CDR.MackChainLadder", src)
  if (length(i1) != 1L || length(i2) != 1L || i2 <= i1)
    return(list(ok = FALSE, md5_archive = md5_a, motif = "CL_MSEPs introuvable dans R/MWChainLadder.R"))
  txt <- src[i1:(i2 - 1L)]
  f_txt <- file.path(d, "CL_MSEPs.txt"); writeLines(txt, f_txt)
  env <- new.env(parent = baseenv())
  eval(parse(text = txt, keep.source = FALSE), envir = env)
  desc <- read.dcf(file.path(d, "ChainLadder", "DESCRIPTION"), fields = c("Package", "Version", "Date/Publication"))
  e_g <- new.env(parent = emptyenv())
  load(file.path(d, "ChainLadder", "data", "GenIns.RData"), envir = e_g)
  g <- if (exists("GenIns", envir = e_g, inherits = FALSE)) get("GenIns", envir = e_g) else NULL
  gm <- if (is.null(g)) NULL else matrix(as.numeric(unclass(g)), nrow(g), ncol(g))
  list(ok = is.function(env$CL_MSEPs), CL_MSEPs = env$CL_MSEPs, md5_archive = md5_a,
       md5_fichier = unname(tools::md5sum(f_src)), md5_fonction = unname(tools::md5sum(f_txt)),
       lignes = c(i1, i2 - 1L), version = unname(desc[1, "Version"]), paquet = unname(desc[1, "Package"]),
       publication = unname(desc[1, "Date/Publication"]),
       auteur = any(grepl("Author: Mario Wuthrich", txt, fixed = TRUE)), genins = gm, motif = NA_character_)
}
transcrire <- function(tri) {
  I <- nrow(tri) - 1; J <- ncol(tri) - 1
  f <- s2 <- numeric(J)
  for (j in 0:(J - 1)) { r <- 0:(I - j - 1)
    f[j + 1] <- sum(tri[r + 1, j + 2]) / sum(tri[r + 1, j + 1]) }
  for (j in 0:(J - 2)) { r <- 0:(I - j - 1)
    s2[j + 1] <- sum(tri[r + 1, j + 1] * (tri[r + 1, j + 2] / tri[r + 1, j + 1] - f[j + 1])^2) /
      (I - j - 1) }
  s2[J] <- min(s2[J - 1], s2[J - 2], s2[J - 1]^2 / s2[J - 2])
  s2d <- if (I > J) {
    r <- 0:(I - J)
    sum(tri[r + 1, J] * (tri[r + 1, J + 1] / tri[r + 1, J] - f[J])^2) / (I - J)
  } else NA_real_
  complet <- tri
  for (i in 0:I) { d <- I - i
    if (d < J) for (j in (d + 1):J) complet[i + 1, j + 1] <- complet[i + 1, j] * f[j] }
  Sp <- vapply(0:(J - 1), function(j) sum(tri[(0:(I - j)) + 1, j + 1]), numeric(1))
  alpha <- vapply(0:(J - 1), function(j) tri[I - j + 1, j + 1], numeric(1)) / Sp
  list(I = I, J = J, f = f, s2 = s2, s2d = s2d, complet = complet,
       param = data.frame(f = f, sigma2 = s2, ratio = s2 / f^2, alpha = alpha))
}
c1_triangle <- function(tri, cl_msep, aj = mw_ajuster(tri), msep = mw_msep(aj)$msep) {
  t <- transcrire(tri)
  r <- cl_msep(t$complet, nrow(tri), ncol(tri), t$param)
  m_cl <- r[nrow(tri) + 1L, 2L]; r_cl <- r[nrow(tri) + 1L, 1L]
  e <- c(msep = ecart_rel(msep, m_cl), R = ecart_rel(aj$reserve, r_cl),
         f = ecart_rel(aj$f, t$f), s2 = ecart_rel(aj$sigma2, t$s2),
         dir = if (t$I > t$J) ecart_rel(aj$sigma2_Jm1_direct, t$s2d) else if (is.null(aj$sigma2_Jm1_direct)) 0 else Inf)
  list(ok = all(e <= TOL_C1), e = e, msep = msep, msep_cl = m_cl, R = aj$reserve, R_cl = r_cl,
       s2_regle = aj$sigma2[aj$J], s2_dir = if (is.null(aj$sigma2_Jm1_direct)) NA_real_ else aj$sigma2_Jm1_direct,
       s2_regle_t = t$s2[t$J], s2_dir_t = t$s2d)
}

###############################################################################
#  UN TRIANGLE TIRE, UN TRIANGLE ORACLE
###############################################################################
COLONNES <- c("G", "loi", "b", "g_tri", "g_boot", "statut", "motif_code", "gp", "jd", "R_hat", "msep", "msep_dir",
              "s2_regle", "s2_dir", "n_sans_sigma", "cumuls_retires", "plafond", "B_eff_min", "o8", "ctl", "c1", "c1_ecart", "i1",
              paste0("obs:", CLES), paste0("p:", CLES), paste0("B:", CLES), paste0("m:", CLES), paste0("v:", CLES),
              paste0("in:", CLES), paste0("ef:", FAM), paste0("pf:", FAM), "message", "duree_s")
COLONNES_BRUT <- setdiff(COLONNES, "duree_s")
COL_TEXTE <- c("G", "loi", "statut", "motif_code", "jd", "message", paste0("m:", CLES), paste0("v:", CLES), paste0("ef:", FAM))
COLONNES_ORA <- c("G", "loi", "k", "g_tri", "statut", "motif_code", paste0("obs:", CLES), "duree_s")
COL_TEXTE_ORA <- c("G", "loi", "statut", "motif_code")
STATUTS <- c("admis", "refus", "echec")
CODES_REFUS <- c("cellule", "triangle", "domaine", "ajuster", "msep", "M4", "ajustement", "erreur")

# Ligne du triangle b de (G, loi). ctl : premier triangle admis de la
# tranche (controles (c1) et (i1)). garder : rend aussi les objets.
un_triangle <- function(G, loi, b, B, ctl = FALSE, garder = FALSE, g_tri = graine_tri(loi, b), g_boot = graine_boot(G, loi, b)) {
  t1 <- proc.time()[["elapsed"]]
  L <- stats::setNames(as.list(rep(NA, length(COLONNES))), COLONNES)
  L$G <- G; L$loi <- loi; L$b <- b; L$g_tri <- g_tri; L$g_boot <- g_boot; L$motif_code <- "-"; L$ctl <- as.integer(ctl)
  objets <- NULL
  # Admission passee (m2) : seule une erreur posterieure (bootstrap, tests,
  # lecture des resultats) fait un triangle "echec" admis ; une erreur
  # anterieure (generation, mw_valider_triangle(), ajustement) est un refus
  # de motif "erreur".
  admission_passee <- FALSE
  fin <- function(statut, code = "-", msg = NA_character_) {
    L$statut <- statut; L$motif_code <- code; L$message <- msg
    L$duree_s <- proc.time()[["elapsed"]] - t1
    if (garder) list(ligne = L, objets = objets) else L
  }
  tryCatch({
    J <- J_G[[G]]
    tri <- triangle_G(G, loi, g_tri)
    t8 <- triangle_8(loi, g_tri)
    L$gp <- as.integer(identical(tri, t8[, seq_len(J + 1L), drop = FALSE]))
    ad <- admettre(tri)
    if (!ad$ok) return(fin("refus", ad$code, ad$motif))
    admission_passee <- TRUE
    aj <- ad$aj
    L$R_hat <- aj$reserve; L$msep <- ad$msep; L$s2_regle <- aj$sigma2[aj$J]
    L$s2_dir <- if (is.null(aj$sigma2_Jm1_direct)) NA_real_ else aj$sigma2_Jm1_direct
    L$msep_dir <- msep_direct(aj)
    figes <- .mw_ensembles_figes(aj)
    L$jd <- if (length(figes$degeneres)) paste(figes$degeneres, collapse = ",") else "-"
    if (ctl) {
      c1 <- tryCatch(c1_triangle(tri, CL$CL_MSEPs, aj, ad$msep), error = function(e) NULL)
      L$c1 <- as.integer(!is.null(c1) && isTRUE(c1$ok)); L$c1_ecart <- if (is.null(c1)) Inf else max(c1$e)
    }
    bt <- tryCatch(mw_bootstrap(aj, B = B, seed = g_boot, figes = figes), error = function(e) e)
    if (inherits(bt, "error")) return(fin("echec", "-", nettoyer_champ(paste("mw_bootstrap en erreur :", conditionMessage(bt)))))
    ts <- tryCatch(mw_tests(aj, bt, ALPHA, figes = figes), error = function(e) e)
    if (inherits(ts, "error")) return(fin("echec", "-", nettoyer_champ(paste("mw_tests en erreur :", conditionMessage(ts)))))
    L$n_sans_sigma <- if (is.null(bt$n_sans_sigma)) NA_real_ else as.numeric(bt$n_sans_sigma)
    L$cumuls_retires <- as.integer(isTRUE(bt$cumuls_retires)); L$plafond <- as.integer(isTRUE(bt$plafond_cumuls))
    L$B_eff_min <- min(unlist(bt$B_effectif[CLES]))
    obs <- unlist(bt$stats_obs)
    mc <- vapply(ts, function(l) if (is.null(l$mc_nom) || length(l$mc_nom) != 1L || is.na(l$mc_nom)) NA_character_ else as.character(l$mc_nom), "")
    for (k in CLES) {
      L[[paste0("obs:", k)]] <- unname(obs[[k]]); L[[paste0("p:", k)]] <- unname(bt$p_mc[[k]])
      L[[paste0("B:", k)]] <- unname(bt$B_effectif[[k]]); L[[paste0("m:", k)]] <- unname(code_motif(bt$motif_mc[[k]]))
      i <- match(k, mc)
      L[[paste0("v:", k)]] <- if (is.na(i)) "-" else code_verdict(ts[[i]]$verdict)
      L[[paste0("in:", k)]] <- if (is.na(i)) NA_real_ else as.numeric(isTRUE(ts[[i]]$inoperant))
    }
    fo <- vapply(ts, function(l) if (is.null(l$fonction)) "" else as.character(l$fonction), "")
    pref <- substr(vapply(ts, function(l) as.character(l$famille), ""), 1L, 2L)
    hors <- setdiff(unique(pref[fo == "engine_p_famille"]), FAM)
    for (f in FAM) {
      i <- which(fo == "engine_p_famille" & pref == f)
      p <- if (length(i) == 1L) ts[[i]]$p_mc else NA_real_
      L[[paste0("ef:", f)]] <- if (!length(i)) "A" else if (length(i) > 1L) "X" else if (is.finite(p)) "L" else "N"
      L[[paste0("pf:", f)]] <- if (length(i) == 1L && is.finite(p)) p else NA_real_
    }
    if (length(hors)) L$message <- nettoyer_champ(paste("lignes de famille hors de", paste(FAM, collapse = ", "), ":", paste(hors, collapse = ", ")))
    if (ctl) L$i1 <- as.integer(identical(unname(stats_oracle(aj)[CLES]), unname(obs[CLES])))
    if (G == "8x7" && !.mw_triangle_incomplet(t8)) {
      a8 <- tryCatch(mw_ajuster(t8), error = function(e) NULL)
      if (!is.null(a8)) {
        o8 <- tryCatch(as.list(.mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(a8, .mw_ensembles_figes(a8), new.env(parent = emptyenv())))),
                       error = function(e) NULL)
        L$o8 <- if (is.null(o8)) NA_real_ else as.numeric(identical(bt$stats_obs, o8))
      }
    }
    if (garder) objets <- list(tri = tri, aj = aj, bt = bt, ts = ts)
    msg <- L$message
    fin("admis", "-", msg)
  }, error = function(e) if (admission_passee) fin("echec", "-", nettoyer_champ(conditionMessage(e))) else
    fin("refus", "erreur", nettoyer_champ(paste("erreur avant l'admission :", conditionMessage(e)))))
}
# Triangle k de l'oracle de (G, loi) : admission, puis statistiques par le
# chemin de l'oracle (stats_oracle()).
un_oracle <- function(G, loi, k, graine = graine_ora(loi, k)) {
  t1 <- proc.time()[["elapsed"]]
  L <- stats::setNames(as.list(rep(NA, length(COLONNES_ORA))), COLONNES_ORA)
  L$G <- G; L$loi <- loi; L$k <- k; L$g_tri <- graine; L$motif_code <- "-"
  ad <- tryCatch(admettre(triangle_G(G, loi, graine)), error = function(e) list(ok = FALSE, code = "erreur"))
  if (!ad$ok) { L$statut <- "refus"; L$motif_code <- ad$code } else {
    so <- tryCatch(stats_oracle(ad$aj), error = function(e) NULL)
    L$statut <- if (is.null(so)) "echec" else "admis"
    if (!is.null(so)) for (s in CLES) L[[paste0("obs:", s)]] <- unname(so[[s]])
  }
  L$duree_s <- proc.time()[["elapsed"]] - t1
  L
}

# --- Ecriture et lecture des lignes (copies de tests/couverture_ic_sigma_mw_t8.R)
format_val <- function(v, col, texte) {
  if (col %in% texte) return(if (is.null(v) || is.na(v)) "NA" else gsub("[\t\r\n]+", " ", as.character(v)))
  if (is.null(v) || is.na(v)) "NA" else sprintf("%.17g", as.numeric(v))
}
format_ligne <- function(L, cols = COLONNES, texte = COL_TEXTE)
  paste(vapply(cols, function(c) format_val(L[[c]], c, texte), ""), collapse = "\t")
lire_lignes <- function(lignes, cols = COLONNES, texte = COL_TEXTE) {
  if (!length(lignes)) return(NULL)
  m <- do.call(rbind, strsplit(lignes, "\t", fixed = TRUE))
  if (ncol(m) != length(cols)) stop("nombre de colonnes inattendu")
  df <- as.data.frame(m, stringsAsFactors = FALSE); names(df) <- cols
  for (c in setdiff(cols, texte)) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
  for (c in intersect(cols, texte)) df[[c]][df[[c]] == "NA"] <- NA_character_
  df
}

###############################################################################
#  MODE --prevol (P4)
###############################################################################
if (MODE == "prevol") {
  U <- OPT_UNITES
  ecrire_console(c("## Pr\u00e9-vol de la mesure #567 (S6, \u00e9tape 5 (b)) -- rien d'\u00e9crit", "",
                   sprintf("Commit : %s ; md5 R/engine.R : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s",
                           COMMIT_DEBUT, MD5_MOTEUR_DEBUT, PLATEFORME, COEURS, horodatage()), ""))
  # 1. Admission (un processus) sur les graines du pre-vol : u = 1..N_ADM,
  # memes graines pour toutes les (G, loi) (comme le plan : graine du
  # triangle commune aux geometries).
  N_ADM <- 500L
  ADM <- list()
  for (G in GEOM$code) for (loi in names(LOIS)) {
    t0 <- Sys.time()
    codes <- vapply(seq_len(N_ADM), function(u) tryCatch(admettre(triangle_G(G, loi, graine_pv_tri(u)))$code, error = function(e) "erreur"), "")
    ADM[[paste(G, loi)]] <- list(G = G, loi = loi, codes = codes, a = mean(codes == "-"), c_adm = secs(t0) / N_ADM, u_adm = which(codes == "-"))
  }
  if (any(vapply(ADM, function(x) length(x$u_adm) < U, logical(1)))) stop("--prevol : moins de ", U, " triangles admis sur les graines du pr\u00e9-vol")
  # 2. run_engine() sur reserve2 (B = 999, un processus) : cout c_re (controle
  # (a) ; chacun des quatre bootstraps de (r297) est compte au meme cout).
  t0 <- Sys.time(); invisible(executer_cas("reserve2")); c_re <- secs(t0)
  # 3. Unite de debit (dans chaque processus, les memes U unites) : pour
  # chaque G, un triangle admis (B = 999, mw_bootstrap() + mw_tests()) de la
  # loi N (u impair) ou E (u pair), et 25 triangles d'oracle de la meme loi.
  unite <- function(i) {
    out <- list()
    for (u in seq_len(U)) {
      loi <- if (u %% 2L == 1L) "N" else "E"
      d <- numeric(0)
      for (G in GEOM$code) {
        ua <- ADM[[paste(G, loi)]]$u_adm[u]
        d[[paste0("t", G)]] <- un_triangle(G, loi, ua, B_MESURE, g_tri = graine_pv_tri(ua), g_boot = graine_pv_boot(ua))$duree_s
        t0 <- proc.time()[["elapsed"]]
        for (k in 40000L + 25L * (u - 1L) + seq_len(25L)) invisible(un_oracle(G, loi, k, graine_pv_tri(k)))
        d[[paste0("o", G)]] <- (proc.time()[["elapsed"]] - t0) / 25
      }
      out[[u]] <- d
    }
    do.call(rbind, out)
  }
  # Caches du moteur (loi nulle de Shapiro-Wilk, #206 par. 8 : "cache chaud")
  # chauffes dans le processus maitre avant les phases, et herites par les
  # processus fils : sans cela, la phase a un processus les calcule seule et
  # le debit agrege P_k est surestime (mesure : P_4 = 4,27 sans
  # chauffage, 20/11/2026).
  for (G in GEOM$code) for (loi in names(LOIS)) {
    ua <- ADM[[paste(G, loi)]]$u_adm[1]
    invisible(un_triangle(G, loi, ua, 9, g_tri = graine_pv_tri(ua), g_boot = graine_pv_boot(ua)))
  }
  KMAX <- max(1L, min(4L, COEURS, na.rm = TRUE))
  CB <- list(); MUR <- numeric(KMAX)
  for (k in seq_len(KMAX)) {
    t0 <- Sys.time()
    res <- parallel::mclapply(seq_len(k), unite, mc.cores = k, mc.preschedule = FALSE)
    MUR[k] <- secs(t0)
    if (any(vapply(res, function(x) !is.matrix(x), logical(1)))) stop("--prevol : processus en erreur (k = ", k, ")")
    CB[[k]] <- do.call(rbind, res)
  }
  tot <- function(m) rowSums(m[, paste0("t", GEOM$code), drop = FALSE]) + 25 * rowSums(m[, paste0("o", GEOM$code), drop = FALSE])
  P_k <- vapply(seq_len(KMAX), function(k) k * mean(tot(CB[[1]])) / mean(tot(CB[[k]])), 1)
  c1m <- colMeans(CB[[1]])
  # Duree planifiee (s d'horloge) d'un niveau a k processus [H : debit lineaire
  # par triangle, queues de groupes non comptees] : partie sequentielle
  # (controle (a) et quatre bootstraps de (r297), comptes au cout de
  # run_engine() sur reserve2 ; (g), (g'), (m4), (c1), (o), (graines) negliges)
  # + partie parallele (triangles tires, oracles, recalculs de (rep)) divisee
  # par le debit P_k.
  cpu_tri <- function(G, loi) { x <- ADM[[paste(G, loi)]]; (1 - x$a) * x$c_adm + x$a * c1m[[paste0("t", G)]] }
  duree_plan <- function(Rv, k) {
    par <- sum(vapply(GEOM$code, function(G) sum(vapply(names(LOIS), function(loi) Rv[[G]] * cpu_tri(G, loi), 1)) +
                        length(LOIS) * N0_MESURE * c1m[[paste0("o", G)]], 1)) +
      2 * length(LOIS) * sum(c1m[paste0("t", GEOM$code)])
    5 * c_re + par / P_k[k]
  }
  k_plan <- min(K_BUDGET, KMAX)
  plan <- vapply(names(NIVEAUX), function(l) duree_plan(NIVEAUX[[l]], k_plan), 1)
  tient <- plan <= BUDGET_S
  niveau <- if (any(tient)) names(NIVEAUX)[which(tient)[1]] else NA_character_
  f2 <- function(m, cc) sprintf("%s [%s ; %s]", num(mean(m[, cc]), 2), num(min(m[, cc]), 2), num(max(m[, cc]), 2))
  ecrire_console(c("### Admission sur les graines du pr\u00e9-vol (un processus)", "",
                   entete_md(c("G", "loi", "triangles tir\u00e9s", "admis", "taux d'admission", "motifs de refus", "s par triangle (admission)")),
                   vapply(ADM, function(x) {
                     t <- table(x$codes[x$codes != "-"])
                     ligne_md(x$G, x$loi, length(x$codes), sum(x$codes == "-"), num(x$a, 3),
                              if (length(t)) paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") else "aucun", num(x$c_adm, 4))
                   }, ""), "",
                   sprintf("run_engine() sur reserve2 (B = 999, un processus) : %s s.", num(c_re, 2)), "",
                   "### Co\u00fbts unitaires (secondes, dur\u00e9e murale dans chaque processus)", "",
                   sprintf("Unit\u00e9 : pour chaque G, un triangle admis (mw_bootstrap() \u00e0 B = 999 et mw_tests()) et 25 triangles d'oracle ; loi N (unit\u00e9 impaire) ou E (paire) ; %d unit\u00e9(s) par processus, les m\u00eames dans chaque processus.", U), "",
                   entete_md(c("processus concurrents", "dur\u00e9e murale de la phase (s)", paste("triangle", GEOM$code), paste("oracle", GEOM$code, "(par triangle)"), "d\u00e9bit agr\u00e9g\u00e9 P_k")),
                   vapply(seq_len(KMAX), function(k) do.call(ligne_md, c(list(k, num(MUR[k], 1)),
                     lapply(paste0("t", GEOM$code), function(cc) f2(CB[[k]], cc)), lapply(paste0("o", GEOM$code), function(cc) f2(CB[[k]], cc)),
                     list(num(P_k[k], 3)))), ""), "",
                   sprintf("### Niveaux (P4 : premier niveau dont la dur\u00e9e planifi\u00e9e tient dans H_max = 20 h d'horloge sur %d processus ; sous L2, retour au mainteneur)", K_BUDGET), "",
                   entete_md(c("Niveau", "8x5 (N, E)", "8x6 (N, E)", "8x7 (N, E)", "bootstraps", "oracle (tir\u00e9s)", sprintf("dur\u00e9e planifi\u00e9e \u00e0 %d processus (h)", k_plan),
                               "dans le budget", "segments de 2 h (M42 (b))")),
                   vapply(names(NIVEAUX), function(l) { R_ <- NIVEAUX[[l]]
                     ligne_md(l, R_[["8x5"]], R_[["8x6"]], R_[["8x7"]], length(LOIS) * sum(R_), length(LOIS) * nrow(GEOM) * N0_MESURE,
                              num(plan[[l]] / 3600, 2), if (tient[[l]]) "oui" else "non", ceiling(plan[[l]] / SEGMENT_S)) }, ""), "",
                   if (k_plan < K_BUDGET) sprintf("**Moins de %d c\u0153urs : dur\u00e9e planifi\u00e9e \u00e0 %d processus seulement.**", K_BUDGET, k_plan) else character(0),
                   if (!is.na(niveau))
                     sprintf("**Niveau retenu : %s, dur\u00e9e planifi\u00e9e %s h \u00e0 %d processus, soit %d segment(s) de 2 h au plus (M42 (b))** (hypoth\u00e8se [H] : d\u00e9bit lin\u00e9aire par triangle, queues de groupes non compt\u00e9es ; la charge de la machine n'est pas contr\u00f4l\u00e9e).",
                             niveau, num(plan[[niveau]] / 3600, 2), k_plan, as.integer(ceiling(plan[[niveau]] / SEGMENT_S)))
                   else "**Aucun niveau ne tient dans 20 h, y compris L2 : retour au mainteneur (P4).**",
                   "", sprintf("Commande de la mesure (arbre propre) : LC_ALL=C.UTF-8 Rscript %s --niveau %s --archive-cl CHEMIN --processus %d --duree-max 1.8 --ecrire",
                               SCRIPT_DEPOT, if (is.na(niveau)) "?" else niveau, k_plan),
                   "", sprintf("PREVOL567\t%s\t%s\t%s\t%s\t%s\t%s", paste(sprintf("%.4f", c1m), collapse = "\t"),
                               paste(sprintf("%.4f", P_k), collapse = "\t"), paste(sprintf("%.3f", vapply(ADM, function(x) x$a, 1)), collapse = "\t"),
                               sprintf("%.3f", c_re), paste(sprintf("%.0f", plan), collapse = "\t"), if (is.na(niveau)) "NA" else niveau),
                   sprintf("Dur\u00e9e du pr\u00e9-vol : %s s.", num(secs(t_debut), 0))))
  quit(status = 0L)
}

###############################################################################
#  ESSAI ET MESURE : PARAMETRES, GARDES DE --ecrire, JOURNAL (avant tout
#  calcul couteux, #205)
###############################################################################
B_RUN <- if (OPT_ESSAI) B_ESSAI else B_MESURE
R_RUN <- if (OPT_ESSAI) stats::setNames(rep(R_ESSAI, nrow(GEOM)), GEOM$code) else NIVEAUX[[OPT_NIVEAU]]
N0_RUN <- if (OPT_ESSAI) N0_ESSAI else N0_MESURE
txt_R <- function() paste(c(sprintf("%s=%d", names(R_RUN), R_RUN), sprintf("N0=%d", N0_RUN)), collapse = ",")
if (OPT_ECRIRE) {
  nv <- motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")
  if (length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
                          " -- lancer depuis un arbre au commit propre")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) refuser("dossier de sortie introuvable : docs/tableaux")
}
SUFFIXE <- if (OPT_ESSAI) "essai" else OPT_NIVEAU
TRAVAIL <- if (!is.na(OPT_TRAVAIL)) OPT_TRAVAIL else if (OPT_ESSAI) tempfile("essai567_", tmpdir = dirname(tempdir())) else
  file.path(dirname(normalizePath(RACINE, winslash = "/")), sprintf("issue567-travail-%s", SUFFIXE))
if (sous_depot(TRAVAIL)) refuser("--travail : dossier sous le depot refuse")
if (!dir.exists(TRAVAIL)) dir.create(TRAVAIL, recursive = TRUE)
TRAVAIL <- normalizePath(TRAVAIL, winslash = "/")
JOURNAL_T <- file.path(TRAVAIL, "JOURNAL.md")
CTX <- c(B = B_RUN, sha = SHA_DEBUT, md5_moteur = MD5_MOTEUR_DEBUT, md5_script = MD5_SCRIPT, empreinte = EMPREINTE_DEBUT,
         plateforme = PLATEFORME, essai = if (OPT_ESSAI) "oui" else "non", taille_tranche = TAILLE_TRANCHE)
txt_ctx <- function(ctx) paste(names(ctx), ctx, sep = "=", collapse = " || ")
lire_journal <- function() {
  jl <- readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")
  champ <- function(cle) {
    m <- regmatches(jl, regexec(paste0("^- ", cle, " : (.*)$"), jl))
    v <- vapply(m[lengths(m) == 2L], `[`, "", 2L)
    if (length(v)) v[1] else NA_character_
  }
  list(lignes = jl, R = champ("R par G et loi"), sha = champ("SHA \\(git rev-parse HEAD\\) au lancement"),
       md5 = champ("md5 R/engine\\.R au lancement"), date = champ("Date des sorties"),
       ctx = champ("Contexte des tranches"), lancement = champ("Lancement"),
       empreinte = champ("Empreinte sans commentaires de R/engine\\.R"))
}
if (!file.exists(JOURNAL_T)) {
  ecrire_fichier(JOURNAL_T, c(
    sprintf("# JOURNAL de la mesure #567 (S6, \u00e9tape 5 (b) : niveau \u00e0 T = 8 des tests de Merz-W\u00fcthrich sur 8 x 5, 8 x 6, 8 x 7)%s",
            if (OPT_ESSAI) " -- ESSAI, non versionnable" else ""), "",
    sprintf("- Lancement : %s", horodatage()),
    sprintf("- Date des sorties : %s", format(Sys.time(), "%Y%m%d", tz = "UTC")),
    sprintf("- R par G et loi : %s", txt_R()),
    sprintf("- Niveau : %s", if (OPT_ESSAI) "essai (--essai)" else sprintf("%s (pr\u00e9-vol, P4)", OPT_NIVEAU)),
    sprintf("- B : %s", format(B_RUN)),
    sprintf("- Processus : %d ; taille des tranches : %d", OPT_PROC, TAILLE_TRANCHE),
    sprintf("- SHA (git rev-parse HEAD) au lancement : %s", SHA_DEBUT),
    sprintf("- Commit (commit_depot()) : %s", COMMIT_DEBUT),
    sprintf("- md5 R/engine.R au lancement : %s", MD5_MOTEUR_DEBUT),
    sprintf("- Empreinte sans commentaires de R/engine.R : %s", EMPREINTE_DEBUT),
    sprintf("- Empreintes md5 du code ex\u00e9cut\u00e9 : %s", EMPREINTES),
    sprintf("- md5 protocole (%s) : %s", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))),
    sprintf("- Archive ChainLadder : %s, md5 %s", basename(OPT_ARCHIVE), md5_fichier(OPT_ARCHIVE)),
    sprintf("- Plateforme : %s", PLATEFORME),
    sprintf("- Locale : LC_ALL=%s ; LC_CTYPE=%s", Sys.getenv("LC_ALL"), LOCALE_TRAVAIL),
    sprintf("- Dossier de travail : %s (hors du d\u00e9p\u00f4t)", basename(TRAVAIL)),
    sprintf("- Commande : Rscript %s %s", SCRIPT_DEPOT, args_cites()),
    sprintf("- Contexte des tranches : %s", txt_ctx(CTX))))
} else {
  J0 <- lire_journal()
  if (!identical(J0$R, txt_R())) refuser("reprise : R du JOURNAL (", J0$R, ") different de ", txt_R())
  if (!identical(J0$ctx, txt_ctx(CTX))) refuser("reprise : contexte du JOURNAL different du contexte courant -- autre --travail")
  ecrire_fichier(JOURNAL_T, sprintf("- Reprise : %s ; commande : Rscript %s %s", horodatage(), SCRIPT_DEPOT, args_cites()), mode = "ab")
}
J0 <- lire_journal()
DATE_SORTIES <- J0$date
NOM_MD  <- sprintf("%s-issue567-niveau-trapeze-mw.md", DATE_SORTIES)
NOM_TSV <- sprintf("%s-issue567-niveau-trapeze-mw-brut.tsv", DATE_SORTIES)
NOM_JNL <- sprintf("%s-issue567-niveau-trapeze-mw-journal-mesure.md", DATE_SORTIES)
CIBLES <- file.path(RACINE, "docs", "tableaux", c(NOM_MD, NOM_TSV, NOM_JNL))
REMPLACES <- NULL
if (OPT_ECRIRE) REMPLACES <- garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)

###############################################################################
#  CONTROLES AVANT TOUT TIRAGE DU PLAN : (t), (a), (m4), (g), (g'), (c1)
#  (reserve2), (r297), (o), (graines), (m)
###############################################################################
INTEGRITE <- character(0)
CTRL <- list()
controle <- function(code, ok, detail) {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
  if (!isTRUE(ok)) INTEGRITE <<- c(INTEGRITE, code)
}
# (t) : critere (P7) et statut epistemique du par. 8, presents a l'identique
# dans la specification versee (copies ci-dessus).
T567 <- local({
  f <- file.path(RACINE, PROTOCOLE)
  txt <- if (file.exists(f)) readLines(f, warn = FALSE, encoding = "UTF-8") else character(0)
  c(critere = present_bloc(TEXTE_CRITERE_567, txt), statut = present_bloc(TEXTE_STATUT_567, txt))
})
if (!all(T567))
  refuser("(t) : critere (P7) ou statut epistemique absent ou modifie dans ", PROTOCOLE, " -- le texte reporte dans le script ne concorde plus avec la specification versee")
controle("(t)", all(T567), sprintf("par. 8, P7 (crit\u00e8re et profils, %d lignes) %s ; statut \u00e9pist\u00e9mique (par. 8, une ligne) %s, dans %s (md5 %s) ; v\u00e9rifi\u00e9 avant la boucle de calcul",
                                   length(TEXTE_CRITERE_567), if (T567[["critere"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9",
                                   if (T567[["statut"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))))
# Archive ChainLadder (Q-2a-5), lue avant les controles qui l'emploient.
CL <- charger_cl(OPT_ARCHIVE)
if (!isTRUE(CL$ok)) refuser("--archive-cl : ", CL$motif, " (md5 lu ", CL$md5_archive, ", attendu ", MD5_ARCHIVE_CL, ")")
# (a), (r297) : calculs longs, en parallele (une tache chacun).
BR297 <- local({
  f <- file.path(RACINE, BRUT_297)
  if (!file.exists(f)) NULL else
    utils::read.delim(f, colClasses = "character", check.names = FALSE, quote = "", comment.char = "", stringsAsFactors = FALSE)
})
PLAGES_R297 <- list(N = list(tri = PLAGE_R297_TRI_N, boot = PLAGE_R297_BOOT_N), E = list(tri = PLAGE_R297_TRI_E, boot = PLAGE_R297_BOOT_E))
taches_avant <- c(list(list(type = "a")),
                  unlist(lapply(names(LOIS), function(loi) lapply(1:2, function(b) list(type = "r297", loi = loi, b = b))), recursive = FALSE))
t_avant <- Sys.time()
RES_AVANT <- parallel::mclapply(taches_avant, function(t) {
  if (t$type == "a") {
    r <- executer_cas("reserve2")
    ref <- readRDS(chemin_reference("reserve2"))
    cmp <- comparer_objets(neutraliser_instables(ref), neutraliser_instables(r), tol = 0)
    return(list(type = "a", cmp = cmp[c("conforme", "n_feuilles", "n_differentes", "n_ecarts", "ecart_max")]))
  }
  tri <- engine_sous_graine(PLAGES_R297[[t$loi]]$tri[1] - 1 + t$b, gen_triangle_h0(AJ8, TIREURS[[t$loi]]))
  ad <- admettre(tri)
  if (!ad$ok) return(list(type = "r297", loi = t$loi, b = t$b, ok = FALSE, n = 0L))
  bt <- mw_bootstrap(ad$aj, B = B_MESURE, seed = PLAGES_R297[[t$loi]]$boot[1] - 1 + t$b, figes = .mw_ensembles_figes(ad$aj))
  list(type = "r297", loi = t$loi, b = t$b, ok = TRUE, p = unname(bt$p_mc[CLES]))
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
DUREE_AVANT <- secs(t_avant)
if (any(vapply(RES_AVANT, function(x) !is.list(x), logical(1)))) stop("controles (a) ou (r297) : processus en erreur")
local({
  x <- RES_AVANT[[1]]$cmp
  controle("(a)", isTRUE(x$conforme) && identical(as.integer(x$n_differentes), 0L),
           sprintf("reserve2 (executer_cas(\"reserve2\"), run_engine() par d\u00e9faut) contre tests/reference/reserve2.rds, comparer_objets(tol = 0) : %d feuilles, %d diff\u00e9rente(s), %d \u00e9cart(s), \u00e9cart maximal %g : chemin carr\u00e9 %s",
                   x$n_feuilles, x$n_differentes, x$n_ecarts, x$ecart_max, if (isTRUE(x$conforme) && x$n_differentes == 0L) "intact au seuil 0" else "MODIFI\u00c9"))
})
local({
  det <- character(0); tout <- !is.null(BR297)
  if (is.null(BR297)) det <- sprintf("%s introuvable", BRUT_297)
  for (x in RES_AVANT[-1]) {
    l <- if (is.null(BR297)) NULL else BR297[BR297$type == "rep" & BR297$loi == x$loi & as.integer(BR297$b) == x$b, , drop = FALSE]
    if (!isTRUE(x$ok) || is.null(l) || nrow(l) != 1L || l$statut != "admis") {
      tout <- FALSE; det <- c(det, sprintf("%s b = %d : admission ou ligne du brut en d\u00e9faut", x$loi, x$b)); next
    }
    vb <- suppressWarnings(as.numeric(unlist(l[1, paste0("pR:", CLES)])))
    ok <- identical(unname(vb), x$p)
    tout <- tout && ok
    det <- c(det, sprintf("%s b = %d (graines %.0f et %.0f) : %d / %d p_mc identiques", x$loi, x$b, PLAGES_R297[[x$loi]]$tri[1] - 1 + x$b,
                          PLAGES_R297[[x$loi]]$boot[1] - 1 + x$b, sum(vb == x$p, na.rm = TRUE) + sum(is.na(vb) & is.na(x$p)), NS))
  }
  controle("(r297)", tout, sprintf("%s, lignes rep, lois N et E, b = 1 et 2, colonnes pR:<cl\u00e9> contre mw_bootstrap(B = 999) aux graines de #206 : %s (identical())",
                                   BRUT_297, paste(det, collapse = " ; ")))
})
# (m4) : run_engine() sur les trapezes de reserve2 : ok = FALSE avec MW-04 seul.
local({
  det <- vapply(GEOM$code, function(G) {
    r <- run_engine(methode = "reserve2", triangle = .tri[, seq_len(J_G[[G]] + 1L)], segment = 1, annexe = "II",
                    date_reference = DATE_REFERENCE_TESTS, B = 99)
    ok <- identical(r$ok, FALSE) && length(r$validation$erreurs) == 1L && startsWith(r$validation$erreurs, MOTIF_MW04)
    c(ok = ok, txt = sprintf("%s : ok = %s, %d motif(s)%s", G, format(r$ok), length(r$validation$erreurs),
                             if (ok) ", MW-04 seul" else ""))
  }, character(2))
  controle("(m4)", all(det["ok", ] == "TRUE"), sprintf("run_engine(methode = \"reserve2\", triangle = colonnes 0..J de reserve2) : %s ; la garde MW-04 est en place",
                                                     paste(det["txt", ], collapse = " ; ")))
})
# (g) : generateur identique a .mw_simuler_triangle_etat() (100 graines par
# geometrie, 8 x 8 compris, triangles N b = 1..100) ; pool non dilate puis
# dilate (premier facteur qui rend au moins un triangle a cumul simule non
# fini ou <= 0, exige) ; fonctions du moteur identiques a celles de
# R/engine.R relu.
FACTEURS_G <- c(1, 30, 100, 300, 1000)
local({
  det <- character(0); tout <- TRUE
  for (G in c(GEOM$code, "8x8")) {
    d <- if (G == "8x8") AJ8 else DGP[[G]]
    meme_g <- function(pool) vapply(seq_len(100), function(i) {
      gr <- graine_tri("N", i)
      a <- engine_sous_graine(gr, gen_triangle_h0(d, function(n) sample(pool, n, replace = TRUE)))
      b <- engine_sous_graine(gr, .mw_simuler_triangle_etat(d, pool))
      c(identique = identical(a, b$tri) && identical(b$complet, !.mw_triangle_incomplet(b$tri)), incomplet = .mw_triangle_incomplet(b$tri))
    }, logical(2))
    base <- meme_g(POOL0)["identique", ]
    for (fd in FACTEURS_G[-1]) { dil <- meme_g(fd * POOL0); if (any(dil["incomplet", ])) break }
    ok <- all(base) && all(dil["identique", ]) && any(dil["incomplet", ])
    tout <- tout && ok
    det <- c(det, sprintf("%s : %d / 100 identiques ; pool dilat\u00e9 %g fois : %d / 100 identiques, dont %d \u00e0 cumul simul\u00e9 non fini ou \u2264 0", G, sum(base), fd,
                          sum(dil["identique", ]), sum(dil["incomplet", ])))
  }
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  env_m <- environment(mw_bootstrap)
  meme <- function(nm) { a <- get(nm, envir = env_m); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c("mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_tirer_triangle_valide", ".mw_triangle_incomplet",
           ".mw_pool_residus", "mw_bootstrap", "mw_ajuster", "mw_msep", "mw_tests", "mw_valider_triangle", ".mw_ensembles_figes")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  controle("(g)", tout && ok_fns, sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = .mw_simuler_triangle_etat() sous la m\u00eame graine (identical(), indicateur complet compris) : %s ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                                         paste(det, collapse = " ; "), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
})
# (g') : troncature du 8 x 8 simule = trapeze simule, sous la meme graine,
# lois N et E, b = 1..100 ; et sous des epsilon dilates (premier facteur qui
# rend au moins un triangle incomplet pour la G), pour exercer l'arret au
# premier cumul invalide.
local({
  det <- character(0); tout <- TRUE
  for (G in GEOM$code) {
    J <- J_G[[G]]
    tronq <- function(loi, fd) vapply(seq_len(100), function(i) {
      gr <- graine_tri(loi, i); tir <- TIREURS[[loi]]; td <- function(n) fd * tir(n)
      a <- engine_sous_graine(gr, gen_triangle_h0(DGP[[G]], td))
      b <- engine_sous_graine(gr, gen_triangle_h0(AJ8, td))
      c(identique = identical(a, b[, seq_len(J + 1L), drop = FALSE]), incomplet = .mw_triangle_incomplet(a))
    }, logical(2))
    base <- cbind(tronq("N", 1), tronq("E", 1))
    for (fd in FACTEURS_G[-1]) { dil <- cbind(tronq("N", fd), tronq("E", fd)); if (any(dil["incomplet", ])) break }
    ok <- all(base["identique", ]) && all(dil["identique", ]) && any(dil["incomplet", ])
    tout <- tout && ok
    det <- c(det, sprintf("%s : %d / 200 identiques ; \u03b5 dilat\u00e9s %g fois : %d / 200, dont %d trap\u00e8ze(s) incomplet(s)", G, sum(base["identique", ]), fd,
                          sum(dil["identique", ]), sum(dil["incomplet", ])))
  }
  controle("(g')", tout, sprintf("trap\u00e8ze G simul\u00e9 = colonnes 0..J du 8 x 8 simul\u00e9 sous la m\u00eame graine (identical()), avant tout tirage du plan : %s ; contr\u00f4le r\u00e9p\u00e9t\u00e9 sur chaque triangle tir\u00e9 (colonne gp, plus bas)",
                                    paste(det, collapse = " ; ")))
})
# (c1) sur les trapezes de reserve2 (avant tirage) ; complete plus bas par le
# premier triangle admis de chaque tranche.
C1_R2 <- lapply(stats::setNames(GEOM$code, GEOM$code), function(G) c1_triangle(.tri[, seq_len(J_G[[G]] + 1L)], CL$CL_MSEPs))
TXT_CL <- sprintf("archive %s (md5 %s = attendu), CL_MSEPs lignes %d \u00e0 %d de ChainLadder/R/MWChainLadder.R (md5 %s, texte md5 %s), paquet %s %s, en-t\u00eate d'auteur %s",
                  basename(OPT_ARCHIVE), CL$md5_archive, CL$lignes[1], CL$lignes[2], CL$md5_fichier, CL$md5_fonction, CL$paquet, CL$version,
                  if (isTRUE(CL$auteur)) "pr\u00e9sent" else "ABSENT")
# (o) : statistiques observees du 8 x 7 de reserve2 identical() aux stats_obs
# de reserve2.rds (13 cles), par le chemin de mw_bootstrap() (.mc_evaluer())
# et par celui de l'oracle (stats_oracle()).
local({
  ref <- readRDS(chemin_reference("reserve2"))$bootstrap$stats_obs
  a7 <- mw_ajuster(.tri[, 1:7])
  o7 <- as.list(.mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(a7, .mw_ensembles_figes(a7), new.env(parent = emptyenv()))))
  so7 <- stats_oracle(a7)
  ok1 <- length(ref) == NS && identical(o7, ref)
  ok2 <- identical(unname(so7[CLES]), unname(unlist(ref)[CLES]))
  controle("(o)", ok1 && ok2, sprintf("8 x 7 (colonnes 0..6 de reserve2) : statistiques observ\u00e9es des %d cl\u00e9s identical() \u00e0 bootstrap$stats_obs de tests/reference/reserve2.rds, chemin de mw_bootstrap() : %s ; chemin de l'oracle (stats_oracle()) : %s",
                                      length(ref), if (ok1) "oui" else "NON", if (ok2) "oui" else "NON"))
})
# (graines) : plages de la mesure, disjonction externe (P3) et litteraux du
# depot ; chevauchements INTERNES signales sans bloquer (P3 applique tel quel).
PLAGES <- local({
  P <- list()
  for (loi in names(LOIS)) P[[sprintf("triangles %s", loi)]] <- c(graine_tri(loi, 1), graine_tri(loi, R_MAX_PLAN))
  for (G in GEOM$code) for (loi in names(LOIS)) P[[sprintf("bootstrap %s %s", G, loi)]] <- c(graine_boot(G, loi, 1), graine_boot(G, loi, R_MAX_PLAN))
  for (loi in names(LOIS)) P[[sprintf("oracle %s", loi)]] <- c(graine_ora(loi, 1), graine_ora(loi, N0_MESURE))
  P[["pr\u00e9-vol"]] <- c(graine_pv_tri(1), graine_pv_boot(50000))
  do.call(rbind, P)
})
GRAINES_TXT <- local({
  M <- PLAGES; inter <- character(0)
  for (a in seq_len(nrow(M) - 1L)) for (b in (a + 1L):nrow(M))
    if (M[a, 1] <= M[b, 2] && M[b, 1] <= M[a, 2])
      inter <- c(inter, sprintf("%s (%.0f-%.0f) et %s (%.0f-%.0f)", rownames(M)[a], M[a, 1], M[a, 2], rownames(M)[b], M[b, 1], M[b, 2]))
  ext <- rbind(`#206/#297 MW` = PLAGE_EXT_206, `#297 LN` = PLAGE_EXT_297LN, `#305` = PLAGE_EXT_305, `#387` = PLAGE_EXT_387, `360 380 123` = PLAGE_EXT_360)
  touche <- function(lo, hi) any(lo <= M[, 2] & hi >= M[, 1])
  ext_ok <- !any(vapply(seq_len(nrow(ext)), function(i) touche(ext[i, 1], ext[i, 2]), logical(1)))
  r297 <- rbind(PLAGE_R297_TRI_N, PLAGE_R297_TRI_E, PLAGE_R297_BOOT_N, PLAGE_R297_BOOT_E)
  r297_hors <- !any(vapply(seq_len(nrow(r297)), function(i) touche(r297[i, 1], r297[i, 2]), logical(1)))
  max_ok <- max(M) <= .Machine$integer.max
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT_DEPOT)]
  reservees <- character(0)
  lit <- sort(unique(unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    m <- regmatches(l, regexec(paste0("^[[:space:]]*(PLAGE_[A-Za-z0-9_]+)[[:space:]]*<-[[:space:]]*c\\([[:space:]]*([0-9]+)L?[[:space:]]*,",
                                      "[[:space:]]*([0-9]+)L?[[:space:]]*\\)[[:space:]]*(#.*)?$"), l))
    res <- vapply(m, function(x) length(x) >= 4L && identical(as.numeric(x[3:4]), PLAGE_RESERVEE_P3), logical(1))
    if (any(res)) {
      reservees <<- c(reservees, sprintf("%s, l. %d (%s)", basename(f), which(res), vapply(m[res], `[`, "", 2L)))
      l[res] <- ""
    }
    as.numeric(unlist(regmatches(l, gregexpr("(?<![0-9A-Za-z._])[0-9]{8,10}(?=L?(?![0-9A-Za-z._]))", l, perl = TRUE))))
  }))))
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_LITTERAL), logical(1))]
  dans_567 <- lit[lit >= 567e6 & lit < 572e6]
  ok <- ext_ok && r297_hors && max_ok && !length(coll)
  list(ok = ok, inter = inter,
       txt = sprintf(paste("plages de la mesure (triangles, bootstraps des 3 G x 2 lois, oracles, pr\u00e9-vol ; b \u2264 %d, k \u2264 %d) de %.0f \u00e0 %.0f ;",
                           "disjointes de #206/#297 MW %.0f-%.0f, #297 LN %.0f-%.0f, #305 %.0f-%.0f, #387 %.0f-%.0f et de 360 380 123 : %s ;",
                           "graines de (r297) hors des plages : %s ; maximum \u2264 2^31 \u2212 1 : %s ;",
                           "%d litt\u00e9raux entiers de 8 \u00e0 10 chiffres dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; \u00e9criture scientifique non recherch\u00e9e) ;",
                           "litt\u00e9raux L dont [L ; L + %.0f] touche une plage : %s ; litt\u00e9raux dans [567 000 000 ; 572 000 000[ (plage r\u00e9serv\u00e9e par P3) : %s ;",
                           "d\u00e9clarations de la plage r\u00e9serv\u00e9e par P3 [%.0f ; %.0f] (forme exacte PLAGE_<nom> <- c(L1, L2), R21), \u00e9cart\u00e9es de la recherche des graines et cit\u00e9es ici : %s ;",
                           "**chevauchements internes de P3 (signal\u00e9s, non bloquants)** : %s"),
                     R_MAX_PLAN, N0_MESURE, min(M), max(M), PLAGE_EXT_206[1], PLAGE_EXT_206[2], PLAGE_EXT_297LN[1], PLAGE_EXT_297LN[2],
                     PLAGE_EXT_305[1], PLAGE_EXT_305[2], PLAGE_EXT_387[1], PLAGE_EXT_387[2], if (ext_ok) "oui" else "NON",
                     if (r297_hors) "oui" else "NON", if (max_ok) "oui" else "NON", length(lit), length(fs), DECALAGE_LITTERAL,
                     if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                     if (length(dans_567)) paste(sprintf("%.0f", dans_567), collapse = ", ") else "aucun",
                     PLAGE_RESERVEE_P3[1], PLAGE_RESERVEE_P3[2], if (length(reservees)) paste(reservees, collapse = " ; ") else "aucune",
                     if (length(inter)) paste(inter, collapse = " ; ") else "aucun"))
})
controle("(graines)", GRAINES_TXT$ok, GRAINES_TXT$txt)
# (m) : aucune occurrence du nom du script dans R/, app.R, .github/.
local({
  fs <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE), file.path(RACINE, "app.R"),
          list.files(file.path(RACINE, ".github"), recursive = TRUE, full.names = TRUE, all.files = TRUE))
  fs <- fs[file.exists(fs) & !dir.exists(fs)]
  lit <- function(f) tryCatch(readLines(f, warn = FALSE, skipNul = TRUE), error = function(e) NA_character_)
  trouve <- fs[vapply(fs, function(f) { x <- lit(f); anyNA(x) || any(grepl("niveau_mw_trapeze", x, fixed = TRUE)) }, logical(1))]
  controle("(m)", !length(trouve), sprintf("aucune occurrence de \u00ab niveau_mw_trapeze \u00bb dans R/, app.R et .github/ (%d fichiers lus) ; en d\u00e9faut : %s",
                                           length(fs), if (length(trouve)) paste(basename(trouve), collapse = ", ") else "aucun"))
})
C1_R2_OK <- all(vapply(C1_R2, function(x) isTRUE(x$ok), logical(1)))
AVANT <- c(INTEGRITE, if (!C1_R2_OK) "(c1)")
if (length(AVANT)) {
  ecrire_console(c("## INTEGRITE ECHEC avant tout tirage du plan", "",
                   vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""),
                   sprintf("- (c1) trap\u00e8zes de reserve2 : %s", paste(sprintf("%s %s (\u00e9cart max. %.2e)", names(C1_R2), vapply(C1_R2, function(x) if (isTRUE(x$ok)) "OK" else "\u00c9CHEC", ""),
                                                                            vapply(C1_R2, function(x) max(x$e), 1)), collapse = " ; ")), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(unique(AVANT), collapse = ", "))))
  quit(status = 1L)
}

###############################################################################
#  CALCUL PAR TRANCHES (reprise M42 (b))
###############################################################################
tranches_de <- function(R_) if (R_ < 1L) list() else
  lapply(seq(1L, R_, by = TAILLE_TRANCHE), function(a) c(a, min(a + TAILLE_TRANCHE - 1L, R_)))
fichier_tranche <- function(type, G, loi, tr) file.path(TRAVAIL, sprintf("%s-%s-%s-%06d-%06d.tsv", type, G, loi, tr[1], tr[2]))
lire_tranche <- function(f, type, G, loi, tr) {
  cols <- if (type == "OR") COLONNES_ORA else COLONNES; texte <- if (type == "OR") COL_TEXTE_ORA else COL_TEXTE
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  n <- tr[2] - tr[1] + 1L
  if (length(l) != n + 3L || l[1] != paste0("#CONTEXTE\t", txt_ctx(CTX)) || l[2] != paste(cols, collapse = "\t") ||
      l[length(l)] != sprintf("#FIN\t%d", n))
    refuser("tranche ", basename(f), " : contexte, en-tete ou fin differents du calcul courant -- pas de melange (autre --travail)")
  df <- lire_lignes(l[3:(n + 2L)], cols, texte)
  id <- if (type == "OR") df$k else df$b
  if (!identical(as.integer(id), seq.int(tr[1], tr[2])) || !identical(df$G, rep(G, n)) || !identical(df$loi, rep(loi, n)))
    refuser("tranche ", basename(f), " : triangles inattendus")
  df
}
ecrire_tranche <- function(f, lignes, cols, n) {
  tmp <- paste0(f, ".tmp")
  ecrire_fichier(tmp, c(paste0("#CONTEXTE\t", txt_ctx(CTX)), paste(cols, collapse = "\t"), lignes, sprintf("#FIN\t%d", n)))
  if (!file.rename(tmp, f)) stop("renommage impossible : ", basename(tmp))
}
# Premier triangle admis d'une tranche (controles (c1) et (i1)) : admission
# recalculee par le maitre (cout negligeable), meme triangle.
premier_admis <- function(G, loi, tr) {
  for (b in seq.int(tr[1], tr[2])) if (isTRUE(tryCatch(admettre(triangle_G(G, loi, graine_tri(loi, b)))$ok, error = function(e) FALSE))) return(b)
  NA_integer_
}
BLOCS <- c(lapply(GEOM$code, function(G) lapply(names(LOIS), function(loi) list(type = "OR", G = G, loi = loi, R = N0_RUN))),
           lapply(GEOM$code, function(G) lapply(names(LOIS), function(loi) list(type = "REP", G = G, loi = loi, R = R_RUN[[G]]))))
BLOCS <- unlist(BLOCS, recursive = FALSE)
N_CALC <- 0L; N_TR_CALC <- 0L; T_CALC <- 0; INTERROMPU <- FALSE
# Cout d'une ligne (secondes d'horloge x processus), par type, pour
# l'estimation de la duree d'un groupe (--duree-max) : valeurs par defaut
# remplacees par la mesure des groupes deja calcules dans l'execution.
COUT_LIGNE <- c(OR = 0.05, REP = 16); COUT_MESURE <- c(OR = FALSE, REP = FALSE)
DUREE_MAX_S <- OPT_DUREE_MAX * 3600
# Groupes de tranches traites par un seul appel de mclapply (ordonnancement
# dynamique) : OPT_PROC tranches pour les triangles tires (taches de 5
# triangles, triangle de controle seul), 10 tranches pour l'oracle (taches de
# 25 triangles). Chaque ligne ne depend que de ses graines : le resultat ne
# depend ni des groupes ni du nombre de processus.
for (bl in BLOCS) {
  if (INTERROMPU) break
  trs <- tranches_de(bl$R)
  manquantes <- Filter(function(tr) !file.exists(fichier_tranche(bl$type, bl$G, bl$loi, tr)), trs)
  if (!length(manquantes)) next
  taille_g <- if (bl$type == "OR") 10L else OPT_PROC
  groupes <- split(manquantes, ceiling(seq_along(manquantes) / taille_g))
  for (gr in groupes) {
    n_lignes_g <- sum(vapply(gr, function(tr) tr[2] - tr[1] + 1L, 1L))
    estime <- n_lignes_g * COUT_LIGNE[[bl$type]] / min(OPT_PROC, n_lignes_g)
    if (secs(t_debut) + estime > DUREE_MAX_S) { INTERROMPU <- TRUE; break }
    t0 <- Sys.time()
    taches <- list()
    for (tr in gr) {
      rs <- seq.int(tr[1], tr[2])
      if (bl$type == "OR") {
        for (v in split(rs, ceiling(seq_along(rs) / 25L))) taches[[length(taches) + 1L]] <- list(rs = v, ctl = NA_integer_)
      } else {
        r1 <- premier_admis(bl$G, bl$loi, tr)
        if (!is.na(r1)) taches[[length(taches) + 1L]] <- list(rs = r1, ctl = r1)
        reste <- setdiff(rs, r1)
        for (v in split(reste, ceiling(seq_along(reste) / 5L))) taches[[length(taches) + 1L]] <- list(rs = v, ctl = NA_integer_)
      }
    }
    res <- parallel::mclapply(taches, function(t) {
      if (bl$type == "OR") lapply(t$rs, function(k) un_oracle(bl$G, bl$loi, k)) else
        lapply(t$rs, function(b) un_triangle(bl$G, bl$loi, b, B_RUN, ctl = identical(b, t$ctl)))
    }, mc.cores = OPT_PROC, mc.preschedule = FALSE)
    ok <- vapply(res, function(x) is.list(x) && length(x) && all(vapply(x, is.list, logical(1))), logical(1))
    if (!all(ok)) stop("groupe de tranches ", bl$type, " ", bl$G, " ", bl$loi, " : processus en erreur ; relancer pour reprendre")
    lignes <- unlist(res, recursive = FALSE)
    ids <- vapply(lignes, function(L) as.integer(if (bl$type == "OR") L$k else L$b), 1L)
    for (tr in gr) {
      sel <- lignes[ids >= tr[1] & ids <= tr[2]]
      sel <- sel[order(vapply(sel, function(L) as.integer(if (bl$type == "OR") L$k else L$b), 1L))]
      if (bl$type == "OR") ecrire_tranche(fichier_tranche("OR", bl$G, bl$loi, tr), vapply(sel, format_ligne, "", cols = COLONNES_ORA, texte = COL_TEXTE_ORA), COLONNES_ORA, length(sel))
      else ecrire_tranche(fichier_tranche("REP", bl$G, bl$loi, tr), vapply(sel, format_ligne, ""), COLONNES, length(sel))
      N_CALC <- N_CALC + length(sel); N_TR_CALC <- N_TR_CALC + 1L
    }
    DUREE_GROUPE <- secs(t0)
    T_CALC <- T_CALC + DUREE_GROUPE
    COUT_LIGNE[[bl$type]] <- if (COUT_MESURE[[bl$type]]) max(COUT_LIGNE[[bl$type]], DUREE_GROUPE * min(OPT_PROC, length(lignes)) / length(lignes)) else
      DUREE_GROUPE * min(OPT_PROC, length(lignes)) / length(lignes)
    COUT_MESURE[[bl$type]] <- TRUE
    message(sprintf("%s : %s %s %s, %d tranche(s) calculee(s) (%.0f s)", horodatage(), bl$type, bl$G, bl$loi, length(gr), DUREE_GROUPE))
  }
}
if (INTERROMPU) {
  reste <- sum(vapply(BLOCS, function(bl) sum(vapply(tranches_de(bl$R), function(tr) !file.exists(fichier_tranche(bl$type, bl$G, bl$loi, tr)), logical(1))), 1))
  ecrire_fichier(JOURNAL_T, sprintf("- Segment interrompu : %s ; %d tranche(s) calcul\u00e9e(s) dans ce segment, %d restante(s) (--duree-max %s h)",
                                    horodatage(), N_TR_CALC, reste, format(OPT_DUREE_MAX)), mode = "ab")
  ecrire_console(c(sprintf("Segment : %d tranche(s) calcul\u00e9e(s), %d restante(s) ; dur\u00e9e %s s ; relancer la m\u00eame commande (m\u00eame --travail) pour reprendre.",
                           N_TR_CALC, reste, num(secs(t_debut), 0)), "SEGMENT INTERROMPU"))
  quit(status = 3L)
}
TR <- list(); TRO <- list(); FICHIERS_TR <- character(0)
for (bl in BLOCS) for (tr in tranches_de(bl$R)) {
  f <- fichier_tranche(bl$type, bl$G, bl$loi, tr)
  d <- lire_tranche(f, bl$type, bl$G, bl$loi, tr)
  if (bl$type == "OR") TRO[[length(TRO) + 1L]] <- d else TR[[length(TR) + 1L]] <- cbind(d, tranche = basename(f), stringsAsFactors = FALSE)
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
D <- do.call(rbind, TR)
ORA <- do.call(rbind, TRO)
# Valeurs de l'oracle (non versionnees) : fichier du dossier de travail, md5 au T0.
F_ORACLE <- file.path(TRAVAIL, "oracle.tsv")
ecrire_fichier(F_ORACLE, c(paste(setdiff(COLONNES_ORA, "duree_s"), collapse = "\t"),
                           vapply(seq_len(nrow(ORA)), function(i) format_ligne(as.list(ORA[i, , drop = FALSE]), setdiff(COLONNES_ORA, "duree_s"), COL_TEXTE_ORA), "")))
MD5_ORACLE <- md5_fichier(F_ORACLE)

###############################################################################
#  CONTROLES SUR LES LIGNES CALCULEES : (g'), (c1), (i1), (rep), puis (1)
###############################################################################
ADM <- D[D$statut %in% c("admis", "echec"), , drop = FALSE]
local({
  # Triangle dont la generation meme a echoue (refus de motif "erreur", gp
  # non calcule) : hors du controle, compte a part (deja refuse, K4).
  sans_gp <- D$motif_code %in% "erreur" & is.na(D$gp)
  ok <- nrow(D) > 0L && all(D$gp[!sans_gp] %in% 1)
  CTRL_GP <<- sprintf("plan : %d / %d triangles tir\u00e9s o\u00f9 le trap\u00e8ze = troncature du 8 x 8 simul\u00e9 sous la m\u00eame graine ; triangles dont la g\u00e9n\u00e9ration a \u00e9chou\u00e9 (refus \u00ab erreur \u00bb, troncature non calcul\u00e9e, hors contr\u00f4le) : %d",
                      sum(D$gp[!sans_gp] %in% 1), sum(!sans_gp), sum(sans_gp))
  i <- which(vapply(CTRL, function(k) k$code == "(g')", logical(1)))
  CTRL[[i]]$detail <<- paste(CTRL[[i]]$detail, ";", CTRL_GP)
  if (!ok) { CTRL[[i]]$ok <<- FALSE; INTEGRITE <<- c(INTEGRITE, "(g')") }
})
local({
  det <- character(0); tout <- TRUE
  sans_objet <- character(0)
  for (tn in unique(D$tranche)) {
    d <- D[D$tranche == tn & D$ctl %in% 1, , drop = FALSE]
    # Tranche sans aucun triangle admis (m3) : controle sans objet, consigne.
    if (!nrow(d) && !any(D$tranche == tn & D$statut %in% c("admis", "echec"))) { sans_objet <- c(sans_objet, tn); next }
    if (nrow(d) != 1L) { tout <- FALSE; det <- c(det, sprintf("%s : %d triangle(s) de contr\u00f4le", tn, nrow(d))); next }
    ok <- isTRUE(d$c1 == 1) && is.finite(d$c1_ecart) && d$c1_ecart <= TOL_C1
    tout <- tout && ok
    if (!ok) det <- c(det, sprintf("%s (b = %d) : \u00c9CHEC, \u00e9cart %.2e", tn, as.integer(d$b), d$c1_ecart))
  }
  ctl <- D[D$ctl %in% 1, , drop = FALSE]
  controle("(c1)", C1_R2_OK && tout,
           sprintf("crit\u00e8re C1 (par. 1.3) : MSEP et R du moteur contre CL_MSEPs, f, \u03c3\u00b2_j et estimateur direct contre la transcription ind\u00e9pendante, tol\u00e9rance %g relative ; %s ; trap\u00e8zes de reserve2 : %s ; premier triangle admis de chaque tranche : %d / %d tranches, \u00e9cart maximal %.2e%s",
                   TOL_C1, TXT_CL, paste(sprintf("%s %s (%.2e)", names(C1_R2), vapply(C1_R2, function(x) if (isTRUE(x$ok)) "OK" else "\u00c9CHEC", ""), vapply(C1_R2, function(x) max(x$e), 1)), collapse = ", "),
                   sum(ctl$c1 %in% 1), length(unique(D$tranche)) - length(sans_objet), if (nrow(ctl)) max(ctl$c1_ecart) else NA_real_,
                   paste0(sprintf(" ; tranches sans triangle admis (contr\u00f4le sans objet) : %s", if (length(sans_objet)) paste(sans_objet, collapse = ", ") else "aucune"),
                          if (length(det)) paste0(" ; ", paste(det, collapse = " ; ")) else "")))
  # (i1) sur les triangles de controle dont le bootstrap a abouti (statut
  # admis) : i1 n'est pas calcule pour un echec du bootstrap ou des tests.
  ctl_a <- ctl[ctl$statut == "admis", , drop = FALSE]
  controle("(i1)", nrow(ctl_a) > 0L && all(ctl_a$i1 %in% 1),
           sprintf("statistiques observ\u00e9es par le chemin de l'oracle (stats_oracle()) identical() \u00e0 bootstrap$stats_obs (validit\u00e9 du t\u00e9moin K3, #206 par. 6) : %d / %d triangles de contr\u00f4le au bootstrap abouti (%d triangle(s) de contr\u00f4le en \u00e9chec)",
                   sum(ctl_a$i1 %in% 1), nrow(ctl_a), nrow(ctl) - nrow(ctl_a)))
})
# (rep) : premier et dernier triangles admis de chaque (G, loi) recalcules ;
# ligne identique a celle de la tranche, hors duree.
REP_ECH <- do.call(rbind, lapply(GEOM$code, function(G) do.call(rbind, lapply(names(LOIS), function(loi) {
  d <- ADM[ADM$G == G & ADM$loi == loi & ADM$statut == "admis", , drop = FALSE]
  if (!nrow(d)) return(NULL)
  i <- unique(c(1L, nrow(d)))
  data.frame(G = G, loi = loi, b = as.integer(d$b[i]), ctl = as.integer(d$ctl[i]), stringsAsFactors = FALSE)
}))))
t_rep <- Sys.time()
C_REP <- parallel::mclapply(seq_len(NROW(REP_ECH)), function(i) {
  x <- REP_ECH[i, ]
  l <- un_triangle(x$G, x$loi, x$b, B_RUN, ctl = isTRUE(x$ctl == 1))
  ref <- D[D$G == x$G & D$loi == x$loi & D$b == x$b, , drop = FALSE]
  identical(format_ligne(l, COLONNES_BRUT), format_ligne(as.list(ref), COLONNES_BRUT))
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
DUREE_REP <- secs(t_rep)
N_ADM_CEL <- vapply(seq_len(nrow(GEOM) * length(LOIS)), function(i) {
  G <- GEOM$code[(i - 1L) %/% length(LOIS) + 1L]; loi <- names(LOIS)[(i - 1L) %% length(LOIS) + 1L]
  sum(ADM$G == G & ADM$loi == loi & ADM$statut == "admis") }, 1)
# Une (G, loi) sans triangle admis n'a rien a recalculer : consignee, sans
# echec (elle met deja K4 en defaut).
CEL_SANS_ADM <- vapply(seq_along(N_ADM_CEL), function(i) sprintf("%s %s", GEOM$code[(i - 1L) %/% length(LOIS) + 1L],
                                                                names(LOIS)[(i - 1L) %% length(LOIS) + 1L]), "")[N_ADM_CEL < 1]
controle("(rep)", NROW(REP_ECH) > 0L && NROW(REP_ECH) == sum(pmin(2, N_ADM_CEL)) && all(vapply(C_REP, isTRUE, logical(1))),
         sprintf("premier et dernier triangles admis de chaque (G, loi) recalcul\u00e9s : %d / %d lignes identiques \u00e0 celles des tranches, hors dur\u00e9e (%s) ; (G, loi) sans triangle admis (sans objet, K4) : %s",
                 sum(vapply(C_REP, isTRUE, logical(1))), NROW(REP_ECH),
                 paste(sprintf("%s %s b = %d", REP_ECH$G, REP_ECH$loi, REP_ECH$b), collapse = ", "),
                 if (length(CEL_SANS_ADM)) paste(CEL_SANS_ADM, collapse = ", ") else "aucune"))
# (1) : fin du calcul.
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
EMPREINTE_FIN <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
local({
  ctx_tr <- unique(unname(vapply(FICHIERS_TR, function(f) readLines(f, n = 1L, warn = FALSE), "")))
  ok_ctx <- length(ctx_tr) == 1L && identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))
  ok <- MD5_MOTEUR_DEBUT == MD5_MOTEUR_FIN && SHA_DEBUT == SHA_FIN && SHA_DEBUT != "inconnu" && EMPREINTE_DEBUT == EMPREINTE_FIN &&
    identical(J0$sha, SHA_DEBUT) && identical(J0$md5, MD5_MOTEUR_DEBUT) && identical(J0$empreinte, EMPREINTE_DEBUT) && ok_ctx
  controle("(1)", ok, sprintf("md5 R/engine.R d\u00e9but %s, fin %s, JOURNAL %s ; SHA d\u00e9but %s, fin %s, JOURNAL %s ; empreinte #231 d\u00e9but %s, fin %s, JOURNAL %s ; contexte (B, SHA, md5 du moteur et du script, empreinte, plateforme) identique dans les %d tranche(s) : %s",
                              MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN, J0$md5, SHA_DEBUT, SHA_FIN, J0$sha, EMPREINTE_DEBUT, EMPREINTE_FIN, J0$empreinte,
                              length(FICHIERS_TR), if (ok_ctx) "oui" else "NON"))
})
ORDRE_CTRL <- c("(1)", "(a)", "(m4)", "(g)", "(g')", "(c1)", "(r297)", "(o)", "(t)", "(graines)", "(m)", "(i1)", "(rep)")
CTRL <- CTRL[order(match(vapply(CTRL, function(k) k$code, ""), ORDRE_CTRL))]

###############################################################################
#  AGREGATION : rho, K1, K-T6, K3, K4, K5, K-T4, K-T7 (P7)
###############################################################################
# Copies declarees de tests/calibration_mc_mw_t8.R : taille_lissee() (par. 4
# de #206 ; rho a B, statistique oracle non finie comptee comme non-rejet),
# lecture() (classes de #166 avec rho), cellule(), m_rejet_oracle(),
# atome_cheval(), p_betabinom(), p_oracle_region(), classer_k3() (regle
# beta-binomiale de l'annotation du 05/11/2026 de #206) ; ic_cp() (qbeta,
# forme de tests/couverture_ic_sigma_mw_t8.R).
ic_cp <- function(k, n) {
  if (n <= 0) return(c(NA_real_, NA_real_))
  c(if (k == 0) 0 else stats::qbeta(0.025, k, n - k + 1), if (k == n) 1 else stats::qbeta(0.975, k + 1, n - k))
}
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
cellule <- function(p, a, ref) {
  fin <- is.finite(p); k <- sum(fin & p < a)
  x <- lecture(k, length(p), ref)
  x$absentes <- sum(!fin); x$taux_def <- if (any(fin)) k / sum(fin) else NA_real_
  x
}
m_rejet_oracle <- function(S0, queue, a) {
  S <- sort(S0[is.finite(S0)]); N <- length(S)
  if (!N || N < B_MIN_DEGENERESCENCE || diff(range(S)) <= TOL_DISPERSION_MC * max(1, abs(S[1]))) return(NA_real_)
  v <- unique(S)
  n_le <- findInterval(v, S)
  n_ge <- N - findInterval(v, S, left.open = TRUE)
  cnt <- n_le - c(0L, utils::head(n_le, -1L))
  p_bas <- (1 + n_le) / (N + 1); p_haut <- (1 + n_ge) / (N + 1)
  p <- pmin(switch(queue, haut = p_haut, bas = p_bas, deux = 2 * pmin(p_haut, p_bas)), 1)
  sum(cnt[p < a])
}
atome_cheval <- function(S0, queue, a, n_tot = sum(is.finite(S0))) {
  S <- S0[is.finite(S0)]; N <- length(S)
  vide <- data.frame(cote = character(0), valeur = numeric(0), masse = numeric(0), avant = numeric(0), avec = numeric(0),
                     decision = character(0), credit = numeric(0), stringsAsFactors = FALSE)
  if (!N) return(vide)
  v <- sort(unique(S)); cnt <- tabulate(match(S, v), length(v))
  seuil <- round((if (queue == "deux") a / 2 else a) * (N + 1), 9)
  c_t <- ceiling(round((if (queue == "deux") a / 2 else a) * (N + 1), 9)) - 2
  cotes <- list(basse = cumsum(cnt), haute = N - cumsum(cnt) + cnt)
  cotes <- cotes[switch(queue, bas = "basse", haut = "haute", deux = c("basse", "haute"))]
  out <- lapply(names(cotes), function(ct) {
    avec <- cotes[[ct]]; avant <- avec - cnt
    j <- which(cnt >= 2L & 1 + avant < seuil & seuil <= 1 + avec)
    if (!length(j)) return(NULL)
    p <- engine_p_mc(S0, v[j[1]], queue)$p_mc
    data.frame(cote = ct, valeur = v[j[1]], masse = cnt[j[1]] / N, avant = avant[j[1]] / N, avec = avec[j[1]] / N,
               decision = if (is.finite(p) && p < a) "rejet\u00e9 par l'oracle" else "non rejet\u00e9 par l'oracle",
               credit = cnt[j[1]] / n_tot * stats::pbinom(c_t, N, avec[j[1]] / N), stringsAsFactors = FALSE)
  })
  out <- Filter(Negate(is.null), out)
  if (length(out)) do.call(rbind, out) else vide
}
p_betabinom <- function(k, n, a, b) {
  x <- 0:n; lp <- lchoose(n, x) + lbeta(x + a, n - x + b) - lbeta(a, b)
  lse <- function(z) { m <- max(z); m + log(sum(exp(z - m))) }
  min(1, 2 * exp(min(lse(lp[seq_len(k + 1L)]), lse(lp[(k + 1L):(n + 1L)]))))
}
p_oracle_region <- function(k, n, m_r, N, t) {
  if (!is.finite(m_r) || !is.finite(N)) return(NA_real_)
  a <- m_r + t; b <- N + 1 - a
  if (a <= 0 || b <= 0) return(NA_real_)
  p_betabinom(k, n, a, b)
}
CLASSES_K3 <- c(i = "(i)", ii = "(ii)", non = "non expliqu\u00e9", aucun = "\u2014")
classer_k3 <- function(signal, p_holm_part, n_atomes) {
  vapply(seq_along(signal), function(i) {
    if (!isTRUE(signal[i])) return(CLASSES_K3[["aucun"]])
    if (is.finite(p_holm_part[i]) && p_holm_part[i] >= NIVEAU_HOLM) {
      if (n_atomes[i] > 0L) CLASSES_K3[["ii"]] else CLASSES_K3[["i"]]
    } else CLASSES_K3[["non"]]
  }, "")
}
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
lib_cle <- function(s) sprintf("%s (%s)", s, QUEUE[[s]])
txt_lec <- function(c_) if (is.na(c_$taux)) "\u2014" else sprintf("%s %s", num(c_$taux, D_IC), txt_ic(c_$ci))
txt_classe <- function(c_) if (isTRUE(c_$disj)) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
mat <- function(d, pre) { M <- as.matrix(d[, paste0(pre, ":", CLES), drop = FALSE]); dimnames(M) <- list(NULL, CLES); M }
CELLS <- expand.grid(loi = names(LOIS), G = GEOM$code, stringsAsFactors = FALSE)[, c("G", "loi")]
pop <- function(G, loi) ADM[ADM$G == G & ADM$loi == loi, , drop = FALSE]

# --- Oracle et rho par (G, loi, cle) -----------------------------------------
OR <- list()
for (i in seq_len(nrow(CELLS))) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]
  O <- ORA[ORA$G == G & ORA$loi == loi, , drop = FALSE]
  adm <- O[O$statut == "admis", , drop = FALSE]; n_adm <- nrow(adm)
  OR[[paste(G, loi)]] <- c(list(n_tire = nrow(O), n_adm = n_adm, refus = table(O$motif_code[O$statut == "refus"]), echec = sum(O$statut == "echec")),
    lapply(stats::setNames(nm = CLES), function(s) {
      S0 <- adm[[paste0("obs:", s)]]; S <- S0[is.finite(S0)]
      vv <- sort(unique(S)); cnt <- if (length(S)) tabulate(match(S, vv), length(vv)) else integer(0)
      list(S0 = S0, n_fin = length(S), n_nonfini = n_adm - length(S), distinctes = length(vv),
           atome = if (length(S)) max(cnt) / length(S) else NA_real_,
           rho = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], B_RUN, a, n_adm), 1),
           taille_or = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], length(S), a, n_adm), 1))
    }))
}
rho_de <- function(G, loi, s, ia) OR[[paste(G, loi)]][[s]]$rho[[ia]]

# --- K1 (8 x 5, 8 x 6) et classes de K-T6 (8 x 7) ----------------------------
K1 <- list()
for (i in seq_len(nrow(CELLS))) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]; d <- pop(G, loi); P <- mat(d, "p")
  for (s in CLES) for (ia in names(SEUILS))
    K1[[paste(G, loi, s, ia)]] <- c(list(G = G, loi = loi, s = s, ia = ia, ref = rho_de(G, loi, s, ia)),
                                    list(c = cellule(P[, s], SEUILS[[ia]], rho_de(G, loi, s, ia))))
}

# --- K-T6 : Fisher exact bilateral, 8 x 7 contre 8 x 8 (#297), Holm sur 13 --
KT6 <- NULL
if (!is.null(BR297)) {
  KT6 <- do.call(rbind, lapply(names(LOIS), function(loi) do.call(rbind, lapply(names(SEUILS), function(ia) {
    a <- SEUILS[[ia]]
    b8 <- BR297[BR297$type == "rep" & BR297$loi == loi & BR297$statut == "admis", , drop = FALSE]
    n8 <- nrow(b8); d7 <- pop("8x7", loi); n7 <- nrow(d7)
    x <- do.call(rbind, lapply(CLES, function(s) {
      p8 <- suppressWarnings(as.numeric(b8[[paste0("pR:", s)]])); k8 <- sum(is.finite(p8) & p8 < a)
      p7 <- d7[[paste0("p:", s)]]; k7 <- sum(is.finite(p7) & p7 < a)
      pf <- if (n7 && n8) stats::fisher.test(matrix(c(k7, n7 - k7, k8, n8 - k8), 2L))$p.value else NA_real_
      l8 <- lecture(k8, n8, rho_de("8x7", loi, s, ia))
      data.frame(loi = loi, ia = ia, s = s, k7 = k7, n7 = n7, k8 = k8, n8 = n8, abs8 = sum(!is.finite(p8)), p = pf,
                 classe8 = txt_classe(l8), lib8 = isTRUE(l8$disj) && identical(l8$cote, "lib\u00e9ral"), cote8 = if (isTRUE(l8$disj)) l8$cote else NA_character_,
                 stringsAsFactors = FALSE)
    }))
    x$p_holm <- stats::p.adjust(x$p, "holm", n = NS)
    x$signal <- is.finite(x$p_holm) & x$p_holm < NIVEAU_HOLM
    x
  }))))
}

# --- K3 : temoins oracle par (G, loi, alpha) ---------------------------------
K3 <- do.call(rbind, lapply(seq_len(nrow(CELLS)), function(i) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]; d <- pop(G, loi); n <- nrow(d); o <- OR[[paste(G, loi)]]
  if (!n || !o$n_adm) return(NULL)
  OBS <- mat(d, "obs")
  P <- vapply(CLES, function(s) vapply(OBS[, s], function(v) engine_p_mc(o[[s]]$S0, v, QUEUE[[s]])$p_mc, 1), numeric(n))
  if (!is.matrix(P)) P <- matrix(P, nrow = n, dimnames = list(NULL, CLES))
  do.call(rbind, lapply(names(SEUILS), function(ia) {
    a <- SEUILS[[ia]]
    k <- colSums(is.finite(P) & P < a); ab <- colSums(!is.finite(P))
    tl <- vapply(CLES, function(s) o[[s]]$taille_or[[ia]], 1)
    p <- vapply(CLES, function(s) if (is.finite(tl[[s]])) stats::binom.test(k[[s]], n, tl[[s]])$p.value else NA_real_, 1)
    p_holm <- stats::p.adjust(p, "holm", n = NS)
    m_r <- vapply(CLES, function(s) m_rejet_oracle(o[[s]]$S0, QUEUE[[s]], a), 1)
    n_f <- vapply(CLES, function(s) o[[s]]$n_fin, 1)
    tq <- ifelse(QUEUE[CLES] == "deux", 2, 1)
    p_part <- vapply(seq_along(CLES), function(j) p_oracle_region(k[[j]], n, m_r[[j]], n_f[[j]], tq[[j]]), 1)
    p_holm_part <- stats::p.adjust(p_part, "holm", n = NS)
    at <- lapply(CLES, function(s) atome_cheval(o[[s]]$S0, QUEUE[[s]], a, o$n_adm))
    n_at <- vapply(at, nrow, 1L)
    signal <- is.finite(p_holm) & p_holm < NIVEAU_HOLM
    data.frame(G = G, loi = loi, ia = ia, s = CLES, n = n, absentes = ab, k = k, taille = tl, p = p, p_holm = p_holm, m_r = m_r,
               N_or = n_f, p_holm_part = p_holm_part, n_atomes = n_at, classe = classer_k3(signal, p_holm_part, n_at),
               signal = signal, stringsAsFactors = FALSE)
  }))
}))
K3_NON <- if (is.null(K3)) NULL else K3[K3$classe == CLASSES_K3[["non"]], , drop = FALSE]

# --- K4 : p absentes, refus ---------------------------------------------------
K4 <- do.call(rbind, lapply(seq_len(nrow(CELLS)), function(i) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]; dt <- D[D$G == G & D$loi == loi, , drop = FALSE]; d <- pop(G, loi)
  P <- mat(d, "p"); n <- nrow(d)
  ab <- if (n) sum(rowSums(!is.finite(P)) > 0) else 0L
  data.frame(G = G, loi = loi, tires = nrow(dt), admis = sum(dt$statut == "admis"), echec = sum(dt$statut == "echec"),
             refus = sum(dt$statut == "refus"), absentes = ab, part_abs = if (n) ab / n else NA_real_,
             part_refus = if (nrow(dt)) sum(dt$statut == "refus") / nrow(dt) else NA_real_,
             motifs = { t <- table(dt$motif_code[dt$statut == "refus"]); if (length(t)) paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") else "aucun" },
             m4 = sum(dt$motif_code %in% "M4"), stringsAsFactors = FALSE)
}))
K4$ok <- is.finite(K4$part_abs) & K4$part_abs <= SEUIL_K4 & is.finite(K4$part_refus) & K4$part_refus <= SEUIL_REFUS

# --- K-T7 : p de famille et p globale ----------------------------------------
KT7 <- do.call(rbind, lapply(seq_len(nrow(CELLS)), function(i) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]; d <- pop(G, loi)
  do.call(rbind, lapply(FAM, function(f) do.call(rbind, lapply(names(SEUILS), function(ia) {
    e <- d[[paste0("ef:", f)]]; p <- d[[paste0("pf:", f)]]
    pres <- e %in% c("L", "N"); k <- sum(pres & is.finite(p) & p < SEUILS[[ia]])
    l <- lecture(k, sum(pres), RHO_F[[ia]])
    data.frame(G = G, loi = loi, f = f, ia = ia, n = nrow(d), presents = sum(pres), absentes = sum(e %in% "N"), x = sum(e %in% "X"),
               k = k, taux = l$taux, bas = l$ci[1], haut = l$ci[2], classe = txt_classe(l), stringsAsFactors = FALSE)
  }))))
}))

# --- Profils Theta0 a Theta5 (evalues mecaniquement, sans decision) ----------
THETA <- local({
  ev <- Filter(function(x) x$G %in% c("8x5", "8x6") && isTRUE(x$c$evaluable), K1)
  ne <- Filter(function(x) x$G %in% c("8x5", "8x6") && !isTRUE(x$c$evaluable), K1)
  txt <- function(x) sprintf("%s %s %s %s", x$G, x$loi, x$s, lib_ia(x$ia))
  cl <- vapply(ev, function(x) x$c$classe, ""); co <- vapply(ev, function(x) if (isTRUE(x$c$disj)) x$c$cote else NA_character_, "")
  lib <- co %in% "lib\u00e9ral"; cons <- co %in% "conservateur"
  # Theta5 : par (G, cle), cotes de distorsion materielle sous N et sous E
  # (un seuil ou l'autre), opposes ; evalue sur les trois G.
  t5 <- character(0)
  for (G in GEOM$code) for (s in CLES) {
    side <- function(loi) unique(na.omit(vapply(names(SEUILS), function(ia) { c_ <- K1[[paste(G, loi, s, ia)]]$c; if (isTRUE(c_$disj)) c_$cote else NA_character_ }, "")))
    sN <- side("N"); sE <- side("E")
    if ((("lib\u00e9ral" %in% sN) && ("conservateur" %in% sE)) || (("conservateur" %in% sN) && ("lib\u00e9ral" %in% sE))) t5 <- c(t5, sprintf("%s %s", G, s))
  }
  # Theta4 : meme distorsion liberale sur le 8 x 8 (#297), contre rho du 8 x 7
  # (oracle egal en loi a celui du 8 x 8 sous (c), critere (o)).
  t4 <- vapply(ev[lib], function(x) {
    r <- if (is.null(KT6)) NULL else KT6[KT6$loi == x$loi & KT6$s == x$s & KT6$ia == x$ia, , drop = FALSE]
    sprintf("%s (8 x 8, #297, contre \u03c1 du 8 x 7 : %s)", txt(x), if (is.null(r) || !nrow(r)) "non \u00e9valuable" else if (isTRUE(r$lib8)) "**m\u00eame distorsion lib\u00e9rale**" else r$classe8)
  }, "")
  integ <- !length(INTEGRITE)
  k3_non <- !is.null(K3_NON) && nrow(K3_NON) > 0L
  k3_abs <- is.null(K3)
  k4 <- all(K4$ok)
  kt6_sig <- !is.null(KT6) && any(KT6$signal)
  kt6_abs <- is.null(KT6)
  p0 <- !integ || k3_non || k3_abs || !k4 || kt6_sig || kt6_abs
  p5 <- length(t5) > 0L; p4 <- any(lib); p3 <- any(cons); p2 <- !any(lib | cons) && any(cl == CLASSES[3])
  p1 <- length(ev) > 0L && !length(ne) && all(cl %in% CLASSES[1:2]) && !kt6_sig && !kt6_abs
  ordre <- c(T0 = p0, T5 = p5, T4 = p4, T3 = p3, T2 = p2, T1 = p1)
  noms <- c(T0 = "\u03980", T5 = "\u03985", T4 = "\u03984", T3 = "\u03983", T2 = "\u03982", T1 = "\u03981")
  propose <- if (any(ordre)) noms[[names(ordre)[which(ordre)[1]]]] else "non \u00e9valuable"
  list(p0 = p0, p1 = p1, p2 = p2, p3 = p3, p4 = p4, p5 = p5, propose = propose, integ = integ, k3_non = k3_non, k3_abs = k3_abs, k4 = k4,
       kt6_sig = kt6_sig, kt6_abs = kt6_abs, t5 = t5, t4 = t4, cons = vapply(ev[cons], txt, ""), nt = vapply(ev[cl == CLASSES[3]], txt, ""),
       ne = vapply(ne, txt, ""), n_ev = length(ev))
})

###############################################################################
#  SORTIE MARKDOWN (P8)
###############################################################################
oui <- function(b) if (isTRUE(b)) "**oui**" else "non"
liste <- function(x, n = 30) if (!length(x)) "\u2014" else paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")
q_txt <- function(v, d = 4) { v <- v[is.finite(v)]; if (!length(v)) "\u2014" else
  paste(vapply(stats::quantile(v, c(.05, .25, .5, .75, .95), type = 7, names = FALSE), num, "", d = d), collapse = " ; ") }
virg <- function(x) sub(".", ",", x, fixed = TRUE)
TXT_DGP <- vapply(GEOM$code, function(G) { d <- DGP[[G]]
  sprintf("%s (J = %d) : f\u0302 = (%s) ; \u03c3\u00b2 = (%s) ; \u03c3\u00b2_(J\u22121) vrai = %s (crit\u00e8re : %s, arrondi %s)", G, d$J,
          paste(virg(sprintf("%.6g", d$f)), collapse = " ; "), paste(virg(sprintf("%.6g", d$sigma2)), collapse = " ; "),
          virg(sprintf("%.6g", S2_VRAI[[G]])), virg(S2_VRAI_SPEC[[G]]),
          if (identical(sprintf("%.5g", S2_VRAI[[G]]), S2_VRAI_SPEC[[G]])) "conforme" else "**DIFF\u00c9RENT**") }, "")
S <- c(sprintf("## Mesure #567 (S6, \u00e9tape 5 (b)) : niveau \u00e0 T = 8 des tests de Merz-W\u00fcthrich sur les trap\u00e8zes 8 x 5, 8 x 6 et 8 x 7%s",
               if (OPT_ESSAI) " -- ESSAI (--essai), non versionnable" else ""), "",
       "### Statut \u00e9pist\u00e9mique (sp\u00e9cification, par. 8, reproduit tel quel)", "", TEXTE_STATUT_567, "",
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Protocole", sprintf("%s, par. 8 (P1 \u00e0 P8) et 9 ; d\u00e9cisions du mainteneur du 20/11/2026 (D1', Q-2a-1 (c), Q-2a-2, Q-2a-3, Q-2a-5) ; md5 %s",
                                      PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE)))),
       ligne_md("Mode", if (OPT_ESSAI) "essai (--essai) : non versionnable" else sprintf("mesure, niveau %s (pr\u00e9-vol, P4)", OPT_NIVEAU)),
       ligne_md("R par (G, loi) (tir\u00e9s) ; N0 par (G, loi) ; B", sprintf("%s ; %d ; %s", paste(sprintf("%s : %d", names(R_RUN), R_RUN), collapse = ", "), N0_RUN, format(B_RUN))),
       ligne_md("DGP (P2)", sprintf("mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv, md5 %s), j = 0..J \u2212 1, premi\u00e8re colonne fix\u00e9e, I = 7 ; %s",
                                     md5_fichier(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")), paste(TXT_DGP, collapse = " ; "))),
       ligne_md("Lois", sprintf("N : stats::rnorm ; E : tirage uniforme dans les %d valeurs de .mw_pool_residus(aj0, jd0) de reserve2 divis\u00e9es par leur \u00e9cart-type de population (%s)",
                                 length(POOL0), virg(sprintf("%.5f", SD_POP0)))),
       ligne_md("Chemin (P1)", "gen_triangle_h0(DGP_G, loi) sous engine_sous_graine(graine du triangle) ; admission hors MW-04 (mw_valider_triangle(), domaine num\u00e9rique, mw_ajuster(), mw_msep(), mw_valider_ajustement() ; segment 1, annexe II) ; mw_ajuster() \u2192 .mw_ensembles_figes() \u2192 mw_bootstrap(aj, B, graine du bootstrap, figes) \u2192 mw_tests(aj, boot, \u03b1 = 0,10, figes)"),
       ligne_md("Graines (P3, appliqu\u00e9es exactement)", "triangle b, loi \u2113 : 567 000 000 + 100 000 (\u2113 \u2212 1) + b ; bootstrap : 568 000 000 + 1 000 000 (g \u2212 1) + 100 000 (\u2113 \u2212 1) + b ; oracle k : 570 000 000 + 100 000 (\u2113 \u2212 1) + k ; pr\u00e9-vol : 571 000 000 + u et 571 050 000 + u ; \u2113 = 1 (N), 2 (E) ; g = 1 (8 x 5), 2 (8 x 6), 3 (8 x 7)"),
       ligne_md("Chevauchement interne de P3", if (length(GRAINES_TXT$inter)) sprintf("**%s** : signal\u00e9, non bloquant ; question pour actuary", paste(GRAINES_TXT$inter, collapse = " ; ")) else "aucun"),
       ligne_md("G\u00e9n\u00e9rateur al\u00e9atoire", paste(ENGINE_RNG_KIND, collapse = ", ")),
       ligne_md("Oracle", sprintf("%s ; valeurs non versionn\u00e9es (oracle.tsv du dossier de travail), md5 %s",
                                  paste(vapply(names(OR), function(nm) sprintf("%s : %d tir\u00e9s, %d admis", nm, OR[[nm]]$n_tire, OR[[nm]]$n_adm), ""), collapse = " ; "), MD5_ORACLE)),
       ligne_md("Archive ChainLadder (contr\u00f4le (c1))", TXT_CL),
       ligne_md("Brut de #297 (K-T6, (r297))", sprintf("%s, md5 %s", BRUT_297, md5_fichier(file.path(RACINE, BRUT_297)))),
       ligne_md("SHA, git rev-parse HEAD (d\u00e9but ; fin)", sprintf("%s ; %s", SHA_DEBUT, SHA_FIN)),
       ligne_md("Commit (commit_depot(), au d\u00e9but)", COMMIT_DEBUT),
       ligne_md("md5 R/engine.R (d\u00e9but ; fin)", sprintf("%s ; %s", MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN)),
       ligne_md("Empreinte sans commentaires de R/engine.R (#231 ; d\u00e9but ; fin)", sprintf("%s ; %s", EMPREINTE_DEBUT, EMPREINTE_FIN)),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
       ligne_md("Tranches", sprintf("%d (taille %d), triangles tir\u00e9s et oracles", length(FICHIERS_TR), TAILLE_TRANCHE)),
       ligne_md("JOURNAL ; valeurs brutes", sprintf("%s ; %s (une ligne par triangle tir\u00e9, %%.17g)", NOM_JNL, NOM_TSV)),
       ligne_md("Versionnable (--ecrire)", if (length(motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")) || OPT_ESSAI) "non" else "oui"),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) paste("\u00c9CHEC :", paste(INTEGRITE, collapse = ", ")) else "OK"),
       "",
       "### Aide \u00e0 la lecture", "",
       paste("Erreurs s\u00e9par\u00e9es (P5) : IC de Clopper-Pearson \u00e0 95 % sur \u03c4 (erreur Monte-Carlo, fonction de R) ; err_mc de chaque p (fonction de B), incluse dans la proc\u00e9dure",
             "et dans \u03c1 ; erreur de \u03c1 due \u00e0 N0 (de l'ordre de 0,002 [H], #206) ; \u00e9cart \u03c4 \u2212 \u03c1, objet mesur\u00e9 (erreur \u00e0 T = 8 du test bootstrap \u00e0 param\u00e8tres estim\u00e9s) ;",
             "erreur de substitution (plan et loi au lieu de la v\u00e9rit\u00e9), non quantifi\u00e9e. Population : triangles admis (statut admis ou \u00e9chec ; un \u00e9chec du bootstrap",
             "ou des tests donne des p absentes, compt\u00e9es comme non-rejets et \u00e0 part). Classes et profils calcul\u00e9s m\u00e9caniquement, sur les valeurs non arrondies, **sans conclure**."), "",
       "**Crit\u00e8re (sp\u00e9cification, par. 8, P7), report\u00e9 sans modification :**", "",
       TEXTE_CRITERE_567, "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLES[1]))
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9 (P6)", "",
       entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "")
# Oracle et rho.
S <- c(S, "### R\u00e9f\u00e9rence \u03c1 et oracle par (G, loi)", "",
       sprintf("\u03c1 : taille liss\u00e9e \u00e0 B = %s du test de Monte-Carlo id\u00e9al tirant ses r\u00e9pliques dans l'oracle de (G, loi) (r\u00e8gle de #206, par. 4) ; statistique oracle non finie compt\u00e9e comme non-rejet ; \u00ab approch\u00e9 \u00bb au-del\u00e0 de 1 %% de statistiques oracle non finies. Taille du t\u00e9moin : m\u00eame r\u00e8gle \u00e0 B = nombre de statistiques finies.", format(B_RUN)), "",
       entete_md(c("G", "Loi", "Cl\u00e9 (sens)", "oracle admis / tir\u00e9s", "non finies", "valeurs distinctes", "masse du plus gros atome", "\u03c1 0,10", "\u03c1 0,05", "taille t\u00e9moin 0,10", "taille t\u00e9moin 0,05")))
for (nm in names(OR)) for (s in CLES) {
  o <- OR[[nm]]; x <- o[[s]]; ap <- if (o$n_adm && x$n_nonfini / o$n_adm > 0.01) " (**approch\u00e9**)" else ""
  S <- c(S, ligne_md(sub(" .*", "", nm), sub(".* ", "", nm), lib_cle(s), sprintf("%d / %d", o$n_adm, o$n_tire), x$n_nonfini, x$distinctes, num(x$atome, 5),
                     paste0(num(x$rho[[1]], 5), ap), paste0(num(x$rho[[2]], 5), ap), num(x$taille_or[[1]], 5), num(x$taille_or[[2]], 5)))
}
# K1 et classes de K-T6.
tableau_k1 <- function(G, titre) {
  L <- c(titre, "", entete_md(c("Loi", "\u03b1", "Cl\u00e9 (sens)", "n", "p absentes", "k", "\u03c4 [IC CP 95 %]", "\u03c1", "classe", "\u03c4 sur p d\u00e9finies")))
  for (loi in names(LOIS)) for (ia in names(SEUILS)) for (s in CLES) {
    x <- K1[[paste(G, loi, s, ia)]]; c_ <- x$c
    L <- c(L, ligne_md(loi, lib_ia(ia), lib_cle(s), c_$n, c_$absentes, c_$k, txt_lec(c_), num(x$ref, 5), txt_classe(c_), num(c_$taux_def, D_IC)))
  }
  c(L, "")
}
S <- c(S, "", tableau_k1("8x5", "### K1 (principal) \u2014 8 x 5 : classe des 13 cl\u00e9s par (loi, \u03b1)"),
       tableau_k1("8x6", "### K1 (principal) \u2014 8 x 6 : classe des 13 cl\u00e9s par (loi, \u03b1)"),
       tableau_k1("8x7", "### K-T6 (contr\u00f4le d'impl\u00e9mentation, sous (c)) \u2014 8 x 7 : classes K1"))
S <- c(S, "### K-T6 \u2014 8 x 7 contre 8 x 8 (#297, m\u00eame loi) : Fisher exact bilat\u00e9ral, Holm sur 13 \u00e0 0,05 par (loi, \u03b1)", "",
       paste("\u03c4(8 x 8) : lignes rep admises du brut de #297, p_mc du pool redress\u00e9 (pR:<cl\u00e9>) < \u03b1, p absente compt\u00e9e comme non-rejet. Classe du 8 x 8 contre \u03c1 de l'oracle du 8 x 7",
             "(descriptive : sous (c), les statistiques observ\u00e9es d'un 8 x 7 sont celles du 8 x 8 dont il est tronqu\u00e9, crit\u00e8re (o), d'o\u00f9 la m\u00eame loi oracle ; le contr\u00f4le (r297) atteste que le moteur reproduit les p de #297).",
             "Les \u00e9chantillons sont ind\u00e9pendants (graines disjointes)."), "")
if (is.null(KT6)) S <- c(S, sprintf("%s introuvable : K-T6 non \u00e9valuable.", BRUT_297), "") else
  S <- c(S, entete_md(c("Loi", "\u03b1", "Cl\u00e9 (sens)", "k / n (8 x 7)", "\u03c4 8 x 7 [IC]", "k / n (8 x 8, #297)", "\u03c4 8 x 8 [IC]", "classe du 8 x 8 (\u03c1 du 8 x 7)", "p Fisher", "p Holm", "significatif (0,05)")),
         vapply(seq_len(nrow(KT6)), function(i) { x <- KT6[i, ]
           ligne_md(x$loi, lib_ia(x$ia), lib_cle(x$s), sprintf("%d / %d", x$k7, x$n7), sprintf("%s %s", num(x$k7 / x$n7, D_IC), txt_ic(ic_cp(x$k7, x$n7))),
                    sprintf("%d / %d", x$k8, x$n8), sprintf("%s %s", num(x$k8 / x$n8, D_IC), txt_ic(ic_cp(x$k8, x$n8))), x$classe8, fmt_p(x$p), fmt_p(x$p_holm),
                    if (x$signal) "**oui**" else "non") }, ""),
         "", sprintf("Triangles 8 x 7 dont les statistiques observ\u00e9es sont identical() \u00e0 celles du 8 x 8 simul\u00e9 sous la m\u00eame graine (descriptif ; (o) sur triangle tir\u00e9) : %s.",
                     paste(vapply(names(LOIS), function(loi) { d <- pop("8x7", loi); sprintf("%s %d / %d (8 x 8 non ajustable : %d)", loi, sum(d$o8 %in% 1), nrow(d), sum(is.na(d$o8))) }, ""), collapse = " ; ")), "")
# K3.
S <- c(S, "### K3 \u2014 t\u00e9moins oracle (r\u00e8gle b\u00eata-binomiale du 05/11/2026, Holm sur 13 par (G, loi, \u03b1))", "",
       paste("p_or = engine_p_mc(S0, s_obs, sens) contre l'oracle de (G, loi) ; test binomial exact bilat\u00e9ral de \u03c4_or contre la taille du t\u00e9moin ; un signal est expliqu\u00e9 si la p de Holm",
             "b\u00eata-binomiale sur la r\u00e9gion de rejet r\u00e9alis\u00e9e de l'oracle est au moins 0,05 (\u00ab (i) \u00bb, ou \u00ab (ii) \u00bb avec un atome \u00e0 cheval), non expliqu\u00e9 sinon (seul ce cas met \u03980 en d\u00e9faut).",
             "Limite d\u00e9clar\u00e9e (#206) : un seul \u00e9chantillon oracle sert \u00e0 tous les triangles mesur\u00e9s."), "")
if (is.null(K3)) S <- c(S, "Oracle ou triangles absents : t\u00e9moins non calcul\u00e9s.", "") else
  S <- c(S, entete_md(c("G", "Loi", "\u03b1", "Cl\u00e9 (sens)", "n", "p_or absentes", "k", "\u03c4_or [IC]", "taille", "p binomiale", "p Holm", "m_r / N", "p Holm b\u00eata-binomiale", "atomes \u00e0 cheval", "K3")),
         vapply(seq_len(nrow(K3)), function(i) { x <- K3[i, ]
           ligne_md(x$G, x$loi, lib_ia(x$ia), lib_cle(x$s), x$n, x$absentes, x$k, sprintf("%s %s", num(x$k / x$n, D_IC), txt_ic(ic_cp(x$k, x$n))), num(x$taille, 5),
                    fmt_p(x$p), fmt_p(x$p_holm), if (is.finite(x$m_r)) sprintf("%s / %d", format(x$m_r), x$N_or) else "\u2014", fmt_p(x$p_holm_part), x$n_atomes, x$classe) }, ""), "")
# K4.
S <- c(S, "### K4 \u2014 p absentes (au plus 1 % par (G, loi)) et refus (au plus 1 %)", "",
       entete_md(c("G", "Loi", "tir\u00e9s", "admis", "\u00e9checs (bootstrap ou tests)", "refus", "motifs de refus", "part des refus", "admis \u00e0 au moins une p_mc absente", "part", "K4")),
       vapply(seq_len(nrow(K4)), function(i) { x <- K4[i, ]
         ligne_md(x$G, x$loi, x$tires, x$admis, x$echec, x$refus, x$motifs, num(x$part_refus, 4), x$absentes, num(x$part_abs, 4), if (x$ok) "rempli" else "**en d\u00e9faut**") }, ""), "")
msgs <- unique(D$message[!is.na(D$message) & D$statut == "echec"])
if (length(msgs)) S <- c(S, paste0("\u00c9checs rencontr\u00e9s : ", paste(utils::head(msgs, 10), collapse = " ; ")), "")
# K5.
S <- c(S, "### K5 (descriptif) \u2014 B effectif, motifs, lignes inop\u00e9rantes, statistiques NA", "",
       entete_md(c("G", "Loi", "n admis", "B effectif minimal (sur les 13 cl\u00e9s) : min ; q25 ; m\u00e9diane", "part \u00e0 B effectif < B", "retirage (cumuls) ; plafond", "n_sans_sigma > 0")))
for (i in seq_len(nrow(CELLS))) {
  d <- pop(CELLS$G[i], CELLS$loi[i]); b <- d$B_eff_min[is.finite(d$B_eff_min)]
  S <- c(S, ligne_md(CELLS$G[i], CELLS$loi[i], nrow(d),
                     if (length(b)) paste(vapply(stats::quantile(b, c(0, .25, .5), type = 7, names = FALSE), num, "", d = 0), collapse = " ; ") else "\u2014",
                     if (length(b)) num(mean(b < B_RUN), 4) else "\u2014", sprintf("%d ; %d", sum(d$cumuls_retires %in% 1), sum(d$plafond %in% 1)),
                     sum(d$n_sans_sigma > 0, na.rm = TRUE)))
}
S <- c(S, "", entete_md(c("G", "Cl\u00e9 (sens)", "ligne inop\u00e9rante N ; E (part)", "statistique observ\u00e9e NA N ; E (part)", "p_mc absente N ; E", "motifs des p absentes (N | E)")))
for (G in GEOM$code) for (s in CLES) {
  part <- function(loi, f) { d <- pop(G, loi); if (!nrow(d)) "\u2014" else num(f(d), 4) }
  mot <- function(loi) { m <- pop(G, loi)[[paste0("m:", s)]]; t <- table(m[!is.na(m) & m != "-"]); if (length(t)) paste(sprintf("%s (%d)", LIB_MOTIF[names(t)], as.integer(t)), collapse = ", ") else "aucun" }
  S <- c(S, ligne_md(G, lib_cle(s),
                     sprintf("%s ; %s", part("N", function(d) mean(d[[paste0("in:", s)]] %in% 1)), part("E", function(d) mean(d[[paste0("in:", s)]] %in% 1))),
                     sprintf("%s ; %s", part("N", function(d) mean(!is.finite(d[[paste0("obs:", s)]]))), part("E", function(d) mean(!is.finite(d[[paste0("obs:", s)]])))),
                     sprintf("%d ; %d", sum(!is.finite(pop(G, "N")[[paste0("p:", s)]])), sum(!is.finite(pop(G, "E")[[paste0("p:", s)]]))),
                     sprintf("%s | %s", mot("N"), mot("E"))))
}
# K-T4.
S <- c(S, "", "### K-T4 (descriptif, sans crit\u00e8re) \u2014 \u03c3\u0302\u00b2_(J\u22121) de la r\u00e8gle et estimateur direct, rapport des \u221aMSEP, taux de M4", "",
       "Quantiles 5 %, 25 %, 50 %, 75 %, 95 % (type 7) sur les triangles admis ; \u03c3\u00b2_(J\u22121) vrai du DGP au T0. \u221aMSEP directe : MSEP o\u00f9 \u03c3\u00b2_(J\u22121) et Q_(J\u22121) sont remplac\u00e9s par l'estimateur direct (m\u00e9canique de mw_sensibilite_sigma2_dernier()), calcul\u00e9e dans ce script seulement, pour information (Q-2a-4).", "",
       entete_md(c("G", "Loi", "n admis", "\u03c3\u0302\u00b2 r\u00e8gle / \u03c3\u00b2 vrai", "moyenne", "\u03c3\u0302\u00b2 direct / \u03c3\u00b2 vrai", "moyenne", "\u221aMSEP r\u00e8gle / \u221aMSEP directe", "refus M4 / tir\u00e9s")))
for (i in seq_len(nrow(CELLS))) {
  G <- CELLS$G[i]; loi <- CELLS$loi[i]; d <- pop(G, loi); v <- S2_VRAI[[G]]; k4 <- K4[K4$G == G & K4$loi == loi, ]
  r1 <- d$s2_regle / v; r2 <- d$s2_dir / v; r3 <- sqrt(d$msep) / sqrt(d$msep_dir)
  S <- c(S, ligne_md(G, loi, nrow(d), q_txt(r1), num(mean(r1[is.finite(r1)]), 4), q_txt(r2), num(mean(r2[is.finite(r2)]), 4), q_txt(r3),
                     sprintf("%d / %d (%s)", k4$m4, k4$tires, num(k4$m4 / k4$tires, 4))))
}
# K-T7.
S <- c(S, "", "### K-T7 (descriptif) \u2014 niveau des p de famille et de la p globale (engine_p_famille())", "",
       paste("\u03c4 sur les triangles admis o\u00f9 la ligne de famille est pr\u00e9sente (p absente : non-rejet, compt\u00e9e \u00e0 part) ; classe contre \u03c1_F (0,099 ; 0,049), taille du test id\u00e9al",
             "sans atome, majorant (sp\u00e9cification de Fk, par. 5.3), \u00e0 titre descriptif."), "",
       entete_md(c("G", "Loi", "Famille", "\u03b1", "admis", "ligne pr\u00e9sente", "p absente", "k", "\u03c4 [IC]", "classe (\u03c1_F, descriptive)")),
       vapply(seq_len(nrow(KT7)), function(i) { x <- KT7[i, ]
         ligne_md(x$G, x$loi, x$f, lib_ia(x$ia), x$n, x$presents, x$absentes, x$k, if (is.na(x$taux)) "\u2014" else sprintf("%s %s", num(x$taux, D_IC), txt_ic(c(x$bas, x$haut))), x$classe) }, ""), "")
# Profils.
S <- c(S, "### Profils pour D2 (\u0398), \u00e9valu\u00e9s m\u00e9caniquement, sans d\u00e9cision (ordre \u03980, \u03985, \u03984, \u03983, \u03982, \u03981)", "",
       entete_md(c("Profil", "Condition m\u00e9canique", "Pr\u00e9sent", "Cellules")),
       ligne_md("\u03980", "int\u00e9grit\u00e9, K3 (signal non expliqu\u00e9) ou K4 en d\u00e9faut ; ou K-T6 significatif (\u00ab non expliqu\u00e9 \u00bb : jugement d'actuary)", oui(THETA$p0),
                sprintf("int\u00e9grit\u00e9 %s ; K3 non expliqu\u00e9 : %s ; K4 rempli : %s ; K-T6 significatif : %s",
                        if (THETA$integ) "OK" else paste("\u00c9CHEC", paste(INTEGRITE, collapse = ", ")),
                        if (THETA$k3_abs) "t\u00e9moin absent" else liste(if (nrow(K3_NON)) sprintf("%s %s %s %s", K3_NON$G, K3_NON$loi, K3_NON$s, vapply(K3_NON$ia, lib_ia, "")) else character(0)),
                        if (THETA$k4) "oui" else "non", if (THETA$kt6_abs) "non \u00e9valuable" else liste(if (any(KT6$signal)) with(KT6[KT6$signal, ], sprintf("%s %s %s", loi, s, vapply(ia, lib_ia, ""))) else character(0)))),
       ligne_md("\u03985", "une cl\u00e9 en distorsion de c\u00f4t\u00e9s oppos\u00e9s entre N et E pour une G (un seuil ou l'autre ; trois G)", oui(THETA$p5), liste(THETA$t5)),
       ligne_md("\u03984", "distorsion mat\u00e9rielle lib\u00e9rale d'une cl\u00e9 sur 8 x 5 ou 8 x 6, pour une loi", oui(THETA$p4), liste(THETA$t4)),
       ligne_md("\u03983", "distorsion mat\u00e9rielle conservatrice sur une cl\u00e9 (8 x 5, 8 x 6)", oui(THETA$p3), liste(THETA$cons)),
       ligne_md("\u03982", "aucune distorsion, des non tranch\u00e9s (8 x 5, 8 x 6)", oui(THETA$p2), liste(THETA$nt)),
       ligne_md("\u03981", "13 cl\u00e9s compatibles ou en \u00e9cart mineur sur 8 x 5 et 8 x 6, N et E, aux deux seuils, et K-T6 sans signal", oui(THETA$p1),
                sprintf("%d cellules \u00e9valuables ; non \u00e9valuables : %s", THETA$n_ev, liste(THETA$ne))),
       ligne_md("**Profil propos\u00e9 (premier pr\u00e9sent dans l'ordre)**", sprintf("**%s**", THETA$propose), "\u2014", "lecture d'actuary, d\u00e9cision du mainteneur \u00e0 D2"),
       "", sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%s)", paste(INTEGRITE, collapse = ", ")) else "OK"), "")
duree_cumulee <- sum(D$duree_s, na.rm = TRUE) + sum(ORA$duree_s, na.rm = TRUE)
S_EXEC <- c("### Ex\u00e9cution (varie d'une ex\u00e9cution \u00e0 l'autre)", "",
            sprintf("- Lancement (JOURNAL) : %s ; fin : %s", J0$lancement, horodatage()),
            sprintf("- Processus : %d ; lignes calcul\u00e9es par cette ex\u00e9cution : %d, %d tranche(s), %s s d'horloge ; tranches reprises : %d",
                    OPT_PROC, N_CALC, N_TR_CALC, num(T_CALC, 0), length(FICHIERS_TR) - N_TR_CALC),
            sprintf("- Dur\u00e9e cumul\u00e9e des lignes (somme des processus) : %s s ; contr\u00f4les (a) et (r297) : %s s ; (rep) : %s s ; dur\u00e9e totale : %s s",
                    num(duree_cumulee, 0), num(DUREE_AVANT, 1), num(DUREE_REP, 1), num(secs(t_debut), 0)), "")

###############################################################################
#  ECRITURE
###############################################################################
brut <- c(paste(COLONNES_BRUT, collapse = "\t"),
          vapply(seq_len(nrow(D)), function(i) format_ligne(as.list(D[i, , drop = FALSE]), COLONNES_BRUT), ""))
MD_FINAL <- c(S, S_EXEC)
f_md <- file.path(TRAVAIL, NOM_MD); f_tsv <- file.path(TRAVAIL, NOM_TSV)
ecrire_fichier(f_md, MD_FINAL)
ecrire_fichier(f_tsv, brut)
ecrire_fichier(JOURNAL_T, c(sprintf("- Fin : %s ; SHA \u00e0 la fin %s ; md5 R/engine.R \u00e0 la fin %s ; INTEGRITE %s",
                                    horodatage(), SHA_FIN, MD5_MOTEUR_FIN, if (length(INTEGRITE)) "ECHEC" else "OK"),
                            sprintf("- Sortie %s : md5 %s", NOM_MD, md5_fichier(f_md)),
                            sprintf("- Sortie %s : md5 %s", NOM_TSV, md5_fichier(f_tsv)),
                            sprintf("- Oracle (oracle.tsv, non versionn\u00e9) : md5 %s", MD5_ORACLE)), mode = "ab")
ecrire_console(MD_FINAL)
ecrire_console(sprintf("Sorties (dossier de travail, hors du d\u00e9p\u00f4t) : %s ; %s ; %s", f_md, f_tsv, JOURNAL_T))
REFUS_ECRITURE <- FALSE
copier_fichier <- function(src, dst) {
  tmp <- tempfile(pattern = paste0(".", basename(dst), "."), tmpdir = dirname(dst))
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  tryCatch({
    oct <- readBin(src, "raw", n = file.size(src))
    con <- file(tmp, open = "wb")
    tryCatch(writeBin(oct, con), finally = close(con))
    identical(unname(tools::md5sum(tmp)), unname(tools::md5sum(src))) && isTRUE(suppressWarnings(file.rename(tmp, dst)))
  }, error = function(e) FALSE)
}
if (OPT_ECRIRE) {
  ab <- chemins_absolus(c(readLines(f_md, warn = FALSE, encoding = "UTF-8"), readLines(f_tsv, warn = FALSE, encoding = "UTF-8"),
                          readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")))
  if (length(INTEGRITE)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : INTEGRITE ECHEC (", paste(INTEGRITE, collapse = ", "), ") ; sorties laissees dans le dossier de travail")
  } else if (length(ab)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : chemin absolu ou /tmp dans une sortie : ", paste(utils::head(ab, 3), collapse = " | "))
  } else {
    nv <- motifs_non_versionnable(commit_depot(SCRIPT_DEPOT), empreintes_code(), "de la mesure")
    if (length(nv)) { message("--ecrire refuse au moment d'ecrire : ", paste(nv, collapse = " ; ")); REFUS_ECRITURE <- TRUE } else {
      garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)
      if (!all(mapply(copier_fichier, c(f_md, f_tsv, JOURNAL_T), CIBLES))) {
        message("--ecrire : copie incomplete vers docs/tableaux"); REFUS_ECRITURE <- TRUE
      } else ecrire_console(sprintf("\u00c9crit : %s", paste(file.path("docs", "tableaux", basename(CIBLES)), collapse = " ; ")))
    }
  }
}
ecrire_console(paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK"))
quit(status = if (length(INTEGRITE) || REFUS_ECRITURE) 1L else 0L)
