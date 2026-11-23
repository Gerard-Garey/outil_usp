###############################################################################
#  tests/simulation_jm1_trapeze_t8.R  --  SIMULATION DE LA COLONNE J-1 D'UN
#  TRAPEZE DANS LE BOOTSTRAP DE MERZ-WUTHRICH : V0 (VALEUR DE LA REGLE DE
#  MINIMUM, ETAT ACTUEL) CONTRE V2 (ESTIMATEUR DIRECT), TAILLE APPARIEE DES
#  13 CLES ET COUVERTURE A T = 8 (issue #612, creneau A2, etape 2)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; parallel, utils et tools (livres avec R). Il ne modifie
#  ni R/, ni app.R, ni tests/reference/ ; ni le moteur ni l'application ne le
#  lisent (controle (m)). Le moteur est charge par tests/outils_tests.R, donc
#  par charger_moteur() (ADR 0016), qui porte aussi commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), empreinte_sans_commentaires(),
#  comparer_objets(), DATE_REFERENCE_TESTS, .tri et .tri_trapeze. Fichier
#  source ASCII : libelles non ASCII en echappements \u ; sortie en UTF-8, y
#  compris sous LC_ALL=C.
#
#  Protocole : docs/revues/20261123-a2-creneau/actuary-1-protocole-612.md
#  (actuary-approfondi, md5 70176c2e3ded10922eeb81971b533ae7), par. 8
#  (specification du script), en s'appuyant sur les par. 2 a 7 et 9 ;
#  decisions du mainteneur au point d'arret PA-1 (E-23/11 (PA-1),
#  docs/feuille-de-route.md par. 4) : niveau L-A, bloc D compris ; session
#  cloud, segments de 1,8 h, branche de sauvegarde claude/sauvegarde-612
#  (M42) ; reemploi des graines de #567 avec le prolongement du 8 x 7
#  (b = 1001 a 2000) ; V1 lue comme composite des deux executions, sans
#  implementation ; couverture mesuree pour V0 et V2, cible sigma_A^regle ;
#  criteres K0 a K4 et regles R0 a R-V0 reportes SANS MODIFICATION dans
#  TEXTE_CRITERE_612 (controle (t), bloquant : presence a l'identique dans
#  le protocole verse ET md5 du protocole egal a celui approuve a PA-1,
#  MD5_PROTOCOLE_PA1 ; md5 lu au T0 fixe dans le contexte des tranches et
#  controle a la fin), evalues mecaniquement, SANS CONCLURE : la lecture
#  revient a actuary (etape 4), la decision au mainteneur (PA-2).
#  Decisions du mainteneur sur le controle du script (E-23/11 (etape 2),
#  docs/feuille-de-route.md par. 4 ; rapports actuary-2-conformite-script-612.md
#  et audit-leger-script-612.md) : (C2) les controles (inv), (o) et (dc)
#  carre ne sont pas des controles d'integrite mais des criteres de K0 ;
#  leur defaut met K0 en defaut et declenche R0, sans INTEGRITE ECHEC : les
#  sorties restent ecrites ; (dc) sur le bloc D en defaut rend les constats
#  (3) et (4) non evaluables, sans R0 ; (R3) le bloc D n'entre pas dans le
#  verdict K0 sur les refus et les p absentes (affiche, hors verdict) ;
#  (R4) le bloc S (sonde du constat (1)) se lance en premier.
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack
#  ajuste a reserve2, T = I + 1 = 8, lois N et E, B = 999), conditionnel a
#  l'admission ; pas un resultat general.
#
#  Copies declarees (aucune modification des fichiers d'origine) :
#    - de tests/niveau_mw_trapeze_t8.R (#567) : outils de forme, gen_triangle_h0()
#      (lui-meme copie de tests/calibration_mc_mw_t8.R), admettre() (adaptee :
#      depuis la levee de MW-04, toute erreur de mw_valider_triangle() fait
#      refuser le triangle, l'avertissement de geometrie n'est pas un motif),
#      stats_oracle(), msep_direct(), ic_cp(), taille_lissee(), lecture(),
#      ecriture et lecture des tranches, controles (g), (g'), (graines), (m),
#      copier_fichier() ;
#    - de tests/couverture_ic_sigma_mw_t8.R (#387) : boucle_allegee()
#      (adaptee : la copie aj_sim de mw_bootstrap(), constat M-1 de #567,
#      option (b), y est reproduite par le predicat de l'environnement du
#      moteur, d'ou la meme simulation sous V0 et sous V2) et recomposer().
#
#  Variantes. V0 : moteur tel quel. V2 : substitution de
#  .mw_simulation_sigma_direct() dans environment(run_engine) par le corps
#  impose du par. 2 du protocole (F_V2 ci-dessous). Deux autres
#  substitutions, diagnostiques : .mw_tirer_triangle_valide() (balayage,
#  bloc BAL) et mw_residus() (sonde, bloc S). Chacune est posee par
#  substituer(), restauree par on.exit et la restauration controlee par
#  identical() a l'objet d'origine ; leurs corps sont imprimes au T0.
#  Tout tirage passe par engine_sous_graine(), graines explicites (par. 6).
#
#  Blocs (par. 3) : OR (oracle des trapezes, N0 par (G, loi)), M7a (8 x 7,
#  b <= 1000, V2 complet, V0 lu dans le brut de #567 avec couverture par la
#  boucle allegee), M7b (8 x 7, b = 1001 a 2000, V0 et V2 complets), M5 et
#  M6 (8 x 5, 8 x 6, b <= 2000, comme M7a), C (carre 8 x 8, parent des
#  trapezes, une execution), OD et D (plan d'actuary-10 : 8 x 6 a sigma2_2 = 0,
#  oracle propre, une execution), BAL (balayage du sigma2 de simulation de
#  J-1, b <= 20), S (sonde de la plage de dispersion relative 1e-12 a 1e-10).
#  Sous --essai, le V0 des blocs M7a, M5 et M6 est calcule en entier a B = 199
#  (le brut de #567 est a B = 999) ; la lecture du brut n'y est exercee que
#  par le controle (r567).
#
#  Modes :
#    --aide : imprime l'usage et l'ordre conseille des lancements (USAGE).
#    --essai [--processus k] [--travail D] [--duree-max H] [--bloc LISTE] :
#      R = 3 triangles par cellule, N0 = 100, B = 199 ; dossier temporaire
#      supprime en fin d'essai (sauf --travail) ; sortie marquee ESSAI ;
#      --ecrire refuse ; le controle (oracle) y lit le tableau de #567
#      (78 lignes, quatre champs numeriques) sans comparer les valeurs.
#    --prevol : couts a 1, 2, 3 et 4 processus concurrents, controles (v0) et
#      (v2), taux d'admission ; duree planifiee de L-A, L-B, L-C ; niveau qui
#      tient dans le budget de PA-1 (13 segments de 1,8 h) ; nombre de
#      segments ; rien d'ecrit. La partie deterministe de la sortie est
#      suivie de son md5 (deux pre-vols doivent le reproduire) ; les durees
#      viennent apres.
#    mesure : --niveau L-A|L-B|L-C [--bloc LISTE] [--processus k]
#      [--travail D] [--duree-max H] [--ecrire [--remplacer]].
#  Reprise (M42 (b)) : tranches de 100 triangles, ecrites dans le dossier de
#  travail (hors du depot) des qu'elles sont completes ; une relance avec le
#  meme dossier reprend aux tranches absentes ; le contexte (B, SHA, md5 du
#  moteur et du script, empreinte #231, plateforme) est compare entre
#  tranches. --duree-max H : aucun groupe de tranches n'est lance au-dela
#  (l'agregation finale, controle (rep) compris, vient apres : voir R7
#  ci-dessous) ; --bloc : seuls les blocs listes sont calcules ; sans
#  --bloc, le bloc S est calcule en premier (R4). Mesure incomplete : sortie
#  "SEGMENT INTERROMPU", code 3 ; si le bloc S est alors complet, son
#  tableau et la regle du constat (1) sont imprimes et ecrits dans le
#  dossier de travail (constat-1-sonde.md, provisoire : les controles sur
#  les lignes et (1) fin ne sont evalues qu'a la mesure complete). Dossier
#  par defaut : <parent de la racine>/issue612-travail-<niveau>.
#  Sorties (par. 8 ; avec --ecrire, dans docs/tableaux/ si INTEGRITE OK,
#  commit propre et garde_ecrasement()) :
#  <AAAAMMJJ>-issue612-simulation-jm1-trapeze.md, ...-brut.tsv,
#  ...-balayage-brut.tsv, ...-sonde.tsv, ...-journal-mesure.md ; les oracles
#  restent dans le dossier de travail (oracle-567.tsv, oracle-D.tsv), md5 au T0.
#
#  Ordre conseille des lancements (R4, R7 ; aussi imprime par --aide), depuis
#  un arbre fige au commit de mesure (git worktree detache : tout commit sur
#  la branche pendant un segment le fait echouer, reserve d'audit) :
#    1. deux pre-vols, a comparer (empreinte de la partie deterministe) :
#         Rscript tests/simulation_jm1_trapeze_t8.R --prevol
#    2. essai : Rscript tests/simulation_jm1_trapeze_t8.R --essai
#    3. bloc S EN PREMIER (sonde du constat (1), quelques minutes) :
#         Rscript tests/simulation_jm1_trapeze_t8.R --niveau L-A --bloc S
#             --processus 4 --travail DOSSIER
#       si la regle du constat (1) se declenche (correction), l'ordre de la
#       correction moteur: par rapport a la mesure revient au mainteneur
#       avant la mesure longue ;
#    4. segments, meme DOSSIER (reprise aux tranches absentes) :
#         Rscript tests/simulation_jm1_trapeze_t8.R --niveau L-A --processus 4
#             --duree-max 1.8 --travail DOSSIER
#    5. dernier segment (reste estime dans un segment) et tout segment lance
#       avec --ecrire : --duree-max 1.6 au lieu de 1.8 (R7 : marge pour
#       l'agregation finale, (rep) et temoin, avant la fin du segment de
#       1,8 h) :
#         Rscript tests/simulation_jm1_trapeze_t8.R --niveau L-A --processus 4
#             --duree-max 1.6 --travail DOSSIER --ecrire
#
#  Sortie et codes (derniere ligne de la console) :
#    INTEGRITE OK       code 0 (K0 en defaut compris : R0 est alors ecrite
#                       dans la sortie, les sorties restent ecrites) ;
#    INTEGRITE ECHEC    code 1 (controle de code ou de reproductibilite en
#                       defaut ; --ecrire refuse) ;
#    ECRITURE REFUSEE   code 1 (--ecrire seul, INTEGRITE OK : chemin absolu
#                       dans une sortie, commit non propre au moment
#                       d'ecrire, copie incomplete) ;
#    SEGMENT INTERROMPU code 3.
#  Refus d'option ou de reprise (message "REFUS : ..." sur la sortie
#  d'erreur, code 1) et erreur R (code 1 de Rscript) : aucune de ces
#  dernieres lignes. --aide : code 0.
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
CONNUES <- c("--aide", "--essai", "--prevol", "--niveau", "--bloc", "--processus", "--travail", "--duree-max",
             "--ecrire", "--remplacer")
AVEC_VALEUR <- c("--niveau", "--bloc", "--processus", "--travail", "--duree-max")
refuser <- function(...) { message("REFUS : ", ...); quit(status = 1L) }
# Aide (--aide) : usage, ordre conseille des lancements (R4 : bloc S en
# premier ; R7 : --duree-max 1.6 au dernier segment) et codes de sortie.
USAGE <- c(
  "Usage (racine du depot ; LC_ALL=C.UTF-8 sous Linux ; arbre fige au commit de mesure, git worktree detache) :",
  "  Rscript tests/simulation_jm1_trapeze_t8.R --aide",
  "  Rscript tests/simulation_jm1_trapeze_t8.R --prevol",
  "  Rscript tests/simulation_jm1_trapeze_t8.R --essai [--processus k] [--travail D] [--duree-max H] [--bloc LISTE]",
  "  Rscript tests/simulation_jm1_trapeze_t8.R --niveau L-A|L-B|L-C [--bloc LISTE] [--processus k] [--travail D]",
  "      [--duree-max H] [--ecrire [--remplacer]]",
  "  Blocs (--bloc, separes par des virgules) : S, OR, M7a, M7b, M5, M6, C, OD, D, BAL ; sans --bloc, S d'abord.",
  "",
  "Ordre conseille des lancements :",
  "  1. --prevol, deux fois (empreintes de la partie deterministe identiques) ;",
  "  2. --essai (doit finir sur INTEGRITE OK) ;",
  "  3. bloc S EN PREMIER (sonde du constat (1), quelques minutes) :",
  "       --niveau L-A --bloc S --processus 4 --travail DOSSIER",
  "     si la regle du constat (1) se declenche, l'ordre de la correction moteur: par rapport a",
  "     la mesure revient au mainteneur avant la mesure longue ;",
  "  4. segments (meme DOSSIER, reprise aux tranches absentes) :",
  "       --niveau L-A --processus 4 --duree-max 1.8 --travail DOSSIER",
  "  5. dernier segment (reste estime dans un segment) et tout segment lance avec --ecrire :",
  "       --niveau L-A --processus 4 --duree-max 1.6 --travail DOSSIER --ecrire",
  "     (marge pour l'agregation finale, (rep) et temoin, sous la limite de 1,8 h du segment).",
  "",
  "Derniere ligne et code : INTEGRITE OK (0, K0 en defaut compris : R0 ecrite dans la sortie) ;",
  "  INTEGRITE ECHEC (1) ; ECRITURE REFUSEE (1, --ecrire seul) ; SEGMENT INTERROMPU (3) ;",
  "  refus d'option ou de reprise (REFUS sur la sortie d'erreur) et erreur R : code 1, sans ces lignes.")
if ("--aide" %in% ARGS) {
  if (length(setdiff(ARGS, "--aide"))) refuser("--aide : aucune autre option admise")
  writeLines(USAGE)
  quit(status = 0L)
}
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
BLOCS_CONNUS <- c("OR", "M7a", "M7b", "M5", "M6", "C", "OD", "D", "BAL", "S")
# Ordre de calcul des blocs (R4, decision du mainteneur E-23/11 (etape 2)) :
# le bloc S (sonde du constat (1)) en premier. Chaque ligne ne depend que de
# ses graines : l'ordre ne change aucun nombre.
ORDRE_CALCUL <- c("S", setdiff(BLOCS_CONNUS, "S"))
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_PREVOL    <- "--prevol" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_NIVEAU    <- lire_option("--niveau", NA_character_)
OPT_TRAVAIL   <- lire_option("--travail", NA_character_)
OPT_BLOC_TXT  <- lire_option("--bloc", NA_character_)
OPT_DUREE_MAX <- suppressWarnings(as.numeric(lire_option("--duree-max", "Inf")))
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)
OPT_PROC <- suppressWarnings(as.integer(lire_option("--processus",
              as.character(if (.Platform$OS.type == "windows") 1L else max(1L, min(4L, COEURS, na.rm = TRUE))))))
MODE <- if (OPT_PREVOL) "prevol" else if (OPT_ESSAI) "essai" else "mesure"
if (OPT_PREVOL && OPT_ESSAI) refuser("--prevol et --essai sont exclusifs")
if (OPT_PREVOL && length(setdiff(ARGS, "--prevol"))) refuser("--prevol : aucune autre option admise")
if (OPT_ESSAI && OPT_ECRIRE) refuser("--ecrire refuse sous --essai (sorties non versionnables)")
if (OPT_ESSAI && !is.na(OPT_NIVEAU)) refuser("--niveau : reserve a la mesure")
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (MODE == "mesure" && is.na(OPT_NIVEAU)) refuser("mesure : --niveau L-A, L-B ou L-C obligatoire (fixe par le pre-vol)")
if (MODE == "mesure" && !OPT_NIVEAU %in% c("L-A", "L-B", "L-C")) refuser("--niveau : L-A, L-B ou L-C")
OPT_BLOCS <- if (is.na(OPT_BLOC_TXT)) BLOCS_CONNUS else strsplit(OPT_BLOC_TXT, ",", fixed = TRUE)[[1]]
if (!length(OPT_BLOCS) || !all(OPT_BLOCS %in% BLOCS_CONNUS))
  refuser("--bloc : liste separee par des virgules parmi ", paste(BLOCS_CONNUS, collapse = ", "))
if (is.na(OPT_PROC) || OPT_PROC < 1L) refuser("--processus : entier >= 1")
if (.Platform$OS.type == "windows" && OPT_PROC > 1L) refuser("--processus > 1 : fork indisponible sous Windows")
if (is.na(OPT_DUREE_MAX) || OPT_DUREE_MAX <= 0) refuser("--duree-max : nombre d'heures > 0")

# --- Protocole (constantes, par. 3, 4, 6, 8, 9) -------------------------------
# B en double, comme le B par defaut de run_engine().
B_MESURE <- 999
B_ESSAI  <- 199
ALPHA_TESTS <- 0.10                                       # alpha des verdicts (chemin de .run_engine_mw())
SEUILS <- c(a05 = 0.05, a10 = 0.10)                       # par. 4 : alpha mesures
DELTA <- c(a05 = 0.010, a10 = 0.020)                      # par. 4 : marges d'equivalence (alpha / 5)
NIV_IC <- 0.90                                            # par. 4 : intervalle de Delta a 90 % (TOST a 5 %)
MARGE_K4 <- 0.02                                          # par. 4, K4
NIVEAU_HOLM <- 0.05
SEUIL_K0 <- 0.01                                          # par. 4, K0 : refus et p absentes
SEUIL_INV <- 0.995                                        # par. 4, K0 : invariance
MIN_SIGMA <- 20L                                          # intervalle si plus de 20 sigma* (#387)
CLES_V2 <- c("PenteIntra", "Alpha")                       # par. 0 et 2 : cles touchees par V2
GEOM <- data.frame(code = c("8x5", "8x6", "8x7"), J = c(4L, 5L, 6L), g = 1:3, stringsAsFactors = FALSE)
J_G <- stats::setNames(GEOM$J, GEOM$code); IDX_G <- stats::setNames(GEOM$g, GEOM$code)
LOIS <- c(N = 1L, E = 2L)
TAILLE_TRANCHE <- 100L
SEGMENT_S <- 1.8 * 3600                                   # PA-1 : segments de 1,8 h (M42 (b))
N_SEGMENTS_PA1 <- 13L                                     # PA-1 : 12 a 13 segments pour L-A
BUDGET_S <- N_SEGMENTS_PA1 * SEGMENT_S                    # budget de PA-1 (borne haute decidee)
K_BUDGET <- 4L
N0_MESURE <- 20000L; N0_ESSAI <- 100L; R_ESSAI <- 3L
K_BAL <- c(1e-8, 1e-6, 1e-4, 1e-2, 0.1, 0.3, 1, 3, 10)  # par. 5 (2)
RHO_S <- c(5e-13, 2e-12, 5e-12, 1e-11, 3e-11, 1e-10, 3e-10)  # par. 5 (1)
PLAGE_RHO_S <- c(1e-12, 1e-10)                            # plage sondee (bornes comprises)
# Par. 1 : sigma2_(J-1) de la regle au generateur (reserve2 tronque a G ;
# docs/tableaux/20261121-issue567-levee-mw04.md, l. 34) et sigma2_(J-1) vrai
# du plan.
S2_REGLE_SPEC <- c("8x5" = "0.684464", "8x6" = "0.141928", "8x7" = "0.030091")
S2_VRAI_SPEC <- c("8x5" = "0.314779", "8x6" = "0.0973248", "8x7" = "0.189674")
# Niveaux (par. 9) : triangles tires par loi et par bloc ; OR et OD : N0.
NIVEAUX <- list(
  "L-A" = list(M7a = c(N = 1000L, E = 1000L), M7b = c(N = 1000L, E = 1000L), M5 = c(N = 2000L, E = 2000L),
               M6 = c(N = 2000L, E = 2000L), C = c(N = 2000L, E = 2000L), D = c(N = 1000L, E = 1000L),
               BAL = c(N = 20L, E = 20L), S = 1L, OR = c(N = 20000L, E = 20000L), OD = c(N = 20000L, E = 20000L)),
  "L-B" = list(M7a = c(N = 1000L, E = 1000L), M7b = c(N = 1000L, E = 1000L), M5 = c(N = 2000L, E = 2000L),
               M6 = c(N = 2000L, E = 2000L), C = c(N = 1000L, E = 1000L), D = c(N = 0L, E = 1000L),
               BAL = c(N = 20L, E = 0L), S = 1L, OR = c(N = 20000L, E = 20000L), OD = c(N = 0L, E = 20000L)),
  "L-C" = list(M7a = c(N = 1000L, E = 1000L), M7b = c(N = 1000L, E = 1000L), M5 = c(N = 2000L, E = 2000L),
               M6 = c(N = 2000L, E = 2000L), C = c(N = 0L, E = 0L), D = c(N = 0L, E = 0L),
               BAL = c(N = 0L, E = 0L), S = 1L, OR = c(N = 20000L, E = 20000L), OD = c(N = 0L, E = 0L)))
DEBUT_BLOC <- c(OR = 1L, M7a = 1L, M7b = 1001L, M5 = 1L, M6 = 1L, C = 1L, OD = 1L, D = 1L, BAL = 1L, S = 1L)
G_BLOC <- list(OR = GEOM$code, M7a = "8x7", M7b = "8x7", M5 = "8x5", M6 = "8x6", C = "8x8", OD = "D", D = "8x6",
               BAL = GEOM$code, S = "-")
BLOCS_TRI <- c("M7a", "M7b", "M5", "M6", "C", "D")       # une ligne (ou deux) par triangle tire
BLOCS_567 <- c("M7a", "M5", "M6")                         # V0 lu dans le brut de #567
BLOCS_TRAPEZE <- c("M7a", "M7b", "M5", "M6")
# Graines (par. 6). Bases ecrites en entier. Reemploi declare des graines de
# #567 (triangles, bootstraps, oracle ; hors du controle de chevauchement
# avec #567) ; plage neuve d'A2 : 660 000 000 a 664 999 999.
GRAINE_TRI_567 <- 567000000; GRAINE_BOOT_567 <- 568000000; GRAINE_ORA_567 <- 570500000
GRAINE_BOOT_C <- 660000000
GRAINE_TRI_D <- 661000000; GRAINE_BOOT_D <- 661500000; GRAINE_ORA_D <- 662000000
GRAINE_SONDE <- 663000000
GRAINE_PV_TRI <- 664000000; GRAINE_PV_BOOT <- 664500000
graine_tri  <- function(loi, b) GRAINE_TRI_567 + 100000 * (LOIS[[loi]] - 1L) + b
graine_boot <- function(G, loi, b) GRAINE_BOOT_567 + 1000000 * (IDX_G[[G]] - 1L) + 100000 * (LOIS[[loi]] - 1L) + b
graine_tri_bloc <- function(bloc, loi, b) if (bloc %in% c("D", "OD")) GRAINE_TRI_D + 100000 * (LOIS[[loi]] - 1L) + b else graine_tri(loi, b)
graine_boot_bloc <- function(bloc, G, loi, b) switch(bloc,
  C = GRAINE_BOOT_C + 100000 * (LOIS[[loi]] - 1L) + b,
  D = GRAINE_BOOT_D + 100000 * (LOIS[[loi]] - 1L) + b,
  graine_boot(G, loi, b))
graine_ora <- function(cle, loi, k) (if (cle == "D") GRAINE_ORA_D else GRAINE_ORA_567) + 100000 * (LOIS[[loi]] - 1L) + k
graine_sonde <- function(u) GRAINE_SONDE + u
graine_pv_tri  <- function(u) GRAINE_PV_TRI + u
graine_pv_boot <- function(u) GRAINE_PV_BOOT + u
U_MAX_PV <- 50L; U_MAX_SONDE <- 50L; B_MAX_PLAN <- 2000L
# Plage reservee a A2 et plages des mesures anterieures (disjonction,
# controle (graines)) ; forme exacte PLAGE_<nom> <- c(L1, L2) (R21, #350).
PLAGE_A2_612 <- c(660000000, 664999999)
PLAGE_EXT_610 <- c(610000001, 644999999)    # #610 (dont la sous-plage du trapeze a 642 10^6)
PLAGE_EXT_206 <- c(20840001, 20960000)      # #206 et #297, Merz-Wuthrich
PLAGE_EXT_297LN <- c(20260831, 20262831)    # #297 lognormale
PLAGE_EXT_305 <- c(305000000, 305939169)    # #305
PLAGE_EXT_387 <- c(387000000, 393100000)    # #387
PLAGE_EXT_360 <- c(360380123, 360380123)    # graine 360 380 123
PLAGE_REEMPLOI_567 <- c(567000000, 572000000)
DECALAGE_LITTERAL <- 20000
PROTOCOLE <- "docs/revues/20261123-a2-creneau/actuary-1-protocole-612.md"
# md5 du protocole approuve a PA-1 (E-23/11 (PA-1)) : le controle (t),
# bloquant, exige ce md5 ET la presence a l'identique du par. 4 (correction
# C1 d'actuary-2-conformite-script-612.md) ; le md5 lu au T0 est en outre
# fixe dans le contexte des tranches et controle a la fin ((1) fin).
MD5_PROTOCOLE_PA1 <- "70176c2e3ded10922eeb81971b533ae7"
# md5 de R/engine.R a la mesure de #567 (T0 de TABLEAU_567) : cite par (r567),
# ou seule l'identite des nombres fait foi.
MD5_MOTEUR_567 <- "faf36c545999c147087759155a2bd38a"
SCRIPT_DEPOT <- "tests/simulation_jm1_trapeze_t8.R"
BRUT_567 <- "docs/tableaux/20261120-issue567-niveau-trapeze-mw-brut.tsv"
TABLEAU_567 <- "docs/tableaux/20261120-issue567-niveau-trapeze-mw.md"
BRUT_297 <- "docs/tableaux/20261026-issue297-calibration-famille-mw-brut.tsv"
MD5_ENTREES <- c(brut567 = "9fcb59cd24212f7f1c851e7634a34e3f", tableau567 = "adf5de226021c2521cb564757086e26b",
                 brut297 = "01325170c75ccc603707f96332dc1e96")
MD5_ORACLE_567 <- "5bdafe159cd5624fee6ba906896d4f40"
# Taux de MinP4 de #297 cites par le protocole (par. 5 (4)), a 0,10 / 0,05 :
# N 0,071 / 0,029 ; E 0,0785 / 0,0395 (controle (t297) sur le brut relu).
TAUX_297_SPEC <- list(N = c(a10 = "0.071", a05 = "0.029"), E = c(a10 = "0.0785", a05 = "0.0395"))

# Criteres et regles du par. 4 du protocole, reportes SANS MODIFICATION
# (controle (t) : presence a l'identique dans le protocole verse).
TEXTE_CRITERE_612 <- c(
  "> **Crit\u00e8re A2 / #612.** D = 1 si p_mc < \u03b1, \u03b1 \u2208 {0,05 ; 0,10} ; une p absente compte comme un non-rejet, compt\u00e9e \u00e0 part. T\u00e9moin : test id\u00e9al sur l'oracle de (G, \u2113), d\u00e9finition de #567 (K3). Pour deux d\u00e9cisions appari\u00e9es A et B sur les m\u00eames triangles : \u0394 = (n10 \u2212 n01)/n ; test de McNemar exact (binomial bilat\u00e9ral de param\u00e8tre 1/2 sur n10 + n01) ; intervalle exact conditionnel de \u0394 = (2\u03c0 \u2212 1)(n10 + n01)/n, \u03c0 par Clopper-Pearson sur n10 parmi n10 + n01. Marges d'\u00e9quivalence \u03b4_0,05 = 0,010 et \u03b4_0,10 = 0,020 (convention : \u03b1/5). \u00ab Align\u00e9 \u00bb : intervalle \u00e0 90 % de \u0394 inclus dans [\u2212\u03b4_\u03b1 ; +\u03b4_\u03b1] (\u00e9quivalence par deux tests unilat\u00e9raux \u00e0 5 %, Schuirmann 1987). Valeurs non arrondies ; aucune extension du nombre de triangles apr\u00e8s lecture ; un \u00ab non tranch\u00e9 \u00bb reste non tranch\u00e9.",
  "> - **K0 (int\u00e9grit\u00e9)** : tous les contr\u00f4les du \u00a7 8 OK ; refus et p absentes \u2264 1 % par (G, \u2113) ; invariance : p_mc des cl\u00e9s autres que PenteIntra et Alpha (autres que PenteIntra sur 8\u00d77) identiques entre V0 et V2 sur au moins 99,5 % des triangles de chaque (G, \u2113), \u00e9carts compt\u00e9s avec leur cause.",
  "> - **K1 (reproduction, confirmatoire)** : sur le 8\u00d77, b = 1001 \u00e0 2000, PenteIntra \u00e0 0,05, V0 contre t\u00e9moin, McNemar exact par loi, Holm sur les deux lois \u00e0 0,05 : \u00ab exc\u00e8s reproduit \u00bb si rejet avec \u0394 > 0 pour au moins une loi.",
  "> - **K2 (correction)** : sur le 8\u00d77, b \u2264 2000, PenteIntra, chaque loi et chaque \u03b1 : V2 align\u00e9 sur le t\u00e9moin (K2a) **ou** sur le carr\u00e9 8\u00d78 des m\u00eames triangles (K2b). K2 tenu si les quatre cellules le sont.",
  "> - **K2\u2032 (am\u00e9lioration partielle)** : sur le 8\u00d77, PenteIntra, V2 contre V0 (m\u00eames graines), McNemar exact unilat\u00e9ral vers moins de rejets, Holm sur les quatre cellules \u00e0 0,05 : au moins une cellule significative, et aucune cellule o\u00f9 |\u0394\u0302_V2| > |\u0394\u0302_V0|.",
  "> - **K3 (non-d\u00e9gradation)** : sur 8\u00d75 et 8\u00d76, PenteIntra et Alpha, chaque loi et chaque \u03b1 (16 cellules) : V2 align\u00e9 sur le t\u00e9moin, **ou** |\u0394\u0302_V2| \u2264 |\u0394\u0302_V0| + \u03b4_\u03b1/2 ; et aucune cellule o\u00f9 \u03c4_V2 est en distorsion mat\u00e9rielle (classes de #567) alors que \u03c4_V0 ne l'est pas. K3 tenu si les 16 cellules le sont.",
  "> - **K4 (couverture, comparative)** : intervalle percentile \u00e0 90 %, cible \u03c3_A^r\u00e8gle, chaque (G, \u2113) des trois trap\u00e8zes : borne haute de l'intervalle \u00e0 90 % de la diff\u00e9rence appari\u00e9e des taux de non-couverture (V2 \u2212 V0) \u2264 +0,02. Le 95 %, les queues s\u00e9par\u00e9es, \u03c3_A^vrai et \u03c3_B sont descriptifs.",
  ">",
  "> **R\u00e8gles** (\u00e9valu\u00e9es m\u00e9caniquement par le script, sans conclure ; lecture par `actuary` \u00e0 l'\u00e9tape 4, d\u00e9cision du mainteneur \u00e0 PA-2) :",
  "> - **R0** : K0 en d\u00e9faut \u2192 lecture suspendue, aucune recommandation.",
  "> - **R-V2** : K1, K2, K3, K4 tenus \u2192 simuler J\u22121 avec l'estimateur direct (V2).",
  "> - **R-V2\u2032** : K1, K2\u2032, K3, K4 tenus, K2 non tenu \u2192 V2 recommand\u00e9e comme am\u00e9lioration, la r\u00e9serve PenteIntra restant \u00e9crite sur le 8\u00d77.",
  "> - **R-V1** : K1, (K2 ou K2\u2032), K3 tenus, K4 en d\u00e9faut \u2192 V1 (tests de V2, \u03c3_boot de V0), prototyp\u00e9e hors moteur avant toute impl\u00e9mentation (contrat partag\u00e9).",
  "> - **R-V0** : K2 et K2\u2032 en d\u00e9faut, ou K3 en d\u00e9faut \u2192 Q-2a-2 confirm\u00e9e, r\u00e9serves des fiches reprises avec les nouveaux chiffres.",
  "> - **D\u00e9faut** : toute autre combinaison, K1 en d\u00e9faut compris, est \u00ab non tranch\u00e9e \u00bb \u2192 V0 par d\u00e9faut, les deux lectures sont port\u00e9es au mainteneur.",
  ">",
  "> **Statut \u00e9pist\u00e9mique** : constat de simulation sous un plan (mod\u00e8le de Mack ajust\u00e9 \u00e0 `reserve2`, T = I + 1 = 8, lois N et E, B = 999), conditionnel \u00e0 l'admission ; aucun th\u00e9or\u00e8me ne couvre ces tests bootstrap ni cet intervalle \u00e0 T = 8 ; rien ne se transpose \u00e0 d'autres param\u00e8tres ni \u00e0 d'autres g\u00e9om\u00e9tries.")
TEXTE_STATUT_612 <- sub("^> ", "", TEXTE_CRITERE_612[length(TEXTE_CRITERE_612)])

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
ENV_MOTEUR <- environment(run_engine)
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
FAM <- c("M1", "M2", "M3", "M4", PREFIXE_LECTURE_CONJOINTE)
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))
# Cles dont la p_mc doit etre invariante entre V0 et V2 (par. 4, K0).
cles_libres <- function(G) if (G == "8x7") setdiff(CLES, "PenteIntra") else setdiff(CLES, CLES_V2)

# --- Outils de forme (copies de tests/niveau_mw_trapeze_t8.R) -----------------
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
D_IC <- 5L
txt_ic <- function(ci, d = D_IC) if (length(ci) != 2L || anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
fmt_p <- function(p) if (length(p) != 1L || !is.finite(p)) "\u2014" else sub(".", ",", sprintf("%.3g", p), fixed = TRUE)
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
md5_texte <- function(x) {
  f <- tempfile("md5_"); on.exit(unlink(f))
  ecrire_fichier(f, x)
  unname(tools::md5sum(f))
}
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
# git diff --quiet HEAD -- R/engine.R : TRUE si la copie de travail de
# R/engine.R est identique a HEAD (par. 8, controle (1)).
moteur_sans_diff <- function() {
  s <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RACINE), "diff", "--quiet", "HEAD", "--", "R/engine.R"),
                                         stdout = FALSE, stderr = FALSE)), error = function(e) 2L)
  identical(as.integer(s), 0L)
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
args_cites <- function() {
  a <- ARGS
  i <- match("--travail", a); if (!is.na(i)) a[i + 1L] <- "(dossier hors du d\u00e9p\u00f4t)"
  if (length(a)) paste(a, collapse = " ") else "(aucun)"
}
present_bloc <- function(bloc, txt) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
ligne_vide <- function(cols) stats::setNames(as.list(rep(NA, length(cols))), cols)
oui_non <- function(b) if (isTRUE(b)) "oui" else if (isFALSE(b)) "non" else "non \u00e9valuable"

# --- Contexte au debut du calcul (controle (1)) ------------------------------
MD5_MOTEUR_DEBUT <- md5_fichier(file.path(RACINE, "R", "engine.R"))
MD5_PROTOCOLE_T0 <- md5_fichier(file.path(RACINE, PROTOCOLE))
DIFF_MOTEUR_DEBUT <- moteur_sans_diff()
SHA_DEBUT <- sha_head()
COMMIT_DEBUT <- commit_depot(SCRIPT_DEPOT)
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
EMPREINTE_DEBUT <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
PLATEFORME <- plateforme_calcul()
EMPREINTES <- empreintes_code()
PLATEFORME_567 <- "R version 4.3.3 (2024-02-29) ; Ubuntu 24.04.5 LTS ; Linux, x86_64 ; BLAS : libblas.so.3.12.0 ; LAPACK : liblapack.so.3.12.0 (version 3.12.0)"

###############################################################################
#  SUBSTITUTIONS (par. 2 et 8 ; ADR 0016) : toutes dans environment(run_engine)
###############################################################################
NOMS_SUBST <- c(".mw_simulation_sigma_direct", ".mw_tirer_triangle_valide", "mw_residus")
ORIG_SUBST <- lapply(stats::setNames(nm = NOMS_SUBST), function(n) get(n, envir = ENV_MOTEUR, inherits = FALSE))
# Pose f a la place de nom dans l'environnement du moteur, evalue expr, puis
# restaure l'objet d'origine (on.exit) et verifie la restauration par
# identical() ; une substitution non restauree (imbrication sur le meme nom)
# leve une erreur avant la pose.
substituer <- function(nom, f, expr) {
  orig <- ORIG_SUBST[[nom]]
  if (!identical(get(nom, envir = ENV_MOTEUR, inherits = FALSE), orig))
    stop("substitution de ", nom, " deja en place (non restauree)")
  assign(nom, f, envir = ENV_MOTEUR)
  on.exit({
    assign(nom, orig, envir = ENV_MOTEUR)
    if (!identical(get(nom, envir = ENV_MOTEUR, inherits = FALSE), orig)) stop("restauration de ", nom, " en echec")
  }, add = TRUE)
  force(expr)
}
substitutions_restaurees <- function()
  all(vapply(NOMS_SUBST, function(n) identical(get(n, envir = ENV_MOTEUR, inherits = FALSE), ORIG_SUBST[[n]]), logical(1)))
# V2 : corps impose du par. 2, environnement du moteur.
F_V2 <- function(aj) !is.null(aj[["sigma2_Jm1_direct"]]) && !.mw_colonne_degeneree(aj, aj$J - 1L)
environment(F_V2) <- ENV_MOTEUR
avec_variante <- function(v, expr) if (identical(v, "V2")) substituer(".mw_simulation_sigma_direct", F_V2, expr) else force(expr)
# Predicat courant (substitution comprise) de l'environnement du moteur.
sim_dir_env <- function(aj) isTRUE(get(".mw_simulation_sigma_direct", envir = ENV_MOTEUR, inherits = FALSE)(aj))
# Balayage (par. 5 (2)) : enveloppe de .mw_tirer_triangle_valide() qui pose
# aj$sigma2[aj$J] <- k * sigma2 direct (point k) ou la valeur v donnee (point
# "regle") avant l'appel d'origine ; diagnostic seulement.
f_tirer_k <- function(k) {
  e <- new.env(parent = ENV_MOTEUR); e$orig <- ORIG_SUBST[[".mw_tirer_triangle_valide"]]; e$k <- k
  f <- function(aj, pool, reste) { aj$sigma2[aj$J] <- k * aj$sigma2_Jm1_direct; orig(aj, pool, reste) }
  environment(f) <- e; f
}
f_tirer_valeur <- function(v) {
  e <- new.env(parent = ENV_MOTEUR); e$orig <- ORIG_SUBST[[".mw_tirer_triangle_valide"]]; e$v <- v
  f <- function(aj, pool, reste) { aj$sigma2[aj$J] <- v; orig(aj, pool, reste) }
  environment(f) <- e; f
}
# Sonde (par. 5 (1)) : enveloppe de mw_residus() qui compte les appels ou une
# colonne j hors de l'ensemble exclu (j_degeneres, ou celui de aj), degeneree
# au sens de .mw_colonne_degeneree(aj, j), au moins deux facteurs, garde
# s2 > 0 fini, donc ses residus ; et, en mode "P1", exclut
# union(jd, .mw_colonnes_degenerees(aj)) (prototype P1). Les appels sur le
# triangle observe (aj$tri identical() a cpt$tri_obs, pose par une_sonde())
# sont comptes a part (obs_appels, obs_touche) ; les autres le sont par
# replication : triangles successifs distincts (n_triangles : replications
# ajustees, chacune passant par .mw_stats() -> .mw_contexte_mc() ->
# mw_residus() dans mw_bootstrap()) et ceux ou au moins un appel est touche
# (tri_touches). Part touchee (R5) : tri_touches / triangles, triangle
# observe exclu.
f_residus_sonde <- function(mode, cpt) {
  e <- new.env(parent = ENV_MOTEUR); e$orig <- ORIG_SUBST[["mw_residus"]]; e$mode <- mode; e$cpt <- cpt
  f <- function(aj, j_degeneres = NULL) {
    jd <- .mw_j_exclues(aj, j_degeneres)
    deg <- .mw_colonnes_degenerees(aj)
    s2 <- .mw_sigma2_residus(aj)
    cand <- setdiff(deg, jd)
    touche <- any(vapply(cand, function(j) aj$I - j >= 2 && is.finite(s2[j + 1L]) && s2[j + 1L] > 0, logical(1)))
    if (!is.null(cpt$tri_obs) && identical(aj$tri, cpt$tri_obs)) {
      cpt$obs_appels <- cpt$obs_appels + 1L
      if (touche) cpt$obs_touche <- TRUE
    } else {
      cpt$appels <- cpt$appels + 1L
      if (!identical(aj$tri, cpt$dernier)) { cpt$dernier <- aj$tri; cpt$triangles <- cpt$triangles + 1L; cpt$marque <- FALSE }
      if (touche) {
        cpt$touches <- cpt$touches + 1L
        if (!cpt$marque) { cpt$tri_touches <- cpt$tri_touches + 1L; cpt$marque <- TRUE }
      }
    }
    if (identical(mode, "P1")) orig(aj, union(jd, deg)) else orig(aj, j_degeneres)
  }
  environment(f) <- e; f
}
nouveau_compteur <- function(tri_obs = NULL) { e <- new.env(); e$appels <- 0L; e$touches <- 0L; e$triangles <- 0L; e$tri_touches <- 0L
  e$dernier <- NULL; e$marque <- FALSE; e$tri_obs <- tri_obs; e$obs_appels <- 0L; e$obs_touche <- FALSE; e }
corps_txt <- function(f) paste(trimws(deparse(f, width.cutoff = 500L)), collapse = " ")
CORPS_SUBST <- c(V2 = corps_txt(F_V2), balayage_k = corps_txt(f_tirer_k(1)), balayage_regle = corps_txt(f_tirer_valeur(0)),
                 sonde = corps_txt(f_residus_sonde("courant", nouveau_compteur())))

###############################################################################
#  DGP, LOIS, GENERATEUR, ADMISSION (par. 3 ; copies de #567)
###############################################################################
AJ8 <- mw_ajuster(.tri)
JD8 <- .mw_colonnes_degenerees(AJ8)
POOL0 <- .mw_pool_residus(AJ8, JD8)
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
POOL_E <- POOL0 / SD_POP0
dgp_G <- function(J) list(I = AJ8$I, J = J, tri = AJ8$tri[, seq_len(J + 1L), drop = FALSE],
                          f = AJ8$f[seq_len(J)], sigma2 = AJ8$sigma2[seq_len(J)])
DGP <- lapply(stats::setNames(GEOM$J, GEOM$code), dgp_G)
# Bloc D (plan d'actuary-10) : 8 x 6 de #567, sigma2_2 := 0 (colonne J-3
# deterministe, j = 2).
DGP_D <- DGP[["8x6"]]; DGP_D$sigma2[3L] <- 0
S2_VRAI <- vapply(GEOM$code, function(G) DGP[[G]]$sigma2[J_G[[G]]], 1)
TIREURS <- list(N = function(n) stats::rnorm(n), E = function(n) sample(POOL_E, n, replace = TRUE))
dgp_cle <- function(cle) switch(cle, D = DGP_D, "8x8" = AJ8, DGP[[cle]])
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
triangle_cle <- function(cle, loi, graine) engine_sous_graine(graine, gen_triangle_h0(dgp_cle(cle), TIREURS[[loi]]))
triangle_8 <- function(loi, graine) triangle_cle("8x8", loi, graine)
# Admission (par. 3, P1 de #567 adaptee a la levee de MW-04) : cellule a NA
# ou cumul <= 0 ; toute erreur de mw_valider_triangle() ; domaine numerique ;
# erreur de mw_ajuster() ou de mw_msep() ; refus M4. L'avertissement de
# geometrie n'est pas un motif.
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, code = "cellule", motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = 1, annexe = "II")
  if (!isTRUE(v$ok)) return(list(ok = FALSE, code = "triangle", motif = nettoyer_champ(paste("mw_valider_triangle :", paste(v$erreurs, collapse = " ; ")))))
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
  list(ok = TRUE, code = "-", motif = NA_character_, aj = aj, msep = ms$msep)
}
stats_oracle <- function(aj) .mw_stats(aj, .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj)))
msep_avec_s2 <- function(aj, v) {
  if (is.null(v) || !is.finite(v)) return(NA_real_)
  a <- aj; J <- aj$J
  a$sigma2[J] <- v; a$Q[J] <- v / a$f[J]^2
  tryCatch(mw_msep(a)$msep, error = function(e) NA_real_)
}
msep_direct <- function(aj) msep_avec_s2(aj, aj$sigma2_Jm1_direct)
# Boucle allegee (copie adaptee de tests/couverture_ic_sigma_mw_t8.R, #387) :
# memes tirages que mw_bootstrap(), dans le meme ordre, sous la meme graine,
# SANS .mw_stats() ni p-value ; la copie aj_sim de mw_bootstrap() (constat M-1
# de #567, option (b)) est reproduite par le predicat de l'environnement du
# moteur, substitution V2 comprise ; .mw_tirer_triangle_valide() est lue dans
# l'environnement du moteur. Rend sigma* aligne sur b.
boucle_allegee <- function(aj, B, seed, figes) {
  tirer <- get(".mw_tirer_triangle_valide", envir = ENV_MOTEUR, inherits = FALSE)
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, figes$degeneres)
    aj_sim <- aj
    if (sim_dir_env(aj)) aj_sim$sigma2[aj$J] <- aj$sigma2_Jm1_direct
    n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1)
    n_tires <- 0; retires <- FALSE; plafond <- FALSE
    sig <- rep(NA_real_, B)
    for (b in seq_len(B)) {
      tir <- tirer(aj_sim, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (tir$rejets > 0) retires <- TRUE
      if (is.null(tir$tri)) { plafond <- TRUE; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) next
      mb <- try(mw_msep(ab), silent = TRUE)
      if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0)
        sig[b] <- sqrt(mb$msep) / ab$reserve
    }
    list(sig = sig, retires = retires, plafond = plafond)
  })
}
# sigma_B (#387, P3) : copie de l'ajustement aj avec f <- f, sigma2 <- s2.
recomposer <- function(aj, f, s2) {
  I <- aj$I; J <- aj$J
  Ch <- aj$tri
  for (i in 0:I) {
    d <- I - i
    if (d < J) for (j in (d + 1):J)
      Ch[i + 1, j + 1] <- Ch[i + 1, j] * f[j]
  }
  a <- aj
  a$f <- f; a$sigma2 <- s2; a$Q <- s2 / f^2; a$C_chapeau <- Ch
  a$ultime <- Ch[, J + 1]
  a$reserve_par_annee <- a$ultime - aj$dernier_observe
  a$reserve <- sum(a$ultime - aj$dernier_observe)
  a
}
# Cibles de couverture (par. 1) : sigma_A^regle(G) = sqrt(MSEP)/R du
# generateur (reserve2 tronque a G, regle appliquee) ; sigma_A^vrai(G) : MSEP
# avec le vrai sigma2_(J-1) du plan (DGP).
CIBLES_COUV <- lapply(stats::setNames(nm = GEOM$code), function(G) {
  aj <- mw_ajuster(.tri[, seq_len(J_G[[G]] + 1L)]); ms <- mw_msep(aj)$msep
  mv <- msep_avec_s2(aj, S2_VRAI[[G]])
  list(regle = sqrt(ms) / aj$reserve, vrai = sqrt(mv) / aj$reserve, s2_regle = aj$sigma2[aj$J])
})
SIGMA_A_REGLE <- vapply(CIBLES_COUV, function(x) x$regle, 1)
SIGMA_A_VRAI <- vapply(CIBLES_COUV, function(x) x$vrai, 1)
S2_REGLE_GEN <- vapply(CIBLES_COUV, function(x) x$s2_regle, 1)

###############################################################################
#  ENTREES : BRUT DE #567, TABLEAU DE #567, BRUT DE #297
###############################################################################
lire_brut <- function(rel) {
  f <- file.path(RACINE, rel)
  if (!file.exists(f)) return(NULL)
  utils::read.delim(f, colClasses = "character", check.names = FALSE, quote = "", comment.char = "",
                    na.strings = character(0), stringsAsFactors = FALSE)
}
BR567 <- lire_brut(BRUT_567)
BR567_IDX <- if (is.null(BR567)) integer(0) else stats::setNames(seq_len(nrow(BR567)), paste(BR567$G, BR567$loi, BR567$b))
ligne_567 <- function(G, loi, b) { i <- BR567_IDX[paste(G, loi, b)]; if (length(i) != 1L || is.na(i)) NULL else BR567[i, , drop = FALSE] }
BR297 <- lire_brut(BRUT_297)
fv <- function(v) if (is.null(v) || length(v) != 1L || is.na(v)) "NA" else sprintf("%.17g", as.numeric(v))
nv <- function(s) suppressWarnings(as.numeric(s))
fv_vec <- function(x) vapply(x, fv, "")

###############################################################################
#  UN TRIANGLE, UN ORACLE, UN POINT DU BALAYAGE, UNE SONDE
###############################################################################
COLONNES <- c("bloc", "G", "loi", "b", "variante", "origine", "g_tri", "g_boot", "statut", "motif_code", "gp", "jd",
              "R_hat", "msep", "msep_dir", "sigma_hat", "sigma_B", "s2_regle", "s2_dir", "r", "sim_dir", "sim_dir_v2",
              "q025", "q05", "q50", "q95", "q975", "n_sigma", "n_sans_sigma", "cumuls_retires", "plafond", "B_eff_min",
              "ctl", "r567", "al", "o8", "i1",
              paste0("obs:", CLES), paste0("p:", CLES), paste0("m:", CLES), paste0("pf:", FAM), "message", "duree_s")
COL_TEXTE <- c("bloc", "G", "loi", "variante", "origine", "statut", "motif_code", "jd", "message", paste0("m:", CLES))
COLONNES_BRUT <- c(setdiff(COLONNES, "duree_s"), paste0("pT:", CLES))
COLONNES_ORA <- c("G", "loi", "k", "g_tri", "statut", "motif_code", paste0("obs:", CLES), "duree_s")
COL_TEXTE_ORA <- c("G", "loi", "statut", "motif_code")
COLONNES_BAL <- c("G", "loi", "b", "g_tri", "g_boot", "point", "k", "s2_pose", "statut", "motif_code", "s2_regle", "s2_dir",
                  "sim_dir", "sim_dir_v2", "cumuls_retires", "plafond", "B_eff_min", "n_sigma", "q05", "q95",
                  paste0("p:", CLES), "message", "duree_s")
COL_TEXTE_BAL <- c("G", "loi", "point", "statut", "motif_code", "message")
COLONNES_S <- c("cfg", "base", "jstar", "rho", "u", "graine", "variante", "mode", "statut", "jd", "deg_jstar",
                "n_appels", "n_touches", "n_triangles", "n_tri_touches", "obs_appels", "obs_touche", "B_eff_min",
                paste0("obs:", CLES), paste0("p:", CLES), paste0("err:", CLES), "message", "duree_s")
COL_TEXTE_S <- c("base", "variante", "mode", "statut", "jd", "message")
variantes_bloc <- function(bloc) if (bloc %in% c("C", "D")) "V0" else c("V2", "V0")
origine_v <- function(bloc, v) if (v == "V0" && bloc %in% BLOCS_567 && !OPT_ESSAI) "brut567" else "calcul"
cle_triangle <- function(bloc, G) if (bloc == "D") "D" else G
# Remplit une ligne a partir d'un bootstrap et des tests du moteur.
remplir_bt <- function(L, bt, ts) {
  L$n_sans_sigma <- if (is.null(bt$n_sans_sigma)) NA_real_ else as.numeric(bt$n_sans_sigma)
  L$cumuls_retires <- as.integer(isTRUE(bt$cumuls_retires)); L$plafond <- as.integer(isTRUE(bt$plafond_cumuls))
  L$B_eff_min <- min(unlist(bt$B_effectif[CLES]))
  L <- remplir_sigma(L, bt$sigma_boot)
  for (k in CLES) {
    L[[paste0("obs:", k)]] <- unname(bt$stats_obs[[k]]); L[[paste0("p:", k)]] <- unname(bt$p_mc[[k]])
    L[[paste0("m:", k)]] <- unname(code_motif(bt$motif_mc[[k]]))
  }
  if (!is.null(ts)) {
    fo <- vapply(ts, function(l) if (is.null(l$fonction)) "" else as.character(l$fonction), "")
    pref <- substr(vapply(ts, function(l) as.character(l$famille), ""), 1L, 2L)
    for (f in FAM) {
      i <- which(fo == "engine_p_famille" & pref == f)
      L[[paste0("pf:", f)]] <- if (length(i) == 1L && is.finite(ts[[i]]$p_mc)) ts[[i]]$p_mc else NA_real_
    }
  }
  L
}
remplir_sigma <- function(L, s) {
  s <- s[is.finite(s)]
  L$n_sigma <- length(s)
  q <- if (length(s) > MIN_SIGMA) stats::quantile(s, c(.025, .05, .5, .95, .975), type = 7, names = FALSE) else rep(NA_real_, 5L)
  L$q025 <- q[1]; L$q05 <- q[2]; L$q50 <- q[3]; L$q95 <- q[4]; L$q975 <- q[5]
  L
}
# V0 lu dans le brut de #567 (blocs M7a, M5, M6 en mesure).
remplir_567 <- function(L, br) {
  L$n_sans_sigma <- nv(br$n_sans_sigma); L$cumuls_retires <- nv(br$cumuls_retires); L$plafond <- nv(br$plafond)
  L$B_eff_min <- nv(br$B_eff_min)
  for (k in CLES) {
    L[[paste0("obs:", k)]] <- nv(br[[paste0("obs:", k)]]); L[[paste0("p:", k)]] <- nv(br[[paste0("p:", k)]])
    m <- br[[paste0("m:", k)]]; L[[paste0("m:", k)]] <- if (identical(m, "NA")) NA_character_ else m
  }
  for (f in FAM) L[[paste0("pf:", f)]] <- nv(br[[paste0("pf:", f)]])
  L
}
# (r567) : V0 recalcule identique au brut de #567 relu en %.17g (13 p_mc,
# obs, s2_regle, s2_dir, R_hat, msep).
comparer_567 <- function(aj, msep, bt, br) {
  if (is.null(br)) return(FALSE)
  s2d <- if (is.null(aj$sigma2_Jm1_direct)) NA_real_ else aj$sigma2_Jm1_direct
  neuf <- c(vapply(CLES, function(k) fv(bt$p_mc[[k]]), ""), vapply(CLES, function(k) fv(bt$stats_obs[[k]]), ""),
            fv(aj$sigma2[aj$J]), fv(s2d), fv(aj$reserve), fv(msep))
  ancien <- c(unlist(br[1, paste0("p:", CLES)]), unlist(br[1, paste0("obs:", CLES)]), br$s2_regle, br$s2_dir, br$R_hat, br$msep)
  identical(unname(neuf), unname(as.character(ancien)))
}
calcul <- function(aj, figes, B, graine, v, tests = TRUE) avec_variante(v, {
  bt <- mw_bootstrap(aj, B = B, seed = graine, figes = figes)
  ts <- if (tests) mw_tests(aj, bt, ALPHA_TESTS, figes = figes) else NULL
  list(bt = bt, ts = ts)
})

# Lignes du triangle b de (bloc, G, loi) : une par variante (V2 puis V0 ; C et
# D : V0 seul, la simulation etant la meme sous V2, colonnes sim_dir et
# sim_dir_v2). ctl : premier triangle admis de la tranche (controles (r567),
# (al), (i1)).
un_triangle <- function(bloc, G, loi, b, B, ctl = FALSE, g_tri = graine_tri_bloc(bloc, loi, b),
                        g_boot = graine_boot_bloc(bloc, G, loi, b)) {
  t1 <- proc.time()[["elapsed"]]
  vars <- variantes_bloc(bloc)
  L <- ligne_vide(COLONNES)
  L$bloc <- bloc; L$G <- G; L$loi <- loi; L$b <- b; L$g_tri <- g_tri; L$g_boot <- g_boot; L$motif_code <- "-"; L$ctl <- as.integer(ctl)
  LV <- stats::setNames(lapply(vars, function(v) { x <- L; x$variante <- v; x$origine <- origine_v(bloc, v); x }), vars)
  admission_passee <- FALSE
  fin <- function(statut = NULL, code = "-", msg = NA_character_) {
    d <- proc.time()[["elapsed"]] - t1
    lapply(vars, function(v) { x <- LV[[v]]
      if (!is.null(statut)) { x$statut <- statut; x$motif_code <- code; if (!is.na(msg)) x$message <- msg }
      x$duree_s <- d; x })
  }
  pose <- function(nom, val) for (v in vars) LV[[v]][[nom]] <<- val
  tryCatch({
    cle <- cle_triangle(bloc, G)
    tri <- triangle_cle(cle, loi, g_tri)
    if (bloc %in% BLOCS_TRAPEZE) {
      t8 <- triangle_8(loi, g_tri)
      pose("gp", as.integer(identical(tri, t8[, seq_len(J_G[[G]] + 1L), drop = FALSE])))
    }
    ad <- admettre(tri)
    if (!ad$ok) return(fin("refus", ad$code, ad$motif))
    admission_passee <- TRUE
    aj <- ad$aj; figes <- .mw_ensembles_figes(aj)
    s2d <- if (is.null(aj$sigma2_Jm1_direct)) NA_real_ else aj$sigma2_Jm1_direct
    dg <- dgp_cle(cle)
    aB <- recomposer(aj, dg$f, dg$sigma2)
    mB <- tryCatch(mw_msep(aB)$msep, error = function(e) NA_real_)
    pose("R_hat", aj$reserve); pose("msep", ad$msep); pose("msep_dir", msep_direct(aj))
    pose("sigma_hat", sqrt(ad$msep) / aj$reserve)
    pose("sigma_B", if (is.finite(aB$reserve) && aB$reserve > 0 && is.finite(mB) && mB >= 0) sqrt(mB) / aB$reserve else NA_real_)
    pose("s2_regle", aj$sigma2[aj$J]); pose("s2_dir", s2d); pose("r", aj$sigma2[aj$J] / s2d)
    pose("jd", if (length(figes$degeneres)) paste(figes$degeneres, collapse = ",") else "-")
    pose("sim_dir", as.integer(sim_dir_env(aj))); pose("sim_dir_v2", as.integer(avec_variante("V2", sim_dir_env(aj))))
    BT <- list()
    for (v in vars) {
      if (LV[[v]]$origine == "brut567") {
        br <- ligne_567(G, loi, b)
        if (is.null(br)) { LV[[v]]$statut <- "echec"; LV[[v]]$message <- "ligne absente du brut de #567"; next }
        LV[[v]] <- remplir_567(LV[[v]], br)
        lg <- boucle_allegee(aj, B, g_boot, figes)
        LV[[v]] <- remplir_sigma(LV[[v]], lg$sig)
        BT$lg0 <- lg
        LV[[v]]$statut <- "admis"
      } else {
        r <- tryCatch(calcul(aj, figes, B, g_boot, v), error = function(e) e)
        if (inherits(r, "error")) { LV[[v]]$statut <- "echec"; LV[[v]]$message <- nettoyer_champ(paste("bootstrap ou tests en erreur :", conditionMessage(r))); next }
        LV[[v]] <- remplir_bt(LV[[v]], r$bt, r$ts)
        BT[[v]] <- r$bt
        LV[[v]]$statut <- "admis"
      }
    }
    if (bloc == "C") {
      t7 <- tri[, 1:7, drop = FALSE]
      o8 <- NA_real_
      if (!.mw_triangle_incomplet(t7) && !is.null(BT$V0)) {
        a7 <- tryCatch(mw_ajuster(t7), error = function(e) NULL)
        if (!is.null(a7)) {
          o7 <- tryCatch(as.list(.mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(a7, .mw_ensembles_figes(a7), new.env(parent = emptyenv())))),
                         error = function(e) NULL)
          o8 <- if (is.null(o7)) NA_real_ else as.numeric(identical(BT$V0$stats_obs, o7))
        }
      }
      pose("o8", o8)
    }
    if (ctl) {
      bt1 <- if (!is.null(BT$V2)) BT$V2 else BT$V0
      if (!is.null(bt1)) pose("i1", as.integer(identical(unname(stats_oracle(aj)[CLES]), unname(unlist(bt1$stats_obs)[CLES]))))
      # (al) : boucle allegee contre mw_bootstrap(), V2 et V0.
      if (!is.null(BT$V2)) {
        lg2 <- avec_variante("V2", boucle_allegee(aj, B, g_boot, figes))
        LV$V2$al <- as.integer(identical(lg2$sig[is.finite(lg2$sig)], BT$V2$sigma_boot))
      }
      if ("V0" %in% vars && !is.null(BT$V0)) {
        lg0 <- boucle_allegee(aj, B, g_boot, figes)
        LV$V0$al <- as.integer(identical(lg0$sig[is.finite(lg0$sig)], BT$V0$sigma_boot))
      }
      # (r567) : V0 recalcule a B = 999 sur le premier triangle admis de la
      # tranche de #567, compare au brut ; en mesure, ce bootstrap sert aussi
      # a (al) pour V0 (boucle allegee de la ligne).
      if (bloc %in% BLOCS_567) {
        b999 <- tryCatch(calcul(aj, figes, B_MESURE, g_boot, "V0", tests = FALSE)$bt, error = function(e) NULL)
        LV$V0$r567 <- as.integer(!is.null(b999) && comparer_567(aj, ad$msep, b999, ligne_567(G, loi, b)))
        if (!is.null(BT$lg0) && !is.null(b999) && B == B_MESURE)
          LV$V0$al <- as.integer(identical(BT$lg0$sig[is.finite(BT$lg0$sig)], b999$sigma_boot))
      }
    }
    fin()
  }, error = function(e) if (admission_passee) fin("echec", "-", nettoyer_champ(conditionMessage(e))) else
    fin("refus", "erreur", nettoyer_champ(paste("erreur avant l'admission :", conditionMessage(e)))))
}
# Triangle k de l'oracle de cle (8x5, 8x6, 8x7 ou D) : admission, puis
# statistiques par le chemin de l'oracle.
un_oracle <- function(cle, loi, k, graine = graine_ora(cle, loi, k)) {
  t1 <- proc.time()[["elapsed"]]
  L <- ligne_vide(COLONNES_ORA)
  L$G <- cle; L$loi <- loi; L$k <- k; L$g_tri <- graine; L$motif_code <- "-"
  ad <- tryCatch(admettre(triangle_cle(cle, loi, graine)), error = function(e) list(ok = FALSE, code = "erreur"))
  if (!ad$ok) { L$statut <- "refus"; L$motif_code <- ad$code } else {
    so <- tryCatch(stats_oracle(ad$aj), error = function(e) NULL)
    L$statut <- if (is.null(so)) "echec" else "admis"
    if (!is.null(so)) for (s in CLES) L[[paste0("obs:", s)]] <- unname(so[[s]])
  }
  L$duree_s <- proc.time()[["elapsed"]] - t1
  L
}
# Balayage (par. 5 (2)) : triangle b de (G, loi), memes graines que M ; un
# point par k, plus le point "regle" (sigma2 pose a la valeur de la regle,
# controle (bal)).
POINTS_BAL <- c(sprintf("k=%g", K_BAL), "regle")
un_balayage <- function(G, loi, b, B) {
  t1 <- proc.time()[["elapsed"]]
  g_tri <- graine_tri(loi, b); g_boot <- graine_boot(G, loi, b)
  base <- ligne_vide(COLONNES_BAL)
  base$G <- G; base$loi <- loi; base$b <- b; base$g_tri <- g_tri; base$g_boot <- g_boot; base$motif_code <- "-"
  lignes <- lapply(seq_along(POINTS_BAL), function(i) { x <- base; x$point <- POINTS_BAL[i]; x$k <- if (i <= length(K_BAL)) K_BAL[i] else NA_real_; x })
  fin <- function(statut, code = "-", msg = NA_character_) {
    d <- proc.time()[["elapsed"]] - t1
    lapply(lignes, function(x) { x$statut <- statut; x$motif_code <- code; x$message <- msg; x$duree_s <- d / length(lignes); x })
  }
  res <- tryCatch({
    ad <- admettre(triangle_cle(G, loi, g_tri))
    if (!ad$ok) return(fin("refus", ad$code, ad$motif))
    aj <- ad$aj; figes <- .mw_ensembles_figes(aj)
    s2r <- aj$sigma2[aj$J]; s2d <- aj$sigma2_Jm1_direct
    s0 <- as.integer(sim_dir_env(aj)); s2 <- as.integer(avec_variante("V2", sim_dir_env(aj)))
    for (i in seq_along(lignes)) {
      x <- lignes[[i]]
      x$s2_regle <- s2r; x$s2_dir <- s2d; x$sim_dir <- s0; x$sim_dir_v2 <- s2
      f <- if (i <= length(K_BAL)) f_tirer_k(K_BAL[i]) else f_tirer_valeur(s2r)
      x$s2_pose <- if (i <= length(K_BAL)) K_BAL[i] * s2d else s2r
      bt <- tryCatch(substituer(".mw_tirer_triangle_valide", f, mw_bootstrap(aj, B = B, seed = g_boot, figes = figes)), error = function(e) e)
      if (inherits(bt, "error")) { x$statut <- "echec"; x$message <- nettoyer_champ(conditionMessage(bt)) } else {
        x$statut <- "admis"
        x$cumuls_retires <- as.integer(isTRUE(bt$cumuls_retires)); x$plafond <- as.integer(isTRUE(bt$plafond_cumuls))
        x$B_eff_min <- min(unlist(bt$B_effectif[CLES]))
        y <- remplir_sigma(list(), bt$sigma_boot); x$n_sigma <- y$n_sigma; x$q05 <- y$q05; x$q95 <- y$q95
        for (k in CLES) x[[paste0("p:", k)]] <- unname(bt$p_mc[[k]])
      }
      x$motif_code <- "-"
      lignes[[i]] <- x
    }
    d <- proc.time()[["elapsed"]] - t1
    lapply(lignes, function(x) { x$duree_s <- d / length(lignes); x })
  }, error = function(e) fin("echec", "-", nettoyer_champ(conditionMessage(e))))
  res
}
# Sonde (par. 5 (1)) : triangles construits sur reserve2 (8 x 8) et
# reserve2_trapeze (8 x 6) ; colonne j* remplacee par
# C(i,j*+1) = C(i,j*) f_(j*) (1 + rho u_i), u = seq(-1, 1) (ecart relatif
# maximal 1) ; colonnes suivantes recomposees avec leurs facteurs d'origine.
SONDE_CFG <- data.frame(base = c("reserve2", "reserve2_trapeze", "reserve2_trapeze"), jstar = c(5L, 3L, 4L),
                        lib = c("J\u22122 du carr\u00e9 (j* = 5)", "J\u22122 du 8 x 6 (j* = 3)", "J\u22121 du 8 x 6 (j* = 4)"),
                        stringsAsFactors = FALSE)
SONDE_BASES <- list(reserve2 = .tri, reserve2_trapeze = .tri_trapeze)
tri_sonde <- function(base, jstar, rho) {
  tri <- SONDE_BASES[[base]]; I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  a0 <- mw_ajuster(tri); f <- a0$f[jstar + 1L]
  F0 <- tri[, -1L, drop = FALSE] / tri[, -ncol(tri), drop = FALSE]
  n <- I - jstar; u <- seq(-1, 1, length.out = n)
  nt <- tri
  nt[seq_len(n), jstar + 2L] <- nt[seq_len(n), jstar + 1L] * f * (1 + rho * u)
  if (jstar + 1L <= J - 1L) for (j in (jstar + 1L):(J - 1L)) {
    r <- seq_len(I - j)
    nt[r, j + 2L] <- nt[r, j + 1L] * F0[r, j + 1L]
  }
  nt
}
taches_sonde <- function() {
  out <- list()
  for (c_ in seq_len(nrow(SONDE_CFG))) for (ir in seq_along(RHO_S))
    out[[length(out) + 1L]] <- list(cfg = c_, ir = ir, u = (c_ - 1L) * length(RHO_S) + ir)
  out
}
une_sonde <- function(cfg, ir, u, B) {
  base <- SONDE_CFG$base[cfg]; jstar <- SONDE_CFG$jstar[cfg]; rho <- RHO_S[ir]
  vars <- if (base == "reserve2") "V0" else c("V0", "V2")
  out <- list()
  tri <- tri_sonde(base, jstar, rho)
  ad <- tryCatch(admettre(tri), error = function(e) list(ok = FALSE, code = "erreur", motif = conditionMessage(e)))
  for (v in vars) for (mode in c("courant", "P1")) {
    t1 <- proc.time()[["elapsed"]]
    L <- ligne_vide(COLONNES_S)
    L$cfg <- cfg; L$base <- base; L$jstar <- jstar; L$rho <- rho; L$u <- u; L$graine <- graine_sonde(u); L$variante <- v; L$mode <- mode
    if (!ad$ok) { L$statut <- "refus"; L$message <- nettoyer_champ(paste(ad$code, ad$motif)) } else {
      aj <- ad$aj
      L$deg_jstar <- as.integer(.mw_colonne_degeneree(aj, jstar))
      cpt <- nouveau_compteur(aj$tri)
      r <- tryCatch(avec_variante(v, substituer("mw_residus", f_residus_sonde(mode, cpt), {
        figes <- .mw_ensembles_figes(aj)
        list(figes = figes, bt = mw_bootstrap(aj, B = B, seed = graine_sonde(u), figes = figes))
      })), error = function(e) e)
      if (inherits(r, "error")) { L$statut <- "echec"; L$message <- nettoyer_champ(conditionMessage(r)) } else {
        L$statut <- "admis"
        L$jd <- if (length(r$figes$degeneres)) paste(r$figes$degeneres, collapse = ",") else "-"
        L$n_appels <- cpt$appels; L$n_touches <- cpt$touches; L$n_triangles <- cpt$triangles; L$n_tri_touches <- cpt$tri_touches
        L$obs_appels <- cpt$obs_appels; L$obs_touche <- as.integer(cpt$obs_touche)
        L$B_eff_min <- min(unlist(r$bt$B_effectif[CLES]))
        for (k in CLES) {
          L[[paste0("obs:", k)]] <- unname(r$bt$stats_obs[[k]]); L[[paste0("p:", k)]] <- unname(r$bt$p_mc[[k]])
          L[[paste0("err:", k)]] <- unname(r$bt$err_mc[[k]])
        }
      }
    }
    L$duree_s <- proc.time()[["elapsed"]] - t1
    out[[length(out) + 1L]] <- L
  }
  out
}

# --- Ecriture et lecture des lignes (copies de #567) --------------------------
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
COLS_TYPE <- list(OR = list(COLONNES_ORA, COL_TEXTE_ORA), OD = list(COLONNES_ORA, COL_TEXTE_ORA),
                  BAL = list(COLONNES_BAL, COL_TEXTE_BAL), S = list(COLONNES_S, COL_TEXTE_S))
cols_type <- function(type) if (type %in% names(COLS_TYPE)) COLS_TYPE[[type]] else list(COLONNES, COL_TEXTE)
chaine <- function(d, cols) if (!NROW(d)) character(0) else
  do.call(paste, c(lapply(cols, function(c) vapply(d[[c]], fv, "")), sep = " "))

# --- Constat (1) : evaluation de la sonde (bloc S, par. 5 (1)) ---------------
# Utilisee a la fin de la mesure et, bloc S complet, a l'interruption d'un
# segment (R4 : bloc S lance en premier). Par (colonne sondee, rho,
# variante) : part touchee (R5) = replications ajustees touchees / replications
# ajustees, triangle observe exclu (compte a part) ; |Delta p| maximal sur
# les 13 cles entre code courant et prototype P1, rapporte a err_mc du code
# courant ; cle du maximum "-" si |Delta p| maximal nul ou non defini.
evaluer_sonde <- function(SON) {
  if (is.null(SON)) return(list(tab = NULL, regle = NA))
  tab <- do.call(rbind, lapply(split(SON, paste(SON$cfg, SON$rho, SON$variante)), function(d) {
    co <- d[d$mode == "courant", , drop = FALSE]; p1 <- d[d$mode == "P1", , drop = FALSE]
    if (nrow(co) != 1L || nrow(p1) != 1L) return(NULL)
    pc <- unlist(co[, paste0("p:", CLES)]); pp <- unlist(p1[, paste0("p:", CLES)]); er <- unlist(co[, paste0("err:", CLES)])
    dp <- abs(pc - pp); ratio <- ifelse(dp == 0, 0, dp / er)
    dp_max <- suppressWarnings(max(dp, na.rm = TRUE))
    data.frame(cfg = co$cfg, base = co$base, jstar = co$jstar, rho = co$rho, variante = co$variante, statut = co$statut,
               jd = co$jd, deg_jstar = co$deg_jstar, obs_touche = co$obs_touche, n_rep = co$n_triangles, n_rep_touchees = co$n_tri_touches,
               part = if (is.finite(co$n_triangles) && co$n_triangles > 0) co$n_tri_touches / co$n_triangles else NA_real_,
               appels = co$n_appels, touches = co$n_touches,
               obs_ident = identical(chaine(co, paste0("obs:", CLES)), chaine(p1, paste0("obs:", CLES))),
               dp_max = dp_max, ratio_max = suppressWarnings(max(ratio, na.rm = TRUE)),
               cle_max = if (!is.finite(dp_max) || dp_max == 0) "-" else CLES[which.max(replace(ratio, is.na(ratio), -1))],
               stringsAsFactors = FALSE)
  }))
  if (!is.null(tab)) tab <- tab[order(tab$cfg, tab$rho, tab$variante), , drop = FALSE]
  regle <- if (is.null(tab)) NA else {
    pl <- tab$rho >= PLAGE_RHO_S[1] & tab$rho <= PLAGE_RHO_S[2]
    touchee <- is.finite(tab$part) & tab$part > 0
    any(pl & touchee & is.finite(tab$ratio_max) & tab$ratio_max > 2) || any(pl & touchee & is.infinite(tab$ratio_max))
  }
  list(tab = tab, regle = regle)
}
lignes_constat_1 <- function(ev) {
  x <- c("### Constat (1) : sonde de la plage de dispersion relative 1e-12 \u00e0 1e-10 (bloc S)", "",
         sprintf("Part touch\u00e9e : r\u00e9plications ajust\u00e9es o\u00f9 une colonne hors de l'ensemble fig\u00e9, d\u00e9g\u00e9n\u00e9r\u00e9e au sens de .mw_colonne_degeneree(), garde des r\u00e9sidus (code courant), divis\u00e9es par le nombre de r\u00e9plications ajust\u00e9es, triangle observ\u00e9 exclu (compt\u00e9 \u00e0 part) ; |\u0394p| max entre code courant et prototype P1 rapport\u00e9 \u00e0 err_mc du code courant. R\u00e8gle (plage %s \u00e0 %s) : %s.",
                 format(PLAGE_RHO_S[1]), format(PLAGE_RHO_S[2]),
                 if (is.na(ev$regle)) "non \u00e9valuable" else if (ev$regle) "**correction (part touch\u00e9e non nulle et |\u0394p| > 2 err_mc dans la plage)**" else "constat document\u00e9, mineur (ADR 0018)"), "")
  if (!is.null(ev$tab)) x <- c(x, entete_md(c("Colonne sond\u00e9e", "\u03c1", "Variante", "statut", "colonnes fig\u00e9es", "j* d\u00e9g\u00e9n\u00e9r\u00e9e", "observ\u00e9 touch\u00e9",
                                               "r\u00e9plications ajust\u00e9es", "touch\u00e9es", "part touch\u00e9e", "appels touch\u00e9s / appels (r\u00e9plications)", "stats_obs identiques", "|\u0394p| max", "|\u0394p| / err_mc max (cl\u00e9)")),
    vapply(seq_len(nrow(ev$tab)), function(i) { y <- ev$tab[i, ]
      ligne_md(SONDE_CFG$lib[y$cfg], format(y$rho), y$variante, y$statut, y$jd, y$deg_jstar, if (isTRUE(y$obs_touche == 1)) "oui" else if (isTRUE(y$obs_touche == 0)) "non" else "\u2014",
               format(y$n_rep), format(y$n_rep_touchees), num(y$part, 4), sprintf("%s / %s", format(y$touches), format(y$appels)),
               if (isTRUE(y$obs_ident)) "oui" else "**non**", num(y$dp_max, 5), sprintf("%s (%s)", num(y$ratio_max, 2), y$cle_max)) }, ""), "")
  x
}

###############################################################################
#  CONTROLES COMMUNS AU PRE-VOL ET A LA MESURE
###############################################################################
# Nature d'un controle (decision C2 du mainteneur, E-23/11 (etape 2)) :
# "integrite" : controle de code ou de reproductibilite, bloquant (INTEGRITE
# ECHEC, --ecrire refuse) ; "k0" : critere de K0 ((inv), (o), (dc) carre),
# dont le defaut met K0 en defaut et declenche R0 sans bloquer l'ecriture ;
# "constat" : (dc) sur le bloc D, dont le defaut rend les constats (3) et (4)
# non evaluables, sans R0.
INTEGRITE <- character(0)
DEFAUTS_K0 <- character(0)
DEFAUTS_CONSTAT <- character(0)
CTRL <- list()
controle <- function(code, ok, detail, nature = "integrite") {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail, nature = nature)
  if (!isTRUE(ok)) switch(nature,
    integrite = INTEGRITE <<- c(INTEGRITE, code),
    k0 = DEFAUTS_K0 <<- c(DEFAUTS_K0, code),
    constat = DEFAUTS_CONSTAT <<- c(DEFAUTS_CONSTAT, code),
    stop("nature de controle inconnue : ", nature))
}
etat_ctrl <- function(k) if (k$ok) "OK" else switch(k$nature,
  integrite = "\u00c9CHEC",
  k0 = "D\u00c9FAUT DE K0 (R0, sans INTEGRITE ECHEC)",
  constat = "D\u00c9FAUT (constats (3) et (4) non \u00e9valuables, sans R0)")
lignes_ctrl <- function() vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, etat_ctrl(k), k$detail), "")
# (t), bloquant (correction C1) : criteres et regles du par. 4 presents a
# l'identique dans le protocole verse ET md5 du protocole egal a celui
# approuve a PA-1 (MD5_PROTOCOLE_PA1).
controle_t <- function() {
  f <- file.path(RACINE, PROTOCOLE)
  txt <- if (file.exists(f)) readLines(f, warn = FALSE, encoding = "UTF-8") else character(0)
  ok_b <- present_bloc(TEXTE_CRITERE_612, txt); m <- md5_fichier(f)
  ok_m <- identical(m, MD5_PROTOCOLE_PA1)
  controle("(t)", ok_b && ok_m,
           sprintf("par. 4 (crit\u00e8re, K0 \u00e0 K4, r\u00e8gles R0 \u00e0 d\u00e9faut, statut \u00e9pist\u00e9mique ; %d lignes) %s dans %s ; md5 %s, %s md5 approuv\u00e9 \u00e0 PA-1 (%s, exig\u00e9) ; md5 lu au T0 fix\u00e9 dans le contexte des tranches et contr\u00f4l\u00e9 \u00e0 la fin ; v\u00e9rifi\u00e9 avant tout tirage",
                   length(TEXTE_CRITERE_612), if (ok_b) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9", PROTOCOLE, m,
                   if (ok_m) "identique au" else "DIFF\u00c9RENT du", MD5_PROTOCOLE_PA1))
}
# (v0), (v2) : V0 (resp. V2) du script identical() a run_engine() (meme
# substitution) sur les 13 p_mc des triangles du pre-vol : premier triangle
# admis des graines du pre-vol, pour chaque (G, loi) des trapezes.
U_V <- local({
  out <- list()
  for (G in GEOM$code) for (loi in names(LOIS)) {
    u <- NA_integer_
    for (k in seq_len(U_MAX_PV)) if (isTRUE(tryCatch(admettre(triangle_cle(G, loi, graine_pv_tri(k)))$ok, error = function(e) FALSE))) { u <- k; break }
    out[[paste(G, loi)]] <- list(G = G, loi = loi, u = u)
  }
  out
})
taches_v <- function() unlist(lapply(U_V, function(x) lapply(c("V0", "V2"), function(v) c(x, list(v = v)))), recursive = FALSE)
une_tache_v <- function(t, B) {
  t1 <- proc.time()[["elapsed"]]
  if (is.na(t$u)) return(list(t = t, ok = FALSE, p = NULL, duree = 0, duree_re = 0))
  tri <- triangle_cle(t$G, t$loi, graine_pv_tri(t$u)); ad <- admettre(tri); figes <- .mw_ensembles_figes(ad$aj)
  r <- calcul(ad$aj, figes, B, graine_pv_boot(t$u), t$v, tests = FALSE)
  d1 <- proc.time()[["elapsed"]] - t1; t2 <- proc.time()[["elapsed"]]
  re <- avec_variante(t$v, run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II",
                                     date_reference = DATE_REFERENCE_TESTS, B = B, seed = graine_pv_boot(t$u)))
  d2 <- proc.time()[["elapsed"]] - t2
  p1 <- unname(unlist(r$bt$p_mc[CLES])); p2 <- unname(unlist(re$bootstrap$p_mc[CLES]))
  list(t = t, ok = isTRUE(re$ok) && identical(p1, p2), p = p1, duree = d1, duree_re = d2, restaure = substitutions_restaurees())
}
consigner_v <- function(RV, B) for (v in c("V0", "V2")) {
  x <- Filter(function(y) y$t$v == v, RV)
  ok <- length(x) == length(U_V) && all(vapply(x, function(y) isTRUE(y$ok) && isTRUE(y$restaure), logical(1)))
  det <- vapply(x, function(y) sprintf("%s %s u = %s : %s", y$t$G, y$t$loi, format(y$t$u), if (isTRUE(y$ok)) "13 / 13 identiques" else "\u00c9CHEC"), "")
  controle(sprintf("(%s)", tolower(v)), ok,
           sprintf("%s du script (mw_bootstrap(), B = %s, graine 664 500 000 + u) identical() \u00e0 run_engine()%s sur les 13 p_mc ; triangles du pr\u00e9-vol (graine 664 000 000 + u, premier admis par (G, loi)) : %s ; substitutions restaur\u00e9es (identical()) : %s",
                   v, format(B), if (v == "V2") " sous la m\u00eame substitution" else "", paste(det, collapse = " ; "),
                   if (all(vapply(x, function(y) isTRUE(y$restaure), logical(1)))) "oui" else "NON"))
}

###############################################################################
#  MODE --prevol (par. 8 et 9)
###############################################################################
if (MODE == "prevol") {
  DET <- character(0); DUR <- character(0)
  det <- function(...) DET <<- c(DET, ...)
  controle_t()
  controle("(1)", DIFF_MOTEUR_DEBUT && SHA_DEBUT != "inconnu", sprintf("git diff --quiet HEAD -- R/engine.R au d\u00e9but : %s ; md5 R/engine.R %s ; SHA %s",
                                                                 if (DIFF_MOTEUR_DEBUT) "vide" else "NON VIDE", MD5_MOTEUR_DEBUT, SHA_DEBUT))
  N_ADM <- U_MAX_PV
  t0 <- Sys.time()
  ADM <- list()
  for (cle in c(GEOM$code, "8x8", "D")) for (loi in names(LOIS)) {
    t1 <- Sys.time()
    codes <- vapply(seq_len(N_ADM), function(u) tryCatch(admettre(triangle_cle(cle, loi, graine_pv_tri(u)))$code, error = function(e) "erreur"), "")
    ADM[[paste(cle, loi)]] <- list(cle = cle, loi = loi, codes = codes, a = mean(codes == "-"), c_adm = secs(t1) / N_ADM, u_adm = which(codes == "-"))
  }
  # Caches du moteur chauffes dans le processus maitre (precedent de #567).
  for (G in GEOM$code) { x <- U_V[[paste(G, "N")]]
    tri <- triangle_cle(G, "N", graine_pv_tri(x$u)); ad <- admettre(tri)
    invisible(calcul(ad$aj, .mw_ensembles_figes(ad$aj), 9, graine_pv_boot(x$u), "V2")) }
  # (v0), (v2) a B = 999.
  t1 <- Sys.time()
  RV <- parallel::mclapply(taches_v(), une_tache_v, B = B_MESURE, mc.cores = max(1L, min(4L, COEURS, na.rm = TRUE)), mc.preschedule = FALSE)
  MUR_V <- secs(t1)
  if (any(vapply(RV, function(x) !is.list(x), logical(1)))) stop("--prevol : controles (v0), (v2) en erreur")
  consigner_v(RV, B_MESURE)
  C_RE <- mean(vapply(RV, function(x) x$duree_re, 1))
  # Unite de debit (memes unites dans chaque processus) : pour chaque G, un
  # triangle admis V2 complet (mw_bootstrap() et mw_tests(), B = 999), sa
  # boucle allegee V0 et 25 triangles d'oracle ; un carre V0 complet ; loi N.
  unite <- function(i) {
    d <- numeric(0); p <- character(0)
    loi <- "N"
    for (G in GEOM$code) {
      ua <- ADM[[paste(G, loi)]]$u_adm[1]
      tri <- triangle_cle(G, loi, graine_pv_tri(ua)); ad <- admettre(tri); figes <- .mw_ensembles_figes(ad$aj)
      t1 <- proc.time()[["elapsed"]]; r <- calcul(ad$aj, figes, B_MESURE, graine_pv_boot(ua), "V2"); d[[paste0("v2_", G)]] <- proc.time()[["elapsed"]] - t1
      t1 <- proc.time()[["elapsed"]]; lg <- boucle_allegee(ad$aj, B_MESURE, graine_pv_boot(ua), figes); d[[paste0("al_", G)]] <- proc.time()[["elapsed"]] - t1
      t1 <- proc.time()[["elapsed"]]
      for (k in seq_len(25L)) invisible(un_oracle(G, loi, k, graine_pv_tri(k)))
      d[[paste0("or_", G)]] <- (proc.time()[["elapsed"]] - t1) / 25
      p <- c(p, vapply(CLES, function(k) fv(r$bt$p_mc[[k]]), ""), vapply(lg$sig, fv, ""))
    }
    u8 <- ADM[[paste("8x8", loi)]]$u_adm[1]
    tri <- triangle_cle("8x8", loi, graine_pv_tri(u8)); ad <- admettre(tri)
    t1 <- proc.time()[["elapsed"]]; r <- calcul(ad$aj, .mw_ensembles_figes(ad$aj), B_MESURE, graine_pv_boot(u8), "V0"); d[["car"]] <- proc.time()[["elapsed"]] - t1
    p <- c(p, vapply(CLES, function(k) fv(r$bt$p_mc[[k]]), ""))
    list(d = d, p = paste(p, collapse = " "))
  }
  KMAX <- max(1L, min(4L, COEURS, na.rm = TRUE))
  CB <- list(); MUR <- numeric(KMAX); EMP_U <- character(0)
  for (k in seq_len(KMAX)) {
    t1 <- Sys.time()
    res <- parallel::mclapply(seq_len(k), unite, mc.cores = k, mc.preschedule = FALSE)
    MUR[k] <- secs(t1)
    if (any(vapply(res, function(x) !is.list(x), logical(1)))) stop("--prevol : processus en erreur (k = ", k, ")")
    CB[[k]] <- do.call(rbind, lapply(res, function(x) x$d))
    EMP_U <- c(EMP_U, vapply(res, function(x) x$p, ""))
  }
  UNITES_IDENTIQUES <- length(unique(EMP_U)) == 1L
  controle("(u)", UNITES_IDENTIQUES, sprintf("unit\u00e9s de d\u00e9bit identiques au bit dans les %d ex\u00e9cutions (1 + 2 + ... + %d processus) : %s",
                                            length(EMP_U), KMAX, if (UNITES_IDENTIQUES) "oui" else "NON"))
  tot <- function(m) rowSums(m[, c(paste0("v2_", GEOM$code), paste0("al_", GEOM$code), "car"), drop = FALSE]) +
    25 * rowSums(m[, paste0("or_", GEOM$code), drop = FALSE])
  # Debit agrege mesure, borne par k (hypothese prudente [H] : une seule
  # unite par processus, la phase a un processus porte des couts de premier
  # appel ; P_k > k n'est pas retenu).
  P_k_mes <- vapply(seq_len(KMAX), function(k) k * mean(tot(CB[[1]])) / mean(tot(CB[[k]])), 1)
  P_k <- pmin(P_k_mes, seq_len(KMAX))
  c1m <- colMeans(CB[[1]])
  c_v2 <- c1m[paste0("v2_", GEOM$code)]; names(c_v2) <- GEOM$code
  c_al <- c1m[paste0("al_", GEOM$code)]; names(c_al) <- GEOM$code
  c_or <- c1m[paste0("or_", GEOM$code)]; names(c_or) <- GEOM$code
  c_car <- c1m[["car"]]
  c_adm <- mean(vapply(ADM, function(x) x$c_adm, 1))
  a_ <- function(cle, loi) ADM[[paste(cle, loi)]]$a
  # Temps de calcul (s, un processus) d'un niveau [H : cout lineaire par
  # triangle ; V0 complet compte au cout de V2 ; bloc D au cout du 8 x 6 ;
  # balayage au cout de V2 ; agregation finale non comptee].
  cpu_niveau <- function(R) {
    m <- function(G, n, loi, plein) n * (a_(G, loi) * (c_v2[[G]] * (if (plein) 2 else 1) + (if (plein) 0 else c_al[[G]])) + (1 - a_(G, loi)) * c_adm)
    s <- 0
    for (loi in names(LOIS)) {
      s <- s + m("8x7", R$M7a[[loi]], loi, FALSE) + ceiling(R$M7a[[loi]] / TAILLE_TRANCHE) * c_v2[["8x7"]]
      s <- s + m("8x7", R$M7b[[loi]], loi, TRUE)
      s <- s + m("8x5", R$M5[[loi]], loi, FALSE) + ceiling(R$M5[[loi]] / TAILLE_TRANCHE) * c_v2[["8x5"]]
      s <- s + m("8x6", R$M6[[loi]], loi, FALSE) + ceiling(R$M6[[loi]] / TAILLE_TRANCHE) * c_v2[["8x6"]]
      s <- s + R$C[[loi]] * (a_("8x8", loi) * c_car + (1 - a_("8x8", loi)) * c_adm)
      s <- s + R$D[[loi]] * (a_("D", loi) * c_v2[["8x6"]] + (1 - a_("D", loi)) * c_adm)
      s <- s + sum(vapply(GEOM$code, function(G) R$BAL[[loi]] * length(POINTS_BAL) * c_v2[[G]], 1))
      s <- s + sum(vapply(GEOM$code, function(G) R$OR[[loi]] * c_or[[G]], 1)) + R$OD[[loi]] * c_or[["8x6"]]
    }
    s <- s + R$S * (14 * c_car + 56 * c_v2[["8x6"]])
    n_cel <- sum(vapply(BLOCS_TRI, function(bl) sum(R[[bl]] > 0), 1))
    s + 2 * n_cel * 2 * mean(c_v2)
  }
  n_boot <- function(R) sum(unlist(lapply(c("M7a", "M5", "M6", "C", "D"), function(bl) R[[bl]]))) + 2 * sum(R$M7b) +
    sum(ceiling(c(R$M7a, R$M5, R$M6) / TAILLE_TRANCHE)) + 3 * sum(R$BAL) * length(POINTS_BAL) + 70 * R$S
  k_plan <- min(K_BUDGET, KMAX)
  # Surcout de chaque lancement (controles avant tirage) : (v0) et (v2)
  # (duree murale mesuree), (a) (un run_engine(), en parallele), (r567)
  # initial (un bootstrap du 8 x 7).
  SURCOUT <- MUR_V + C_RE + c_v2[["8x7"]]
  plan <- lapply(names(NIVEAUX), function(l) {
    mur <- cpu_niveau(NIVEAUX[[l]]) / P_k[k_plan]
    nseg <- as.integer(ceiling(mur / (SEGMENT_S - SURCOUT)))
    list(niveau = l, mur = mur, nseg = nseg, total = mur + nseg * SURCOUT, boot = n_boot(NIVEAUX[[l]]))
  })
  names(plan) <- names(NIVEAUX)
  tient <- vapply(plan, function(x) x$total <= BUDGET_S, logical(1))
  niveau <- if (any(tient)) names(plan)[which(tient)[1]] else NA_character_
  # --- Partie deterministe (identique d'un pre-vol a l'autre) ---
  det(sprintf("## Pr\u00e9-vol de la mesure #612 (A2, \u00e9tape 2) -- rien d'\u00e9crit"), "",
      sprintf("Commit : %s ; md5 R/engine.R : %s ; empreinte #231 : %s ; script : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s",
              COMMIT_DEBUT, MD5_MOTEUR_DEBUT, EMPREINTE_DEBUT, MD5_SCRIPT, PLATEFORME, COEURS), "",
      "### Substitutions (corps imprim\u00e9s ; toutes dans environment(run_engine), restaur\u00e9es par on.exit)", "",
      sprintf("- %s : `%s`", names(CORPS_SUBST), CORPS_SUBST), "",
      "### Admission sur les graines du pr\u00e9-vol (664 000 000 + u, u \u2264 50)", "",
      entete_md(c("Triangle", "loi", "tir\u00e9s", "admis", "taux d'admission", "motifs de refus")),
      vapply(ADM, function(x) { t <- table(x$codes[x$codes != "-"])
        ligne_md(x$cle, x$loi, length(x$codes), sum(x$codes == "-"), num(x$a, 3),
                 if (length(t)) paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") else "aucun") }, ""), "",
      "### Contr\u00f4les (v0) et (v2) (B = 999) et p_mc des triangles du pr\u00e9-vol", "",
      entete_md(c("G", "loi", "u", "variante", "identique \u00e0 run_engine()", "p_mc (13 cl\u00e9s, %.17g)")),
      vapply(RV, function(x) ligne_md(x$t$G, x$t$loi, format(x$t$u), x$t$v, if (isTRUE(x$ok)) "oui" else "NON",
                                      paste(vapply(x$p, fv, ""), collapse = " ")), ""), "",
      sprintf("Unit\u00e9s de d\u00e9bit : md5 des p_mc et \u03c3* de l'unit\u00e9 %s ; identiques dans les %d ex\u00e9cutions : %s.",
              md5_texte(EMP_U[1]), length(EMP_U), if (UNITES_IDENTIQUES) "oui" else "NON"), "",
      "### Contr\u00f4les", "",
      lignes_ctrl(), "",
      "### Bootstraps par niveau (par. 9)", "",
      entete_md(c("Niveau", "bootstraps \u00e0 B = 999")),
      vapply(plan, function(x) ligne_md(x$niveau, format(x$boot)), ""))
  EMPREINTE_DET <- md5_texte(DET)
  # --- Durees (varient d'un pre-vol a l'autre) ---
  f2 <- function(m, cc) sprintf("%s [%s ; %s]", num(mean(m[, cc]), 2), num(min(m[, cc]), 2), num(max(m[, cc]), 2))
  cols_u <- colnames(CB[[1]])
  DUR <- c("### Dur\u00e9es (varient d'un pr\u00e9-vol \u00e0 l'autre)", "",
           sprintf("D\u00e9but %s ; admission : %s s par triangle (moyenne) ; (v0) et (v2) : %s s d'horloge (%d processus), run_engine() %s s, mw_bootstrap() %s s en moyenne.",
                   format(t_debut, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), num(c_adm, 4), num(MUR_V, 1), max(1L, min(4L, COEURS, na.rm = TRUE)), num(C_RE, 2),
                   num(mean(vapply(RV, function(x) x$duree, 1)), 2)), "",
           entete_md(c("processus", "dur\u00e9e murale (s)", cols_u, "d\u00e9bit agr\u00e9g\u00e9 mesur\u00e9", "P_k retenu (\u2264 k)")),
           vapply(seq_len(KMAX), function(k) do.call(ligne_md, c(list(k, num(MUR[k], 1)), lapply(cols_u, function(cc) f2(CB[[k]], cc)), list(num(P_k_mes[k], 3), num(P_k[k], 3)))), ""), "",
           sprintf("Surco\u00fbt de chaque lancement (contr\u00f4les avant tirage) : %s s.", num(SURCOUT, 0)), "",
           sprintf("### Niveaux (premier dont la dur\u00e9e totale tient dans le budget de PA-1 : %d segments de 1,8 h = %s h, sur %d processus)", N_SEGMENTS_PA1, num(BUDGET_S / 3600, 1), k_plan), "",
           entete_md(c("Niveau", "bootstraps", sprintf("calcul \u00e0 %d processus (h)", k_plan), "segments de 1,8 h", "dur\u00e9e totale, surco\u00fbts compris (h)", "dans le budget")),
           vapply(plan, function(x) ligne_md(x$niveau, format(x$boot), num(x$mur / 3600, 2), x$nseg, num(x$total / 3600, 2), if (x$total <= BUDGET_S) "oui" else "non"), ""), "",
           if (k_plan < K_BUDGET) sprintf("**Moins de %d c\u0153urs : dur\u00e9es \u00e0 %d processus seulement.**", K_BUDGET, k_plan) else character(0),
           if (!is.na(niveau)) sprintf("**Niveau retenu : %s, %s h, %d segment(s) de 1,8 h** (hypoth\u00e8se [H] : co\u00fbt lin\u00e9aire par triangle ; agr\u00e9gation finale et queues de groupes non compt\u00e9es).",
                                       niveau, num(plan[[niveau]]$total / 3600, 2), plan[[niveau]]$nseg)
           else "**Aucun niveau ne tient dans le budget de PA-1 : retour au mainteneur.**", "",
           sprintf("Ordre conseill\u00e9 (arbre fig\u00e9 au commit de mesure ; --aide) : (1) bloc S en premier : LC_ALL=C.UTF-8 Rscript %s --niveau %s --bloc S --processus %d --travail DOSSIER ; (2) segments : LC_ALL=C.UTF-8 Rscript %s --niveau %s --processus %d --duree-max 1.8 --travail DOSSIER ; (3) dernier segment et tout segment avec --ecrire : --duree-max 1.6 (marge d'agr\u00e9gation finale) [--ecrire]",
                   SCRIPT_DEPOT, if (is.na(niveau)) "?" else niveau, k_plan, SCRIPT_DEPOT, if (is.na(niveau)) "?" else niveau, k_plan),
           sprintf("PREVOL612\t%s\t%s\t%s\t%s", paste(sprintf("%.4f", c1m), collapse = "\t"), paste(sprintf("%.4f", P_k), collapse = "\t"),
                   paste(vapply(plan, function(x) sprintf("%.0f", x$total), ""), collapse = "\t"), if (is.na(niveau)) "NA" else niveau),
           sprintf("Dur\u00e9e du pr\u00e9-vol : %s s.", num(secs(t_debut), 0)))
  controle("(1) fin", moteur_sans_diff() && identical(md5_fichier(file.path(RACINE, "R", "engine.R")), MD5_MOTEUR_DEBUT) && substitutions_restaurees() &&
             identical(md5_fichier(file.path(RACINE, PROTOCOLE)), MD5_PROTOCOLE_T0),
           "git diff --quiet HEAD -- R/engine.R \u00e0 la fin, md5 du moteur et du protocole inchang\u00e9s, substitutions restaur\u00e9es")
  ecrire_console(c(DET, "", sprintf("EMPREINTE DU PR\u00c9-VOL (md5 de la partie d\u00e9terministe ci-dessus) : %s", EMPREINTE_DET), "", DUR, "",
                   paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK")))
  quit(status = if (length(INTEGRITE)) 1L else 0L)
}

###############################################################################
#  ESSAI ET MESURE : PARAMETRES, GARDES DE --ecrire, JOURNAL
###############################################################################
B_RUN <- if (OPT_ESSAI) B_ESSAI else B_MESURE
R_PLAN <- if (OPT_ESSAI) {
  x <- NIVEAUX[["L-A"]]
  for (bl in setdiff(names(x), "S")) x[[bl]] <- pmin(x[[bl]], if (bl %in% c("OR", "OD")) N0_ESSAI else R_ESSAI)
  x
} else NIVEAUX[[OPT_NIVEAU]]
txt_R <- function() paste(vapply(names(R_PLAN), function(bl) sprintf("%s=%s", bl, paste(R_PLAN[[bl]], collapse = "/")), ""), collapse = ",")
if (OPT_ECRIRE) {
  nvs <- motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")
  if (length(nvs)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nvs, collapse = " ; "),
                           " -- lancer depuis un arbre au commit propre")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) refuser("dossier de sortie introuvable : docs/tableaux")
}
SUFFIXE <- if (OPT_ESSAI) "essai" else OPT_NIVEAU
TRAVAIL_TEMP <- OPT_ESSAI && is.na(OPT_TRAVAIL)
TRAVAIL <- if (!is.na(OPT_TRAVAIL)) OPT_TRAVAIL else if (OPT_ESSAI) tempfile("essai612_", tmpdir = dirname(tempdir())) else
  file.path(dirname(normalizePath(RACINE, winslash = "/")), sprintf("issue612-travail-%s", SUFFIXE))
if (sous_depot(TRAVAIL)) refuser("--travail : dossier sous le depot refuse")
if (!dir.exists(TRAVAIL)) dir.create(TRAVAIL, recursive = TRUE)
TRAVAIL <- normalizePath(TRAVAIL, winslash = "/")
nettoyer_essai <- function() if (TRAVAIL_TEMP) unlink(TRAVAIL, recursive = TRUE)
# Essai sans --travail : dossier temporaire supprime aussi sur erreur R
# (finaliseur de fin de session ; les processus fils de mclapply sortent sans
# l'executer) ; garde pour la reprise d'un segment interrompu.
GARDER_TRAVAIL <- FALSE
if (TRAVAIL_TEMP) invisible(reg.finalizer(globalenv(), function(e) if (!isTRUE(GARDER_TRAVAIL)) unlink(TRAVAIL, recursive = TRUE), onexit = TRUE))
JOURNAL_T <- file.path(TRAVAIL, "JOURNAL.md")
CTX <- c(B = B_RUN, sha = SHA_DEBUT, md5_moteur = MD5_MOTEUR_DEBUT, md5_script = MD5_SCRIPT, empreinte = EMPREINTE_DEBUT,
         md5_protocole = MD5_PROTOCOLE_T0,
         plateforme = PLATEFORME, essai = if (OPT_ESSAI) "oui" else "non", taille_tranche = TAILLE_TRANCHE)
txt_ctx <- function(ctx) paste(names(ctx), ctx, sep = "=", collapse = " || ")
lire_journal <- function() {
  jl <- readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")
  champ <- function(cle) {
    m <- regmatches(jl, regexec(paste0("^- ", cle, " : (.*)$"), jl))
    v <- vapply(m[lengths(m) == 2L], `[`, "", 2L)
    if (length(v)) v[1] else NA_character_
  }
  list(lignes = jl, R = champ("R par bloc et loi"), sha = champ("SHA \\(git rev-parse HEAD\\) au lancement"),
       md5 = champ("md5 R/engine\\.R au lancement"), date = champ("Date des sorties"),
       ctx = champ("Contexte des tranches"), lancement = champ("Lancement"),
       empreinte = champ("Empreinte sans commentaires de R/engine\\.R"))
}
if (!file.exists(JOURNAL_T)) {
  ecrire_fichier(JOURNAL_T, c(
    sprintf("# JOURNAL de la mesure #612 (A2, \u00e9tape 3 : simulation de la colonne J\u22121 d'un trap\u00e8ze, V0 contre V2)%s",
            if (OPT_ESSAI) " -- ESSAI, non versionnable" else ""), "",
    sprintf("- Lancement : %s", horodatage()),
    sprintf("- Date des sorties : %s", format(Sys.time(), "%Y%m%d", tz = "UTC")),
    sprintf("- R par bloc et loi : %s", txt_R()),
    sprintf("- Niveau : %s", if (OPT_ESSAI) "essai (--essai)" else sprintf("%s (pr\u00e9-vol, PA-1)", OPT_NIVEAU)),
    sprintf("- B : %s", format(B_RUN)),
    sprintf("- Processus : %d ; taille des tranches : %d", OPT_PROC, TAILLE_TRANCHE),
    sprintf("- SHA (git rev-parse HEAD) au lancement : %s", SHA_DEBUT),
    sprintf("- Commit (commit_depot()) : %s", COMMIT_DEBUT),
    sprintf("- md5 R/engine.R au lancement : %s", MD5_MOTEUR_DEBUT),
    sprintf("- Empreinte sans commentaires de R/engine.R : %s", EMPREINTE_DEBUT),
    sprintf("- Empreintes md5 du code ex\u00e9cut\u00e9 : %s", EMPREINTES),
    sprintf("- md5 protocole (%s) : %s", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))),
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
PREFIXE_SORTIE <- sprintf("%s-issue612-simulation-jm1-trapeze", DATE_SORTIES)
NOMS_SORTIES <- c(md = paste0(PREFIXE_SORTIE, ".md"), brut = paste0(PREFIXE_SORTIE, "-brut.tsv"),
                  bal = paste0(PREFIXE_SORTIE, "-balayage-brut.tsv"), sonde = paste0(PREFIXE_SORTIE, "-sonde.tsv"),
                  jnl = paste0(PREFIXE_SORTIE, "-journal-mesure.md"))
CIBLES <- file.path(RACINE, "docs", "tableaux", NOMS_SORTIES)
REMPLACES <- NULL
if (OPT_ECRIRE) REMPLACES <- garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)
arret_integrite <- function(titre) {
  ecrire_console(c(sprintf("## INTEGRITE ECHEC %s", titre), "",
                   lignes_ctrl(), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(unique(INTEGRITE), collapse = ", "))))
  ecrire_fichier(JOURNAL_T, sprintf("- INTEGRITE ECHEC %s : %s ; %s", titre, horodatage(), paste(unique(INTEGRITE), collapse = ", ")), mode = "ab")
  nettoyer_essai()
  quit(status = 1L)
}

###############################################################################
#  CONTROLES AVANT TOUT TIRAGE : (t), (e), (1), (a), (v0), (v2), (r567)
#  initial, (g), (g'), (c), (graines), (m)
###############################################################################
controle_t()
if (!CTRL[[length(CTRL)]]$ok) arret_integrite("avant tout tirage ((t))")
local({
  m <- c(brut567 = md5_fichier(file.path(RACINE, BRUT_567)), tableau567 = md5_fichier(file.path(RACINE, TABLEAU_567)),
         brut297 = md5_fichier(file.path(RACINE, BRUT_297)))
  ok <- identical(m, MD5_ENTREES)
  # Taux de MinP4 de #297 cites par le protocole (par. 5 (4)), relus.
  t297 <- if (is.null(BR297)) NULL else vapply(names(LOIS), function(loi) {
    b8 <- BR297[BR297$type == "rep" & BR297$loi == loi & BR297$statut == "admis", , drop = FALSE]
    p <- nv(b8[["pR:MinP4"]])
    c(a10 = sprintf("%.4g", mean(is.finite(p) & p < 0.10)), a05 = sprintf("%.4g", mean(is.finite(p) & p < 0.05)))
  }, character(2))
  ok297 <- !is.null(t297) && all(vapply(names(LOIS), function(loi) identical(unname(t297[, loi]), unname(TAUX_297_SPEC[[loi]])), logical(1)))
  controle("(e)", ok && ok297 && !is.null(BR567) && nrow(BR567) == 10000L,
           sprintf("md5 des entr\u00e9es : brut de #567 %s, tableau de #567 %s, brut de #297 %s (attendus %s) ; brut de #567 : %d lignes ; taux de MinP4 de #297 relus (0,10 / 0,05) : %s (protocole : N 0,071 / 0,029 ; E 0,0785 / 0,0395)",
                   m[["brut567"]], m[["tableau567"]], m[["brut297"]], paste(MD5_ENTREES, collapse = ", "), if (is.null(BR567)) 0L else nrow(BR567),
                   if (is.null(t297)) "brut absent" else paste(sprintf("%s %s / %s", names(LOIS), t297["a10", ], t297["a05", ]), collapse = " ; ")))
})
controle("(1) d\u00e9but", DIFF_MOTEUR_DEBUT && SHA_DEBUT != "inconnu" && substitutions_restaurees(),
         sprintf("git diff --quiet HEAD -- R/engine.R au d\u00e9but : %s ; md5 R/engine.R %s ; SHA %s",
                 if (DIFF_MOTEUR_DEBUT) "vide" else "NON VIDE", MD5_MOTEUR_DEBUT, SHA_DEBUT))
# (a), (v0), (v2), (r567) initial : calculs longs, en parallele.
TACHES_AVANT <- c(list(list(type = "a", cas = "reserve2"), list(type = "a", cas = "reserve2_trapeze"),
                       list(type = "r567")), lapply(taches_v(), function(t) c(list(type = "v"), t)))
t_avant <- Sys.time()
RES_AVANT <- parallel::mclapply(TACHES_AVANT, function(t) {
  if (t$type == "a") {
    r <- executer_cas(t$cas); ref <- readRDS(chemin_reference(t$cas))
    tol <- if (identical(PLATEFORME, PLATEFORME_567)) 0 else TOLERANCE
    cmp <- comparer_objets(neutraliser_instables(ref), neutraliser_instables(r), tol = tol)
    return(list(type = "a", cas = t$cas, tol = tol, cmp = cmp[c("conforme", "n_feuilles", "n_differentes", "n_ecarts", "ecart_max")]))
  }
  if (t$type == "r567") {
    tri <- triangle_cle("8x7", "N", graine_tri("N", 1)); ad <- admettre(tri)
    if (!ad$ok) return(list(type = "r567", ok = FALSE))
    bt <- calcul(ad$aj, .mw_ensembles_figes(ad$aj), B_MESURE, graine_boot("8x7", "N", 1), "V0", tests = FALSE)$bt
    return(list(type = "r567", ok = comparer_567(ad$aj, ad$msep, bt, ligne_567("8x7", "N", 1))))
  }
  c(list(type = "v"), une_tache_v(t, B_RUN))
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
DUREE_AVANT <- secs(t_avant)
if (any(vapply(RES_AVANT, function(x) !is.list(x), logical(1)))) stop("controles avant tirage : processus en erreur")
local({
  xa <- Filter(function(x) x$type == "a", RES_AVANT)
  ok <- all(vapply(xa, function(x) isTRUE(x$cmp$conforme), logical(1))) &&
    all(vapply(xa, function(x) x$tol > 0 || identical(as.integer(x$cmp$n_differentes), 0L), logical(1)))
  controle("(a)", ok, sprintf("%s ; plateforme %s celle de #567 (%s)",
                              paste(vapply(xa, function(x) sprintf("%s contre tests/reference/%s.rds, comparer_objets(tol = %g) : %d feuilles, %d diff\u00e9rente(s), %d \u00e9cart(s), \u00e9cart maximal %g",
                                                                   x$cas, x$cas, x$tol, x$cmp$n_feuilles, x$cmp$n_differentes, x$cmp$n_ecarts, x$cmp$ecart_max), ""), collapse = " ; "),
                              if (identical(PLATEFORME, PLATEFORME_567)) "=" else "\u2260 (seuil 1e-6, plateforme not\u00e9e)", PLATEFORME))
})
consigner_v(Filter(function(x) x$type == "v", RES_AVANT), B_RUN)
local({
  x <- Filter(function(x) x$type == "r567", RES_AVANT)[[1]]
  controle("(r567) initial", isTRUE(x$ok), sprintf("8 x 7, loi N, b = 1 (graines 567 000 001 et 570 000 001) : V0 recalcul\u00e9 \u00e0 B = 999 identique au brut de #567 relu en %%.17g (13 p_mc, obs, s2_regle, s2_dir, R_hat, msep) : %s ; md5 de R/engine.R \u00e0 la mesure de #567 %s, \u00e0 ce calcul %s (l'identit\u00e9 des nombres fait foi)",
                                                    if (isTRUE(x$ok)) "oui" else "NON", MD5_MOTEUR_567, MD5_MOTEUR_DEBUT))
})
# (g) : generateur identique a .mw_simulation_triangle_etat() ; fonctions du
# moteur identiques a celles de R/engine.R relu (aucune substitution posee).
FACTEURS_G <- c(1, 30, 100, 300, 1000)
local({
  det <- character(0); tout <- TRUE
  for (cle in c(GEOM$code, "8x8", "D")) {
    d <- dgp_cle(cle)
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
    det <- c(det, sprintf("%s : %d / 100 ; pool dilat\u00e9 %g fois : %d / 100, dont %d incomplet(s)", cle, sum(base), fd,
                          sum(dil["identique", ]), sum(dil["incomplet", ])))
  }
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  meme <- function(nm) { a <- get(nm, envir = ENV_MOTEUR); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c(NOMS_SUBST, "mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_triangle_incomplet", ".mw_pool_residus",
           "mw_bootstrap", "mw_ajuster", "mw_msep", "mw_tests", "mw_valider_triangle", ".mw_ensembles_figes")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  controle("(g)", tout && ok_fns, sprintf("gen_triangle_h0() = .mw_simuler_triangle_etat() sous la m\u00eame graine (identical()) : %s ; %s de l'environnement du moteur identiques (formals, body) \u00e0 R/engine.R relu : %s",
                                         paste(det, collapse = " ; "), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
})
# (g') : troncature du 8 x 8 simule = trapeze simule (b = 1..100, N et E) ;
# repete sur chaque triangle tire (colonne gp).
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
    det <- c(det, sprintf("%s : %d / 200 ; \u03b5 dilat\u00e9s %g fois : %d / 200, dont %d incomplet(s)", G, sum(base["identique", ]), fd,
                          sum(dil["identique", ]), sum(dil["incomplet", ])))
  }
  controle("(g')", tout, sprintf("trap\u00e8ze = colonnes 0..J du 8 x 8 simul\u00e9 sous la m\u00eame graine, avant tout tirage : %s", paste(det, collapse = " ; ")))
})
# (c) : sigma2_(J-1) de la regle au generateur et sigma2_(J-1) vrai du plan
# conformes au par. 1 ; cibles de couverture sigma_A^regle et sigma_A^vrai
# citees.
local({
  a <- vapply(GEOM$code, function(G) sprintf("%.6f", S2_REGLE_GEN[[G]]), "")
  v <- vapply(GEOM$code, function(G) sprintf("%.6g", S2_VRAI[[G]]), "")
  ok <- identical(unname(a), unname(S2_REGLE_SPEC)) && identical(unname(v), unname(S2_VRAI_SPEC))
  controle("(c)", ok, sprintf("\u03c3\u00b2_(J\u22121) de la r\u00e8gle au g\u00e9n\u00e9rateur (reserve2 tronqu\u00e9) : %s (protocole : %s) ; \u03c3\u00b2_(J\u22121) vrai du plan : %s (protocole : %s) ; cibles : \u03c3_A^r\u00e8gle = \u221aMSEP/R du g\u00e9n\u00e9rateur %s ; \u03c3_A^vrai (descriptive) %s",
                              paste(sprintf("%s %s", GEOM$code, a), collapse = ", "), paste(S2_REGLE_SPEC, collapse = ", "),
                              paste(sprintf("%s %s", GEOM$code, v), collapse = ", "), paste(S2_VRAI_SPEC, collapse = ", "),
                              paste(sprintf("%s %.6f", GEOM$code, SIGMA_A_REGLE), collapse = ", "),
                              paste(sprintf("%s %.6f", GEOM$code, SIGMA_A_VRAI), collapse = ", ")))
})
# (graines) : plages, disjonction externe, litteraux du depot.
PLAGES <- local({
  P <- list()
  for (loi in names(LOIS)) P[[sprintf("triangles %s (#567, r\u00e9emploi)", loi)]] <- c(graine_tri(loi, 1), graine_tri(loi, B_MAX_PLAN))
  for (G in GEOM$code) for (loi in names(LOIS)) P[[sprintf("bootstrap %s %s (#567, r\u00e9emploi ; 8 x 7 prolong\u00e9)", G, loi)]] <- c(graine_boot(G, loi, 1), graine_boot(G, loi, B_MAX_PLAN))
  for (loi in names(LOIS)) P[[sprintf("oracle %s (#567, r\u00e9emploi)", loi)]] <- c(graine_ora("8x5", loi, 1), graine_ora("8x5", loi, N0_MESURE))
  for (loi in names(LOIS)) P[[sprintf("bootstrap du carr\u00e9 %s", loi)]] <- c(graine_boot_bloc("C", "8x8", loi, 1), graine_boot_bloc("C", "8x8", loi, B_MAX_PLAN))
  for (loi in names(LOIS)) P[[sprintf("triangles D %s", loi)]] <- c(graine_tri_bloc("D", loi, 1), graine_tri_bloc("D", loi, B_MAX_PLAN))
  for (loi in names(LOIS)) P[[sprintf("bootstrap D %s", loi)]] <- c(graine_boot_bloc("D", "8x6", loi, 1), graine_boot_bloc("D", "8x6", loi, B_MAX_PLAN))
  for (loi in names(LOIS)) P[[sprintf("oracle D %s", loi)]] <- c(graine_ora("D", loi, 1), graine_ora("D", loi, N0_MESURE))
  P[["sonde"]] <- c(graine_sonde(1), graine_sonde(U_MAX_SONDE))
  P[["pr\u00e9-vol (triangles)"]] <- c(graine_pv_tri(1), graine_pv_tri(U_MAX_PV))
  P[["pr\u00e9-vol (bootstraps)"]] <- c(graine_pv_boot(1), graine_pv_boot(U_MAX_PV))
  do.call(rbind, P)
})
GRAINES_TXT <- local({
  M <- PLAGES; inter <- character(0)
  for (a in seq_len(nrow(M) - 1L)) for (b in (a + 1L):nrow(M))
    if (M[a, 1] <= M[b, 2] && M[b, 1] <= M[a, 2])
      inter <- c(inter, sprintf("%s et %s", rownames(M)[a], rownames(M)[b]))
  neuves <- M[M[, 1] >= PLAGE_A2_612[1], , drop = FALSE]
  dans_a2 <- all(neuves[, 1] >= PLAGE_A2_612[1] & neuves[, 2] <= PLAGE_A2_612[2])
  ext <- rbind(`#610` = PLAGE_EXT_610, `#206/#297 MW` = PLAGE_EXT_206, `#297 LN` = PLAGE_EXT_297LN, `#305` = PLAGE_EXT_305,
               `#387` = PLAGE_EXT_387, `360 380 123` = PLAGE_EXT_360)
  touche <- function(lo, hi, MM = M) any(lo <= MM[, 2] & hi >= MM[, 1])
  ext_ok <- !any(vapply(seq_len(nrow(ext)), function(i) touche(ext[i, 1], ext[i, 2]), logical(1)))
  max_ok <- max(M) <= .Machine$integer.max
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT_DEPOT)]
  par_fichier <- lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    as.numeric(unlist(regmatches(l, gregexpr("(?<![0-9A-Za-z._])[0-9]{8,10}(?=L?(?![0-9A-Za-z._]))", l, perl = TRUE))))
  })
  lit <- sort(unique(unlist(par_fichier)))
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_LITTERAL, neuves), logical(1))]
  dans_plage_a2 <- lit[lit >= PLAGE_A2_612[1] & lit <= PLAGE_A2_612[2]]
  f567 <- basename(fs)[vapply(par_fichier, function(v) any(v >= PLAGE_REEMPLOI_567[1] & v <= PLAGE_REEMPLOI_567[2]), logical(1))]
  ok <- ext_ok && max_ok && !length(coll) && !length(inter) && dans_a2 && !length(dans_plage_a2)
  list(ok = ok, inter = inter,
       txt = sprintf(paste("plages de la mesure de %.0f \u00e0 %.0f ; neuves dans la plage d'A2 [%.0f ; %.0f] : %s ;",
                           "disjointes de #610 %.0f-%.0f, #206/#297 MW, #297 LN, #305, #387 et de 360 380 123 : %s ; maximum \u2264 2^31 \u2212 1 : %s ;",
                           "%d litt\u00e9raux entiers de 8 \u00e0 10 chiffres dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R) ;",
                           "litt\u00e9raux dans la plage d'A2 : %s ; litt\u00e9raux L dont [L ; L + %.0f] touche une plage neuve : %s ;",
                           "fichiers portant un litt\u00e9ral de la plage de #567 [%.0f ; %.0f] (r\u00e9emploi d\u00e9clar\u00e9, hors contr\u00f4le de chevauchement) : %s ;",
                           "chevauchements internes : %s"),
                     min(M), max(M), PLAGE_A2_612[1], PLAGE_A2_612[2], if (dans_a2) "oui" else "NON", PLAGE_EXT_610[1], PLAGE_EXT_610[2],
                     if (ext_ok) "oui" else "NON", if (max_ok) "oui" else "NON", length(lit), length(fs),
                     if (length(dans_plage_a2)) paste(sprintf("%.0f", dans_plage_a2), collapse = ", ") else "aucun", DECALAGE_LITTERAL,
                     if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                     PLAGE_REEMPLOI_567[1], PLAGE_REEMPLOI_567[2], if (length(f567)) paste(f567, collapse = ", ") else "aucun",
                     if (length(inter)) paste(inter, collapse = " ; ") else "aucun"))
})
controle("(graines)", GRAINES_TXT$ok, GRAINES_TXT$txt)
local({
  fs <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE), file.path(RACINE, "app.R"),
          list.files(file.path(RACINE, ".github"), recursive = TRUE, full.names = TRUE, all.files = TRUE))
  fs <- fs[file.exists(fs) & !dir.exists(fs)]
  lit <- function(f) tryCatch(readLines(f, warn = FALSE, skipNul = TRUE), error = function(e) NA_character_)
  trouve <- fs[vapply(fs, function(f) { x <- lit(f); anyNA(x) || any(grepl("simulation_jm1_trapeze", x, fixed = TRUE)) }, logical(1))]
  controle("(m)", !length(trouve), sprintf("aucune occurrence de \u00ab simulation_jm1_trapeze \u00bb dans R/, app.R et .github/ (%d fichiers lus) ; en d\u00e9faut : %s",
                                           length(fs), if (length(trouve)) paste(basename(trouve), collapse = ", ") else "aucun"))
})
if (length(INTEGRITE)) arret_integrite("avant tout tirage")

###############################################################################
#  CALCUL PAR TRANCHES (reprise M42 (b))
###############################################################################
# Cellules du plan : (type, G, loi, b1, b2). BAL : une tranche par (G, loi) ;
# S : une tranche.
cellules_plan <- function() {
  out <- list()
  for (bl in BLOCS_CONNUS) {
    if (bl == "S") { if (R_PLAN$S > 0) out[[length(out) + 1L]] <- list(type = "S", G = "-", loi = "-", b1 = 1L, b2 = length(taches_sonde())); next }
    for (G in G_BLOC[[bl]]) for (loi in names(LOIS)) {
      n <- R_PLAN[[bl]][[loi]]
      if (n > 0) out[[length(out) + 1L]] <- list(type = bl, G = G, loi = loi, b1 = DEBUT_BLOC[[bl]], b2 = DEBUT_BLOC[[bl]] + n - 1L)
    }
  }
  out
}
CELLULES <- cellules_plan()
tranches_de <- function(cel) if (cel$type %in% c("BAL", "S")) list(c(cel$b1, cel$b2)) else
  lapply(seq(cel$b1, cel$b2, by = TAILLE_TRANCHE), function(a) c(a, min(a + TAILLE_TRANCHE - 1L, cel$b2)))
fichier_tranche <- function(cel, tr) file.path(TRAVAIL, sprintf("%s-%s-%s-%06d-%06d.tsv", cel$type, cel$G, cel$loi, tr[1], tr[2]))
ids_ligne <- function(type, L) as.integer(switch(type, OR = L$k, OD = L$k, S = L$u, L$b))
lire_tranche <- function(f, cel, tr) {
  ct <- cols_type(cel$type); cols <- ct[[1]]; texte <- ct[[2]]
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  n <- as.integer(sub("^#FIN\t", "", l[length(l)]))
  if (is.na(n) || length(l) != n + 3L || l[1] != paste0("#CONTEXTE\t", txt_ctx(CTX)) || l[2] != paste(cols, collapse = "\t"))
    refuser("tranche ", basename(f), " : contexte, en-tete ou fin differents du calcul courant -- pas de melange (autre --travail)")
  df <- lire_lignes(l[3:(n + 2L)], cols, texte)
  id <- switch(cel$type, OR = df$k, OD = df$k, S = df$u, df$b)
  if (!all(as.integer(id) >= tr[1] & as.integer(id) <= tr[2]) || !identical(sort(unique(as.integer(id))), seq.int(tr[1], tr[2])))
    refuser("tranche ", basename(f), " : triangles inattendus")
  df
}
ecrire_tranche <- function(f, lignes, cols, n) {
  tmp <- paste0(f, ".tmp")
  ecrire_fichier(tmp, c(paste0("#CONTEXTE\t", txt_ctx(CTX)), paste(cols, collapse = "\t"), lignes, sprintf("#FIN\t%d", n)))
  if (!file.rename(tmp, f)) stop("renommage impossible : ", basename(tmp))
}
premier_admis <- function(cel, tr) {
  cle <- cle_triangle(cel$type, cel$G)
  for (b in seq.int(tr[1], tr[2])) if (isTRUE(tryCatch(admettre(triangle_cle(cle, cel$loi, graine_tri_bloc(cel$type, cel$loi, b)))$ok, error = function(e) FALSE))) return(b)
  NA_integer_
}
taches_tranche <- function(cel, tr) {
  rs <- seq.int(tr[1], tr[2])
  if (cel$type %in% c("OR", "OD")) return(lapply(split(rs, ceiling(seq_along(rs) / 25L)), function(v) list(rs = v, ctl = NA_integer_)))
  if (cel$type == "BAL") return(lapply(rs, function(v) list(rs = v, ctl = NA_integer_)))
  if (cel$type == "S") return(lapply(taches_sonde(), function(t) list(rs = t$u, ctl = NA_integer_, s = t)))
  r1 <- premier_admis(cel, tr)
  out <- list()
  if (!is.na(r1)) out[[1L]] <- list(rs = r1, ctl = r1)
  reste <- setdiff(rs, r1)
  c(out, lapply(split(reste, ceiling(seq_along(reste) / 5L)), function(v) list(rs = v, ctl = NA_integer_)))
}
executer_tache <- function(cel, t) {
  switch(cel$type,
         OR = lapply(t$rs, function(k) un_oracle(cel$G, cel$loi, k)),
         OD = lapply(t$rs, function(k) un_oracle("D", cel$loi, k)),
         BAL = un_balayage(cel$G, cel$loi, t$rs, B_RUN),
         S = une_sonde(t$s$cfg, t$s$ir, t$s$u, B_RUN),
         unlist(lapply(t$rs, function(b) un_triangle(cel$type, cel$G, cel$loi, b, B_RUN, ctl = identical(b, t$ctl))), recursive = FALSE))
}
manquantes_de <- function(cel) Filter(function(tr) !file.exists(fichier_tranche(cel, tr)), tranches_de(cel))
N_CALC <- 0L; N_TR_CALC <- 0L; T_CALC <- 0; INTERROMPU <- FALSE
# Cout d'une unite (triangle, ou point de la sonde) en secondes d'horloge x
# processus, par type ; valeurs par defaut remplacees par la mesure.
COUT_UNITE <- c(OR = 0.05, OD = 0.05, M7a = 14, M7b = 27, M5 = 14, M6 = 14, C = 13, D = 13, BAL = 140, S = 45)
if (OPT_ESSAI) COUT_UNITE <- COUT_UNITE * B_ESSAI / B_MESURE
COUT_MESURE <- stats::setNames(rep(FALSE, length(COUT_UNITE)), names(COUT_UNITE))
DUREE_MAX_S <- OPT_DUREE_MAX * 3600
# Groupes de tranches d'un meme bloc, toutes cellules confondues, traites par
# un seul appel de mclapply (ordonnancement dynamique) : OPT_PROC tranches
# (10 pour les oracles). Chaque ligne ne depend que de ses graines : le
# resultat ne depend ni des groupes ni du nombre de processus.
for (bl in ORDRE_CALCUL) {
  if (INTERROMPU) break
  if (!bl %in% OPT_BLOCS) next
  a_faire <- unlist(lapply(Filter(function(x) x$type == bl, CELLULES), function(cel)
    lapply(manquantes_de(cel), function(tr) list(cel = cel, tr = tr))), recursive = FALSE)
  if (!length(a_faire)) next
  taille_g <- if (bl %in% c("OR", "OD")) 10L else OPT_PROC
  groupes <- split(a_faire, ceiling(seq_along(a_faire) / taille_g))
  for (gr in groupes) {
    n_u <- sum(vapply(gr, function(x) x$tr[2] - x$tr[1] + 1L, 1L))
    estime <- n_u * COUT_UNITE[[bl]] / min(OPT_PROC, n_u)
    if (secs(t_debut) + estime > DUREE_MAX_S) { INTERROMPU <- TRUE; break }
    t0 <- Sys.time()
    taches <- unlist(lapply(seq_along(gr), function(j) lapply(taches_tranche(gr[[j]]$cel, gr[[j]]$tr), function(t) c(t, list(j = j)))),
                     recursive = FALSE)
    res <- parallel::mclapply(taches, function(t) executer_tache(gr[[t$j]]$cel, t), mc.cores = OPT_PROC, mc.preschedule = FALSE)
    ok <- vapply(res, function(x) is.list(x) && length(x) && all(vapply(x, is.list, logical(1))), logical(1))
    if (!all(ok)) stop("groupe de tranches ", bl, " : processus en erreur ; relancer pour reprendre")
    j_t <- vapply(taches, function(t) t$j, 1L)
    ct <- cols_type(bl)
    for (j in seq_along(gr)) {
      sel <- unlist(res[j_t == j], recursive = FALSE)
      sel <- sel[order(vapply(sel, function(L) ids_ligne(bl, L), 1L))]
      ecrire_tranche(fichier_tranche(gr[[j]]$cel, gr[[j]]$tr), vapply(sel, format_ligne, "", cols = ct[[1]], texte = ct[[2]]), ct[[1]], length(sel))
      N_CALC <- N_CALC + length(sel); N_TR_CALC <- N_TR_CALC + 1L
    }
    lignes <- unlist(res, recursive = FALSE)
    DUREE_GROUPE <- secs(t0)
    T_CALC <- T_CALC + DUREE_GROUPE
    c_u <- DUREE_GROUPE * min(OPT_PROC, length(taches)) / n_u
    COUT_UNITE[[bl]] <- if (COUT_MESURE[[bl]]) max(COUT_UNITE[[bl]], c_u) else c_u
    COUT_MESURE[[bl]] <- TRUE
    message(sprintf("%s : %s, %d tranche(s) calculee(s) (%s ; %.0f s)", horodatage(), bl, length(gr),
                    paste(unique(vapply(gr, function(x) paste(x$cel$G, x$cel$loi), "")), collapse = ", "), DUREE_GROUPE))
    # (r567) : un echec arrete la mesure et revient au mainteneur (par. 8).
    if (bl %in% BLOCS_567) {
      r <- vapply(lignes, function(L) if (identical(L$variante, "V0") && isTRUE(L$ctl == 1) && L$statut %in% "admis") as.integer(isTRUE(L$r567 == 1)) else NA_integer_, 1L)
      if (any(r %in% 0L)) {
        controle("(r567)", FALSE, sprintf("%s : %d triangle(s) de contr\u00f4le dont le V0 recalcul\u00e9 diff\u00e8re du brut de #567 ; mesure arr\u00eat\u00e9e, retour au mainteneur (le V0 serait \u00e0 recalculer en entier)",
                                          bl, sum(r %in% 0L)))
        arret_integrite("pendant le calcul ((r567))")
      }
    }
  }
}
INCOMPLET <- any(vapply(CELLULES, function(cel) length(manquantes_de(cel)) > 0L, logical(1)))
if (INTERROMPU || INCOMPLET) {
  reste <- sum(vapply(CELLULES, function(cel) length(manquantes_de(cel)), 1L))
  # Bloc S complet (R4 : lance en premier) : tableau et regle du constat (1)
  # imprimes et ecrits dans le dossier de travail, a titre provisoire.
  CEL_S <- Filter(function(cel) cel$type == "S", CELLULES)
  if (length(CEL_S) && !any(vapply(CEL_S, function(cel) length(manquantes_de(cel)) > 0L, logical(1)))) {
    SON_P <- do.call(rbind, unlist(lapply(CEL_S, function(cel) lapply(tranches_de(cel), function(tr) lire_tranche(fichier_tranche(cel, tr), cel, tr))), recursive = FALSE))
    EV_P <- evaluer_sonde(SON_P)
    C1 <- c(sprintf("## Constat (1), bloc S complet -- PROVISOIRE (mesure #612 incompl\u00e8te%s)", if (OPT_ESSAI) " ; ESSAI, non versionnable" else ""), "",
            sprintf("B = %s ; SHA %s ; md5 R/engine.R %s ; script %s ; protocole md5 %s. Contr\u00f4les avant tout tirage : OK. Les contr\u00f4les sur les lignes calcul\u00e9es et (1) fin ne sont \u00e9valu\u00e9s qu'\u00e0 la mesure compl\u00e8te.",
                    format(B_RUN), SHA_DEBUT, MD5_MOTEUR_DEBUT, MD5_SCRIPT, MD5_PROTOCOLE_T0), "",
            lignes_constat_1(EV_P))
    F_C1 <- file.path(TRAVAIL, "constat-1-sonde.md")
    ecrire_fichier(F_C1, C1)
    ecrire_console(C1)
    ecrire_fichier(JOURNAL_T, sprintf("- Constat (1) (bloc S complet, provisoire) : %s ; r\u00e8gle : %s ; %s md5 %s",
                                      horodatage(), if (is.na(EV_P$regle)) "non \u00e9valuable" else if (EV_P$regle) "CORRECTION" else "constat document\u00e9, mineur",
                                      basename(F_C1), md5_fichier(F_C1)), mode = "ab")
  }
  ecrire_fichier(JOURNAL_T, sprintf("- Segment interrompu : %s ; %d tranche(s) calcul\u00e9e(s) dans ce segment, %d restante(s) (--duree-max %s h ; blocs %s)",
                                    horodatage(), N_TR_CALC, reste, format(OPT_DUREE_MAX), paste(OPT_BLOCS, collapse = ",")), mode = "ab")
  ecrire_console(c(sprintf("Segment : %d tranche(s) calcul\u00e9e(s), %d restante(s) ; dur\u00e9e %s s ; relancer avec le m\u00eame --travail (sans --bloc, ou avec les blocs restants) pour reprendre ; si le reste tient dans un segment, --duree-max 1.6 (marge d'agr\u00e9gation finale, R7).",
                           N_TR_CALC, reste, num(secs(t_debut), 0)), "SEGMENT INTERROMPU"))
  if (TRAVAIL_TEMP) { GARDER_TRAVAIL <- TRUE; message("dossier d'essai temporaire conserve pour la reprise : ", TRAVAIL) }
  quit(status = 3L)
}
LECT <- list(); FICHIERS_TR <- character(0)
for (cel in CELLULES) for (tr in tranches_de(cel)) {
  f <- fichier_tranche(cel, tr)
  d <- lire_tranche(f, cel, tr)
  LECT[[cel$type]][[length(LECT[[cel$type]]) + 1L]] <- d
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
rbind_type <- function(types) { x <- unlist(LECT[types], recursive = FALSE); if (length(x)) do.call(rbind, x) else NULL }
D <- rbind_type(BLOCS_TRI)
ORA <- rbind_type(c("OR", "OD"))
BAL <- rbind_type("BAL")
SON <- rbind_type("S")
# Oracles (non versionnes) : format de #567 (oracle.tsv) pour les trapezes,
# fichier distinct pour D ; md5 au T0.
COLS_ORA_BRUT <- setdiff(COLONNES_ORA, "duree_s")
ecrire_oracle <- function(f, d) ecrire_fichier(f, c(paste(COLS_ORA_BRUT, collapse = "\t"),
  vapply(seq_len(NROW(d)), function(i) format_ligne(as.list(d[i, , drop = FALSE]), COLS_ORA_BRUT, COL_TEXTE_ORA), "")))
F_ORACLE <- file.path(TRAVAIL, "oracle-567.tsv"); F_ORACLE_D <- file.path(TRAVAIL, "oracle-D.tsv")
ecrire_oracle(F_ORACLE, ORA[ORA$G != "D", , drop = FALSE])
ecrire_oracle(F_ORACLE_D, ORA[ORA$G == "D", , drop = FALSE])
MD5_ORACLE <- md5_fichier(F_ORACLE); MD5_ORACLE_D <- md5_fichier(F_ORACLE_D)

###############################################################################
#  TEMOIN : ORACLES, rho, p du temoin par triangle (definition de #567, K3)
###############################################################################
# Copies declarees de #567 : ic_cp(), taille_lissee(), lecture().
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
txt_classe <- function(c_) if (isTRUE(c_$disj)) sprintf("%s (**%s**)", c_$classe, c_$cote) else c_$classe
OR <- list()
for (cle in unique(ORA$G)) for (loi in names(LOIS)) {
  O <- ORA[ORA$G == cle & ORA$loi == loi, , drop = FALSE]
  if (!nrow(O)) next
  adm <- O[O$statut == "admis", , drop = FALSE]; n_adm <- nrow(adm)
  OR[[paste(cle, loi)]] <- c(list(n_tire = nrow(O), n_adm = n_adm),
    lapply(stats::setNames(nm = CLES), function(s) {
      S0 <- adm[[paste0("obs:", s)]]; S <- S0[is.finite(S0)]
      list(S0 = S0, n_fin = length(S), rho = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], B_RUN, a, n_adm), 1),
           taille_or = vapply(SEUILS, function(a) taille_lissee(S, QUEUE[[s]], length(S), a, n_adm), 1))
    }))
}
cle_oracle <- function(bloc, G) if (bloc == "D") "D" else if (G == "8x8") "8x7" else G
rho_de <- function(cle, loi, s, ia) { o <- OR[[paste(cle, loi)]]; if (is.null(o)) NA_real_ else o[[s]]$rho[[ia]] }
# p du temoin : engine_p_mc(S0 de l'oracle, statistique observee, sens),
# calculee par (bloc, G, loi) en parallele ; V0 reprend celle de V2 quand
# les statistiques observees sont identiques (controle (so)).
for (s in CLES) D[[paste0("pT:", s)]] <- NA_real_
local({
  grp <- unique(D[, c("bloc", "G", "loi")])
  res <- parallel::mclapply(seq_len(nrow(grp)), function(i) {
    x <- grp[i, ]; idx <- which(D$bloc == x$bloc & D$G == x$G & D$loi == x$loi & D$statut %in% c("admis", "echec"))
    o <- OR[[paste(cle_oracle(x$bloc, x$G), x$loi)]]
    if (is.null(o) || !length(idx)) return(list(idx = idx, P = NULL))
    cache <- list()
    P <- t(vapply(idx, function(r) {
      obs <- vapply(CLES, function(s) D[[paste0("obs:", s)]][r], 1)
      key <- paste(D$b[r], paste(fv_vec(obs), collapse = " "))
      if (!is.null(cache[[key]])) return(cache[[key]])
      p <- vapply(CLES, function(s) if (is.finite(obs[[s]])) engine_p_mc(o[[s]]$S0, obs[[s]], QUEUE[[s]])$p_mc else NA_real_, 1)
      cache[[key]] <<- p
      p
    }, numeric(NS)))
    list(idx = idx, P = P)
  }, mc.cores = OPT_PROC, mc.preschedule = FALSE)
  for (r in res) if (!is.null(r$P)) for (j in seq_len(NS)) D[[paste0("pT:", CLES[j])]][r$idx] <<- r$P[, j]
})

###############################################################################
#  CONTROLES SUR LES LIGNES CALCULEES
###############################################################################
ADM <- D[D$statut %in% c("admis", "echec"), , drop = FALSE]
cles_lignes <- function(d) paste(d$bloc, d$G, d$loi, d$b)
# (g') sur chaque triangle tire des trapezes.
local({
  d <- D[D$bloc %in% BLOCS_TRAPEZE & !(D$motif_code %in% "erreur" & is.na(D$gp)), , drop = FALSE]
  ok <- nrow(d) > 0L && all(d$gp %in% 1)
  i <- which(vapply(CTRL, function(k) k$code == "(g')", logical(1)))
  CTRL[[i]]$detail <<- paste(CTRL[[i]]$detail, sprintf("; plan : %d / %d lignes de trap\u00e8ze o\u00f9 le trap\u00e8ze est la troncature du 8 x 8", sum(d$gp %in% 1), nrow(d)))
  if (!ok) { CTRL[[i]]$ok <<- FALSE; INTEGRITE <<- c(INTEGRITE, "(g')") }
})
# (r567), (al), (i1) sur les triangles de controle.
local({
  c5 <- D[D$bloc %in% BLOCS_567 & D$variante == "V0" & D$ctl %in% 1 & D$statut == "admis", , drop = FALSE]
  n_tr <- length(unique(paste(D$bloc, D$G, D$loi, (D$b - 1L) %/% TAILLE_TRANCHE)[D$bloc %in% BLOCS_567]))
  controle("(r567)", nrow(c5) > 0L && nrow(c5) == n_tr && all(c5$r567 %in% 1),
           sprintf("V0 recalcul\u00e9 \u00e0 B = 999 sur le premier triangle admis de chaque tranche de #567 couverte (M7a, M5, M6) : %d / %d identiques au brut relu en %%.17g (13 p_mc, obs, s2_regle, s2_dir, R_hat, msep) ; %d tranche(s) ; md5 de R/engine.R \u00e0 la mesure de #567 %s, \u00e0 ce calcul %s (l'identit\u00e9 des nombres fait foi)",
                   sum(c5$r567 %in% 1), nrow(c5), n_tr, MD5_MOTEUR_567, MD5_MOTEUR_DEBUT))
  ca <- D[D$ctl %in% 1 & D$bloc %in% BLOCS_TRAPEZE & D$statut == "admis", , drop = FALSE]
  controle("(al)", nrow(ca) > 0L && all(ca$al %in% 1),
           sprintf("\u03c3* de la boucle all\u00e9g\u00e9e identical() \u00e0 sigma_boot de mw_bootstrap(), premier triangle de chaque tranche des trap\u00e8zes : V2 %d / %d ; V0 %d / %d",
                   sum(ca$al[ca$variante == "V2"] %in% 1), sum(ca$variante == "V2"), sum(ca$al[ca$variante == "V0"] %in% 1), sum(ca$variante == "V0")))
  ci <- D[D$ctl %in% 1 & D$statut == "admis" & !is.na(D$i1), , drop = FALSE]
  n_ctl <- length(unique(paste(D$bloc, D$G, D$loi, D$b)[D$ctl %in% 1 & D$statut == "admis"]))
  controle("(i1)", nrow(ci) > 0L && all(ci$i1 %in% 1) && length(unique(cles_lignes(ci))) == n_ctl,
           sprintf("statistiques observ\u00e9es par le chemin de l'oracle (stats_oracle()) identical() \u00e0 bootstrap$stats_obs (validit\u00e9 du t\u00e9moin) : %d / %d triangles de contr\u00f4le",
                   length(unique(cles_lignes(ci[ci$i1 %in% 1, ]))), n_ctl))
})
# (o) : carre, statistiques observees du 8 x 8 identical() a celles du 8 x 7
# tronque, par triangle. Critere de K0 (C2) : un defaut declenche R0, sans
# INTEGRITE ECHEC.
local({
  d <- ADM[ADM$bloc == "C" & ADM$statut == "admis", , drop = FALSE]
  if (!nrow(d)) { controle("(o)", TRUE, "sans objet (aucun carr\u00e9 au niveau)", nature = "k0"); return(invisible()) }
  controle("(o)", all(d$o8 %in% 1), sprintf("crit\u00e8re de K0 : carr\u00e9 8 x 8 : statistiques observ\u00e9es identical() \u00e0 celles du 8 x 7 tronqu\u00e9 (m\u00eame t\u00e9moin) : %d / %d triangles ; 8 x 7 tronqu\u00e9 non ajustable : %d",
                                           sum(d$o8 %in% 1), nrow(d), sum(is.na(d$o8))), nature = "k0")
})
# (so) et (inv) : apparier V0 et V2 par triangle.
paires <- function(G_, blocs, loi) {
  d <- ADM[ADM$bloc %in% blocs & ADM$G == G_ & ADM$loi == loi, , drop = FALSE]
  v2 <- d[d$variante == "V2", , drop = FALSE]; v0 <- d[d$variante == "V0", , drop = FALSE]
  b <- intersect(v2$b, v0$b)
  list(v2 = v2[match(b, v2$b), , drop = FALSE], v0 = v0[match(b, v0$b), , drop = FALSE], b = b)
}
CEL_M <- list("8x5" = "M5", "8x6" = "M6", "8x7" = c("M7a", "M7b"))
INV <- list()
local({
  det_so <- character(0); ok_so <- TRUE; ok_inv <- TRUE; det_inv <- character(0)
  for (G in GEOM$code) for (loi in names(LOIS)) {
    pr <- paires(G, CEL_M[[G]], loi)
    if (!length(pr$b)) next
    so <- chaine(pr$v2, paste0("obs:", CLES)) == chaine(pr$v0, paste0("obs:", CLES))
    ok_so <- ok_so && all(so)
    det_so <- c(det_so, sprintf("%s %s %d / %d", G, loi, sum(so), length(so)))
    cl <- cles_libres(G)
    ident <- chaine(pr$v2, paste0("p:", cl)) == chaine(pr$v0, paste0("p:", cl))
    cause <- ifelse(ident, "-", ifelse(pr$v2$cumuls_retires %in% 1 | pr$v0$cumuls_retires %in% 1 | pr$v2$plafond %in% 1 | pr$v0$plafond %in% 1, "retirage",
                    ifelse(!(pr$v2$B_eff_min == pr$v0$B_eff_min) %in% TRUE, "B effectif", "autre")))
    part <- mean(ident)
    INV[[paste(G, loi)]] <<- list(G = G, loi = loi, n = length(ident), ident = sum(ident), part = part, causes = table(cause[!ident]),
                                  ok = part >= SEUIL_INV)
    ok_inv <- ok_inv && part >= SEUIL_INV
    t <- table(cause[!ident])
    det_inv <- c(det_inv, sprintf("%s %s %d / %d (%s)%s", G, loi, sum(ident), length(ident), num(part, 4),
                                  if (length(t)) paste0(" ; \u00e9carts : ", paste(sprintf("%s %d", names(t), as.integer(t)), collapse = ", ")) else ""))
  }
  controle("(so)", ok_so && length(det_so) > 0L, sprintf("statistiques observ\u00e9es (13 cl\u00e9s) identiques entre V0 et V2, par triangle admis : %s", paste(det_so, collapse = " ; ")))
  # (inv) : critere de K0 (C2), un defaut declenche R0 sans INTEGRITE ECHEC.
  controle("(inv)", ok_inv && length(det_inv) > 0L,
           sprintf("crit\u00e8re de K0, invariance : p_mc des cl\u00e9s autres que PenteIntra et Alpha (autres que PenteIntra sur 8 x 7) identiques entre V0 et V2 sur au moins %s des triangles de chaque (G, \u2113) : %s",
                   "99,5 %", paste(det_inv, collapse = " ; ")), nature = "k0")
})
# (dc) : carre et D, une execution : le predicat de simulation directe vaut
# la meme chose sous V0 et sous V2 (meme simulation). Decision C2 : sur le
# carre, critere de K0 (defaut -> R0, sans INTEGRITE ECHEC) ; sur le bloc D,
# un defaut rend les constats (3) et (4) non evaluables, sans R0.
local({
  meme <- function(x) (x$sim_dir == x$sim_dir_v2) %in% TRUE
  dc <- ADM[ADM$bloc == "C" & ADM$statut == "admis", , drop = FALSE]
  if (!nrow(dc)) controle("(dc) carr\u00e9", TRUE, "sans objet (aucun carr\u00e9 au niveau)", nature = "k0") else
    controle("(dc) carr\u00e9", all(meme(dc)),
             sprintf("crit\u00e8re de K0 : carr\u00e9 : pr\u00e9dicat .mw_simulation_sigma_direct() identique sous V0 et V2 (simulation identique, une ex\u00e9cution) : %d / %d ; pr\u00e9dicat faux : %d / %d",
                     sum(meme(dc)), nrow(dc), sum(dc$sim_dir %in% 0), nrow(dc)), nature = "k0")
  dd <- ADM[ADM$bloc == "D" & ADM$statut == "admis", , drop = FALSE]
  if (!nrow(dd)) controle("(dc) D", TRUE, "sans objet (aucun bloc D au niveau)", nature = "constat") else
    controle("(dc) D", all(meme(dd)),
             sprintf("bloc D (constats (3) et (4)) : pr\u00e9dicat .mw_simulation_sigma_direct() identique sous V0 et V2 (simulation identique, une ex\u00e9cution) : %d / %d ; cas M-1 (b) (pr\u00e9dicat vrai) : %d / %d ; un d\u00e9faut rend les constats (3) et (4) non \u00e9valuables, sans R0",
                     sum(meme(dd)), nrow(dd), sum(dd$sim_dir %in% 1), nrow(dd)), nature = "constat")
})
# (oracle) : rho et tailles du temoin de #567 reproduits aux cinq decimales
# imprimees (78 lignes) ; md5 du fichier au format de #567. Lecture du
# tableau de #567 commune a l'essai et a la mesure (R1) : 78 lignes, une par
# (G, loi, cle) des trapezes, sans doublon, quatre champs numeriques a cinq
# decimales (rho a 0,10 et 0,05, tailles a 0,10 et 0,05). En essai (N0 et B
# reduits), seule la lecture est controlee, sans comparaison des valeurs.
lire_tableau_oracle_567 <- function() {
  tx <- readLines(file.path(RACINE, TABLEAU_567), warn = FALSE, encoding = "UTF-8")
  rx <- "^\\| (8x[567]) \\| ([NE]) \\| ([A-Za-z0-9]+) \\([a-z]+\\) \\| [0-9]+ / [0-9]+ \\|"
  l <- tx[grepl(rx, tx)]
  lapply(l, function(x) {
    f <- trimws(strsplit(x, "|", fixed = TRUE)[[1]])[-1]
    list(G = f[1], loi = f[2], s = sub(" .*", "", f[3]), lu = sub(" \\(.*$", "", f[8:11]))
  })
}
local({
  T567 <- lire_tableau_oracle_567()
  n_l <- length(T567)
  champs_ok <- vapply(T567, function(x) length(x$lu) == 4L && !anyNA(x$lu) && all(grepl("^[0-9]+,[0-9]{5}$", x$lu)) &&
                        x$G %in% GEOM$code && x$loi %in% names(LOIS) && x$s %in% CLES, logical(1))
  cles_t <- vapply(T567, function(x) paste(x$G, x$loi, x$s), "")
  lecture_ok <- n_l == 78L && all(champs_ok) && !anyDuplicated(cles_t)
  txt_lecture <- sprintf("lecture du tableau de #567 (%s) : %d ligne(s) (78 attendues), %d \u00e0 quatre champs num\u00e9riques \u00e0 cinq d\u00e9cimales et (G, \u2113, cl\u00e9) connus, %d (G, \u2113, cl\u00e9) distincts",
                         TABLEAU_567, n_l, sum(champs_ok), length(unique(cles_t)))
  if (OPT_ESSAI) {
    controle("(oracle)", lecture_ok, sprintf("essai (N0 = %d, B = %s) : valeurs non compar\u00e9es ; %s ; md5 oracle-567.tsv %s", N0_ESSAI, format(B_RUN), txt_lecture, MD5_ORACLE))
    return(invisible())
  }
  n_ok <- 0L; ecarts <- character(0)
  for (x in T567) {
    o <- OR[[paste(x$G, x$loi)]]; s <- x$s
    calc <- if (is.null(o) || is.null(o[[s]])) rep("?", 4) else c(num(o[[s]]$rho[["a10"]], 5), num(o[[s]]$rho[["a05"]], 5), num(o[[s]]$taille_or[["a10"]], 5), num(o[[s]]$taille_or[["a05"]], 5))
    if (identical(calc, x$lu)) n_ok <- n_ok + 1L else ecarts <- c(ecarts, sprintf("%s %s %s", x$G, x$loi, s))
  }
  ok <- lecture_ok && n_ok == 78L
  controle("(oracle)", ok, sprintf("\u03c1 (0,10 ; 0,05) et tailles du t\u00e9moin de #567 reproduits aux cinq d\u00e9cimales : %d / %d lignes ; %s ; md5 oracle-567.tsv %s (#567 : %s, %s) ; \u00e9carts : %s",
                                   n_ok, n_l, txt_lecture, MD5_ORACLE, MD5_ORACLE_567, if (identical(MD5_ORACLE, MD5_ORACLE_567)) "identique" else "diff\u00e9rent",
                                   if (length(ecarts)) paste(utils::head(ecarts, 10), collapse = ", ") else "aucun"))
})
# (bal) : point k = 1 identique a V2, point "regle" identique a V0 (p_mc des
# 13 cles, retirage) ; exceptions comptees : colonne J-1 degeneree (V2 simule
# alors la regle) ou cas M-1 (b) (V0 simule alors le direct).
local({
  if (is.null(BAL)) { controle("(bal)", TRUE, "sans objet (aucun balayage au niveau)"); return(invisible()) }
  cols <- c(paste0("p:", CLES), "cumuls_retires")
  n1 <- 0L; ok1 <- 0L; nr <- 0L; okr <- 0L; exc <- 0L
  for (i in which(BAL$statut == "admis" & BAL$point %in% c("k=1", "regle"))) {
    x <- BAL[i, ]
    ref <- D[D$bloc %in% CEL_M[[x$G]] & D$G == x$G & D$loi == x$loi & D$b == x$b & D$variante == (if (x$point == "k=1") "V2" else "V0") & D$statut == "admis", , drop = FALSE]
    attendu <- if (x$point == "k=1") x$sim_dir_v2 %in% 1 else x$sim_dir %in% 0
    if (!attendu) { exc <- exc + 1L; next }
    same <- nrow(ref) == 1L && identical(chaine(x, cols), chaine(ref, cols))
    if (x$point == "k=1") { n1 <- n1 + 1L; ok1 <- ok1 + same } else { nr <- nr + 1L; okr <- okr + same }
  }
  controle("(bal)", n1 > 0L && nr > 0L && ok1 == n1 && okr == nr,
           sprintf("balayage : point k = 1 (\u03c3\u00b2 pos\u00e9 = \u03c3\u0302\u00b2_dir) identique \u00e0 V2 : %d / %d ; point \u00ab r\u00e8gle \u00bb (\u03c3\u00b2 pos\u00e9 = \u03c3\u0302\u00b2_r\u00e8gle) identique \u00e0 V0 : %d / %d (p_mc des 13 cl\u00e9s et retirage, %%.17g) ; exceptions (colonne J\u22121 d\u00e9g\u00e9n\u00e9r\u00e9e ou cas M-1 (b)) : %d",
                   ok1, n1, okr, nr, exc))
})
# (rep) : premier et dernier triangles admis de chaque cellule des blocs a
# triangles recalcules ; lignes identiques hors duree.
REP_ECH <- do.call(rbind, lapply(Filter(function(c_) c_$type %in% BLOCS_TRI, CELLULES), function(cel) {
  d <- ADM[ADM$bloc == cel$type & ADM$G == cel$G & ADM$loi == cel$loi & ADM$statut == "admis", , drop = FALSE]
  if (!nrow(d)) return(NULL)
  b <- unique(d$b); i <- unique(c(1L, length(b)))
  data.frame(bloc = cel$type, G = cel$G, loi = cel$loi, b = as.integer(b[i]),
             ctl = vapply(b[i], function(x) as.integer(any(d$ctl[d$b == x] %in% 1)), 1L), stringsAsFactors = FALSE)
}))
t_rep <- Sys.time()
COLS_REP <- setdiff(COLONNES, "duree_s")
C_REP <- parallel::mclapply(seq_len(NROW(REP_ECH)), function(i) {
  x <- REP_ECH[i, ]
  l <- un_triangle(x$bloc, x$G, x$loi, x$b, B_RUN, ctl = isTRUE(x$ctl == 1))
  ref <- D[D$bloc == x$bloc & D$G == x$G & D$loi == x$loi & D$b == x$b, , drop = FALSE]
  ref <- ref[match(vapply(l, function(L) L$variante, ""), ref$variante), , drop = FALSE]
  nrow(ref) == length(l) && identical(vapply(l, format_ligne, "", cols = COLS_REP),
                                      vapply(seq_len(nrow(ref)), function(j) format_ligne(as.list(ref[j, , drop = FALSE]), COLS_REP), ""))
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
# (rep), oracles (R2) : premier et dernier k de chaque cellule des blocs OR et
# OD recalcules par un_oracle() ; lignes identiques hors duree (statut,
# motif et 13 statistiques, %.17g).
REP_ORA <- do.call(rbind, lapply(Filter(function(c_) c_$type %in% c("OR", "OD"), CELLULES), function(cel)
  data.frame(type = cel$type, cle = if (cel$type == "OD") "D" else cel$G, loi = cel$loi, k = unique(c(cel$b1, cel$b2)), stringsAsFactors = FALSE)))
COLS_REP_ORA <- setdiff(COLONNES_ORA, "duree_s")
C_REP_ORA <- parallel::mclapply(seq_len(NROW(REP_ORA)), function(i) {
  x <- REP_ORA[i, ]
  l <- un_oracle(x$cle, x$loi, x$k)
  ref <- ORA[ORA$G == x$cle & ORA$loi == x$loi & ORA$k == x$k, , drop = FALSE]
  nrow(ref) == 1L && identical(format_ligne(l, COLS_REP_ORA, COL_TEXTE_ORA), format_ligne(as.list(ref[1, , drop = FALSE]), COLS_REP_ORA, COL_TEXTE_ORA))
}, mc.cores = OPT_PROC, mc.preschedule = FALSE)
DUREE_REP <- secs(t_rep)
local({
  ok_t <- vapply(C_REP, isTRUE, logical(1)); ok_o <- vapply(C_REP_ORA, isTRUE, logical(1))
  controle("(rep)", NROW(REP_ECH) > 0L && all(ok_t) && NROW(REP_ORA) > 0L && all(ok_o),
           sprintf("premier et dernier triangles admis de chaque cellule (blocs M7a, M7b, M5, M6, C, D) recalcul\u00e9s : %d / %d triangles aux lignes identiques, hors dur\u00e9e ; premier et dernier k de chaque cellule des oracles (OR, OD) recalcul\u00e9s : %d / %d lignes identiques, hors dur\u00e9e",
                   sum(ok_t), NROW(REP_ECH), sum(ok_o), NROW(REP_ORA)))
})
# (1) fin.
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
EMPREINTE_FIN <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
DIFF_MOTEUR_FIN <- moteur_sans_diff()
local({
  ctx_tr <- unique(unname(vapply(FICHIERS_TR, function(f) readLines(f, n = 1L, warn = FALSE), "")))
  ok_ctx <- length(ctx_tr) == 1L && identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))
  ok <- MD5_MOTEUR_DEBUT == MD5_MOTEUR_FIN && SHA_DEBUT == SHA_FIN && SHA_DEBUT != "inconnu" && EMPREINTE_DEBUT == EMPREINTE_FIN &&
    identical(J0$sha, SHA_DEBUT) && identical(J0$md5, MD5_MOTEUR_DEBUT) && identical(J0$empreinte, EMPREINTE_DEBUT) && ok_ctx &&
    DIFF_MOTEUR_FIN && substitutions_restaurees() && identical(md5_fichier(file.path(RACINE, PROTOCOLE)), MD5_PROTOCOLE_T0)
  controle("(1) fin", ok, sprintf("md5 du protocole d\u00e9but %s, fin %s ; md5 R/engine.R d\u00e9but %s, fin %s, JOURNAL %s ; SHA d\u00e9but %s, fin %s, JOURNAL %s ; empreinte #231 d\u00e9but %s, fin %s ; git diff --quiet HEAD -- R/engine.R \u00e0 la fin : %s ; substitutions restaur\u00e9es : %s ; contexte identique dans les %d tranche(s) : %s",
                                   MD5_PROTOCOLE_T0, md5_fichier(file.path(RACINE, PROTOCOLE)),
                                   MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN, J0$md5, SHA_DEBUT, SHA_FIN, J0$sha, EMPREINTE_DEBUT, EMPREINTE_FIN,
                                   if (DIFF_MOTEUR_FIN) "vide" else "NON VIDE", if (substitutions_restaurees()) "oui" else "NON",
                                   length(FICHIERS_TR), if (ok_ctx) "oui" else "NON"))
})
ORDRE_CTRL <- c("(1) d\u00e9but", "(1) fin", "(t)", "(e)", "(a)", "(v0)", "(v2)", "(r567) initial", "(r567)", "(g)", "(g')", "(c)",
                "(graines)", "(m)", "(i1)", "(al)", "(so)", "(inv)", "(o)", "(dc) carr\u00e9", "(dc) D", "(oracle)", "(bal)", "(rep)")
CTRL <- CTRL[order(match(vapply(CTRL, function(k) k$code, ""), ORDRE_CTRL))]

###############################################################################
#  CRITERES K0 A K4 ET REGLES (par. 4), EVALUES MECANIQUEMENT
###############################################################################
dec <- function(p, a) is.finite(p) & p < a
# Deux decisions appariees A et B : Delta = (n10 - n01)/n ; McNemar exact
# (bilateral, et unilateral vers moins de rejets de A) ; intervalle exact
# conditionnel a 90 % : (2 pi - 1)(n10 + n01)/n, pi par Clopper-Pearson.
apparier <- function(a, b) {
  n <- length(a); n10 <- sum(a & !b); n01 <- sum(!a & b); d <- n10 + n01
  delta <- if (n) (n10 - n01) / n else NA_real_
  p2 <- if (d) stats::binom.test(n10, d, 0.5)$p.value else 1
  p_inf <- if (d) stats::binom.test(n10, d, 0.5, alternative = "less")$p.value else 1
  ic <- if (!n) c(NA_real_, NA_real_) else if (d) (2 * as.numeric(stats::binom.test(n10, d, conf.level = NIV_IC)$conf.int) - 1) * d / n else c(0, 0)
  list(n = n, n10 = n10, n01 = n01, kA = sum(a), kB = sum(b), delta = delta, p2 = p2, p_inf = p_inf, ic = ic)
}
aligne <- function(x, ia) is.finite(x$ic[1]) && x$ic[1] >= -DELTA[[ia]] && x$ic[2] <= DELTA[[ia]]
txt_ap <- function(x) if (!x$n) "\u2014" else sprintf("%s %s (n10 = %d, n01 = %d)", num(x$delta, D_IC), txt_ic(x$ic), x$n10, x$n01)
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
# Population appariee d'une geometrie de trapeze : triangles admis aux deux
# variantes ; colonnes V2, V0, temoin.
pop_trap <- function(G, loi, blocs = CEL_M[[G]]) paires(G, blocs, loi)
dec_pop <- function(pr, s, a) list(V2 = dec(pr$v2[[paste0("p:", s)]], a), V0 = dec(pr$v0[[paste0("p:", s)]], a),
                                   T = dec(pr$v2[[paste0("pT:", s)]], a))
classe_de <- function(dd, cle, loi, s, ia) lecture(sum(dd), length(dd), rho_de(cle, loi, s, ia))
# K0 : refus et p absentes par (bloc, G, loi, variante).
K0_TAB <- do.call(rbind, lapply(Filter(function(c_) c_$type %in% BLOCS_TRI, CELLULES), function(cel) {
  dt <- D[D$bloc == cel$type & D$G == cel$G & D$loi == cel$loi, , drop = FALSE]
  do.call(rbind, lapply(unique(dt$variante), function(v) {
    x <- dt[dt$variante == v, , drop = FALSE]; a <- x[x$statut %in% c("admis", "echec"), , drop = FALSE]
    P <- as.matrix(a[, paste0("p:", CLES), drop = FALSE])
    ab <- if (nrow(a)) sum(rowSums(!is.finite(P)) > 0) else 0L
    data.frame(bloc = cel$type, G = cel$G, loi = cel$loi, variante = v, tires = nrow(x), admis = sum(x$statut == "admis"),
               echec = sum(x$statut == "echec"), refus = sum(x$statut == "refus"), absentes = ab,
               part_refus = if (nrow(x)) sum(x$statut == "refus") / nrow(x) else NA_real_, part_abs = if (nrow(a)) ab / nrow(a) else NA_real_,
               stringsAsFactors = FALSE)
  }))
}))
K0_TAB$ok <- is.finite(K0_TAB$part_refus) & K0_TAB$part_refus <= SEUIL_K0 & is.finite(K0_TAB$part_abs) & K0_TAB$part_abs <= SEUIL_K0
# R3 : le bloc D (plan d'actuary-10, constats (3) et (4)) est affiche mais
# n'entre pas dans le verdict K0 sur les refus et les p absentes.
K0_TAB$verdict <- K0_TAB$bloc != "D"
K0_REFUS_KO <- K0_TAB[K0_TAB$verdict & !K0_TAB$ok, , drop = FALSE]
# K0 (par. 4) : controles d'integrite OK ; criteres de K0 (inv), (o), (dc)
# carre (decision C2) ; refus et p absentes <= 1 % par (bloc, G, loi,
# variante), bloc D exclu (R3). MOTIFS_K0 : causes du defaut, en clair.
MOTIFS_K0 <- c(if (length(INTEGRITE)) sprintf("contr\u00f4les d'int\u00e9grit\u00e9 en \u00e9chec (%s)", paste(unique(INTEGRITE), collapse = ", ")),
               if (length(DEFAUTS_K0)) sprintf("crit\u00e8res de K0 en d\u00e9faut : %s", paste(unique(DEFAUTS_K0), collapse = ", ")),
               if (nrow(K0_REFUS_KO)) sprintf("refus ou p absentes > 1 %% : %s",
                                              paste(sprintf("%s %s %s %s", K0_REFUS_KO$bloc, K0_REFUS_KO$G, K0_REFUS_KO$loi, K0_REFUS_KO$variante), collapse = ", ")))
K0 <- !length(MOTIFS_K0)
TXT_MOTIFS_K0 <- if (length(MOTIFS_K0)) paste(MOTIFS_K0, collapse = " ; ") else "aucun"
# K1 : M7b, PenteIntra a 0,05, V0 contre temoin, McNemar exact par loi, Holm.
K1_TAB <- lapply(names(LOIS), function(loi) { pr <- pop_trap("8x7", loi, "M7b"); dd <- dec_pop(pr, "PenteIntra", SEUILS[["a05"]])
  c(list(loi = loi), apparier(dd$V0, dd$T)) })
local({
  p <- vapply(K1_TAB, function(x) x$p2, 1); ph <- stats::p.adjust(p, "holm")
  for (i in seq_along(K1_TAB)) { K1_TAB[[i]]$p_holm <<- ph[i]; K1_TAB[[i]]$rejet <<- ph[i] < NIVEAU_HOLM && isTRUE(K1_TAB[[i]]$delta > 0) }
})
K1 <- if (any(vapply(K1_TAB, function(x) x$n, 1) == 0)) NA else any(vapply(K1_TAB, function(x) isTRUE(x$rejet), logical(1)))
# K2 : 8 x 7, b <= 2000, PenteIntra, chaque loi et alpha : V2 aligne sur le
# temoin (K2a) ou sur le carre des memes triangles (K2b).
CARRE <- ADM[ADM$bloc == "C" & ADM$statut %in% c("admis", "echec"), , drop = FALSE]
K2_TAB <- list()
for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  pr <- pop_trap("8x7", loi); dd <- dec_pop(pr, "PenteIntra", SEUILS[[ia]])
  a <- apparier(dd$V2, dd$T)
  cc <- CARRE[CARRE$loi == loi, , drop = FALSE]
  bb <- intersect(pr$b, cc$b)
  b2 <- if (length(bb)) apparier(dec(pr$v2$`p:PenteIntra`[match(bb, pr$b)], SEUILS[[ia]]), dec(cc$`p:PenteIntra`[match(bb, cc$b)], SEUILS[[ia]])) else NULL
  K2_TAB[[paste(loi, ia)]] <- list(loi = loi, ia = ia, a = a, b = b2, ka = aligne(a, ia), kb = if (is.null(b2)) NA else aligne(b2, ia))
}
K2 <- all(vapply(K2_TAB, function(x) isTRUE(x$ka) || isTRUE(x$kb), logical(1)))
if (!K2 && any(vapply(K2_TAB, function(x) !isTRUE(x$ka) && is.na(x$kb), logical(1)))) K2 <- NA
# K2' : V2 contre V0, unilateral vers moins de rejets, Holm sur 4 cellules.
K2P_TAB <- list()
for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  pr <- pop_trap("8x7", loi); dd <- dec_pop(pr, "PenteIntra", SEUILS[[ia]])
  K2P_TAB[[paste(loi, ia)]] <- list(loi = loi, ia = ia, x = apparier(dd$V2, dd$V0), d2 = apparier(dd$V2, dd$T), d0 = apparier(dd$V0, dd$T))
}
local({
  ph <- stats::p.adjust(vapply(K2P_TAB, function(x) x$x$p_inf, 1), "holm")
  for (i in seq_along(K2P_TAB)) K2P_TAB[[i]]$p_holm <<- ph[i]
})
K2P <- any(vapply(K2P_TAB, function(x) x$p_holm < NIVEAU_HOLM, logical(1))) &&
  !any(vapply(K2P_TAB, function(x) isTRUE(abs(x$d2$delta) > abs(x$d0$delta)), logical(1)))
# K3 : 8 x 5 et 8 x 6, PenteIntra et Alpha, chaque loi et alpha (16 cellules).
K3_TAB <- list()
for (G in c("8x5", "8x6")) for (s in CLES_V2) for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  pr <- pop_trap(G, loi); dd <- dec_pop(pr, s, SEUILS[[ia]])
  d2 <- apparier(dd$V2, dd$T); d0 <- apparier(dd$V0, dd$T)
  c2 <- classe_de(dd$V2, G, loi, s, ia); c0 <- classe_de(dd$V0, G, loi, s, ia)
  br1 <- aligne(d2, ia); br2 <- isTRUE(abs(d2$delta) <= abs(d0$delta) + DELTA[[ia]] / 2)
  degr <- isTRUE(c2$disj) && !isTRUE(c0$disj)
  K3_TAB[[paste(G, s, loi, ia)]] <- list(G = G, s = s, loi = loi, ia = ia, d2 = d2, d0 = d0, c2 = c2, c0 = c0, br1 = br1, br2 = br2, degr = degr,
                                         ok = (br1 || br2) && !degr && d2$n > 0)
}
K3 <- all(vapply(K3_TAB, function(x) x$ok, logical(1)))
# K4 : couverture de l'intervalle percentile a 90 %, cible sigma_A^regle,
# difference appariee des taux de non-couverture (V2 - V0).
nc <- function(lo, hi, cible) !(is.finite(lo) & is.finite(hi) & lo <= cible & cible <= hi)
K4_TAB <- list()
for (G in GEOM$code) for (loi in names(LOIS)) {
  pr <- pop_trap(G, loi)
  def2 <- is.finite(pr$v2$q05); def0 <- is.finite(pr$v0$q05)
  def <- def2 & def0
  v2 <- pr$v2[def, , drop = FALSE]; v0 <- pr$v0[def, , drop = FALSE]; cib <- SIGMA_A_REGLE[[G]]
  x <- apparier(nc(v2$q05, v2$q95, cib), nc(v0$q05, v0$q95, cib))
  # R6 : triangles sans intervalle ventiles par variante (V2 seule, V0
  # seule, les deux) ; descriptif : difference appariee sur tous les
  # triangles apparies, un triangle sans intervalle compte comme une
  # non-couverture (nc() rend TRUE sur une borne non finie).
  sans <- c(V2 = sum(!def2 & def0), V0 = sum(def2 & !def0), deux = sum(!def2 & !def0))
  x_tous <- apparier(nc(pr$v2$q05, pr$v2$q95, cib), nc(pr$v0$q05, pr$v0$q95, cib))
  desc <- lapply(list(V2 = v2, V0 = v0), function(d) list(
    nc90 = mean(nc(d$q05, d$q95, cib)), nc95 = mean(nc(d$q025, d$q975, cib)),
    haute90 = mean(d$q95 < cib), basse90 = mean(d$q05 > cib), larg90 = mean(d$q95 - d$q05), larg95 = mean(d$q975 - d$q025),
    nc90_vrai = mean(nc(d$q05, d$q95, SIGMA_A_VRAI[[G]])),
    nc90_B = { k <- is.finite(d$sigma_B); if (any(k)) mean(nc(d$q05[k], d$q95[k], d$sigma_B[k])) else NA_real_ }))
  K4_TAB[[paste(G, loi)]] <- list(G = G, loi = loi, x = x, sans = sum(!def), sans_v = sans, x_tous = x_tous,
                                  ok = is.finite(x$ic[2]) && x$ic[2] <= MARGE_K4 && x$n > 0, desc = desc)
}
K4 <- all(vapply(K4_TAB, function(x) x$ok, logical(1)))
REGLE <- local({
  t <- function(x) isTRUE(x); f <- function(x) isFALSE(x)
  if (!t(K0)) "R0" else if (t(K1) && t(K2) && t(K3) && t(K4)) "R-V2" else
    if (t(K1) && t(K2P) && t(K3) && t(K4) && f(K2)) "R-V2\u2032" else
      if (t(K1) && (t(K2) || t(K2P)) && t(K3) && f(K4)) "R-V1" else
        if ((f(K2) && f(K2P)) || f(K3)) "R-V0" else "D\u00e9faut (non tranch\u00e9)"
})

###############################################################################
#  CONSTATS (1) A (4) (par. 5), DESCRIPTIFS
###############################################################################
# (1) Sonde (evaluer_sonde(), definie avant le calcul par tranches).
EV_SONDE <- evaluer_sonde(SON)
# (2) Stratification par quartile de log r (donnees de M, N et E reunies).
STRATES <- list()
for (x in list(c("8x7", "PenteIntra"), c("8x5", "Alpha"), c("8x6", "Alpha"))) {
  G <- x[1]; s <- x[2]
  pr <- list(v2 = NULL, v0 = NULL)
  for (loi in names(LOIS)) { p <- pop_trap(G, loi); pr$v2 <- rbind(pr$v2, p$v2); pr$v0 <- rbind(pr$v0, p$v0) }
  lr <- log(pr$v2$r); ok <- is.finite(lr)
  if (sum(ok) < 4L) next
  q <- stats::quantile(lr[ok], c(.25, .5, .75), type = 7, names = FALSE)
  st <- findInterval(lr, q, left.open = TRUE) + 1L
  for (k in 1:4) {
    i <- ok & st == k
    dd <- list(V2 = dec(pr$v2[[paste0("p:", s)]][i], 0.05), V0 = dec(pr$v0[[paste0("p:", s)]][i], 0.05), T = dec(pr$v2[[paste0("pT:", s)]][i], 0.05))
    STRATES[[length(STRATES) + 1L]] <- list(G = G, s = s, q = k, bornes = c(if (k > 1) exp(q[k - 1]) else NA, if (k < 4) exp(q[k]) else NA),
                                            d0 = apparier(dd$V0, dd$T), d2 = apparier(dd$V2, dd$T))
  }
}
# (3) et (4) : bloc D contre son oracle ; MinP4 contre #297.
DBLOC <- ADM[ADM$bloc == "D", , drop = FALSE]
lect_bloc <- function(d, cle, loi, s, ia) { dd <- dec(d[[paste0("p:", s)]], SEUILS[[ia]]); list(c = lecture(sum(dd), length(dd), rho_de(cle, loi, s, ia)),
  a = apparier(dd, dec(d[[paste0("pT:", s)]], SEUILS[[ia]]))) }
CONST_D <- list()
for (s in c("Alpha", "MinP4")) for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  d <- DBLOC[DBLOC$loi == loi, , drop = FALSE]
  if (!nrow(d)) next
  CONST_D[[paste(s, loi, ia)]] <- c(list(s = s, loi = loi, ia = ia), lect_bloc(d, "D", loi, s, ia))
}
cote_D <- function(s) unique(stats::na.omit(vapply(Filter(function(x) x$s == s, CONST_D), function(x) if (isTRUE(x$c$disj)) x$c$cote else NA_character_, "")))
# Decision C2 : (dc) en defaut sur le bloc D -> constats (3) et (4) non
# evaluables, sans R0.
DC_D_KO <- "(dc) D" %in% DEFAUTS_CONSTAT
TXT_DC_D <- "non \u00e9valuable : (dc) en d\u00e9faut sur le bloc D (simulation non identique sous V0 et V2), sans R0"
REGLE_3 <- if (DC_D_KO) TXT_DC_D else if (!length(Filter(function(x) x$s == "Alpha", CONST_D))) "non \u00e9valuable (bloc D absent)" else {
  co <- cote_D("Alpha")
  if ("conservateur" %in% co) "distorsion mat\u00e9rielle conservatrice dans D : r\u00e9serve \u00ab un OK d'Alpha est une preuve faible quand la r\u00e8gle est nulle \u00bb" else
    if ("lib\u00e9ral" %in% co) "distorsion lib\u00e9rale dans D : constat gard\u00e9 (E3), tri\u00e9 par la session (ADR 0018)" else "constat clos"
}
REGLE_4 <- if (DC_D_KO) TXT_DC_D else if (!length(Filter(function(x) x$s == "MinP4", CONST_D))) "non \u00e9valuable (bloc D absent)" else {
  if ("lib\u00e9ral" %in% cote_D("MinP4")) "distorsion mat\u00e9rielle lib\u00e9rale dans D : constat gard\u00e9 (E3), hors de #612, tri\u00e9 par la session" else
    "(4) s'explique par la r\u00e9f\u00e9rence nominale et B = 199, et se cl\u00f4t"
}
MINP4 <- NULL
if (!is.null(BR297)) {
  MINP4 <- do.call(rbind, lapply(c("8x5", "8x6", "8x7", "8x8"), function(G) do.call(rbind, lapply(names(LOIS), function(loi) do.call(rbind, lapply(names(SEUILS), function(ia) {
    a <- SEUILS[[ia]]
    d <- if (G == "8x8") CARRE[CARRE$loi == loi, , drop = FALSE] else pop_trap(G, loi)$v2
    if (!NROW(d)) return(NULL)
    b8 <- BR297[BR297$type == "rep" & BR297$loi == loi & BR297$statut == "admis", , drop = FALSE]
    p8 <- nv(b8[["pR:MinP4"]]); k8 <- sum(is.finite(p8) & p8 < a); n8 <- nrow(b8)
    k <- sum(dec(d$`p:MinP4`, a)); n <- nrow(d)
    data.frame(G = G, loi = loi, ia = ia, k = k, n = n, k8 = k8, n8 = n8,
               p = stats::fisher.test(matrix(c(k, n - k, k8, n8 - k8), 2L))$p.value, stringsAsFactors = FALSE)
  }))))))
  if (NROW(MINP4)) { MINP4$p_holm <- stats::p.adjust(MINP4$p, "holm"); MINP4$signal <- MINP4$p_holm < NIVEAU_HOLM }
}
# Balayage : par (G, loi) et k, mediane de p(PenteIntra) et p(Alpha) ;
# rejets a 0,05 ; invariance des autres cles contre le point k = 1.
BAL_TAB <- if (is.null(BAL)) NULL else do.call(rbind, lapply(split(BAL, paste(BAL$G, BAL$loi, BAL$point)), function(d) {
  a <- d[d$statut == "admis", , drop = FALSE]
  ref <- BAL[BAL$G == d$G[1] & BAL$loi == d$loi[1] & BAL$point == "k=1" & BAL$statut == "admis", , drop = FALSE]
  cl <- cles_libres(d$G[1]); bb <- intersect(a$b, ref$b)
  inv <- if (length(bb)) sum(chaine(a[match(bb, a$b), , drop = FALSE], paste0("p:", cl)) != chaine(ref[match(bb, ref$b), , drop = FALSE], paste0("p:", cl))) else NA_integer_
  data.frame(G = d$G[1], loi = d$loi[1], point = d$point[1], k = d$k[1], n = nrow(a),
             med_pente = stats::median(a$`p:PenteIntra`, na.rm = TRUE), rej_pente = sum(dec(a$`p:PenteIntra`, 0.05)),
             med_alpha = stats::median(a$`p:Alpha`, na.rm = TRUE), rej_alpha = sum(dec(a$`p:Alpha`, 0.05)),
             exceptions = inv, retirage = sum(a$cumuls_retires %in% 1), stringsAsFactors = FALSE)
}))
if (!is.null(BAL_TAB)) BAL_TAB <- BAL_TAB[order(BAL_TAB$G, BAL_TAB$loi, match(BAL_TAB$point, POINTS_BAL)), , drop = FALSE]

###############################################################################
#  SORTIE MARKDOWN (par. 8)
###############################################################################
liste <- function(x, n = 30) if (!length(x)) "\u2014" else paste(c(utils::head(x, n), if (length(x) > n) sprintf("... (%d en tout)", length(x))), collapse = " ; ")
S <- c(sprintf("## Mesure #612 (A2) : simulation de la colonne J\u22121 d'un trap\u00e8ze, V0 (r\u00e8gle de minimum) contre V2 (estimateur direct)%s",
               if (OPT_ESSAI) " -- ESSAI (--essai), non versionnable" else ""), "",
       "### Statut \u00e9pist\u00e9mique (protocole, par. 4, reproduit tel quel)", "", TEXTE_STATUT_612, "",
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Protocole", sprintf("%s, par. 8 (et 2 \u00e0 7, 9) ; d\u00e9cisions du mainteneur \u00e0 PA-1 (E-23/11 (PA-1)) ; md5 %s", PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE)))),
       ligne_md("Mode", if (OPT_ESSAI) "essai (--essai) : non versionnable ; V0 des blocs M7a, M5, M6 calcul\u00e9 en entier \u00e0 B = 199" else sprintf("mesure, niveau %s", OPT_NIVEAU)),
       ligne_md("Triangles par bloc et loi ; B", sprintf("%s ; %s", txt_R(), format(B_RUN))),
       ligne_md("DGP", sprintf("mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2 (tests/donnees/triangle_mw.csv, md5 %s), j = 0..J \u2212 1, premi\u00e8re colonne fix\u00e9e, I = 7 ; bloc D : 8 x 6 avec \u03c3\u00b2_2 = 0 ; carr\u00e9 : 8 x 8 complet",
                               md5_fichier(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")))),
       ligne_md("Lois", sprintf("N : stats::rnorm ; E : tirage uniforme dans les %d valeurs du pool redress\u00e9 de reserve2 divis\u00e9es par leur \u00e9cart-type de population (%s)",
                                 length(POOL0), sub(".", ",", sprintf("%.5f", SD_POP0), fixed = TRUE))),
       ligne_md("Chemin", "gen_triangle_h0() sous engine_sous_graine() ; admission (cellule, mw_valider_triangle(), domaine, mw_ajuster(), mw_msep(), M4) ; mw_ajuster() \u2192 .mw_ensembles_figes() \u2192 mw_bootstrap(aj, B, graine, figes) \u2192 mw_tests(aj, boot, 0,10, figes)"),
       ligne_md("Graines", "triangle b, loi \u2113 : 567 000 000 + 100 000 (\u2113 \u2212 1) + b ; bootstrap : 568 000 000 + 1 000 000 (g \u2212 1) + 100 000 (\u2113 \u2212 1) + b, la m\u00eame pour V0 et V2 ; oracle : 570 500 000 + 100 000 (\u2113 \u2212 1) + k (r\u00e9emploi de #567) ; carr\u00e9 : 660 000 000 + 100 000 (\u2113 \u2212 1) + b ; D : 661 000 000, 661 500 000, 662 000 000 + 100 000 (\u2113 \u2212 1) + b ou k ; sonde : 663 000 000 + u ; pr\u00e9-vol : 664 000 000 + u, 664 500 000 + u"),
       ligne_md("Substitutions (environment(run_engine), on.exit, identical())", paste(sprintf("%s : `%s`", names(CORPS_SUBST), CORPS_SUBST), collapse = " ; ")),
       ligne_md("Oracles (non versionn\u00e9s)", sprintf("%s ; oracle-567.tsv md5 %s ; oracle-D.tsv md5 %s",
                                                    paste(vapply(names(OR), function(nm) sprintf("%s : %d / %d admis", nm, OR[[nm]]$n_adm, OR[[nm]]$n_tire), ""), collapse = " ; "), MD5_ORACLE, MD5_ORACLE_D)),
       ligne_md("Entr\u00e9es", sprintf("%s md5 %s ; %s md5 %s ; %s md5 %s", BRUT_567, md5_fichier(file.path(RACINE, BRUT_567)), TABLEAU_567, md5_fichier(file.path(RACINE, TABLEAU_567)),
                                     BRUT_297, md5_fichier(file.path(RACINE, BRUT_297)))),
       ligne_md("SHA (d\u00e9but ; fin)", sprintf("%s ; %s", SHA_DEBUT, SHA_FIN)),
       ligne_md("Commit (commit_depot(), au d\u00e9but)", COMMIT_DEBUT),
       ligne_md("md5 R/engine.R (d\u00e9but ; fin)", sprintf("%s ; %s", MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN)),
       ligne_md("Empreinte #231 (d\u00e9but ; fin)", sprintf("%s ; %s", EMPREINTE_DEBUT, EMPREINTE_FIN)),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
       ligne_md("Tranches", sprintf("%d (taille %d)", length(FICHIERS_TR), TAILLE_TRANCHE)),
       ligne_md("Sorties", paste(NOMS_SORTIES, collapse = " ; ")),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) paste("\u00c9CHEC :", paste(unique(INTEGRITE), collapse = ", ")) else "OK"),
       ligne_md("K0 (crit\u00e8res (inv), (o), (dc) carr\u00e9 ; refus et p absentes)", if (K0) "tenu" else sprintf("**EN D\u00c9FAUT : %s \u2192 R0**", TXT_MOTIFS_K0)),
       ligne_md("(dc) sur le bloc D", if (DC_D_KO) "**EN D\u00c9FAUT : constats (3) et (4) non \u00e9valuables, sans R0**" else "OK ou sans objet"), "",
       "### Crit\u00e8res et r\u00e8gles (protocole, par. 4), report\u00e9s sans modification", "", TEXTE_CRITERE_612, "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLES[1]))
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9 (par. 8)", "", entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, etat_ctrl(k), k$detail), ""), "")
S <- c(S, "### Cibles de couverture (par. 1)", "", entete_md(c("G", "\u03c3_A^r\u00e8gle (cible principale)", "\u03c3_A^vrai (descriptive)", "\u03c3\u00b2_(J\u22121) de la r\u00e8gle", "\u03c3\u00b2_(J\u22121) vrai")),
       vapply(GEOM$code, function(G) ligne_md(G, num(SIGMA_A_REGLE[[G]], 6), num(SIGMA_A_VRAI[[G]], 6), num(S2_REGLE_GEN[[G]], 6), num(S2_VRAI[[G]], 7)), ""), "")
S <- c(S, "### R\u00e9f\u00e9rence \u03c1 par oracle et loi", "",
       sprintf("\u03c1 : taille liss\u00e9e \u00e0 B = %s du test de Monte-Carlo id\u00e9al sur l'oracle (r\u00e8gle de #206, par. 4) ; carr\u00e9 : oracle du 8 x 7 ; D : oracle propre.", format(B_RUN)), "",
       entete_md(c("Oracle", "Loi", "admis / tir\u00e9s", paste("\u03c1", CLES, "0,05"))),
       vapply(names(OR), function(nm) { o <- OR[[nm]]; do.call(ligne_md, c(list(sub(" .*", "", nm), sub(".* ", "", nm), sprintf("%d / %d", o$n_adm, o$n_tire)),
         lapply(CLES, function(s) num(o[[s]]$rho[["a05"]], 5)))) }, ""), "")
# K0.
S <- c(S, sprintf("### K0 (int\u00e9grit\u00e9) : %s", if (isTRUE(K0)) "**tenu**" else sprintf("**en d\u00e9faut** (%s)", TXT_MOTIFS_K0)), "",
       sprintf("Contr\u00f4les d'int\u00e9grit\u00e9 : %s. Crit\u00e8res de K0 (d\u00e9cision C2 du mainteneur : d\u00e9faut \u2192 R0, sans INTEGRITE ECHEC) : (inv) invariance, (o) carr\u00e9, (dc) carr\u00e9 : %s. Refus et p absentes (au moins une des 13 p_mc) au plus 1 %% par (bloc, G, \u2113, variante), bloc D affich\u00e9 hors verdict (R3).",
               if (length(INTEGRITE)) paste("\u00c9CHEC", paste(unique(INTEGRITE), collapse = ", ")) else "OK",
               if (length(DEFAUTS_K0)) paste("**EN D\u00c9FAUT :**", paste(unique(DEFAUTS_K0), collapse = ", ")) else "OK"), "",
       entete_md(c("Bloc", "G", "Loi", "Variante", "tir\u00e9s", "admis", "\u00e9checs", "refus", "part des refus", "p absentes", "part", "rempli", "dans le verdict K0")),
       vapply(seq_len(nrow(K0_TAB)), function(i) { x <- K0_TAB[i, ]
         ligne_md(x$bloc, x$G, x$loi, x$variante, x$tires, x$admis, x$echec, x$refus, num(x$part_refus, 4), x$absentes, num(x$part_abs, 4), if (x$ok) "oui" else "**non**",
                  if (x$verdict) "oui" else "non (bloc D, R3)") }, ""), "",
       entete_md(c("G", "Loi", "triangles appari\u00e9s", "p_mc invariantes", "part", "\u00e9carts par cause", "\u2265 99,5 %")),
       vapply(INV, function(x) ligne_md(x$G, x$loi, x$n, x$ident, num(x$part, 4),
                                        if (length(x$causes)) paste(sprintf("%s %d", names(x$causes), as.integer(x$causes)), collapse = ", ") else "aucun", if (x$ok) "oui" else "**non**"), ""), "")
# K1.
S <- c(S, sprintf("### K1 (reproduction, confirmatoire) : %s", oui_non(K1)), "",
       "8 x 7, b = 1001 \u00e0 2000 (bloc M7b), PenteIntra \u00e0 0,05, V0 contre t\u00e9moin, McNemar exact bilat\u00e9ral par loi, Holm sur les deux lois.", "",
       entete_md(c("Loi", "n", "k V0", "k t\u00e9moin", "\u0394\u0302 [IC 90 %] (n10, n01)", "p McNemar", "p Holm", "rejet avec \u0394 > 0")),
       vapply(K1_TAB, function(x) ligne_md(x$loi, x$n, x$kA, x$kB, txt_ap(x), fmt_p(x$p2), fmt_p(x$p_holm), if (isTRUE(x$rejet)) "**oui**" else "non"), ""), "")
# K2.
S <- c(S, sprintf("### K2 (correction) : %s", oui_non(K2)), "",
       "8 x 7, b \u2264 2000 (M7a et M7b), PenteIntra : V2 align\u00e9 sur le t\u00e9moin (K2a) ou sur le carr\u00e9 8 x 8 des m\u00eames triangles (K2b) ; align\u00e9 : IC \u00e0 90 % de \u0394 dans [\u2212\u03b4_\u03b1 ; +\u03b4_\u03b1].", "",
       entete_md(c("Loi", "\u03b1", "n", "V2 contre t\u00e9moin \u0394\u0302 [IC 90 %]", "K2a", "n (carr\u00e9)", "V2 contre carr\u00e9 \u0394\u0302 [IC 90 %]", "K2b", "cellule tenue")),
       vapply(K2_TAB, function(x) ligne_md(x$loi, lib_ia(x$ia), x$a$n, txt_ap(x$a), oui_non(x$ka), if (is.null(x$b)) 0 else x$b$n,
                                           if (is.null(x$b)) "\u2014" else txt_ap(x$b), oui_non(x$kb), if (isTRUE(x$ka) || isTRUE(x$kb)) "oui" else "**non**"), ""), "")
# K2'.
S <- c(S, sprintf("### K2\u2032 (am\u00e9lioration partielle) : %s", oui_non(K2P)), "",
       entete_md(c("Loi", "\u03b1", "n", "k V2", "k V0", "V2 contre V0 \u0394\u0302 [IC 90 %]", "p unilat\u00e9rale", "p Holm", "|\u0394\u0302_V2|", "|\u0394\u0302_V0|")),
       vapply(K2P_TAB, function(x) ligne_md(x$loi, lib_ia(x$ia), x$x$n, x$x$kA, x$x$kB, txt_ap(x$x), fmt_p(x$x$p_inf), fmt_p(x$p_holm),
                                            num(abs(x$d2$delta), D_IC), num(abs(x$d0$delta), D_IC)), ""), "")
# K3.
S <- c(S, sprintf("### K3 (non-d\u00e9gradation) : %s", oui_non(K3)), "",
       entete_md(c("G", "Cl\u00e9", "Loi", "\u03b1", "n", "V2 contre t\u00e9moin \u0394\u0302 [IC 90 %]", "V0 contre t\u00e9moin \u0394\u0302 [IC 90 %]", "align\u00e9", "|\u0394\u0302_V2| \u2264 |\u0394\u0302_V0| + \u03b4/2",
                   "classe \u03c4_V2", "classe \u03c4_V0", "cellule tenue")),
       vapply(K3_TAB, function(x) ligne_md(x$G, x$s, x$loi, lib_ia(x$ia), x$d2$n, txt_ap(x$d2), txt_ap(x$d0), oui_non(x$br1), oui_non(x$br2),
                                           txt_classe(x$c2), txt_classe(x$c0), if (x$ok) "oui" else "**non**"), ""), "")
# K4.
S <- c(S, sprintf("### K4 (couverture, comparative) : %s", oui_non(K4)), "",
       sprintf("Intervalle percentile \u00e0 90 %% [q_0,05 ; q_0,95] de \u03c3* (ic_bootstrap \u00e0 la transformation affine pr\u00e8s), cible \u03c3_A^r\u00e8gle ; triangles admis aux deux intervalles d\u00e9finis (plus de %d \u03c3*), les autres compt\u00e9s \u00e0 part, ventil\u00e9s par variante sans intervalle (V2 seule, V0 seule, les deux). V0 des blocs M7a, M5, M6 : boucle all\u00e9g\u00e9e ; M7b : mw_bootstrap().", MIN_SIGMA), "",
       entete_md(c("G", "Loi", "n", "sans intervalle (V2 seule / V0 seule / les deux)", "non-couverture V2", "non-couverture V0", "V2 \u2212 V0 \u0394\u0302 [IC 90 %]", "borne haute \u2264 0,02")),
       vapply(K4_TAB, function(x) ligne_md(x$G, x$loi, x$x$n, sprintf("%d (%d / %d / %d)", x$sans, x$sans_v[["V2"]], x$sans_v[["V0"]], x$sans_v[["deux"]]),
                                           num(x$desc$V2$nc90, 4), num(x$desc$V0$nc90, 4), txt_ap(x$x), if (x$ok) "oui" else "**non**"), ""), "",
       "Descriptif (hors crit\u00e8re K4) : tous les triangles appari\u00e9s, un triangle sans intervalle comptant comme une non-couverture.", "",
       entete_md(c("G", "Loi", "n", "non-couverture V2", "non-couverture V0", "V2 \u2212 V0 \u0394\u0302 [IC 90 %]")),
       vapply(K4_TAB, function(x) ligne_md(x$G, x$loi, x$x_tous$n, num(if (x$x_tous$n) x$x_tous$kA / x$x_tous$n else NA, 4), num(if (x$x_tous$n) x$x_tous$kB / x$x_tous$n else NA, 4),
                                           txt_ap(x$x_tous)), ""), "",
       "Descriptif : non-couverture \u00e0 95 %, queues s\u00e9par\u00e9es \u00e0 90 % (haute : q_0,95 < cible ; basse : q_0,05 > cible), largeurs moyennes, cibles \u03c3_A^vrai et \u03c3_B.", "",
       entete_md(c("G", "Loi", "Variante", "nc 95 %", "queue haute 90 %", "queue basse 90 %", "largeur 90 %", "largeur 95 %", "nc 90 % (\u03c3_A^vrai)", "nc 90 % (\u03c3_B)")),
       unlist(lapply(K4_TAB, function(x) vapply(c("V2", "V0"), function(v) { d <- x$desc[[v]]
         ligne_md(x$G, x$loi, v, num(d$nc95, 4), num(d$haute90, 4), num(d$basse90, 4), num(d$larg90, 5), num(d$larg95, 5), num(d$nc90_vrai, 4), num(d$nc90_B, 4)) }, ""))), "")
# Regles.
S <- c(S, "### R\u00e8gles (par. 4), \u00e9valu\u00e9es m\u00e9caniquement, sans conclure", "",
       entete_md(c("Crit\u00e8re", "K0", "K1", "K2", "K2\u2032", "K3", "K4")),
       ligne_md("tenu", oui_non(K0), oui_non(K1), oui_non(K2), oui_non(K2P), oui_non(K3), oui_non(K4)), "",
       sprintf("**R\u00e8gle d\u00e9clench\u00e9e m\u00e9caniquement : %s.** Lecture par actuary (\u00e9tape 4), d\u00e9cision du mainteneur (PA-2). V1 se lit en composite : tests de V2 (K1 \u00e0 K3), \u03c3_boot de V0 (couverture V0 ci-dessus).",
               if (K0) REGLE else sprintf("%s -- K0 en d\u00e9faut : %s", REGLE, TXT_MOTIFS_K0)), "")
# Tables des 13 cles.
S <- c(S, "### Tables des 13 cl\u00e9s : \u03c4_V2, \u03c4_V0, \u03c4 du t\u00e9moin, \u03c1, \u0394\u0302 appari\u00e9s", "",
       entete_md(c("G", "Loi", "\u03b1", "Cl\u00e9", "n", "\u03c4_V2", "\u03c4_V0", "\u03c4_T", "\u03c1", "classe \u03c4_V2", "\u0394\u0302 V2 \u2212 T [IC 90 %]", "\u0394\u0302 V0 \u2212 T [IC 90 %]")))
for (G in GEOM$code) for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  pr <- pop_trap(G, loi)
  for (s in CLES) { dd <- dec_pop(pr, s, SEUILS[[ia]]); n <- length(dd$V2)
    S <- c(S, ligne_md(G, loi, lib_ia(ia), s, n, num(if (n) mean(dd$V2) else NA, D_IC), num(if (n) mean(dd$V0) else NA, D_IC), num(if (n) mean(dd$T) else NA, D_IC),
                       num(rho_de(G, loi, s, ia), 5), txt_classe(classe_de(dd$V2, G, loi, s, ia)), txt_ap(apparier(dd$V2, dd$T)), txt_ap(apparier(dd$V0, dd$T)))) }
}
for (bl in c("C", "D")) for (loi in names(LOIS)) for (ia in names(SEUILS)) {
  d <- ADM[ADM$bloc == bl & ADM$loi == loi, , drop = FALSE]; if (!nrow(d)) next
  cle <- if (bl == "C") "8x7" else "D"
  for (s in CLES) { dd <- dec(d[[paste0("p:", s)]], SEUILS[[ia]]); dt <- dec(d[[paste0("pT:", s)]], SEUILS[[ia]])
    S <- c(S, ligne_md(if (bl == "C") "8x8 (carr\u00e9)" else "D (8 x 6, \u03c3\u00b2_2 = 0)", loi, lib_ia(ia), s, length(dd), num(mean(dd), D_IC), "= V2", num(mean(dt), D_IC),
                       num(rho_de(cle, loi, s, ia), 5), txt_classe(lecture(sum(dd), length(dd), rho_de(cle, loi, s, ia))), txt_ap(apparier(dd, dt)), "\u2014")) }
}
S <- c(S, "")
# Constats.
S <- c(S, lignes_constat_1(EV_SONDE))
S <- c(S, "### Constat (2) : balayage du \u03c3\u00b2 de simulation de J\u22121 (bloc BAL) et lecture stratifi\u00e9e", "")
if (!is.null(BAL_TAB)) S <- c(S, entete_md(c("G", "Loi", "point", "n", "m\u00e9diane p PenteIntra", "rejets 0,05", "m\u00e9diane p Alpha", "rejets 0,05", "autres cl\u00e9s diff\u00e9rentes de k = 1 (triangles)", "retirage")),
  vapply(seq_len(nrow(BAL_TAB)), function(i) { x <- BAL_TAB[i, ]
    ligne_md(x$G, x$loi, x$point, x$n, num(x$med_pente, 4), x$rej_pente, num(x$med_alpha, 4), x$rej_alpha, format(x$exceptions), x$retirage) }, ""), "")
S <- c(S, "Exc\u00e8s appari\u00e9 contre le t\u00e9moin \u00e0 0,05 par quartile de log r (r = \u03c3\u0302\u00b2_r\u00e8gle / \u03c3\u0302\u00b2_dir), N et E r\u00e9unis ; descriptif, confondu avec la forme du triangle.", "",
       entete_md(c("G", "Cl\u00e9", "quartile", "r dans", "n", "V0 \u2212 T \u0394\u0302 [IC 90 %]", "V2 \u2212 T \u0394\u0302 [IC 90 %]")),
       vapply(STRATES, function(x) ligne_md(x$G, x$s, x$q, sprintf("]%s ; %s]", num(x$bornes[1], 4), num(x$bornes[2], 4)), x$d0$n, txt_ap(x$d0), txt_ap(x$d2)), ""), "")
S <- c(S, "### Constats (3) et (4) : Alpha sous E et MinP4 (bloc D contre son oracle ; MinP4 contre #297)", "",
       sprintf("R\u00e8gle (3) : %s. R\u00e8gle (4) : %s.", REGLE_3, REGLE_4), "")
if (length(CONST_D)) S <- c(S, entete_md(c("Cl\u00e9", "Loi", "\u03b1", "n", "\u03c4 [IC 95 %]", "\u03c1_D", "classe", "contre t\u00e9moin D \u0394\u0302 [IC 90 %]")),
  vapply(CONST_D, function(x) ligne_md(x$s, x$loi, lib_ia(x$ia), x$c$n, sprintf("%s %s", num(x$c$taux, D_IC), txt_ic(x$c$ci)), num(rho_de("D", x$loi, x$s, x$ia), 5), txt_classe(x$c), txt_ap(x$a)), ""), "")
if (NROW(MINP4)) S <- c(S, "MinP4 contre #297 (8 x 8, lignes rep admises, pR:MinP4) : Fisher exact bilat\u00e9ral, Holm sur les cellules ; trap\u00e8zes : V2 (MinP4 invariant).", "",
  entete_md(c("G", "Loi", "\u03b1", "k / n", "k / n (#297)", "p Fisher", "p Holm", "significatif")),
  vapply(seq_len(nrow(MINP4)), function(i) { x <- MINP4[i, ]
    ligne_md(x$G, x$loi, lib_ia(x$ia), sprintf("%d / %d", x$k, x$n), sprintf("%d / %d", x$k8, x$n8), fmt_p(x$p), fmt_p(x$p_holm), if (x$signal) "**oui**" else "non") }, ""), "")
# K-T7 (descriptif) : p de famille.
S <- c(S, "### p de famille et p globale (descriptif, K-T7 de #567)", "",
       entete_md(c("G", "Loi", "Variante", "Famille", "n", "\u03c4 0,10", "\u03c4 0,05")))
for (G in GEOM$code) for (loi in names(LOIS)) { pr <- pop_trap(G, loi)
  for (v in c("V2", "V0")) { d <- if (v == "V2") pr$v2 else pr$v0
    for (f in FAM) { p <- d[[paste0("pf:", f)]]; S <- c(S, ligne_md(G, loi, v, f, length(p), num(if (length(p)) mean(dec(p, 0.10)) else NA, 4), num(if (length(p)) mean(dec(p, 0.05)) else NA, 4))) } } }
S <- c(S, "", sprintf("Bilan : int\u00e9grit\u00e9 %s ; K0 %s ; r\u00e8gle %s ; constats (3) et (4) : %s",
                      if (length(INTEGRITE)) sprintf("\u00c9CHEC (%s)", paste(unique(INTEGRITE), collapse = ", ")) else "OK",
                      if (K0) "tenu" else sprintf("EN D\u00c9FAUT (%s)", TXT_MOTIFS_K0), REGLE,
                      if (DC_D_KO) "non \u00e9valuables ((dc) D en d\u00e9faut)" else "\u00e9valu\u00e9s ou sans objet"), "")
duree_cumulee <- sum(D$duree_s, na.rm = TRUE) + sum(ORA$duree_s, na.rm = TRUE) + sum(BAL$duree_s, na.rm = TRUE) + sum(SON$duree_s, na.rm = TRUE)
S_EXEC <- c("### Ex\u00e9cution (varie d'une ex\u00e9cution \u00e0 l'autre)", "",
            sprintf("- Lancement (JOURNAL) : %s ; fin : %s", J0$lancement, horodatage()),
            sprintf("- Processus : %d ; lignes calcul\u00e9es par cette ex\u00e9cution : %d, %d tranche(s), %s s d'horloge ; tranches reprises : %d",
                    OPT_PROC, N_CALC, N_TR_CALC, num(T_CALC, 0), length(FICHIERS_TR) - N_TR_CALC),
            sprintf("- Dur\u00e9e cumul\u00e9e des lignes : %s s ; contr\u00f4les avant tirage : %s s ; (rep) : %s s ; dur\u00e9e totale : %s s",
                    num(duree_cumulee, 0), num(DUREE_AVANT, 1), num(DUREE_REP, 1), num(secs(t_debut), 0)), "")

###############################################################################
#  ECRITURE
###############################################################################
brut_de <- function(d, cols, texte) c(paste(cols, collapse = "\t"),
  if (NROW(d)) vapply(seq_len(nrow(d)), function(i) format_ligne(as.list(d[i, , drop = FALSE]), cols, texte), "") else character(0))
MD_FINAL <- c(S, S_EXEC)
f_out <- file.path(TRAVAIL, NOMS_SORTIES)
names(f_out) <- names(NOMS_SORTIES)
ecrire_fichier(f_out[["md"]], MD_FINAL)
ecrire_fichier(f_out[["brut"]], brut_de(D, COLONNES_BRUT, COL_TEXTE))
ecrire_fichier(f_out[["bal"]], brut_de(BAL, setdiff(COLONNES_BAL, "duree_s"), COL_TEXTE_BAL))
ecrire_fichier(f_out[["sonde"]], brut_de(SON, setdiff(COLONNES_S, "duree_s"), COL_TEXTE_S))
ecrire_fichier(JOURNAL_T, c(sprintf("- Fin : %s ; SHA \u00e0 la fin %s ; md5 R/engine.R \u00e0 la fin %s ; INTEGRITE %s ; K0 %s ; r\u00e8gle %s",
                                    horodatage(), SHA_FIN, MD5_MOTEUR_FIN, if (length(INTEGRITE)) "ECHEC" else "OK",
                                    if (K0) "tenu" else sprintf("EN D\u00c9FAUT (%s)", TXT_MOTIFS_K0), REGLE),
                            sprintf("- Sortie %s : md5 %s", NOMS_SORTIES[c("md", "brut", "bal", "sonde")], vapply(f_out[c("md", "brut", "bal", "sonde")], md5_fichier, "")),
                            sprintf("- Oracles (non versionn\u00e9s) : oracle-567.tsv md5 %s ; oracle-D.tsv md5 %s", MD5_ORACLE, MD5_ORACLE_D)), mode = "ab")
invisible(file.copy(JOURNAL_T, f_out[["jnl"]], overwrite = TRUE))
ecrire_console(MD_FINAL)
ecrire_console(sprintf("Sorties (dossier de travail, hors du d\u00e9p\u00f4t) : %s", paste(basename(f_out), collapse = " ; ")))
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
  ab <- chemins_absolus(unlist(lapply(f_out, function(f) readLines(f, warn = FALSE, encoding = "UTF-8"))))
  if (length(INTEGRITE)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : INTEGRITE ECHEC (", paste(unique(INTEGRITE), collapse = ", "), ") ; sorties laissees dans le dossier de travail")
  } else if (length(ab)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : chemin absolu ou /tmp dans une sortie : ", paste(utils::head(ab, 3), collapse = " | "))
  } else {
    nvs <- motifs_non_versionnable(commit_depot(SCRIPT_DEPOT), empreintes_code(), "de la mesure")
    if (length(nvs)) { message("--ecrire refuse au moment d'ecrire : ", paste(nvs, collapse = " ; ")); REFUS_ECRITURE <- TRUE } else {
      garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)
      if (!all(mapply(copier_fichier, f_out[names(NOMS_SORTIES)], CIBLES))) {
        message("--ecrire : copie incomplete vers docs/tableaux"); REFUS_ECRITURE <- TRUE
      } else ecrire_console(sprintf("\u00c9crit : %s", paste(file.path("docs", "tableaux", basename(CIBLES)), collapse = " ; ")))
    }
  }
}
if (TRAVAIL_TEMP) { nettoyer_essai(); ecrire_console("Dossier d'essai temporaire supprim\u00e9.") }
# Derniere ligne : INTEGRITE ECHEC (code 1) ; sinon INTEGRITE OK, suivie, sous
# --ecrire refuse, d'une derniere ligne distincte ECRITURE REFUSEE (code 1).
ecrire_console(paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK"))
if (!length(INTEGRITE) && REFUS_ECRITURE) ecrire_console("ECRITURE REFUSEE")
quit(status = if (length(INTEGRITE) || REFUS_ECRITURE) 1L else 0L)
