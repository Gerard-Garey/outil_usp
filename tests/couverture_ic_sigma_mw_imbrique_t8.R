###############################################################################
#  tests/couverture_ic_sigma_mw_imbrique_t8.R  --  COUVERTURE A T = 8 DES
#  INTERVALLES DE SIGMA CALIBRES PAR BOOTSTRAP IMBRIQUE, METHODE
#  MERZ-WUTHRICH (issue #610, branche S6, etape 4)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; parallel, utils et tools (livres avec R). Il ne modifie
#  ni R/, ni app.R, ni tests/reference/ ; ni le moteur ni l'application ne le
#  lisent (controle 10). C0, C1, C2 et leurs variantes sont calcules ICI,
#  jamais dans le moteur ; aucun effet sur sigma_USP, une p-value ou un
#  verdict (P1). Le moteur est charge par tests/outils_tests.R, donc par
#  charger_moteur() (ADR 0016), qui porte aussi commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), inserer_t0(),
#  ligne_remplacement(), empreinte_sans_commentaires(), TOLERANCE,
#  DATE_REFERENCE_TESTS et .tri.
#  Fichier source ASCII : tous les libelles non ASCII sont ecrits en
#  echappements \u ; sortie en UTF-8, y compris sous LC_ALL=C.
#
#  Protocole : rapport d'actuary
#  docs/revues/20261120-s6-trapeze/actuary-2b-protocole-610.md, par. 2
#  (C0, C1, C2, variantes), par. 3 (P1 a P11), par. 4 (critere et profils),
#  par. 5 (niveaux) et decisions du mainteneur du 20/11/2026 (fin du meme
#  fichier) : Q-2b-1 (a) candidats C1 et C2, C0 descriptif ; Q-2b-2 (a)
#  niveau M1, budget de 12 h d'horloge sur 4 processus, regle du pre-vol
#  (P7), tranches de 20 ; Q-2b-3 (a) P1 et P2 principaux, P3 descriptif si
#  le budget le permet, P4 et P5 exclus ; Q-2b-4 critere K-610-1 a K-610-4,
#  profils Theta0 a Theta4, preference et modificateur W approuves tels
#  quels ; Q-2b-6 (a) aucune mesure sur trapeze.
#  Le critere et les profils du par. 4 sont reportes SANS MODIFICATION dans
#  TEXTE_CRITERE_610, le statut epistemique du par. 3 dans TEXTE_STATUT_610
#  (controle 9, (t610) : presence a l'identique dans le rapport verse) ; le
#  statut est ecrit tel quel en tete de la sortie.
#
#  Statut des valeurs : CONSTAT DE SIMULATION sous le modele de Mack ajuste
#  au triangle de controle, une loi d'erreurs et T = 8 ; pas un resultat
#  general. Classes et profils evalues mecaniquement, SANS CONCLURE : la
#  lecture revient a actuary, la decision (D3) au mainteneur.
#
#  Plan (P2). Generateur : reserve2 (tests/donnees/triangle_mw.csv).
#  Profils : P1 loi E (principal), P2 loi N (principal), P3 loi A
#  (descriptif, niveau M1+P3 seulement). Generateur gen_triangle_h0(),
#  admission admettre(), boucle allegee boucle_allegee(), recomposer() et
#  q7_clair() : copies declarees de tests/couverture_ic_sigma_mw_t8.R (#387,
#  non modifie) ; boucle_allegee() rend en plus, sur demande (garder), les
#  ajustements des replications (theta*_b).
#
#  Par triangle simule r du profil p :
#    1. tri = gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_TRI(p, r)) ;
#    2. admettre(tri) ; refus compte, sans nouveau tirage ;
#    3. sigma chapeau = sqrt(MSEP)/R ; sigma_B par recomposer() ;
#    4. bootstrap externe : boucle allegee a B1, graine G_EXT(p, r) ; sigma*
#       = sigma_boot du moteur (controle 3) ; I1 et I4 (references) ;
#    5. bootstrap interne de chaque replication b a sigma* fini : boucle
#       allegee appliquee a theta*_b, avec .mw_ensembles_figes(theta*_b), a
#       B2, graine G_INT(p, r, b) (chemin de mw_bootstrap(), controle 4) ;
#       b admise si plus de 20 sigma** finis (n_b > 20), sinon exclue ;
#    6. C0, C1, C2 (par. 2), C1 et C2 a B2 reduit (variantes, premiers
#       sigma** de chaque b), a 90 % et 95 %.
#  Definitions (par. 2 ; quantiles de type 7) : Q* quantiles des sigma*
#  finis ; w_b = #{k : sigma**_bk <= sigma*_b^2 / sigma chapeau} / n_b ;
#  u_b = #{k : sigma**_bk <= sigma chapeau} / n_b ; se*_b = sd_k(log
#  sigma**_bk), t*_b = (log sigma*_b - log sigma chapeau) / se*_b ; se = sd
#  des log sigma*.
#    C1 = [s^2 / Q*(Q_w(1 - a)) ; s^2 / Q*(Q_w(a))] ;
#    C0 = [Q*(Q_u(a)) ; Q*(Q_u(1 - a))] ;
#    C2 = [s exp(-se Q_t(1 - a)) ; s exp(-se Q_t(a))], se*_b non fini ou
#         <= 1e-12 exclu et compte ; C2 forme si plus de 20 b a se*_b valide.
#  Saturation de C1 : Q_w(a) = 0 (borne haute s^2/min sigma*) ou Q_w(1 - a)
#  = 1 (borne basse s^2/max sigma*) ; de C0 : Q_u(1 - a) = 1 ou Q_u(a) = 0.
#  Intervalle de reference forme si plus de 20 sigma* finis ; candidats C0,
#  C1 formes si, de plus, plus de 20 b admises.
#
#  Graines (P6), toutes sous engine_sous_graine() ; p = 1, 2, 3 ; r <= 2 000 ;
#  b <= 999 : triangle 610 000 000 + 1 000 000 (p - 1) + r ; externe
#  610 500 000 + 1 000 000 (p - 1) + r ; interne 620 000 000 +
#  4 000 000 (p - 1) + 1 000 (r - 1) + b ; pre-vol : triangle 640 000 000 +
#  10 000 (p - 1) + u, externe 640 050 000 + 10 000 (p - 1) + u, interne
#  641 000 000 + 100 000 (p - 1) + 1 000 (u - 1) + b, u <= 50 ; cout dans les
#  conditions de run_engine() : externe = graine par defaut du moteur,
#  interne 641 300 000 + b (prolongement de la formule du pre-vol a p = 4,
#  u = 1 ; sous-plage non fixee par le protocole) ; sous-plage reservee au
#  trapeze (Q-2b-6) : 642 000 001 a 644 999 999, non employee. Controle 7 :
#  graines de #387 (P1, r <= 20), deliberement.
#
#  Controles d'integrite (P11 ; un seul echec : INTEGRITE ECHEC) : 1 md5,
#  SHA et empreinte #231 ; 2 sigma_A ; 3 sigma* externes contre
#  mw_bootstrap() ; 4 sigma** internes contre mw_bootstrap() ; 5 ecriture
#  independante de C0, C1, C2 ; 6 (g) ; 7 filiation avec le brut de #387 ;
#  8 graines ; 9 (t610) ; 10 (m) ; 11 comptes. Controles 2, 6, 7, 8, 9 et 10
#  AVANT tout tirage du plan : un echec arrete le script.
#
#  Modes :
#    --essai [--processus k] [--travail D] [--arret-apres MIN] : R = 3 par
#      profil (P1, P2, P3), B1 = 199, B2 = 49 (variantes a 30 et 25 tirages
#      internes) ; sortie marquee ESSAI ; --ecrire refuse.
#    --prevol [--unites 2] : cout d'un triangle (externe et interne) a 1, 2,
#      3 et 4 processus concurrents (memes triangles dans chaque processus,
#      graines du pre-vol) ; cout de run_engine(reserve2) et cout additionnel
#      de C0, C1 et C2 sur reserve2 dans ses conditions (B = 999, graine par
#      defaut, B2 = 199 et 50) ; duree prevue des niveaux M0 a M4 et niveau
#      retenu (P7, budget de 12 h sur 4 processus) ; rien d'ecrit.
#    mesure : --niveau (M0, M1+P3, M1, M2, M3 ou M4), ecrit au JOURNAL avant
#      tout calcul ; [--processus k] ; [--travail D] ; [--arret-apres MIN] ;
#      [--ecrire [--remplacer]].
#  Reprise (M42 (b), P8) : tranches de 20 triangles consecutifs d'un profil,
#  ecrites dans le dossier de travail (hors du depot) des qu'elles sont
#  completes (temporaire puis renommage) ; une relance avec le meme dossier
#  reprend aux tranches absentes ; une tranche dont le contexte (B1, B2,
#  variantes, SHA, md5 du moteur et du script, empreinte #231, plateforme)
#  differe du contexte courant arrete le script (pas de melange).
#  --arret-apres MIN : aucun nouveau groupe de tranches n'est lance apres
#  MIN minutes ; le script s'arrete alors sans agreger (code 3, derniere
#  ligne SEGMENT INCOMPLET), pour enchainer des segments de 2 h au plus
#  sans tuer de processus. Dossier par defaut :
#  <parent de la racine>/issue610-travail-<niveau>.
#  Sorties (dossier de travail ; avec --ecrire, copiees dans docs/tableaux/
#  si INTEGRITE OK) : <AAAAMMJJ>-issue610-couverture-ic-sigma-mw-imbrique.md,
#  ...-brut.tsv (une ligne par triangle tire, %.17g, sans duree),
#  ...-journal-mesure.md ; AAAAMMJJ : date (UTC) du premier lancement, lue au
#  JOURNAL. --ecrire exige un commit propre (motifs_non_versionnable()) et
#  garde_ecrasement().
#
#  Usage (racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/couverture_ic_sigma_mw_imbrique_t8.R --essai
#      Rscript tests/couverture_ic_sigma_mw_imbrique_t8.R --prevol
#      Rscript tests/couverture_ic_sigma_mw_imbrique_t8.R --niveau M1
#          --processus 4 [--travail D] [--arret-apres 85]
#          [--ecrire [--remplacer]]
#  La section finale "Execution" de la sortie (dates, durees, processus) est
#  la seule partie qui varie entre deux executions a arguments egaux.
#  Derniere ligne de la console : INTEGRITE OK ou INTEGRITE ECHEC (SEGMENT
#  INCOMPLET sous --arret-apres atteint). Code de sortie : 0 si INTEGRITE OK,
#  3 si segment incomplet, 1 sinon (et sur tout refus).
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
             "--unites", "--arret-apres")
AVEC_VALEUR <- c("--niveau", "--processus", "--travail", "--unites", "--arret-apres")
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
OPT_UNITES    <- suppressWarnings(as.integer(lire_option("--unites", "2")))
OPT_ARRET     <- suppressWarnings(as.numeric(lire_option("--arret-apres", "Inf")))
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)
OPT_PROC <- suppressWarnings(as.integer(lire_option("--processus",
              as.character(if (.Platform$OS.type == "windows") 1L else max(1L, min(4L, COEURS, na.rm = TRUE))))))
MODE <- if (OPT_PREVOL) "prevol" else if (OPT_ESSAI) "essai" else "mesure"
if (OPT_PREVOL && OPT_ESSAI) refuser("--prevol et --essai sont exclusifs")
if (OPT_PREVOL && any(c("--niveau", "--ecrire", "--remplacer", "--travail", "--processus", "--arret-apres") %in% ARGS))
  refuser("--prevol : seule l'option --unites est admise")
if (MODE != "prevol" && "--unites" %in% ARGS) refuser("--unites : reserve a --prevol")
if (OPT_ESSAI && OPT_ECRIRE) refuser("--ecrire refuse sous --essai (sorties non versionnables)")
if (OPT_ESSAI && !is.na(OPT_NIVEAU)) refuser("--niveau : reserve a la mesure")
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (MODE == "mesure" && is.na(OPT_NIVEAU)) refuser("mesure : --niveau obligatoire (fixe par le pre-vol, P7)")
if (is.na(OPT_UNITES) || OPT_UNITES < 1L || OPT_UNITES > 50L) refuser("--unites : entier de 1 a 50 (u <= 50, P6)")
if (is.na(OPT_PROC) || OPT_PROC < 1L) refuser("--processus : entier >= 1")
if (is.na(OPT_ARRET) || OPT_ARRET <= 0) refuser("--arret-apres : nombre de minutes > 0")
if (.Platform$OS.type == "windows" && OPT_PROC > 1L) refuser("--processus > 1 : fork indisponible sous Windows")

# --- Protocole (constantes, P2 a P7) -----------------------------------------
# B1 et B2 en double, comme le B par defaut de run_engine() (controles 3, 4).
B1_MESURE <- 999
B1_ESSAI  <- 199
B2_ESSAI  <- 49
# Variantes descriptives (par. 2.3) : C1 sur les 99 premiers sigma** de
# chaque b, C2 sur les 50 premiers ; sous --essai (B2 = 49), 30 et 25, pour
# exercer le code (valeurs propres a l'essai). Une variante n'est calculee
# que si son nombre de tirages est strictement inferieur a B2.
VARIANTES_MESURE <- c(C1 = 99, C2 = 50)
VARIANTES_ESSAI  <- c(C1 = 30, C2 = 25)
R_ESSAI <- c(P1 = 3L, P2 = 3L, P3 = 3L)
R_MAX <- 2000L                                            # P6 : r <= 2 000
U_MAX <- 50L                                              # P6 : u <= 50
TAILLE_TRANCHE <- 20L                                     # P8
# Niveaux (par. 5) : triangles TIRES par profil, B2, candidats du critere.
NIVEAUX <- list(
  "M0"    = list(R = c(P1 = 2000L, P2 = 2000L, P3 = 0L),   B2 = 199, cand = c("C1", "C2")),
  "M1+P3" = list(R = c(P1 = 1000L, P2 = 1000L, P3 = 500L), B2 = 199, cand = c("C1", "C2")),
  "M1"    = list(R = c(P1 = 1000L, P2 = 1000L, P3 = 0L),   B2 = 199, cand = c("C1", "C2")),
  "M2"    = list(R = c(P1 = 1000L, P2 = 1000L, P3 = 0L),   B2 = 99,  cand = c("C1", "C2")),
  "M3"    = list(R = c(P1 = 500L,  P2 = 500L,  P3 = 0L),   B2 = 199, cand = c("C1", "C2")),
  "M4"    = list(R = c(P1 = 1000L, P2 = 1000L, P3 = 0L),   B2 = 50,  cand = "C2"))
# Echelle de la regle P7 (premier niveau qui tient dans le budget ; sous le
# dernier, retour au mainteneur) : M0 et M2 en sont retires (Q-2b-2 (b) et
# (c), ecartes par le mainteneur) ; M1+P3 precede M1 (Q-2b-3 (a) : P3 si le
# budget le permet). Un niveau retenu sous M1 est signale (Q-2b-2 (a) a
# retenu M1 ; M4 est l'option (d), si le budget est refuse). Lecture du
# script, a confirmer par actuary.
ECHELLE_P7 <- c("M1+P3", "M1", "M3", "M4")
HORS_ECHELLE <- c(M0 = "Q-2b-2 (b)", M2 = "Q-2b-2 (c)")
# Note de niveau (regle 1 d'actuary du 20/11/2026) : sous M1, confirmation
# du mainteneur requise, aucun lancement implicite (--niveau explicite) ; M4
# retire C1 de K-610-1 (decision du mainteneur) ; M0 et M2 hors echelle.
note_niveau <- function(l) {
  x <- character(0)
  if (l %in% names(HORS_ECHELLE)) x <- c(x, sprintf("niveau hors de l'\u00e9chelle P7 (%s, \u00e9cart\u00e9 par le mainteneur)", HORS_ECHELLE[[l]]))
  if (l %in% c("M3", "M4")) x <- c(x, "niveau sous M1 : confirmation du mainteneur requise ; aucun lancement implicite (--niveau explicite exig\u00e9)")
  if (l == "M4") x <- c(x, "M4 retire C1 de K-610-1 (d\u00e9cision du mainteneur, Q-2b-2 (d))")
  x
}
# Regles de lecture fixees par actuary le 20/11/2026 (reponses aux six
# questions du compte rendu de l'etape 4), consignees au JOURNAL et au T0.
TEXTE_REGLES_610 <- c(
  "R\u00e8gle 1 (\u00e9chelle P7) : M1+P3, M1, M3, M4 ; premier niveau dont la dur\u00e9e pr\u00e9vue tient dans 12 h ; sous M1, confirmation du mainteneur requise et aucun lancement implicite (--niveau explicite) ; M4 retire C1 de K-610-1 (d\u00e9cision du mainteneur).",
  "R\u00e8gle 2 (formation) : C1 et C0 si plus de 20 b \u00e0 n_b > 20 ; C2 si plus de 20 b \u00e0 n_b > 20 et se*_b fini et > 1e-12, et si se externe est fini et > 1e-12 (sinon C2 non form\u00e9 et compt\u00e9) ; C1-99 et C2-50 : m\u00eames r\u00e8gles sur les 99 et 50 premiers \u03c3**.",
  "R\u00e8gle 3 (W) : C1 : saturation haute Q_w(\u03b1) = 0 \u00e0 90 % seule (/ triangles o\u00f9 C1 est form\u00e9) et b exclues (n_b \u2264 20, / \u03c3* finis cumul\u00e9s) ; C2 : se*_b d\u00e9g\u00e9n\u00e9r\u00e9s (/ b \u00e0 n_b > 20 cumul\u00e9es) et b exclues ; chaque taux compar\u00e9 s\u00e9par\u00e9ment \u00e0 0,01, proportion non arrondie sans IC, P1 et P2 s\u00e9par\u00e9ment ; W-a si tous les taux sont au plus 0,01.",
  "R\u00e8gle 4 (saturations basses) : C1 Q_w(1 \u2212 \u03b1) = 1, C0 Q_u(\u03b1) = 0 : descriptives (K-610-2), s\u00e9par\u00e9es de la haute, \u00e0 90 % et 95 %, hors W et \u03980.",
  "R\u00e8gle 5 (\u03980) : trois taux distincts, chacun compar\u00e9 \u00e0 0,01 sur P1 et P2 : refus / tir\u00e9s ; triangles sans intervalle (admis o\u00f9 au moins un de I1, I4, C1, C2 \u00e0 90 % n'est pas form\u00e9) / admis ; b exclues / \u03c3* finis ; les se*_b d\u00e9g\u00e9n\u00e9r\u00e9s rel\u00e8vent de W.",
  "R\u00e8gle 6 (pr\u00e9f\u00e9rence) : (i) calcul\u00e9e m\u00e9caniquement sur les estimations ponctuelles des queues (classes sur les valeurs non arrondies) ; (ii) non discriminante : co\u00fbts \u00e9gaux \u00e0 B2 = 199 ; le script ne d\u00e9signe aucun candidat pr\u00e9f\u00e9r\u00e9.")
# Couts par run_engine() du pre-vol du 20/11/2026 (bb2db99, machine au
# repos), cites par la regle 6 (pour information seulement).
COUT_PREVOL <- c(B2_199 = 3.68, B2_50 = 1.77)
BUDGET_S <- 12 * 3600                                     # Q-2b-2 (a) : 12 h d'horloge
K_BUDGET <- 4L                                            # sur 4 processus
ALPHA_NIV <- c("90" = 0.05, "95" = 0.025)                 # alpha par queue
RHO_NIV <- 2 * ALPHA_NIV                                  # non-couverture nominale
PROBS_Q <- c(0.025, 0.05, 0.95, 0.975)                    # niveaux calibres restitues
SUF_Q <- c("025", "05", "95", "975")
MIN_SIGMA <- 20L                                          # plus de 20 valeurs
TOL_SE <- 1e-12                                           # se*_b degenere
TOL_IND <- 1e-12                                          # controle 5
TOL_FIL <- 1e-12                                          # controle 7
SEUIL_THETA0 <- 0.01                                      # profil Theta0
SEUIL_W <- 0.01                                           # modificateur W
PROFILS <- data.frame(code = c("P1", "P2", "P3"), loi = c("E", "N", "A"),
                      role = c("crit\u00e8re principal (K-610-1)", "crit\u00e8re principal (K-610-1)", "descriptif (K-610-2)"),
                      stringsAsFactors = FALSE)
CODES_IC <- c("I1", "I4", "C0", "C1", "C2", "C1r", "C2r")
# Graines (P6). Bases ecrites en entier.
GRAINE_TRI <- 610000000; GRAINE_EXT <- 610500000; PAS_PROFIL <- 1000000
GRAINE_INT <- 620000000; PAS_INT_PROFIL <- 4000000; PAS_INT_R <- 1000
graine_tri <- function(p, r) GRAINE_TRI + PAS_PROFIL * (p - 1) + r
graine_ext <- function(p, r) GRAINE_EXT + PAS_PROFIL * (p - 1) + r
graine_int <- function(p, r, b) GRAINE_INT + PAS_INT_PROFIL * (p - 1) + PAS_INT_R * (r - 1) + b
GRAINE_PV_TRI <- 640000000; GRAINE_PV_EXT <- 640050000; PAS_PV <- 10000
GRAINE_PV_INT <- 641000000; PAS_PV_INT_PROFIL <- 100000
graine_pv_tri <- function(p, u) GRAINE_PV_TRI + PAS_PV * (p - 1) + u
graine_pv_ext <- function(p, u) GRAINE_PV_EXT + PAS_PV * (p - 1) + u
graine_pv_int <- function(p, u, b) GRAINE_PV_INT + PAS_PV_INT_PROFIL * (p - 1) + PAS_INT_R * (u - 1) + b
P_RUN_ENGINE <- 4L                                        # cout run_engine() : graine_pv_int(4, 1, b)
PLAGE_TRAPEZE <- c(642000001, 644999999)                  # reservee (Q-2b-6), non employee
# Graines de #387 (controle 7 seulement) : P1, r <= 20.
GRAINE_TRI_387 <- 387000000; GRAINE_BOOT_387 <- 387500000; R_FIL <- 20L
# Plages des mesures anterieures (P6), pour la disjonction (controle 8).
PLAGE_EXT_2A <- c(567000000, 572000000)     # S6, 2a (#567)
PLAGE_EXT_206 <- c(20840001, 20960000)      # #206 et #297, Merz-Wuthrich
PLAGE_EXT_297LN <- c(20260831, 20262831)    # #297 lognormale
PLAGE_EXT_305 <- c(305000000, 305939169)    # #305
PLAGE_EXT_387 <- c(387000000, 393100000)    # #387
PLAGE_EXT_ISOLEE <- c(360380123, 360380123)
DECALAGE_LITTERAL <- 20000                  # annotation du 10/10/2026 de #206, point 1
PROTOCOLE <- "docs/revues/20261120-s6-trapeze/actuary-2b-protocole-610.md"
SCRIPT_DEPOT <- "tests/couverture_ic_sigma_mw_imbrique_t8.R"
SCRIPT_387 <- "tests/couverture_ic_sigma_mw_t8.R"
BRUT_387 <- "docs/tableaux/20261119-issue387-couverture-ic-sigma-mw-brut.tsv"
MOTIF_GREP <- "couverture_ic_sigma_mw_imbrique"

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
SEED_DEFAUT <- eval(formals(run_engine)$seed)

# --- Outils de forme (copies de tests/couverture_ic_sigma_mw_t8.R) ----------
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
txt_ic <- function(ci, d = 4) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
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
# Lignes portant un chemin absolu ou /tmp (critere de #242) : refus d'ecrire.
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
ecart_relatif_max <- function(a, b) {
  if (length(a) != length(b) || !identical(is.na(a), is.na(b))) return(Inf)
  k <- !is.na(a)
  if (!any(k)) return(0)
  a <- a[k]; b <- b[k]
  e <- abs(a - b) / pmax(abs(a), abs(b))
  e[a == b] <- 0
  max(e)
}

# --- Contexte au debut du calcul (controle 1) --------------------------------
MD5_MOTEUR_DEBUT <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_DEBUT <- sha_head()
COMMIT_DEBUT <- commit_depot(SCRIPT_DEPOT)
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
EMPREINTE_DEBUT <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
PLATEFORME <- plateforme_calcul()
EMPREINTES <- empreintes_code()

###############################################################################
#  GENERATEUR, LOIS, ADMISSION, BOUCLE ALLEGEE (P2) : copies declarees de
#  tests/couverture_ic_sigma_mw_t8.R (#387), corps identiques sauf mention
###############################################################################
restreindre <- function(tri) { tri[row(tri) + col(tri) - 2L > nrow(tri) - 1L] <- NA; tri }
preparer_generateur <- function(tri) {
  tri <- restreindre(tri)
  aj <- mw_ajuster(tri)
  jd <- .mw_colonnes_degenerees(aj)
  pool <- .mw_pool_residus(aj, jd)
  sd_pop <- sqrt(mean((pool - mean(pool))^2))
  ms <- mw_msep(aj)$msep
  list(tri = tri, aj = aj, jd = jd, pool = pool, sd_pop = sd_pop, pool_E = pool / sd_pop,
       msep = ms, sigma_A = sqrt(ms) / aj$reserve)
}
GEN <- preparer_generateur(.tri)
tireur <- function(loi) {
  pE <- GEN$pool_E
  switch(loi,
         N = function(n) stats::rnorm(n),
         E = function(n) sample(pE, n, replace = TRUE),
         A = function(n) (stats::qgamma(stats::runif(n), 2) - 2) / sqrt(2))
}
TIREURS <- lapply(PROFILS$loi, tireur)
SIGMA_A <- GEN$sigma_A
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
triangle_profil <- function(p, graine) engine_sous_graine(graine, gen_triangle_h0(GEN$aj, TIREURS[[p]]))
admettre <- function(tri) {
  if (.mw_triangle_incomplet(tri)) return(list(ok = FALSE, code = "cellule", motif = "cellule <= 0"))
  v <- mw_valider_triangle(tri, segment = 1, annexe = "II")
  if (!isTRUE(v$ok)) return(list(ok = FALSE, code = "triangle", motif = nettoyer_champ(paste("mw_valider_triangle :", paste(v$erreurs, collapse = " ; ")))))
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
# Boucle allegee : transcription de la boucle de mw_bootstrap() sans
# .mw_stats() (copie de #387) ; ajout : garder = TRUE rend aussi
# l'ajustement de chaque replication a sigma* fini (theta*_b, NULL sinon),
# sans changer aucun tirage ni aucun calcul.
boucle_allegee <- function(aj, B, seed, figes, garder = FALSE) {
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, figes$degeneres)
    n_max <- FACTEUR_B_MAX_MW * (as.numeric(B) + 1)
    n_tires <- 0; retires <- FALSE; plafond <- FALSE
    sig <- rep(NA_real_, B); ajuste <- rep(FALSE, B)
    fits <- if (garder) vector("list", B) else NULL
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tires)
      n_tires <- n_tires + tir$n
      if (tir$rejets > 0) retires <- TRUE
      if (is.null(tir$tri)) { plafond <- TRUE; next }
      ab <- try(mw_ajuster(tir$tri), silent = TRUE)
      if (inherits(ab, "try-error")) next
      ajuste[b] <- TRUE
      mb <- try(mw_msep(ab), silent = TRUE)
      if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0) {
        sig[b] <- sqrt(mb$msep) / ab$reserve
        if (garder) fits[[b]] <- ab
      }
    }
    list(sig = sig, ajuste = ajuste, retires = retires, plafond = plafond, fits = fits)
  })
}
# sigma_B (P3 de #387) : copie de recomposer().
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
# Quantile de type 7 en clair (copie de q7_clair() de #387).
q7_clair <- function(v, p) {
  x <- sort(v); n <- length(x)
  vapply(p, function(pp) {
    h <- (n - 1) * pp + 1; j <- floor(h)
    if (j >= n) x[n] else x[j] + (h - j) * (x[j + 1L] - x[j])
  }, numeric(1))
}

###############################################################################
#  INTERVALLES (P4) ET CANDIDATS (par. 2)
###############################################################################
NOMS_BORNES <- unlist(lapply(CODES_IC, function(k) unlist(lapply(names(ALPHA_NIV), function(n)
  paste(k, n, c("bas", "haut"), sep = "_")))))
q7 <- function(x, p) stats::quantile(x, p, type = 7, names = FALSE)
# I1 et I4 (references, formules de #387).
bornes_ref <- function(s, sh) {
  b <- numeric(0)
  for (n in names(ALPHA_NIV)) {
    a <- ALPHA_NIV[[n]]; lo <- q7(s, a); hi <- q7(s, 1 - a)
    b[paste0("I1_", n, "_", c("bas", "haut"))] <- c(lo, hi)
    b[paste0("I4_", n, "_", c("bas", "haut"))] <- c(sh^2 / hi, if (lo == 0) Inf else sh^2 / lo)
  }
  b
}
# Statistiques par replication b, sur les m premiers sigma** de chaque b
# (colonnes de S2 alignees sur les b a sigma* fini ; colonne NA : b en echec).
stats_b <- function(s, sh, S2, m) {
  X <- S2[seq_len(m), , drop = FALSE]
  nb <- colSums(is.finite(X))
  adm <- nb > MIN_SIGMA
  w <- u <- se <- rep(NA_real_, length(s))
  for (i in which(adm)) {
    x <- X[is.finite(X[, i]), i]
    w[i] <- mean(x <= s[i]^2 / sh); u[i] <- mean(x <= sh); se[i] <- stats::sd(log(x))
  }
  t <- (log(s) - log(sh)) / se
  okse <- adm & is.finite(se) & se > TOL_SE
  list(nb = nb, adm = adm, w = w, u = u, se = se, t = t, okse = okse)
}
# Bornes de C0, C1 (formes si plus de 20 b admises, n_b > 20) et de C2
# (forme si plus de 20 b admises a se*_b fini et > 1e-12, et si se externe
# est fini et > 1e-12 ; regle 2 d'actuary du 20/11/2026), aux deux niveaux ;
# memes regles pour les variantes sur leurs premiers sigma** ; niveaux
# calibres Q_u, Q_w, Q_t aux PROBS_Q.
bornes_cand <- function(s, sh, st, codes) {
  b <- stats::setNames(rep(NA_real_, 4L * length(codes)),
                       unlist(lapply(codes, function(k) paste(k, rep(names(ALPHA_NIV), each = 2), c("bas", "haut"), sep = "_"))))
  qs <- list(u = rep(NA_real_, 4), w = rep(NA_real_, 4), t = rep(NA_real_, 4))
  se_hat <- stats::sd(log(s))
  if (sum(st$adm) > MIN_SIGMA) {
    qs$u <- q7(st$u[st$adm], PROBS_Q); qs$w <- q7(st$w[st$adm], PROBS_Q)
  }
  se_ext_ok <- is.finite(se_hat) && se_hat > TOL_SE
  if (sum(st$okse) > MIN_SIGMA && se_ext_ok) qs$t <- q7(st$t[st$okse], PROBS_Q)
  for (n in names(ALPHA_NIV)) {
    ia <- if (n == "90") 2L else 1L; ib <- if (n == "90") 3L else 4L     # indices de a et 1 - a dans PROBS_Q
    for (k in codes) {
      v <- switch(substr(k, 1, 2),
                  C0 = if (!anyNA(qs$u)) c(q7(s, qs$u[ia]), q7(s, qs$u[ib])) else c(NA, NA),
                  C1 = if (!anyNA(qs$w)) c(sh^2 / q7(s, qs$w[ib]), sh^2 / q7(s, qs$w[ia])) else c(NA, NA),
                  C2 = if (!anyNA(qs$t)) c(sh * exp(-se_hat * qs$t[ib]), sh * exp(-se_hat * qs$t[ia])) else c(NA, NA))
      b[paste0(k, "_", n, "_", c("bas", "haut"))] <- v
    }
  }
  list(b = b, q = qs, se_hat = se_hat, se_ext_ok = se_ext_ok)
}
# Ecriture independante (controle 5) : comptes par findInterval() sur les
# sigma** tries, ecart-type en clair (denominateur n - 1), quantiles de type
# 7 en clair (q7_clair()), C1 sous la forme exp(2 log s - log q), C2 sous la
# forme exp(log s - se q).
bornes_independantes <- function(s, sh, S2, m, codes) {
  X <- S2[seq_len(m), , drop = FALSE]
  n_b <- integer(ncol(X)); w <- u <- tt <- rep(NA_real_, ncol(X))
  for (i in seq_len(ncol(X))) {
    x <- sort(X[is.finite(X[, i]), i]); n_b[i] <- length(x)
    if (n_b[i] <= MIN_SIGMA) next
    w[i] <- findInterval(s[i]^2 / sh, x) / n_b[i]
    u[i] <- findInterval(sh, x) / n_b[i]
    lx <- log(x); sdi <- sqrt(sum((lx - sum(lx) / n_b[i])^2) / (n_b[i] - 1))
    if (is.finite(sdi) && sdi > TOL_SE) tt[i] <- (log(s[i]) - log(sh)) / sdi
  }
  adm <- n_b > MIN_SIGMA; okt <- !is.na(tt)
  ls <- log(s); se_hat <- sqrt(sum((ls - sum(ls) / length(ls))^2) / (length(ls) - 1))
  out <- numeric(0)
  for (k in codes) for (n in names(ALPHA_NIV)) {
    a <- ALPHA_NIV[[n]]
    v <- switch(substr(k, 1, 2),
                C0 = if (sum(adm) > MIN_SIGMA) q7_clair(s, q7_clair(u[adm], c(a, 1 - a))) else c(NA, NA),
                C1 = if (sum(adm) > MIN_SIGMA) exp(2 * log(sh) - log(q7_clair(s, q7_clair(w[adm], c(1 - a, a))))) else c(NA, NA),
                C2 = if (sum(okt) > MIN_SIGMA && is.finite(se_hat) && se_hat > TOL_SE)
                  exp(log(sh) - se_hat * q7_clair(tt[okt], c(1 - a, a))) else c(NA, NA))
    out[paste0(k, "_", n, "_", c("bas", "haut"))] <- v
  }
  attr(out, "n_b") <- n_b
  out
}

###############################################################################
#  UN TRIANGLE SIMULE
###############################################################################
COLONNES <- c("profil", "r", "g_tri", "g_ext", "statut", "motif_code", "R_hat", "msep", "sigma_hat", "R_B", "msep_B", "sigma_B",
              "n_lignes", "n_sig", "retires", "plafond", "smin", "smax", "se_hat", NOMS_BORNES,
              "nb_adm", "nb_excl", "nb_echec", "nse_deg", "se_ext_deg", "nb_adm_r1", "nse_deg_r2", "nb_adm_r2",
              paste0("Qu_", SUF_Q), paste0("Qw_", SUF_Q), paste0("Qt_", SUF_Q), paste0("Qw1_", SUF_Q), paste0("Qt2_", SUF_Q),
              "ctl", "ctl3", "ctl4", "ecart_ind", "ctl11", "message", "duree_s", "t_ext", "t_fig", "t_int")
COLONNES_DUREE <- c("duree_s", "t_ext", "t_fig", "t_int")
COLONNES_BRUT <- setdiff(COLONNES, COLONNES_DUREE)
COL_TEXTE <- c("profil", "statut", "motif_code", "message")
STATUTS <- c("ok", "sans_candidat", "sans_intervalle", "refus", "echec_autre")

# Ligne du triangle r du profil p, a B1 et B2 ; var : tirages des variantes
# (NA : sans objet). ctl : controles 3 et 4 (mw_bootstrap() externe et
# interne). Graines par defaut de P6 ; le pre-vol passe les siennes.
un_triangle <- function(p, r, B1, B2, var, ctl = FALSE, g_tri = graine_tri(p, r), g_ext = graine_ext(p, r),
                        g_int = function(b) graine_int(p, r, b)) {
  t1 <- proc.time()[["elapsed"]]
  L <- stats::setNames(as.list(rep(NA, length(COLONNES))), COLONNES)
  L$profil <- PROFILS$code[p]; L$r <- r; L$g_tri <- g_tri; L$g_ext <- g_ext; L$motif_code <- "-"
  L$ctl <- as.integer(ctl)
  fin <- function(statut, code = "-", msg = NA_character_) {
    L$statut <- statut; L$motif_code <- code; L$message <- msg
    L$duree_s <- proc.time()[["elapsed"]] - t1
    L
  }
  tryCatch({
    tri <- triangle_profil(p, g_tri)
    ad <- admettre(tri)
    if (!ad$ok) return(fin("refus", ad$code, ad$motif))
    aj <- ad$aj; ms <- ad$msep; sh <- sqrt(ms) / aj$reserve
    L$R_hat <- aj$reserve; L$msep <- ms; L$sigma_hat <- sh
    aB <- recomposer(aj, GEN$aj$f, GEN$aj$sigma2)
    mB <- tryCatch(mw_msep(aB)$msep, error = function(e) NA_real_)
    L$R_B <- aB$reserve; L$msep_B <- mB
    L$sigma_B <- if (is.finite(aB$reserve) && aB$reserve > 0 && is.finite(mB) && mB >= 0) sqrt(mB) / aB$reserve else NA_real_
    # Bootstrap externe.
    ta <- proc.time()[["elapsed"]]
    figes <- .mw_ensembles_figes(aj)
    lg <- boucle_allegee(aj, B1, g_ext, figes, garder = TRUE)
    bs <- which(is.finite(lg$sig)); s <- lg$sig[bs]
    L$t_ext <- proc.time()[["elapsed"]] - ta
    L$n_lignes <- sum(lg$ajuste); L$n_sig <- length(s)
    L$retires <- as.integer(lg$retires); L$plafond <- as.integer(lg$plafond)
    if (ctl) {
      bt <- mw_bootstrap(aj, B = B1, seed = g_ext)
      L$ctl3 <- as.integer(identical(bt$sigma_boot, s))
    }
    if (length(s) <= MIN_SIGMA) return(fin("sans_intervalle"))
    L$smin <- min(s); L$smax <- max(s); L$se_hat <- stats::sd(log(s))
    br <- bornes_ref(s, sh)
    for (nm in names(br)) L[[nm]] <- br[[nm]]
    # Bootstrap interne de chaque b a sigma* fini.
    S2 <- matrix(NA_real_, B2, length(bs))
    echec <- logical(length(bs)); t_fig <- 0; t_int <- 0
    for (i in seq_along(bs)) {
      b <- bs[i]; ab <- lg$fits[[b]]
      tb <- proc.time()[["elapsed"]]
      fb <- tryCatch(.mw_ensembles_figes(ab), error = function(e) NULL)
      tc <- proc.time()[["elapsed"]]; t_fig <- t_fig + tc - tb
      li <- if (is.null(fb)) NULL else tryCatch(boucle_allegee(ab, B2, g_int(b), fb), error = function(e) NULL)
      t_int <- t_int + proc.time()[["elapsed"]] - tc
      if (is.null(li)) { echec[i] <- TRUE; next }
      S2[, i] <- li$sig
    }
    L$t_fig <- t_fig; L$t_int <- t_int
    # Candidats a B2.
    st <- stats_b(s, sh, S2, B2)
    L$nb_adm <- sum(st$adm); L$nb_excl <- sum(!st$adm); L$nb_echec <- sum(echec); L$nse_deg <- sum(st$adm & !st$okse)
    cc <- bornes_cand(s, sh, st, c("C0", "C1", "C2"))
    L$se_ext_deg <- as.integer(!cc$se_ext_ok)
    for (nm in names(cc$b)) L[[nm]] <- cc$b[[nm]]
    for (j in seq_along(SUF_Q)) { L[[paste0("Qu_", SUF_Q[j])]] <- cc$q$u[j]; L[[paste0("Qw_", SUF_Q[j])]] <- cc$q$w[j]; L[[paste0("Qt_", SUF_Q[j])]] <- cc$q$t[j] }
    ind <- bornes_independantes(s, sh, S2, B2, c("C0", "C1", "C2"))
    e_ind <- ecart_relatif_max(unname(cc$b[names(ind)]), unname(ind))
    # Controle 11 (constat m1 de l'audit) : exclusions recomptees par deux
    # sources independantes de stats_b() : n_b de bornes_independantes()
    # (sigma** finis tries) et colSums(!is.na(S2)) ; echecs internes : colonnes
    # entierement NA.
    nb_ind <- attr(ind, "n_b"); nb_na <- colSums(!is.na(S2))
    L$ctl11 <- as.integer(identical(as.integer(nb_ind), as.integer(nb_na)) && sum(nb_ind > MIN_SIGMA) == L$nb_adm &&
                            sum(nb_na <= MIN_SIGMA) == L$nb_excl && L$nb_adm + L$nb_excl == L$n_sig && all(nb_na[echec] == 0L))
    # Variantes (premiers sigma** de chaque b).
    if (!is.na(var[["C1"]])) {
      s1 <- stats_b(s, sh, S2, var[["C1"]]); c1 <- bornes_cand(s, sh, s1, "C1r")
      L$nb_adm_r1 <- sum(s1$adm)
      for (nm in names(c1$b)) L[[nm]] <- c1$b[[nm]]
      for (j in seq_along(SUF_Q)) L[[paste0("Qw1_", SUF_Q[j])]] <- c1$q$w[j]
      i1 <- bornes_independantes(s, sh, S2, var[["C1"]], "C1r")
      e_ind <- max(e_ind, ecart_relatif_max(unname(c1$b[names(i1)]), unname(i1)))
    }
    if (!is.na(var[["C2"]])) {
      s2 <- stats_b(s, sh, S2, var[["C2"]]); c2 <- bornes_cand(s, sh, s2, "C2r")
      L$nb_adm_r2 <- sum(s2$adm); L$nse_deg_r2 <- sum(s2$adm & !s2$okse)
      for (nm in names(c2$b)) L[[nm]] <- c2$b[[nm]]
      for (j in seq_along(SUF_Q)) L[[paste0("Qt2_", SUF_Q[j])]] <- c2$q$t[j]
      i2 <- bornes_independantes(s, sh, S2, var[["C2"]], "C2r")
      e_ind <- max(e_ind, ecart_relatif_max(unname(c2$b[names(i2)]), unname(i2)))
    }
    L$ecart_ind <- e_ind
    if (ctl) {
      i0 <- which(st$adm)[1]
      L$ctl4 <- if (is.na(i0)) 0L else {
        b0 <- bs[i0]
        bt2 <- mw_bootstrap(lg$fits[[b0]], B = B2, seed = g_int(b0))
        as.integer(identical(bt2$sigma_boot, S2[is.finite(S2[, i0]), i0]))
      }
    }
    if (sum(st$adm) <= MIN_SIGMA) return(fin("sans_candidat"))
    fin("ok")
  }, error = function(e) fin("echec_autre", "-", nettoyer_champ(conditionMessage(e))))
}

# --- Ecriture et lecture des lignes ------------------------------------------
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
#  MODE --prevol (P7, P9)
###############################################################################
if (MODE == "prevol") {
  U <- OPT_UNITES
  B2_PV <- NIVEAUX[["M1"]]$B2
  VAR_PV <- c(C1 = NA_real_, C2 = NA_real_)
  ecrire_console(c("## Pr\u00e9-vol de la mesure #610 (S6, \u00e9tape 4) -- rien d'\u00e9crit", "",
                   sprintf("Commit : %s ; md5 R/engine.R : %s ; empreinte #231 : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s",
                           COMMIT_DEBUT, MD5_MOTEUR_DEBUT, EMPREINTE_DEBUT, PLATEFORME, COEURS, horodatage()), ""))
  # Charge de la machine (Linux : /proc/loadavg), au debut et a la fin : un
  # debit P_k mesure sous charge exterieure n'est pas representatif.
  charge <- function() { f <- "/proc/loadavg"
    if (file.exists(f)) paste(strsplit(readLines(f, n = 1L, warn = FALSE), " ", fixed = TRUE)[[1]][1:3], collapse = " ") else "non disponible" }
  CHARGE_DEBUT <- charge()
  # 1. Admission sur les graines du pre-vol (un processus), u <= 50.
  ADM <- lapply(seq_len(nrow(PROFILS)), function(p) {
    t0 <- Sys.time()
    codes <- vapply(seq_len(U_MAX), function(u) admettre(triangle_profil(p, graine_pv_tri(p, u)))$code, "")
    list(codes = codes, a = mean(codes == "-"), c_adm = secs(t0) / U_MAX, u_adm = which(codes == "-"))
  })
  names(ADM) <- PROFILS$code
  if (length(ADM$P1$u_adm) < U) stop("--prevol : moins de ", U, " triangles admis sur les graines du pr\u00e9-vol de P1")
  # 2. run_engine(reserve2) (un processus), puis cout additionnel de C0, C1
  # et C2 dans ses conditions : sigma* de la boucle allegee a B = 999 sous la
  # graine par defaut (egalite a run_engine()$bootstrap$sigma_boot verifiee),
  # puis bootstrap interne a B2 = 199 et 50 (graines 641 300 000 + b).
  t0 <- Sys.time()
  RE <- run_engine(methode = "reserve2", triangle = .tri, segment = 1, annexe = "II", date_reference = DATE_REFERENCE_TESTS)
  c_re <- secs(t0)
  aj0 <- GEN$aj; sh0 <- GEN$sigma_A
  t0 <- Sys.time()
  fg0 <- .mw_ensembles_figes(aj0)
  lg0 <- boucle_allegee(aj0, B1_MESURE, SEED_DEFAUT, fg0, garder = TRUE)
  c_ext_re <- secs(t0)
  bs0 <- which(is.finite(lg0$sig)); s0 <- lg0$sig[bs0]
  egal_re <- isTRUE(RE$ok) && identical(RE$bootstrap$sigma_boot, s0)
  cout_imbrique <- function(B2) {
    t0 <- Sys.time()
    S2 <- matrix(NA_real_, B2, length(bs0))
    for (i in seq_along(bs0)) {
      b <- bs0[i]; ab <- lg0$fits[[b]]
      fb <- tryCatch(.mw_ensembles_figes(ab), error = function(e) NULL)
      li <- if (is.null(fb)) NULL else tryCatch(boucle_allegee(ab, B2, graine_pv_int(P_RUN_ENGINE, 1L, b), fb), error = function(e) NULL)
      if (!is.null(li)) S2[, i] <- li$sig
    }
    st <- stats_b(s0, sh0, S2, B2)
    cc <- bornes_cand(s0, sh0, st, c("C0", "C1", "C2"))
    list(duree = secs(t0), cc = cc, nb_adm = sum(st$adm), nse = sum(st$adm & !st$okse))
  }
  IMB199 <- cout_imbrique(B2_PV)
  IMB50 <- cout_imbrique(NIVEAUX[["M4"]]$B2)
  # 3. Cout d'un controle 3 et d'un controle 4 (mw_bootstrap() complet,
  # externe a B1 = 999 et interne a B2 = 199) sur le premier triangle admis
  # du pre-vol de P1 ; cout du controle 6 (relecture de R/engine.R).
  u1 <- ADM$P1$u_adm[1]
  ad1 <- admettre(triangle_profil(1L, graine_pv_tri(1L, u1)))
  t0 <- Sys.time(); bt1 <- mw_bootstrap(ad1$aj, B = B1_MESURE, seed = graine_pv_ext(1L, u1)); c_ctl3 <- secs(t0)
  lg1 <- boucle_allegee(ad1$aj, 1, graine_pv_ext(1L, u1), .mw_ensembles_figes(ad1$aj), garder = TRUE)
  ab1 <- Filter(Negate(is.null), lg1$fits)
  c_ctl4 <- if (length(ab1)) { t0 <- Sys.time(); invisible(mw_bootstrap(ab1[[1]], B = B2_PV, seed = graine_pv_int(1L, u1, 1))); secs(t0) } else
    c_ctl3 * B2_PV / B1_MESURE                            # repli : proportionnel a B
  t0 <- Sys.time(); e0 <- new.env(); sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE); c_ctl6 <- secs(t0)
  # 4. Cout d'un triangle (P1, B1 = 999, B2 = 199) a 1 a 4 processus
  # concurrents, les memes U triangles dans chaque processus.
  unite <- function(i) do.call(rbind, lapply(seq_len(U), function(k) {
    u <- ADM$P1$u_adm[k]
    L <- un_triangle(1L, u, B1_MESURE, B2_PV, VAR_PV, g_tri = graine_pv_tri(1L, u), g_ext = graine_pv_ext(1L, u),
                     g_int = function(b) graine_pv_int(1L, u, b))
    if (!identical(L$statut, "ok")) stop("triangle du pr\u00e9-vol sans candidat (u = ", u, ")")
    c(duree = L$duree_s, ext = L$t_ext, fig = L$t_fig, int = L$t_int, nb = L$n_sig)
  }))
  KMAX <- max(1L, min(4L, COEURS, na.rm = TRUE))
  CB <- list(); MUR <- numeric(KMAX)
  for (k in seq_len(KMAX)) {
    t0 <- Sys.time()
    res <- parallel::mclapply(seq_len(k), unite, mc.cores = k, mc.preschedule = FALSE)
    MUR[k] <- secs(t0)
    if (any(vapply(res, function(x) !is.matrix(x), logical(1)))) stop("--prevol : processus en erreur (k = ", k, ")")
    CB[[k]] <- do.call(rbind, res)
  }
  P_k <- vapply(seq_len(KMAX), function(k) k * mean(CB[[1]][, "duree"]) / mean(CB[[k]][, "duree"]), 1)
  m1 <- colMeans(CB[[1]])
  # Modele lineaire du cout d'un triangle admis en un processus (hypothese
  # [H1] : cout interne proportionnel a B2 ; [H2] : P2 et P3 coutent comme
  # P1, precedent de #387) : externe + reste + nb (figes + B2 c_fit).
  c_fit <- mean(CB[[1]][, "int"] / (CB[[1]][, "nb"] * B2_PV))
  c_fig <- mean(CB[[1]][, "fig"] / CB[[1]][, "nb"])
  c_reste <- mean(CB[[1]][, "duree"] - CB[[1]][, "ext"] - CB[[1]][, "fig"] - CB[[1]][, "int"])
  c_tri <- function(B2) m1[["ext"]] + c_reste + m1[["nb"]] * (c_fig + B2 * c_fit)
  a_adm <- vapply(ADM, function(x) x$a, 1); c_adm <- vapply(ADM, function(x) x$c_adm, 1)
  duree_plan <- function(niv, k) {
    N <- NIVEAUX[[niv]]; B2 <- N$B2
    n_tr <- sum(ceiling(N$R / TAILLE_TRANCHE))
    par <- sum(N$R * (a_adm * c_tri(B2) + (1 - a_adm) * c_adm)) + n_tr * (c_ctl3 + c_ctl4 * B2 / B2_PV)
    seq_ <- c_ctl6 + R_FIL * (m1[["ext"]] + c_reste)
    seq_ + par / P_k[k]
  }
  k_plan <- min(K_BUDGET, KMAX)
  plan <- vapply(names(NIVEAUX), function(l) duree_plan(l, k_plan), 1)
  tient <- plan <= BUDGET_S
  ech <- ECHELLE_P7[tient[ECHELLE_P7]]
  niveau <- if (length(ech)) ech[1] else NA_character_
  # Seuil de --arret-apres (M42 (b) : segments de 2 h au plus) : un segment
  # peut depasser son seuil de la duree d'un groupe de k_plan tranches ;
  # seuil = 120 min - 5 min de marge - 1,5 groupe, arrondi aux 5 min
  # inferieures, au moins 30 min.
  g_min <- if (is.na(niveau)) NA_real_ else TAILLE_TRANCHE * k_plan * c_tri(NIVEAUX[[niveau]]$B2) / P_k[k_plan] / 60
  arret_min <- if (is.na(g_min)) 85 else max(30, 5 * floor((120 - 5 - 1.5 * g_min) / 5))
  f2 <- function(m, cc) sprintf("%s [%s ; %s]", num(mean(m[, cc]), 2), num(min(m[, cc]), 2), num(max(m[, cc]), 2))
  ecrire_console(c("### Admission sur les graines du pr\u00e9-vol (un processus, u \u2264 50)", "",
                   entete_md(c("Profil", "triangles tir\u00e9s", "admis", "taux d'admission", "motifs de refus", "s par triangle (admission)")),
                   vapply(names(ADM), function(cd) {
                     x <- ADM[[cd]]; t <- table(x$codes[x$codes != "-"])
                     ligne_md(cd, length(x$codes), sum(x$codes == "-"), num(x$a, 3),
                              if (length(t)) paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") else "aucun", num(x$c_adm, 4))
                   }, ""), "",
                   "### Co\u00fbt dans les conditions de run_engine() (reserve2, B = 999, graine par d\u00e9faut, un processus)", "",
                   entete_md(c("Grandeur", "Valeur")),
                   ligne_md("run_engine(methode = \"reserve2\", triangle de contr\u00f4le) : dur\u00e9e (s)", num(c_re, 2)),
                   ligne_md("\u03c3* de la boucle all\u00e9g\u00e9e (B = 999, graine par d\u00e9faut) identical() \u00e0 run_engine()$bootstrap$sigma_boot",
                            if (egal_re) "oui" else "NON"),
                   ligne_md("boucle all\u00e9g\u00e9e externe avec conservation des \u03b8*_b (s ; nul si le moteur les conservait)", num(c_ext_re, 2)),
                   ligne_md(sprintf("co\u00fbt additionnel de C0, C1 et C2 \u00e0 B2 = %s (s) ; b admises ; se*_b d\u00e9g\u00e9n\u00e9r\u00e9s", format(B2_PV)),
                            sprintf("%s ; %d / %d ; %d", num(IMB199$duree, 2), IMB199$nb_adm, length(bs0), IMB199$nse)),
                   ligne_md(sprintf("idem \u00e0 B2 = %s (niveau M4, C2 seul)", format(NIVEAUX[["M4"]]$B2)),
                            sprintf("%s ; %d / %d ; %d", num(IMB50$duree, 2), IMB50$nb_adm, length(bs0), IMB50$nse)),
                   ligne_md(sprintf("rapport (run_engine() + additionnel) / run_engine() : B2 = %s ; B2 = %s", format(B2_PV), format(NIVEAUX[["M4"]]$B2)),
                            sprintf("%s ; %s", num((c_re + IMB199$duree) / c_re, 2), num((c_re + IMB50$duree) / c_re, 2))),
                   ligne_md("idem, conservation des \u03b8*_b compt\u00e9e en plus", sprintf("%s ; %s", num((c_re + c_ext_re + IMB199$duree) / c_re, 2),
                                                                                      num((c_re + c_ext_re + IMB50$duree) / c_re, 2))),
                   ligne_md(sprintf("bornes \u00e0 90 %% sur reserve2 (B2 = %s), pour information : C0 ; C1 ; C2", format(B2_PV)),
                            paste(vapply(c("C0", "C1", "C2"), function(k) txt_ic(IMB199$cc$b[paste0(k, "_90_", c("bas", "haut"))], 5), ""), collapse = " ; ")), "",
                   "### Co\u00fbts unitaires (secondes, dur\u00e9e murale dans chaque processus)", "",
                   sprintf("Unit\u00e9 : un triangle admis de P1 (graines du pr\u00e9-vol), B1 = %s, B2 = %s ; %d triangle(s) par processus, les m\u00eames dans chaque processus.", format(B1_MESURE), format(B2_PV), U), "",
                   entete_md(c("processus concurrents", "dur\u00e9e murale de la phase (s)", "triangle (total)", "externe", ".mw_ensembles_figes() internes", "boucles internes", "\u03c3* finis (b)", "d\u00e9bit agr\u00e9g\u00e9 P_k")),
                   vapply(seq_len(KMAX), function(k) ligne_md(k, num(MUR[k], 1), f2(CB[[k]], "duree"), f2(CB[[k]], "ext"), f2(CB[[k]], "fig"),
                                                              f2(CB[[k]], "int"), num(mean(CB[[k]][, "nb"]), 0), num(P_k[k], 3)), ""), "",
                   sprintf("Mod\u00e8le (un processus) : co\u00fbt d'un triangle admis = externe %s + reste %s + b %s \u00d7 (figes %s + B2 \u00d7 %s ms par ajustement interne) ; B2 = 199 : %s s ; 99 : %s s ; 50 : %s s. Contr\u00f4le 3 : %s s ; contr\u00f4le 4 (B2 = 199) : %s s ; contr\u00f4le 6 : %s s.",
                           num(m1[["ext"]], 3), num(c_reste, 3), num(m1[["nb"]], 0), num(1000 * c_fig, 2), num(1000 * c_fit, 4), num(c_tri(199), 1), num(c_tri(99), 1),
                           num(c_tri(50), 1), num(c_ctl3, 1), num(c_ctl4, 1), num(c_ctl6, 1)), "",
                   sprintf("### Niveaux (P7 : premier niveau de l'\u00e9chelle %s dont la dur\u00e9e pr\u00e9vue tient dans 12 h d'horloge sur %d processus ; M0 et M2 hors \u00e9chelle, Q-2b-2 (b) et (c) ; sous M4, retour au mainteneur)",
                           paste(ECHELLE_P7, collapse = ", "), K_BUDGET), "",
                   entete_md(c("Niveau", "P1", "P2", "P3", "B2", "candidats", sprintf("dur\u00e9e pr\u00e9vue \u00e0 %d processus (h)", k_plan), "dans le budget", "dans l'\u00e9chelle P7")),
                   vapply(names(NIVEAUX), function(l) { N <- NIVEAUX[[l]]
                     ligne_md(l, N$R[["P1"]], N$R[["P2"]], N$R[["P3"]], format(N$B2), paste(N$cand, collapse = ", "), num(plan[[l]] / 3600, 2),
                              if (tient[[l]]) "oui" else "non", if (l %in% ECHELLE_P7) "oui" else sprintf("non (%s)", HORS_ECHELLE[[l]])) }, ""), "",
                   if (k_plan < K_BUDGET) sprintf("**Moins de %d c\u0153urs : dur\u00e9e pr\u00e9vue \u00e0 %d processus seulement.**", K_BUDGET, k_plan) else character(0),
                   if (!is.na(niveau))
                     sprintf("**Niveau retenu : %s, dur\u00e9e pr\u00e9vue %s h \u00e0 %d processus** (hypoth\u00e8ses : [H1] co\u00fbt interne proportionnel \u00e0 B2 ; [H2] P2 et P3 au co\u00fbt de P1 ; [H3] d\u00e9bit lin\u00e9aire par triangle, queues de groupes non compt\u00e9es ; la charge de la machine n'est pas contr\u00f4l\u00e9e).%s",
                             niveau, num(plan[[niveau]] / 3600, 2), k_plan,
                             if (plan[[niveau]] > 2 * 3600) sprintf(" Au-del\u00e0 de 2 h : segments de 2 h au plus (M42 (b), accord du mainteneur) ; environ %d segment(s) de %d min (groupe de %d tranches : environ %s min) ; branche claude/sauvegarde-610 autoris\u00e9e d'avance (Q-2b-7).",
                                                                as.integer(ceiling(plan[[niveau]] / (arret_min * 60))), as.integer(arret_min), k_plan, num(g_min, 0)) else "")
                   else "**Aucun niveau de l'\u00e9chelle ne tient dans 12 h, y compris M4 : retour au mainteneur (P7).**",
                   if (!is.na(niveau) && !niveau %in% c("M1+P3", "M1"))
                     sprintf("**Niveau sous M1 : Q-2b-2 (a) a retenu M1 (%s h pr\u00e9vues) ; %s.**", num(plan[["M1"]] / 3600, 2),
                             paste(note_niveau(niveau), collapse = " ; ")) else character(0),
                   sprintf("Charge de la machine (/proc/loadavg, 1, 5 et 15 min) : d\u00e9but %s ; fin %s ; avec %d c\u0153urs, une charge sup\u00e9rieure au nombre de processus du pr\u00e9-vol signale une charge ext\u00e9rieure qui d\u00e9prime P_k.",
                           CHARGE_DEBUT, charge(), COEURS),
                   "", if (!is.na(niveau) && niveau %in% c("M1+P3", "M1"))
                     sprintf("Commande de la mesure (arbre propre, script commit\u00e9) : LC_ALL=C.UTF-8 Rscript %s --niveau %s --processus %d --arret-apres %d --ecrire",
                             SCRIPT_DEPOT, niveau, k_plan, as.integer(arret_min))
                   else "Aucune commande de mesure propos\u00e9e : niveau sous M1 ou aucun niveau, d\u00e9cision du mainteneur requise (r\u00e8gle 1).",
                   "", sprintf("PREVOL610\t%s\t%s\t%s\t%s\t%s\t%s\t%s", paste(sprintf("%.4f", m1), collapse = "\t"),
                               paste(sprintf("%.4f", P_k), collapse = "\t"), paste(sprintf("%.3f", a_adm), collapse = "\t"),
                               sprintf("%.3f\t%.3f\t%.3f", c_re, IMB199$duree, IMB50$duree), paste(sprintf("%.0f", plan), collapse = "\t"),
                               if (is.na(niveau)) "NA" else niveau, if (egal_re) "egal_run_engine" else "DIFFERENT_run_engine"),
                   sprintf("Dur\u00e9e du pr\u00e9-vol : %s s.", num(secs(t_debut), 0))))
  quit(status = if (egal_re) 0L else 1L)
}

###############################################################################
#  ESSAI ET MESURE : PARAMETRES, GARDES DE --ecrire, JOURNAL (avant tout
#  calcul couteux, #205)
###############################################################################
if (!is.na(OPT_NIVEAU) && !OPT_NIVEAU %in% names(NIVEAUX)) refuser("--niveau : ", paste(names(NIVEAUX), collapse = ", "))
B1_RUN <- if (OPT_ESSAI) B1_ESSAI else B1_MESURE
B2_RUN <- if (OPT_ESSAI) B2_ESSAI else NIVEAUX[[OPT_NIVEAU]]$B2
R_RUN <- if (OPT_ESSAI) R_ESSAI else NIVEAUX[[OPT_NIVEAU]]$R
CAND <- if (OPT_ESSAI) c("C1", "C2") else NIVEAUX[[OPT_NIVEAU]]$cand
VAR_RUN <- local({ v <- if (OPT_ESSAI) VARIANTES_ESSAI else VARIANTES_MESURE; v[v >= B2_RUN] <- NA_real_; v })
if (any(R_RUN < 0L) || any(R_RUN > R_MAX) || sum(R_RUN) < 1L) refuser("R : entiers de 0 a ", R_MAX)
txt_R <- function(R_) paste(sprintf("%s=%d", names(R_), R_), collapse = ",")
txt_var <- function(v) paste(sprintf("%s=%s", names(v), ifelse(is.na(v), "sans objet", format(v))), collapse = ",")
if (OPT_ECRIRE) {
  nv <- motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")
  if (length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
                          " -- lancer depuis un arbre au commit propre")
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) refuser("dossier de sortie introuvable : docs/tableaux")
}
SUFFIXE <- if (OPT_ESSAI) "essai" else gsub("+", "-", OPT_NIVEAU, fixed = TRUE)
TRAVAIL <- if (!is.na(OPT_TRAVAIL)) OPT_TRAVAIL else if (OPT_ESSAI) tempfile("essai610_", tmpdir = dirname(tempdir())) else
  file.path(dirname(normalizePath(RACINE, winslash = "/")), sprintf("issue610-travail-%s", SUFFIXE))
if (sous_depot(TRAVAIL)) refuser("--travail : dossier sous le depot refuse")
if (!dir.exists(TRAVAIL)) dir.create(TRAVAIL, recursive = TRUE)
TRAVAIL <- normalizePath(TRAVAIL, winslash = "/")
JOURNAL_T <- file.path(TRAVAIL, "JOURNAL.md")
CTX <- c(B1 = B1_RUN, B2 = B2_RUN, variantes = txt_var(VAR_RUN), sha = SHA_DEBUT, md5_moteur = MD5_MOTEUR_DEBUT,
         md5_script = MD5_SCRIPT, empreinte = EMPREINTE_DEBUT, empreintes_code = EMPREINTES, plateforme = PLATEFORME,
         essai = if (OPT_ESSAI) "oui" else "non", taille_tranche = TAILLE_TRANCHE)
txt_ctx <- function(ctx) paste(names(ctx), ctx, sep = "=", collapse = " || ")
lire_journal <- function() {
  jl <- readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")
  champ <- function(cle) {
    m <- regmatches(jl, regexec(paste0("^- ", cle, " : (.*)$"), jl))
    v <- vapply(m[lengths(m) == 2L], `[`, "", 2L)
    if (length(v)) v[1] else NA_character_
  }
  list(lignes = jl, R = champ("R par profil"), sha = champ("SHA \\(git rev-parse HEAD\\) au lancement"),
       md5 = champ("md5 R/engine\\.R au lancement"), date = champ("Date des sorties"),
       ctx = champ("Contexte des tranches"), lancement = champ("Lancement"),
       empreinte = champ("Empreinte sans commentaires de R/engine\\.R"))
}
if (!file.exists(JOURNAL_T)) {
  ecrire_fichier(JOURNAL_T, c(
    sprintf("# JOURNAL de la mesure #610 (S6, \u00e9tape 4 : couverture \u00e0 T = 8 des intervalles de \u03c3 calibr\u00e9s par bootstrap imbriqu\u00e9, Merz-W\u00fcthrich)%s",
            if (OPT_ESSAI) " -- ESSAI, non versionnable" else ""), "",
    sprintf("- Lancement : %s", horodatage()),
    sprintf("- Date des sorties : %s", format(Sys.time(), "%Y%m%d", tz = "UTC")),
    sprintf("- R par profil : %s", txt_R(R_RUN)),
    sprintf("- Niveau : %s", if (OPT_ESSAI) "essai (--essai)" else sprintf("%s (--niveau explicite ; pr\u00e9-vol, P7)%s", OPT_NIVEAU,
                                   if (length(note_niveau(OPT_NIVEAU))) paste0(" ; ", paste(note_niveau(OPT_NIVEAU), collapse = " ; ")) else "")),
    sprintf("- B1 ; B2 ; variantes : %s ; %s ; %s", format(B1_RUN), format(B2_RUN), txt_var(VAR_RUN)),
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
    sprintf("- Contexte des tranches : %s", txt_ctx(CTX)),
    paste0("- R\u00e8gles de lecture (actuary, 20/11/2026 ; taux de W compar\u00e9s s\u00e9par\u00e9ment \u00e0 0,01) : ", TEXTE_REGLES_610)))
} else {
  J0 <- lire_journal()
  if (!identical(J0$R, txt_R(R_RUN))) refuser("reprise : R du JOURNAL (", J0$R, ") different de ", txt_R(R_RUN))
  if (!identical(J0$ctx, txt_ctx(CTX))) refuser("reprise : contexte du JOURNAL different du contexte courant -- autre --travail")
  ecrire_fichier(JOURNAL_T, sprintf("- Reprise : %s ; commande : Rscript %s %s", horodatage(), SCRIPT_DEPOT, args_cites()), mode = "ab")
}
J0 <- lire_journal()
DATE_SORTIES <- J0$date
BASE_NOM <- sprintf("%s-issue610-couverture-ic-sigma-mw-imbrique", DATE_SORTIES)
NOM_MD  <- paste0(BASE_NOM, ".md")
NOM_TSV <- paste0(BASE_NOM, "-brut.tsv")
NOM_JNL <- paste0(BASE_NOM, "-journal-mesure.md")
CIBLES <- file.path(RACINE, "docs", "tableaux", c(NOM_MD, NOM_TSV, NOM_JNL))
REMPLACES <- NULL
if (OPT_ECRIRE) REMPLACES <- garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)

###############################################################################
#  CONTROLES AVANT TOUT TIRAGE DU PLAN : 9, 2, 6, 7, 8, 10
###############################################################################
INTEGRITE <- character(0)
CTRL <- list()
controle <- function(code, ok, detail) {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
  if (!isTRUE(ok)) INTEGRITE <<- c(INTEGRITE, code)
}
# Controle 9 (t610) : par. 4 (critere et profils) et statut epistemique du
# par. 3 du rapport verse, presents a l'identique (copies ci-dessous,
# echappements \u du texte du rapport).
TEXTE_STATUT_610 <- c(
  "**Statut \u00e9pist\u00e9mique (\u00e0 \u00e9crire tel quel en t\u00eate de la sortie).** La couverture mesur\u00e9e est un **constat de simulation**. Elle vaut sous le mod\u00e8le de Mack ajust\u00e9 au triangle de contr\u00f4le (f\u0302, \u03c3\u0302\u00b2 extrapol\u00e9 compris, premi\u00e8re colonne fix\u00e9e), pour une loi d'erreurs donn\u00e9e, \u00e0 T = 8. Elle porte sur la proc\u00e9dure enti\u00e8re \u00e0 B1 = 999 et B2 = 199, conditionnellement \u00e0 l'admission (R\u0302 > 0) et \u00e0 R\\* > 0. Ce n'est pas un r\u00e9sultat g\u00e9n\u00e9ral : aucun th\u00e9or\u00e8me ne couvre ces intervalles \u00e0 triangle fixe, et les ordres asymptotiques du double bootstrap (Chang et Hall, 2014) ne fondent rien \u00e0 T = 8. Erreurs \u00e0 distinguer :",
  "- l'erreur Monte-Carlo en N, encadr\u00e9e par Clopper-Pearson ;",
  "- les effets de B1 et B2, inclus dans la proc\u00e9dure mesur\u00e9e et non isol\u00e9s (C1-99 et C2-50 en donnent seulement un \u00e9clairage) ;",
  "- l'\u00e9cart au nominal, qui est l'objet mesur\u00e9 ;",
  "- l'erreur de substitution (plan et loi au lieu de la v\u00e9rit\u00e9), non quantifi\u00e9e.")
TEXTE_CRITERE_610 <- c(
  "## 4. Crit\u00e8re et profils, fix\u00e9s avant toute ex\u00e9cution (\u00e0 reporter sans modification dans le script et au T0)",
  "",
  "> **Crit\u00e8re.** Taux de non-couverture \u03c4 de chaque (profil, intervalle, niveau), cible \u03c3_A, compar\u00e9 au nominal \u03c1 = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206, Fk, #305 et #387, bande **ferm\u00e9e** [\u03c1/2 ; 3\u03c1/2] : *compatible* (\u03c1 \u2208 IC(\u03c4)) ; *\u00e9cart mineur* (\u03c4\u0302 dans la bande, sans \u00eatre compatible) ; *non tranch\u00e9* (\u03c4\u0302 hors de la bande, IC qui la recoupe) ; *distorsion mat\u00e9rielle lib\u00e9rale* (IC disjoint de la bande, au-dessus) ; *distorsion mat\u00e9rielle conservatrice* (IC disjoint, au-dessous). IC de Clopper-Pearson \u00e0 95 % ; classes sur les valeurs non arrondies ; une estimation sur un bord est dans la bande ; **aucune extension de R apr\u00e8s lecture** ; un \u00ab non tranch\u00e9 \u00bb reste non tranch\u00e9.",
  "> - **K-610-1** (principal) : classe \u00e0 90 % de C1 et de C2 sur P1 et sur P2.",
  "> - **K-610-2** (descriptif) : 95 % ; queues s\u00e9par\u00e9es contre \u03c1/2 (bande [\u03c1/4 ; 3\u03c1/4]) ; cible \u03c3_B ; I1 et I4 recalcul\u00e9s, en regard, et compar\u00e9s aux classes de #387 ; C0, C1-99, C2-50 ; P3 si mesur\u00e9 ; largeur m\u00e9diane / \u03c3_A et rapport \u00e0 la largeur de I1 ; couverture par tiers de \u03c3\u0302/\u03c3_A ; part de \u03c3_A > max \u03c3\\* et > \u03c3\u0302\u00b2/min \u03c3\\* (reproduction du \u00a7 1.1 sur graines nouvelles) ; saturations de C1 et C0 ; part des bornes de C2 hors de [min \u03c3\\* ; max \u03c3\\*] ; quantiles de Q_w(\u03b1), Q_w(1 \u2212 \u03b1) et de Q_t.",
  "> - **K-610-3** (int\u00e9grit\u00e9) : contr\u00f4les 1 \u00e0 11 de P11.",
  "> - **K-610-4** (fronti\u00e8re, descriptif) : l'IC touche-t-il un bord de la bande.",
  ">",
  "> **Profils de lecture pour D3** (`actuary` propose, le mainteneur tranche ; ordre : \u03980, \u03984, \u03981 \u00e0 \u03983, puis modificateur W) :",
  ">",
  "> | Profil | Condition | Lecture propos\u00e9e |",
  "> |---|---|---|",
  "> | \u03980 | K-610-3 en d\u00e9faut ; ou, sur P1 ou P2, refus, triangles sans intervalle ou r\u00e9plications b exclues au-del\u00e0 de 1 % | lecture suspendue ; mesure \u00e0 reprendre |",
  "> | \u03984 | un candidat en distorsion de c\u00f4t\u00e9s oppos\u00e9s entre P1 et P2 | d\u00e9cision du mainteneur ; aucune restitution de ce candidat |",
  "> | \u03981 | C1 ou C2 compatible ou en \u00e9cart mineur sur P1 **et** P2 | **candidat \u00e9ligible** ; D3 : restitution **en regard du percentile, jamais \u00e0 sa place** (Q-42-10), textes tranch\u00e9s \u00e0 D3. Si les deux sont \u00e9ligibles, pr\u00e9f\u00e9rence fix\u00e9e d'avance : (i) celui dont les deux queues \u00e0 90 % sont dans [\u03c1/4 ; 3\u03c1/4] sur P1 et P2 ; (ii) \u00e0 \u00e9galit\u00e9, celui de moindre co\u00fbt par `run_engine()` au pr\u00e9-vol ; le mainteneur d\u00e9cide en dernier ressort |",
  "> | \u03982 | aucun candidat \u00e9ligible, au moins un \u00ab non tranch\u00e9 \u00bb sur P1 ou P2 | constat seul ; aucune restitution par d\u00e9faut ; note inchang\u00e9e |",
  "> | \u03983 | C1 et C2 chacun en distorsion mat\u00e9rielle sur au moins un profil principal, sans \u03984 | constat seul ; note inchang\u00e9e (\u00ab aucun intervalle mesur\u00e9 ne r\u00e9tablit ce niveau \u00bb reste vrai) ; fiche compl\u00e9t\u00e9e par `docwriter` |",
  ">",
  "> **Modificateur W**, sous \u03981, pour le candidat retenu. W-a : bornes d\u00e9g\u00e9n\u00e9r\u00e9es, saturations et b exclus au plus 1 % sur P1 et P2 : aucune limite de plus. W-b : au-del\u00e0 de 1 % : limite \u00e9crite dans la fiche, et d\u00e9cision du mainteneur sur la restitution.",
  ">",
  "> **Port\u00e9e \u00e9crite d'avance** : un \u03981 vaut pour le triangle de contr\u00f4le sous E et N seulement. Le profil volatil (P4) n'est pas mesur\u00e9 : la restitution porterait la mention de ce domaine.")
present_bloc <- function(bloc, txt) {
  i <- which(txt == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(txt) && identical(txt[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
T610 <- local({
  f <- file.path(RACINE, PROTOCOLE)
  txt <- if (file.exists(f)) readLines(f, warn = FALSE, encoding = "UTF-8") else character(0)
  c(critere = present_bloc(TEXTE_CRITERE_610, txt), statut = present_bloc(TEXTE_STATUT_610, txt))
})
if (!all(T610))
  refuser("(t610) : par. 4 ou statut du par. 3 absent ou modifie dans ", PROTOCOLE, " -- le critere reporte dans le script ne concorde plus avec le rapport verse")
controle("9 (t610)", all(T610), sprintf("par. 4 (crit\u00e8re et profils, %d lignes) %s ; statut \u00e9pist\u00e9mique du par. 3 (%d lignes) %s, dans %s (md5 %s) ; v\u00e9rifi\u00e9 avant tout tirage",
                                         length(TEXTE_CRITERE_610), if (T610[["critere"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9",
                                         length(TEXTE_STATUT_610), if (T610[["statut"]]) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9",
                                         PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE))))
# Controle 2 : sigma_A.
REF_R2 <- readRDS(chemin_reference("reserve2"))
local({
  e1 <- abs(SIGMA_A - REF_R2$parametre_final$sigma_estime) / abs(REF_R2$parametre_final$sigma_estime)
  controle("2", is.finite(e1) && e1 <= TOLERANCE,
           sprintf("\u03c3_A de P1 \u00e0 P3 = %.10g ; reserve2.rds : parametre_final$sigma_estime = %.10g (\u00e9cart relatif %.3e) ; TOLERANCE %g",
                   SIGMA_A, REF_R2$parametre_final$sigma_estime, e1, TOLERANCE))
})
# Controle 6 (g) : generateur identique a mw_simuler_triangle() (100 graines,
# triangles r = 1..100 de P1), pool non dilate puis dilate (#271) ; fonctions
# du moteur identiques a celles de R/engine.R relu (copie du controle 6 (g)
# de #387, generateur reserve2 seul ; .mw_ensembles_figes ajoutee).
FACTEURS_G <- c(1, 30, 100, 300, 1000)
local({
  g <- GEN
  meme_g <- function(pool) vapply(seq_len(100), function(i) {
    gr <- graine_tri(1L, i)
    a <- engine_sous_graine(gr, gen_triangle_h0(g$aj, function(n) sample(pool, n, replace = TRUE)))
    b <- engine_sous_graine(gr, mw_simuler_triangle(g$aj, pool))
    c(identique = identical(a, b), incomplet = .mw_triangle_incomplet(b))
  }, logical(2))
  base <- meme_g(g$pool)["identique", ]
  for (fd in FACTEURS_G[-1]) { dil <- meme_g(fd * g$pool); if (any(dil["incomplet", ])) break }
  ok <- all(base) && all(dil["identique", ]) && any(dil["incomplet", ])
  e0 <- new.env()
  sys.source(file.path(RACINE, "R", "engine.R"), envir = e0, keep.source = FALSE)
  env_m <- environment(mw_bootstrap)
  meme <- function(nm) { a <- get(nm, envir = env_m); b <- get(nm, envir = e0)
    identical(formals(a), formals(b)) && identical(body(a), body(b)) }
  fns <- c("mw_simuler_triangle", ".mw_simuler_triangle_etat", ".mw_tirer_triangle_valide", ".mw_triangle_incomplet",
           ".mw_pool_residus", ".mw_ensembles_figes", "mw_bootstrap", "mw_ajuster", "mw_msep")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  controle("6 (g)", ok && ok_fns, sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = mw_simuler_triangle() sous la m\u00eame graine (identical()) : reserve2 : %d / 100 identiques ; pool dilat\u00e9 %g fois : %d / 100 identiques, dont %d triangle(s) \u00e0 cumul simul\u00e9 non fini ou \u2264 0 ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                                          sum(base), fd, sum(dil["identique", ]), sum(dil["incomplet", ]), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
})
# Controle 7 : filiation avec le brut de #387 (P1, r <= 20, graines de #387,
# B = 999, boucle allegee) : sigma chapeau, I1 et I4 aux deux niveaux.
local({
  f <- file.path(RACINE, BRUT_387)
  if (!file.exists(f)) { controle("7", FALSE, sprintf("%s introuvable", BRUT_387)); return(invisible()) }
  br <- utils::read.delim(f, colClasses = "character", check.names = FALSE, quote = "", comment.char = "", stringsAsFactors = FALSE)
  cols <- c("sigma_hat", paste(rep(c("I1", "I4"), each = 4), rep(names(ALPHA_NIV), each = 2), c("bas", "haut"), sep = "_"))
  ecarts <- vapply(seq_len(R_FIL), function(r) {
    l <- br[br$profil == "P1" & as.integer(br$r) == r, , drop = FALSE]
    if (nrow(l) != 1L || l$statut != "ok") return(Inf)
    tri <- engine_sous_graine(GRAINE_TRI_387 + r, gen_triangle_h0(GEN$aj, TIREURS[[1]]))
    ad <- admettre(tri); if (!ad$ok) return(Inf)
    sh <- sqrt(ad$msep) / ad$aj$reserve
    lg <- boucle_allegee(ad$aj, B1_MESURE, GRAINE_BOOT_387 + r, .mw_ensembles_figes(ad$aj))
    s <- lg$sig[is.finite(lg$sig)]
    v <- c(sigma_hat = sh, bornes_ref(s, sh))[cols]
    ecart_relatif_max(unname(v), as.numeric(unlist(l[1, cols])))
  }, 1)
  controle("7", all(is.finite(ecarts)) && max(ecarts) <= TOL_FIL,
           sprintf("graines de #387 (triangle %.0f + r, bootstrap %.0f + r ; P1, r = 1 \u00e0 %d ; B = %s, boucle all\u00e9g\u00e9e) : \u03c3\u0302, I1 et I4 (90 %% et 95 %%) contre %s (md5 %s) : \u00e9cart relatif maximal %.2e (seuil %g) ; %d / %d triangles sous le seuil",
                   GRAINE_TRI_387, GRAINE_BOOT_387, R_FIL, format(B1_MESURE), BRUT_387, md5_fichier(f), max(ecarts), TOL_FIL,
                   sum(is.finite(ecarts) & ecarts <= TOL_FIL), R_FIL))
})
# Controle 8 : plages de graines disjointes (P6), et litteraux du depot.
PLAGES <- local({
  P <- list()
  for (p in seq_len(nrow(PROFILS))) {
    P[[sprintf("tri_%s", PROFILS$code[p])]] <- c(graine_tri(p, 1), graine_tri(p, R_MAX))
    P[[sprintf("ext_%s", PROFILS$code[p])]] <- c(graine_ext(p, 1), graine_ext(p, R_MAX))
    P[[sprintf("int_%s", PROFILS$code[p])]] <- c(graine_int(p, 1, 1), graine_int(p, R_MAX, B1_MESURE))
  }
  P$pv_tri <- c(graine_pv_tri(1, 1), graine_pv_tri(nrow(PROFILS), U_MAX))
  P$pv_ext <- c(graine_pv_ext(1, 1), graine_pv_ext(nrow(PROFILS), U_MAX))
  P$pv_int <- c(graine_pv_int(1, 1, 1), graine_pv_int(P_RUN_ENGINE, 1, B1_MESURE))
  P$trapeze <- PLAGE_TRAPEZE
  do.call(rbind, P)
})
local({
  M <- PLAGES; disj <- TRUE
  for (a in seq_len(nrow(M) - 1L)) for (b in (a + 1L):nrow(M))
    if (M[a, 1] <= M[b, 2] && M[b, 1] <= M[a, 2]) disj <- FALSE
  # Pas des sous-plages : interne du pre-vol 1 000 (u - 1) + b < 100 000 ;
  # interne de la mesure 1 000 (r - 1) + b < 4 000 000 ; b < 1 000 ;
  # u < 10 000 ; r < 500 000 (triangle et externe d'un meme profil).
  pv_ok <- PAS_INT_R * (U_MAX - 1) + B1_MESURE < PAS_PV_INT_PROFIL && PAS_INT_R * (R_MAX - 1) + B1_MESURE < PAS_INT_PROFIL &&
    B1_MESURE < PAS_INT_R && U_MAX < PAS_PV && R_MAX < GRAINE_EXT - GRAINE_TRI
  ext <- rbind(`2a (#567)` = PLAGE_EXT_2A, `#206/#297 MW` = PLAGE_EXT_206, `#297 LN` = PLAGE_EXT_297LN, `#305` = PLAGE_EXT_305,
               `#387` = PLAGE_EXT_387, `360 380 123` = PLAGE_EXT_ISOLEE)
  touche <- function(lo, hi) any(lo <= M[, 2] & hi >= M[, 1])
  ext_ok <- !any(vapply(seq_len(nrow(ext)), function(i) touche(ext[i, 1], ext[i, 2]), logical(1)))
  fil_hors <- !touche(GRAINE_TRI_387 + 1, GRAINE_BOOT_387 + R_FIL)
  max_ok <- max(M) <= .Machine$integer.max
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT_DEPOT)]
  lit <- sort(unique(unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    as.numeric(unlist(regmatches(l, gregexpr("(?<![0-9A-Za-z._])[0-9]{8,10}(?=L?(?![0-9A-Za-z._]))", l, perl = TRUE))))
  }))))
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_LITTERAL), logical(1))]
  dessus <- lit[lit > max(M)]
  controle("8", disj && pv_ok && ext_ok && fil_hors && max_ok && !length(coll),
           sprintf(paste("plages de la mesure (triangles, externes, internes des 3 profils ; pr\u00e9-vol ; r\u00e9serve du trap\u00e8ze) de %.0f \u00e0 %.0f, disjointes entre elles : %s ; pas des sous-plages compatibles (b \u2264 %s < %d, r \u2264 %d, u \u2264 %d) : %s ;",
                         "disjointes de %s : %s ; graines du contr\u00f4le 7 (#387) hors des plages : %s ; maximum \u2264 2^31 \u2212 1 : %s ;",
                         "%d litt\u00e9raux entiers de 8 \u00e0 10 chiffres dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R ; \u00e9criture scientifique non recherch\u00e9e) ;",
                         "litt\u00e9raux L dont [L ; L + %.0f] touche une plage : %s ; litt\u00e9raux au-dessus des plages : %s"),
                   min(M), max(M), if (disj) "oui" else "NON", format(B1_MESURE), PAS_INT_R, R_MAX, U_MAX, if (pv_ok) "oui" else "NON",
                   paste(sprintf("%s %.0f-%.0f", rownames(ext), ext[, 1], ext[, 2]), collapse = ", "), if (ext_ok) "oui" else "NON",
                   if (fil_hors) "oui" else "NON", if (max_ok) "oui" else "NON", length(lit), length(fs),
                   DECALAGE_LITTERAL, if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                   if (length(dessus)) paste(sprintf("%.0f", dessus), collapse = ", ") else "aucun"))
})
# Controle 10 (m) : aucune occurrence du nom du script dans R/, app.R, .github/.
local({
  fs <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE), file.path(RACINE, "app.R"),
          list.files(file.path(RACINE, ".github"), recursive = TRUE, full.names = TRUE, all.files = TRUE))
  fs <- fs[file.exists(fs) & !dir.exists(fs)]
  lit <- function(f) tryCatch(readLines(f, warn = FALSE, skipNul = TRUE), error = function(e) NA_character_)
  trouve <- fs[vapply(fs, function(f) { x <- lit(f); anyNA(x) || any(grepl(MOTIF_GREP, x, fixed = TRUE)) }, logical(1))]
  controle("10 (m)", !length(trouve), sprintf("aucune occurrence de \u00ab %s \u00bb dans R/, app.R et .github/ (%d fichiers lus) ; en d\u00e9faut : %s",
                                              MOTIF_GREP, length(fs), if (length(trouve)) paste(basename(trouve), collapse = ", ") else "aucun"))
})
if (length(INTEGRITE)) {
  ecrire_console(c("## INTEGRITE ECHEC avant tout tirage du plan", "",
                   vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(INTEGRITE, collapse = ", "))))
  quit(status = 1L)
}

###############################################################################
#  CALCUL PAR TRANCHES (reprise M42 (b), P8)
###############################################################################
tranches_de <- function(R_) if (R_ < 1L) list() else
  lapply(seq(1L, R_, by = TAILLE_TRANCHE), function(a) c(a, min(a + TAILLE_TRANCHE - 1L, R_)))
fichier_tranche <- function(cd, tr) file.path(TRAVAIL, sprintf("%s-r%06d-%06d.tsv", cd, tr[1], tr[2]))
lire_tranche <- function(f, cd, tr) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  n <- tr[2] - tr[1] + 1L
  if (length(l) != n + 3L || l[1] != paste0("#CONTEXTE\t", txt_ctx(CTX)) || l[2] != paste(COLONNES, collapse = "\t") ||
      l[length(l)] != sprintf("#FIN\t%d", n))
    refuser("tranche ", basename(f), " : contexte, en-tete ou fin differents du calcul courant -- pas de melange (autre --travail)")
  df <- lire_lignes(l[3:(n + 2L)])
  if (!identical(as.integer(df$r), seq.int(tr[1], tr[2])) || !identical(df$profil, rep(cd, n)))
    refuser("tranche ", basename(f), " : triangles inattendus")
  df
}
ecrire_tranche <- function(f, lignes, n) {
  tmp <- paste0(f, ".tmp")
  ecrire_fichier(tmp, c(paste0("#CONTEXTE\t", txt_ctx(CTX)), paste(COLONNES, collapse = "\t"), lignes, sprintf("#FIN\t%d", n)))
  if (!file.rename(tmp, f)) stop("renommage impossible : ", basename(tmp))
}
# Premier triangle admis d'une tranche (controles 3 et 4) : admission
# recalculee par le maitre (cout negligeable), meme triangle.
premier_admis <- function(p, tr) {
  for (r in seq.int(tr[1], tr[2])) if (admettre(triangle_profil(p, graine_tri(p, r)))$ok) return(r)
  NA_integer_
}
ARRET_S <- 60 * OPT_ARRET
N_CALC <- 0L; N_TR_CALC <- 0L; T_CALC <- 0; SEGMENT_ARRETE <- FALSE
# Groupes de OPT_PROC tranches traites par un seul appel de mclapply
# (ordonnancement dynamique, une tache par triangle, le triangle des
# controles 3 et 4 en tete). Chaque ligne ne depend que de ses graines : le
# resultat ne depend ni des groupes ni du nombre de processus.
for (cd in PROFILS$code) {
  if (SEGMENT_ARRETE) break
  p <- match(cd, PROFILS$code)
  trs <- tranches_de(R_RUN[[cd]])
  manquantes <- Filter(function(tr) !file.exists(fichier_tranche(cd, tr)), trs)
  if (!length(manquantes)) next
  groupes <- split(manquantes, ceiling(seq_along(manquantes) / OPT_PROC))
  for (gr in groupes) {
    if (secs(t_debut) > ARRET_S) { SEGMENT_ARRETE <- TRUE; break }
    t0 <- Sys.time()
    taches <- list()
    for (tr in gr) {
      r_c <- premier_admis(p, tr)
      if (!is.na(r_c)) taches[[length(taches) + 1L]] <- list(r = r_c, ctl = TRUE)
      for (r in setdiff(seq.int(tr[1], tr[2]), r_c)) taches[[length(taches) + 1L]] <- list(r = r, ctl = FALSE)
    }
    res <- parallel::mclapply(taches, function(t) un_triangle(p, t$r, B1_RUN, B2_RUN, VAR_RUN, ctl = t$ctl),
                              mc.cores = OPT_PROC, mc.preschedule = FALSE)
    ok <- vapply(res, function(x) is.list(x) && !is.null(x$r), logical(1))
    if (!all(ok)) stop("groupe de tranches de ", cd, " : processus en erreur ; relancer pour reprendre")
    ids <- vapply(res, function(L) as.integer(L$r), 1L)
    for (tr in gr) {
      sel <- res[ids >= tr[1] & ids <= tr[2]]
      sel <- sel[order(vapply(sel, function(L) as.integer(L$r), 1L))]
      ecrire_tranche(fichier_tranche(cd, tr), vapply(sel, format_ligne, ""), length(sel))
      N_CALC <- N_CALC + length(sel); N_TR_CALC <- N_TR_CALC + 1L
    }
    T_CALC <- T_CALC + secs(t0)
    message(sprintf("%s : %s, %d tranche(s) calculee(s) (%.0f s)", horodatage(), cd, length(gr), secs(t0)))
  }
}
if (SEGMENT_ARRETE) {
  reste <- sum(vapply(PROFILS$code, function(cd) sum(!vapply(tranches_de(R_RUN[[cd]]), function(tr) file.exists(fichier_tranche(cd, tr)), logical(1))), 1))
  ecrire_fichier(JOURNAL_T, sprintf("- Segment arr\u00eat\u00e9 (--arret-apres %s min) : %s ; tranches calcul\u00e9es par ce segment : %d ; tranches restantes : %d",
                                    format(OPT_ARRET), horodatage(), N_TR_CALC, reste), mode = "ab")
  ecrire_console(c(sprintf("Segment arr\u00eat\u00e9 apr\u00e8s %s s (--arret-apres %s min) : %d tranche(s) calcul\u00e9e(s), %d restante(s) ; relancer la m\u00eame commande avec le m\u00eame --travail (reprise M42 (b)).",
                           num(secs(t_debut), 0), format(OPT_ARRET), N_TR_CALC, reste),
                   "SEGMENT INCOMPLET"))
  quit(status = 3L)
}
TR <- list(); FICHIERS_TR <- character(0)
for (cd in PROFILS$code) for (tr in tranches_de(R_RUN[[cd]])) {
  f <- fichier_tranche(cd, tr)
  TR[[length(TR) + 1L]] <- cbind(lire_tranche(f, cd, tr), tranche = basename(f), stringsAsFactors = FALSE)
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
D <- do.call(rbind, TR)

###############################################################################
#  CONTROLES SUR LES LIGNES CALCULEES : 3, 4, 5, 11, puis 1
###############################################################################
ADM <- D[D$statut %in% c("ok", "sans_candidat", "sans_intervalle"), , drop = FALSE]
ACC <- D[D$statut %in% c("ok", "sans_candidat"), , drop = FALSE]        # I1, I4 formes
# Bornes ordonnees (borne basse <= borne haute) sur toutes les bornes formees.
BORNES_ORDONNEES <- all(vapply(CODES_IC, function(k) all(vapply(names(ALPHA_NIV), function(n) {
  lo <- D[[paste0(k, "_", n, "_bas")]]; hi <- D[[paste0(k, "_", n, "_haut")]]
  f <- !is.na(lo) & !is.na(hi)
  all(lo[f] <= hi[f]) && identical(is.na(lo), is.na(hi))
}, logical(1))), logical(1)))
par_tranche <- function(col) {
  vapply(unique(D$tranche), function(tn) { x <- D[D$tranche == tn & D$ctl %in% 1, , drop = FALSE]
    nrow(x) == 1L && isTRUE(x[[col]] == 1) }, logical(1))
}
local({
  v3 <- par_tranche("ctl3")
  controle("3", length(v3) > 0L && all(v3), sprintf("\u03c3* de la boucle all\u00e9g\u00e9e externe identical() \u00e0 mw_bootstrap(aj_r, B1 = %s, G_EXT)$sigma_boot sur le premier triangle admis de chaque tranche : %d / %d tranches",
                                                   format(B1_RUN), sum(v3), length(v3)))
  v4 <- par_tranche("ctl4")
  controle("4", length(v4) > 0L && all(v4), sprintf("\u03c3** de la boucle interne identical() \u00e0 mw_bootstrap(\u03b8*_b, B2 = %s, G_INT)$sigma_boot sur la premi\u00e8re r\u00e9plication b admise du premier triangle admis de chaque tranche : %d / %d tranches",
                                                   format(B2_RUN), sum(v4), length(v4)))
})
local({
  d <- D[!is.na(D$ecart_ind), , drop = FALSE]
  prem <- vapply(unique(D$tranche), function(tn) { x <- D[D$tranche == tn & !is.na(D$ecart_ind), , drop = FALSE]
    nrow(x) > 0L && is.finite(x$ecart_ind[1]) && x$ecart_ind[1] <= TOL_IND }, logical(1))
  tous <- nrow(d) > 0L && all(is.finite(d$ecart_ind) & d$ecart_ind <= TOL_IND)
  controle("5", all(prem) && tous && BORNES_ORDONNEES,
           sprintf("bornes de C0, C1, C2 (et des variantes) aux deux niveaux recalcul\u00e9es par une \u00e9criture ind\u00e9pendante (findInterval() sur les \u03c3** tri\u00e9s, \u00e9cart-type en clair, type 7 en clair, C1 = exp(2 log \u03c3\u0302 \u2212 log q), C2 = exp(log \u03c3\u0302 \u2212 se q)), seuil %g relatif : premier triangle de chaque tranche %d / %d ; tous les triangles calcul\u00e9s %d / %d (\u00e9cart maximal %.2e) ; borne basse \u2264 borne haute sur toutes les bornes form\u00e9es : %s",
                   TOL_IND, sum(prem), length(prem), sum(is.finite(d$ecart_ind) & d$ecart_ind <= TOL_IND), nrow(d),
                   if (nrow(d)) max(d$ecart_ind) else NA_real_, if (BORNES_ORDONNEES) "oui" else "NON (agr\u00e9gation non faite)"))
})
local({
  tir <- sapply(PROFILS$code, function(cd) sum(D$profil == cd))
  adm <- sapply(PROFILS$code, function(cd) sum(ADM$profil == cd))
  ref <- sapply(PROFILS$code, function(cd) sum(D$profil == cd & D$statut == "refus"))
  ech <- sapply(PROFILS$code, function(cd) sum(D$profil == cd & D$statut == "echec_autre"))
  ok_tir <- all(tir == R_RUN[PROFILS$code]) && all(tir == adm + ref + ech)
  d <- D[!is.na(D$nb_adm), , drop = FALSE]
  ok_b <- nrow(d) == 0L || all(d$ctl11 %in% 1 & d$nb_adm + d$nb_excl == d$n_sig)
  controle("11", ok_tir && ok_b, sprintf("tir\u00e9s = admis + refus\u00e9s + \u00e9checs : %s ; b admises + b exclues = \u03c3* finis, exclusions recompt\u00e9es par deux sources ind\u00e9pendantes de stats_b() (n_b de bornes_independantes() et colSums(!is.na(S2))), sur %d / %d triangles \u00e0 bootstrap interne (\u00e9checs internes compt\u00e9s parmi les exclues)",
                                         paste(sprintf("%s %d = %d + %d + %d", PROFILS$code, tir, adm, ref, ech), collapse = " ; "),
                                         sum(d$ctl11 %in% 1 & d$nb_adm + d$nb_excl == d$n_sig), nrow(d)))
})
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
EMPREINTE_FIN <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
local({
  ctx_tr <- unique(unname(vapply(FICHIERS_TR, function(f) readLines(f, n = 1L, warn = FALSE), "")))
  ok_ctx <- length(ctx_tr) == 1L && identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))
  ok <- MD5_MOTEUR_DEBUT == MD5_MOTEUR_FIN && SHA_DEBUT == SHA_FIN && SHA_DEBUT != "inconnu" && EMPREINTE_DEBUT == EMPREINTE_FIN &&
    identical(J0$sha, SHA_DEBUT) && identical(J0$md5, MD5_MOTEUR_DEBUT) && identical(J0$empreinte, EMPREINTE_DEBUT) && ok_ctx
  controle("1", ok, sprintf("md5 R/engine.R d\u00e9but %s, fin %s, JOURNAL %s ; SHA d\u00e9but %s, fin %s, JOURNAL %s ; empreinte #231 d\u00e9but %s, fin %s, JOURNAL %s ; contexte (B1, B2, variantes, SHA, md5 du moteur et du script, empreinte, empreintes md5 du code ex\u00e9cut\u00e9 dont tests/outils_tests.R, plateforme) identique dans les %d tranche(s) : %s",
                            MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN, J0$md5, SHA_DEBUT, SHA_FIN, J0$sha, EMPREINTE_DEBUT, EMPREINTE_FIN, J0$empreinte,
                            length(FICHIERS_TR), if (ok_ctx) "oui" else "NON"))
})
ORDRE_CTRL <- c("1", "2", "3", "4", "5", "6 (g)", "7", "8", "9 (t610)", "10 (m)", "11")
CTRL <- CTRL[order(match(vapply(CTRL, function(k) k$code, ""), ORDRE_CTRL))]
if (!BORNES_ORDONNEES) {
  ecrire_console(c("## INTEGRITE ECHEC avant l'agr\u00e9gation : bornes invers\u00e9es (contr\u00f4le 5)", "",
                   vapply(CTRL, function(k) sprintf("- %s : %s -- %s", k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "",
                   sprintf("INTEGRITE ECHEC : %s", paste(INTEGRITE, collapse = ", "))))
  quit(status = 1L)
}

###############################################################################
#  AGREGATION : COUVERTURE (K-610-1, K-610-2, K-610-4)
###############################################################################
ic_cp <- function(k, n) {
  if (n <= 0) return(c(NA_real_, NA_real_))
  c(if (k == 0) 0 else stats::qbeta(0.025, k, n - k + 1), if (k == n) 1 else stats::qbeta(0.975, k + 1, n - k))
}
CLASSES <- c(comp = "compatible", mineur = "\u00e9cart mineur", nt = "non tranch\u00e9",
             lib = "distorsion mat\u00e9rielle lib\u00e9rale (sous-couverture)", cons = "distorsion mat\u00e9rielle conservatrice")
# Classe d'un taux k/n contre rho (bande fermee [rho/2 ; 3 rho/2]) : copie de
# classer() de #387.
classer <- function(k, n, rho) {
  if (n == 0) return(list(taux = NA_real_, ci = c(NA_real_, NA_real_), classe = "non \u00e9valuable (n = 0)", code = NA_character_, bord = NA_character_))
  t <- k / n; ci <- ic_cp(k, n); bas <- rho / 2; haut <- 3 * rho / 2
  code <- if (ci[1] <= rho && rho <= ci[2]) "comp" else if (ci[1] > haut) "lib" else if (ci[2] < bas) "cons" else
    if (t >= bas && t <= haut) "mineur" else "nt"
  touche <- c(if (ci[1] <= bas && bas <= ci[2]) "\u03c1/2", if (ci[1] <= haut && haut <= ci[2]) "3\u03c1/2")
  list(taux = t, ci = ci, classe = CLASSES[[code]], code = code,
       bord = if (length(touche)) paste0("oui (", paste(touche, collapse = ", "), ")") else "non")
}
LIB_IC <- c(I1 = "I1 percentile (r\u00e9f\u00e9rence)", I4 = "I4 \u00ab basic \u00bb log (r\u00e9f\u00e9rence)",
            C0 = "C0 percentile calibr\u00e9 (descriptif)",
            C1 = if ("C1" %in% CAND) "C1 I4 calibr\u00e9 (candidat)" else "C1 I4 calibr\u00e9 (hors crit\u00e8re \u00e0 ce niveau)",
            C2 = "C2 studentis\u00e9 log (candidat)",
            C1r = sprintf("C1-%s (descriptif)", if (is.na(VAR_RUN[["C1"]])) "r" else format(VAR_RUN[["C1"]])),
            C2r = sprintf("C2-%s (descriptif)", if (is.na(VAR_RUN[["C2"]])) "r" else format(VAR_RUN[["C2"]])))
IC_ACTIFS <- CODES_IC[!(CODES_IC == "C1r" & is.na(VAR_RUN[["C1"]])) & !(CODES_IC == "C2r" & is.na(VAR_RUN[["C2"]]))]
PR_ACTIFS <- PROFILS$code[R_RUN[PROFILS$code] > 0L]
cellule_cov <- function(cd, code, niv, cible = "A", sous = NULL) {
  d <- D[D$profil == cd, , drop = FALSE]
  if (!is.null(sous)) d <- d[sous(d), , drop = FALSE]
  lo <- d[[paste0(code, "_", niv, "_bas")]]; hi <- d[[paste0(code, "_", niv, "_haut")]]
  s0 <- if (cible == "A") rep(SIGMA_A, nrow(d)) else d$sigma_B
  l1 <- d[[paste0("I1_", niv, "_bas")]]; h1 <- d[[paste0("I1_", niv, "_haut")]]
  k_ <- !is.na(lo) & !is.na(hi) & is.finite(s0)
  lo <- lo[k_]; hi <- hi[k_]; s0 <- s0[k_]; l1 <- l1[k_]; h1 <- h1[k_]; n <- length(lo)
  nc <- sum(!(lo <= s0 & s0 <= hi)); nb <- sum(s0 < lo); nh <- sum(s0 > hi); rho <- RHO_NIV[[niv]]
  w <- (hi - lo) / SIGMA_A
  list(n = n, nc = nc, nb = nb, nh = nh, cl = classer(nc, n, rho), cb = classer(nb, n, rho / 2), ch = classer(nh, n, rho / 2),
       cov = if (n) 1 - nc / n else NA_real_, cov_ci = if (n) 1 - rev(ic_cp(nc, n)) else c(NA_real_, NA_real_),
       larg = if (n) stats::median(w) else NA_real_, rapp = if (n) stats::median((hi - lo) / (h1 - l1)) else NA_real_)
}
CEL <- list()
for (cd in PR_ACTIFS) for (code in IC_ACTIFS) for (niv in names(ALPHA_NIV)) CEL[[paste(cd, code, niv)]] <- cellule_cov(cd, code, niv)
REFUS <- lapply(stats::setNames(nm = PR_ACTIFS), function(cd) table(factor(D$statut[D$profil == cd], levels = STATUTS)))
MOTIFS <- lapply(stats::setNames(nm = PR_ACTIFS), function(cd) table(D$motif_code[D$profil == cd & D$statut == "refus"]))
part_non_ok <- function(cd) (R_RUN[[cd]] - REFUS[[cd]][["ok"]]) / R_RUN[[cd]]
part_refus <- function(cd) REFUS[[cd]][["refus"]] / R_RUN[[cd]]
# Regle 5 : triangles admis (non refuses) ou au moins un de I1, I4, C1, C2 a
# 90 % n'est pas forme (union), / admis ; un echec_autre y entre.
part_sans <- function(cd) {
  d <- D[D$profil == cd & D$statut != "refus", , drop = FALSE]
  if (!nrow(d)) return(NA_real_)
  sum(is.na(d$I1_90_bas) | is.na(d$I4_90_bas) | is.na(d$C1_90_bas) | is.na(d$C2_90_bas)) / nrow(d)
}
part_b_excl <- function(cd) { d <- D[D$profil == cd & !is.na(D$nb_adm), , drop = FALSE]; if (sum(d$n_sig)) sum(d$nb_excl) / sum(d$n_sig) else NA_real_ }
part_se_deg <- function(cd) { d <- D[D$profil == cd & !is.na(D$nb_adm), , drop = FALSE]; if (sum(d$nb_adm)) sum(d$nse_deg) / sum(d$nb_adm) else NA_real_ }
# Saturations (par. 2.1, 2.3) au niveau niv : C1 haute Q_w(a) = 0, basse
# Q_w(1 - a) = 1 ; C0 haute Q_u(1 - a) = 1, basse Q_u(a) = 0.
sat <- function(cd, code, niv, cote) {
  d <- D[D$profil == cd & !is.na(D[[paste0(code, "_", niv, "_bas")]]), , drop = FALSE]
  sa <- if (niv == "90") "05" else "025"; sb <- if (niv == "90") "95" else "975"
  pre <- switch(code, C1 = "Qw_", C0 = "Qu_", C1r = "Qw1_")
  v <- switch(paste(substr(code, 1, 2), cote),
              "C1 haut" = d[[paste0(pre, sa)]] == 0, "C1 bas" = d[[paste0(pre, sb)]] == 1,
              "C0 haut" = d[[paste0(pre, sb)]] == 1, "C0 bas" = d[[paste0(pre, sa)]] == 0)
  c(k = sum(v), n = nrow(d))
}
# Classes de #387 (I1, I4 a 90 %, P1, P2), recalculees sur son brut verse.
CL387 <- local({
  br <- utils::read.delim(file.path(RACINE, BRUT_387), colClasses = "character", check.names = FALSE, quote = "", comment.char = "", stringsAsFactors = FALSE)
  out <- list()
  for (cd in c("P1", "P2")) for (code in c("I1", "I4")) {
    b <- br[br$profil == cd & br$statut == "ok", , drop = FALSE]
    lo <- as.numeric(b[[paste0(code, "_90_bas")]]); hi <- as.numeric(b[[paste0(code, "_90_haut")]])
    out[[paste(cd, code)]] <- classer(sum(!(lo <= SIGMA_A & SIGMA_A <= hi)), length(lo), RHO_NIV[["90"]])
  }
  out
})

###############################################################################
#  PROFILS Theta ET W, EVALUES MECANIQUEMENT (SANS DECISION)
###############################################################################
cl90 <- function(cd, code) { x <- CEL[[paste(cd, code, "90")]]; if (is.null(x)) NA_character_ else x$cl$code }
okc <- function(cd) !is.na(cd) && cd %in% c("comp", "mineur")
lib_classe <- function(cd) if (is.na(cd)) "non \u00e9valuable" else CLASSES[[cd]]
PRINC <- intersect(c("P1", "P2"), PR_ACTIFS)
# Modificateur W (regle 3) : C1 : b exclues et saturation haute Q_w(a) = 0 a
# 90 % (/ triangles ou C1 est forme) ; C2 : b exclues et se*_b degeneres (/ b
# a n_b > 20 cumulees) ; chaque taux, non arrondi, compare separement a
# SEUIL_W, sur P1 et P2 separement ; W-a si tous sont au plus SEUIL_W.
W_EVAL <- function(code) {
  r <- vapply(c("P1", "P2"), function(cd) {
    if (!cd %in% PR_ACTIFS) return(c(excl = NA_real_, second = NA_real_))
    sec <- if (code == "C1") { a <- sat(cd, "C1", "90", "haut"); if (a[["n"]]) a[["k"]] / a[["n"]] else NA_real_ } else part_se_deg(cd)
    c(excl = part_b_excl(cd), second = sec)
  }, c(excl = 0, second = 0))
  rownames(r) <- c("b exclues", if (code == "C1") "saturation haute de C1 \u00e0 90 %" else "se*_b d\u00e9g\u00e9n\u00e9r\u00e9s")
  list(taux = r, wa = all(is.finite(r)) && all(r <= SEUIL_W), depasse = which(!is.finite(r) | r > SEUIL_W, arr.ind = TRUE))
}
PROFIL <- local({
  k3 <- !length(INTEGRITE)
  hors <- unlist(lapply(PRINC, function(cd) c(if (part_refus(cd) > SEUIL_THETA0) sprintf("%s refus", cd),
                                                if (isTRUE(part_sans(cd) > SEUIL_THETA0)) sprintf("%s triangles sans intervalle (union I1, I4, C1, C2 \u00e0 90 %%)", cd),
                                                if (isTRUE(part_b_excl(cd) > SEUIL_THETA0)) sprintf("%s b exclues", cd))))
  cl <- lapply(stats::setNames(nm = CAND), function(c_) c(P1 = cl90("P1", c_), P2 = cl90("P2", c_)))
  opp <- CAND[vapply(CAND, function(c_) all(cl[[c_]] %in% c("lib", "cons")) && cl[[c_]][["P1"]] != cl[[c_]][["P2"]], logical(1))]
  elig <- CAND[vapply(CAND, function(c_) okc(cl[[c_]][["P1"]]) && okc(cl[[c_]][["P2"]]), logical(1))]
  nt <- any(unlist(cl) %in% "nt")
  dist <- all(vapply(CAND, function(c_) any(cl[[c_]] %in% c("lib", "cons")), logical(1)))
  suite <- if (length(opp)) "\u03984" else if (length(elig)) "\u03981" else if (nt) "\u03982" else if (dist) "\u03983" else "non class\u00e9"
  p <- if (!k3 || length(hors)) "\u03980" else suite
  # Preference (i) : deux queues a 90 % (estimations) dans [rho/4 ; 3 rho/4]
  # sur P1 et P2.
  qi <- vapply(elig, function(c_) all(vapply(c("P1", "P2"), function(cd) {
    x <- CEL[[paste(cd, c_, "90")]]; r <- RHO_NIV[["90"]]
    all(c(x$cb$taux, x$ch$taux) >= r / 4 & c(x$cb$taux, x$ch$taux) <= 3 * r / 4)
  }, logical(1))), logical(1))
  w <- lapply(stats::setNames(nm = elig), W_EVAL)
  list(profil = p, suite = suite, k3 = k3, hors = hors, cl = cl, opp = opp, elig = elig, qi = qi, w = w)
})

###############################################################################
#  SORTIE MARKDOWN
###############################################################################
txt_cel_cov <- function(c_) if (!c_$n) "\u2014" else sprintf("%s %s", num(c_$cov), txt_ic(c_$cov_ci))
txt_cl <- function(cl) if (is.na(cl$taux)) "\u2014" else sprintf("%s %s", num(cl$taux), txt_ic(cl$ci))
txt_k <- function(k, n) if (!n) "\u2014" else sprintf("%d / %d = %s %s", k, n, num(k / n), txt_ic(ic_cp(k, n)))
qtxt <- function(v, p = c(0.05, 0.5, 0.95), d = 4) { v <- v[is.finite(v)]
  if (!length(v)) "\u2014" else paste(vapply(q7(v, p), num, "", d = d), collapse = " ; ") }
fit_txt <- sprintf("R\u0302 = %.6g ; MSEP = %.6g ; \u03c3_A = %.7g ; f\u0302 = (%s) ; pool n = %d, sd_pop = %.5f ; colonnes d\u00e9g\u00e9n\u00e9r\u00e9es : %s",
                   GEN$aj$reserve, GEN$msep, GEN$sigma_A, paste(sprintf("%.6g", GEN$aj$f), collapse = " ; "), length(GEN$pool), GEN$sd_pop,
                   if (length(GEN$jd)) paste(GEN$jd, collapse = ", ") else "aucune")
S <- c(sprintf("## Mesure #610 (S6, \u00e9tape 4) : couverture \u00e0 T = 8 des intervalles de \u03c3 calibr\u00e9s par bootstrap imbriqu\u00e9, m\u00e9thode Merz-W\u00fcthrich%s",
               if (OPT_ESSAI) " -- ESSAI (--essai), non versionnable" else ""), "",
       "### Statut \u00e9pist\u00e9mique (protocole, par. 3, reproduit tel quel)", "", TEXTE_STATUT_610, "",
       if (OPT_ESSAI) c(sprintf("**ESSAI** : B1 = %s, B2 = %s, variantes %s, R = %s ; ces valeurs ne sont pas celles du protocole et ne valent que pour le contr\u00f4le du script.",
                                format(B1_RUN), format(B2_RUN), txt_var(VAR_RUN), txt_R(R_RUN)), "") else character(0),
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Protocole", sprintf("%s, par. 2 \u00e0 5 ; d\u00e9cisions du mainteneur du 20/11/2026 (Q-2b-1 (a), Q-2b-2 (a), Q-2b-3 (a), Q-2b-4, Q-2b-6 (a)) ; md5 %s",
                                     PROTOCOLE, md5_fichier(file.path(RACINE, PROTOCOLE)))),
       ligne_md("Mode ; niveau", sprintf("%s ; %s", if (OPT_ESSAI) "essai (--essai) : non versionnable" else "mesure", if (OPT_ESSAI) "\u2014" else OPT_NIVEAU)),
       ligne_md("R par profil (tir\u00e9s) ; B1 ; B2 ; variantes", sprintf("%s ; %s ; %s ; %s", txt_R(R_RUN), format(B1_RUN), format(B2_RUN), txt_var(VAR_RUN))),
       ligne_md("Candidats du crit\u00e8re (K-610-1)", paste(c(paste(CAND, collapse = ", "), if (!OPT_ESSAI) note_niveau(OPT_NIVEAU)), collapse = " ; ")),
       ligne_md("R\u00e8gles de lecture (actuary, 20/11/2026)", paste(TEXTE_REGLES_610, collapse = " ")),
       ligne_md("Profils", paste(sprintf("%s : reserve2, loi %s ; %s", PROFILS$code, PROFILS$loi, PROFILS$role), collapse = " ; ")),
       ligne_md("G\u00e9n\u00e9rateur", sprintf("tests/donnees/triangle_mw.csv (md5 %s) ; %s", md5_fichier(file.path(RACINE, "tests", "donnees", "triangle_mw.csv")), fit_txt)),
       ligne_md("Lois", "E : tirage uniforme dans le pool redress\u00e9 du g\u00e9n\u00e9rateur divis\u00e9 par son \u00e9cart-type de population ; N : stats::rnorm ; A : (G \u2212 2)/\u221a2, G ~ Gamma(2) par stats::qgamma(stats::runif(n), 2)"),
       ligne_md("Chemin", "gen_triangle_h0(aj0, loi) sous engine_sous_graine(G_TRI) ; admettre() ; boucle all\u00e9g\u00e9e externe \u00e0 B1, graine G_EXT ; pour chaque b \u00e0 \u03c3* fini : boucle all\u00e9g\u00e9e appliqu\u00e9e \u00e0 \u03b8*_b avec .mw_ensembles_figes(\u03b8*_b), \u00e0 B2, graine G_INT ; b admise si plus de 20 \u03c3** finis"),
       ligne_md("Graines", "triangle 610 000 000 + 1 000 000 (p \u2212 1) + r ; externe 610 500 000 + 1 000 000 (p \u2212 1) + r ; interne 620 000 000 + 4 000 000 (p \u2212 1) + 1 000 (r \u2212 1) + b ; contr\u00f4le 7 : graines de #387 ; disjonction : contr\u00f4le 8"),
       ligne_md("G\u00e9n\u00e9rateur al\u00e9atoire", paste(ENGINE_RNG_KIND, collapse = ", ")),
       ligne_md("Cible", "\u03c3_A (principale) = \u03c3\u0302 du triangle de contr\u00f4le ; \u03c3_B (descriptive) = \u221aMSEP/R de mw_msep() sur la copie de l'ajustement du triangle simul\u00e9 \u00e0 (f, \u03c3\u00b2) du g\u00e9n\u00e9rateur (recomposer() de #387)"),
       ligne_md("Intervalles", "quantiles de type 7 ; I1 [Q*(\u03b1) ; Q*(1\u2212\u03b1)] ; I4 [\u03c3\u0302\u00b2/Q*(1\u2212\u03b1) ; \u03c3\u0302\u00b2/Q*(\u03b1)] ; C0 [Q*(Q_u(\u03b1)) ; Q*(Q_u(1\u2212\u03b1))] ; C1 [\u03c3\u0302\u00b2/Q*(Q_w(1\u2212\u03b1)) ; \u03c3\u0302\u00b2/Q*(Q_w(\u03b1))] ; C2 [\u03c3\u0302 exp(\u2212se Q_t(1\u2212\u03b1)) ; \u03c3\u0302 exp(\u2212se Q_t(\u03b1))] ; 90 % (\u03b1 = 0,05) et 95 % (\u03b1 = 0,025) ; I1, I4 si plus de 20 \u03c3* finis ; C0, C1 si de plus plus de 20 b admises ; C2 si plus de 20 b \u00e0 se*_b valide"),
       ligne_md("SHA, git rev-parse HEAD (d\u00e9but ; fin)", sprintf("%s ; %s", SHA_DEBUT, SHA_FIN)),
       ligne_md("Commit (commit_depot(), au d\u00e9but)", COMMIT_DEBUT),
       ligne_md("md5 R/engine.R (d\u00e9but ; fin)", sprintf("%s ; %s", MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN)),
       ligne_md("Empreinte sans commentaires de R/engine.R (#231 ; d\u00e9but ; fin)", sprintf("%s ; %s", EMPREINTE_DEBUT, EMPREINTE_FIN)),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Locale (LC_CTYPE)", sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL)),
       ligne_md("Tranches", sprintf("%d (taille %d)", length(FICHIERS_TR), TAILLE_TRANCHE)),
       ligne_md("JOURNAL ; valeurs brutes", sprintf("%s ; %s (une ligne par triangle tir\u00e9, %%.17g)", NOM_JNL, NOM_TSV)),
       ligne_md("Versionnable (--ecrire)", if (length(motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")) || OPT_ESSAI) "non" else "oui"),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) paste("\u00c9CHEC :", paste(INTEGRITE, collapse = ", ")) else "OK"),
       "",
       "### Aide \u00e0 la lecture", "",
       paste("\u03c4 = part des triangles \u00e0 intervalle form\u00e9 o\u00f9 la cible est hors de l'intervalle ; IC de Clopper-Pearson \u00e0 95 % (qbeta), erreur Monte-Carlo du taux (fonction du nombre de triangles).",
             "Les effets de B1 et B2 sont inclus dans la proc\u00e9dure mesur\u00e9e et non isol\u00e9s. Couverture conditionnelle \u00e0 l'admission (M4 : R\u0302 > 0) et \u00e0 R* > 0.",
             "Classes et profils calcul\u00e9s m\u00e9caniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient \u00e0 actuary, la d\u00e9cision (D3) au mainteneur."), "",
       "**Crit\u00e8re et profils du protocole (par. 4), report\u00e9s sans modification :**", "",
       TEXTE_CRITERE_610, "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLES[1]))
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9 (K-610-3 : P11, contr\u00f4les 1 \u00e0 11)", "",
       entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""), "")
# T1 : K-610-1.
S <- c(S, "### T1 \u2014 K-610-1 (principal) : classe \u00e0 90 % des candidats sur P1 et P2, cible \u03c3_A", "",
       entete_md(c("Profil", "Intervalle", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC CP 95 %]", "classe (\u03c4, \u03c1 = 0,10)", "K-610-4 : IC touche un bord")))
for (cd in PRINC) for (code in CAND) {
  c_ <- CEL[[paste(cd, code, "90")]]
  S <- c(S, ligne_md(cd, LIB_IC[[code]], c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord))
}
# T2 : toutes les cellules.
S <- c(S, "", "### T2 \u2014 couverture par profil, intervalle et niveau, cible \u03c3_A (K-610-1, K-610-2, K-610-4)", "",
       "Queues s\u00e9par\u00e9es : part de \u03c3_A sous la borne basse et au-dessus de la borne haute, classe contre \u03c1/2 (bande [\u03c1/4 ; 3\u03c1/4]). Largeur : m\u00e9diane de (haute \u2212 basse)/\u03c3_A, et m\u00e9diane du rapport \u00e0 la largeur de I1 du m\u00eame triangle.", "",
       entete_md(c("Profil", "Intervalle", "Niveau", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC]", "classe (\u03c4, \u03c1)", "K-610-4",
                   "sous la borne basse [IC] ; classe (\u03c1/2)", "au-dessus de la borne haute [IC] ; classe (\u03c1/2)",
                   "largeur m\u00e9diane / \u03c3_A", "largeur / largeur de I1 (m\u00e9diane)")))
for (cd in PR_ACTIFS) for (code in IC_ACTIFS) for (niv in names(ALPHA_NIV)) {
  c_ <- CEL[[paste(cd, code, niv)]]
  S <- c(S, ligne_md(cd, LIB_IC[[code]], paste0(niv, " %"), c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord,
                     sprintf("%s ; %s", txt_cl(c_$cb), c_$cb$classe), sprintf("%s ; %s", txt_cl(c_$ch), c_$ch$classe),
                     num(c_$larg), num(c_$rapp)))
}
# T3 : I1, I4 contre #387.
S <- c(S, "", "### T3 \u2014 I1 et I4 recalcul\u00e9s sur les graines nouvelles, en regard des classes de #387 (90 %, cible \u03c3_A, K-610-2)", "",
       sprintf("Classes de #387 recalcul\u00e9es par ce script sur %s (lignes ok), avec la m\u00eame fonction classer().", BRUT_387), "",
       entete_md(c("Profil", "Intervalle", "#610 : \u03c4\u0302 [IC] ; classe", "#387 : \u03c4\u0302 [IC] ; classe")))
for (cd in PRINC) for (code in c("I1", "I4")) {
  c_ <- CEL[[paste(cd, code, "90")]]; o <- CL387[[paste(cd, code)]]
  S <- c(S, ligne_md(cd, LIB_IC[[code]], sprintf("%s ; %s", txt_cl(c_$cl), c_$cl$classe), sprintf("%s ; %s", txt_cl(o), o$classe)))
}
# T4 : cible sigma_B.
S <- c(S, "", "### T4 \u2014 couverture de \u03c3_B (cible descriptive, K-610-2)", "",
       entete_md(c("Profil", "Intervalle", "Niveau", "n", "couverture de \u03c3_B [IC 95 %]", "\u03c4\u0302 [IC]", "classe (\u03c4, \u03c1), descriptive", "\u03c3_B non d\u00e9fini")))
for (cd in PR_ACTIFS) for (code in IC_ACTIFS) for (niv in names(ALPHA_NIV)) {
  c_ <- cellule_cov(cd, code, niv, cible = "B")
  S <- c(S, ligne_md(cd, LIB_IC[[code]], paste0(niv, " %"), c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe,
                     sum(ACC$profil == cd & !is.finite(ACC$sigma_B))))
}
# T5 : tiers de sigma chapeau / sigma_A.
S <- c(S, "", "### T5 \u2014 couverture \u00e0 90 % par tiers de \u03c3\u0302/\u03c3_A (K-610-2, descriptif ; bornes des tiers : quantiles de type 7 \u00e0 1/3 et 2/3 de \u03c3\u0302/\u03c3_A sur les triangles \u00e0 I1 form\u00e9 du profil)", "",
       entete_md(c("Profil", "Intervalle", "tiers 1 : n ; couverture [IC]", "tiers 2 : n ; couverture [IC]", "tiers 3 : n ; couverture [IC]")))
for (cd in PR_ACTIFS) {
  r_ <- ACC$sigma_hat[ACC$profil == cd] / SIGMA_A
  if (length(r_) < 3L) next
  bt <- q7(r_, c(1 / 3, 2 / 3))
  tiers <- function(d) { x <- d$sigma_hat / SIGMA_A; ifelse(x <= bt[1], 1L, ifelse(x <= bt[2], 2L, 3L)) }
  S <- c(S, sprintf("%s : bornes des tiers %s et %s.", cd, num(bt[1]), num(bt[2])))
  for (code in IC_ACTIFS) {
    cel <- vapply(1:3, function(k) { c_ <- cellule_cov(cd, code, "90", sous = function(d) !is.na(d$sigma_hat) & tiers(d) == k)
      sprintf("%d ; %s", c_$n, txt_cel_cov(c_)) }, "")
    S <- c(S, ligne_md(cd, LIB_IC[[code]], cel[1], cel[2], cel[3]))
  }
}
# T6 : reproduction du par. 1.1, saturations, C2 hors etendue, niveaux calibres.
S <- c(S, "", "### T6 \u2014 reproduction du \u00a7 1.1 sur graines nouvelles, saturations, bornes de C2 hors de [min \u03c3* ; max \u03c3*], niveaux calibr\u00e9s (K-610-2)", "",
       entete_md(c("Grandeur", PR_ACTIFS)))
row6 <- function(lib, f) do.call(ligne_md, c(list(lib), as.list(vapply(PR_ACTIFS, f, ""))))
dA <- function(cd) ACC[ACC$profil == cd, , drop = FALSE]
S <- c(S, row6("\u03c3_A > max \u03c3* (triangles \u00e0 I1)", function(cd) { d <- dA(cd); txt_k(sum(SIGMA_A > d$smax), nrow(d)) }),
       row6("\u03c3_A < min \u03c3*", function(cd) { d <- dA(cd); txt_k(sum(SIGMA_A < d$smin), nrow(d)) }),
       row6("\u03c3_A > \u03c3\u0302\u00b2/min \u03c3* (plafond de I4 et de C1)", function(cd) { d <- dA(cd); txt_k(sum(SIGMA_A > d$sigma_hat^2 / d$smin), nrow(d)) }))
for (niv in names(ALPHA_NIV)) for (code in intersect(c("C1", "C0", "C1r"), IC_ACTIFS)) for (cote in c("haut", "bas"))
  S <- c(S, row6(sprintf("saturation de %s, borne %s, %s %%", sub("r$", "-r", code), if (cote == "haut") "haute" else "basse", niv),
                 function(cd) { x <- sat(cd, code, niv, cote); txt_k(x[["k"]], x[["n"]]) }))
for (niv in names(ALPHA_NIV)) for (code in intersect(c("C2", "C2r"), IC_ACTIFS))
  S <- c(S, row6(sprintf("bornes de %s hors de [min \u03c3* ; max \u03c3*], %s %% : basse < min ; haute > max", sub("r$", "-r", code), niv), function(cd) {
    d <- D[D$profil == cd & !is.na(D[[paste0(code, "_", niv, "_bas")]]), , drop = FALSE]
    sprintf("%d ; %d (n = %d)", sum(d[[paste0(code, "_", niv, "_bas")]] < d$smin), sum(d[[paste0(code, "_", niv, "_haut")]] > d$smax), nrow(d)) }))
for (j in seq_along(SUF_Q)) for (pre in c("Qw_", "Qt_", "Qu_"))
  S <- c(S, row6(sprintf("%s(%s), quantiles 5 / 50 / 95 %% entre triangles", c(Qw_ = "Q_w", Qt_ = "Q_t", Qu_ = "Q_u")[[pre]], sub(".", ",", format(PROBS_Q[j]), fixed = TRUE)),
                 function(cd) qtxt(D[[paste0(pre, SUF_Q[j])]][D$profil == cd], d = 4)))
# T7 : admission, comptes.
S <- c(S, "", "### T7 \u2014 admission, refus, triangles sans intervalle, r\u00e9plications b exclues, se*_b d\u00e9g\u00e9n\u00e9r\u00e9s", "",
       entete_md(c("Profil", "tir\u00e9s", paste("statut", STATUTS), "motifs de refus", "refus / tir\u00e9s", "sans intervalle (union I1, I4, C1, C2 \u00e0 90 %) / admis",
                   "b exclues / \u03c3* finis (dont \u00e9checs internes)", "se*_b d\u00e9g\u00e9n\u00e9r\u00e9s / b admises", "C2 non form\u00e9 (triangles \u00e0 C0, C1) : total ; dont se externe d\u00e9g\u00e9n\u00e9r\u00e9", "retirage (cumuls) ; plafond")))
for (cd in PR_ACTIFS) {
  t_ <- REFUS[[cd]]; m_ <- MOTIFS[[cd]]; d <- D[D$profil == cd & !is.na(D$nb_adm), , drop = FALSE]; a <- ADM[ADM$profil == cd, , drop = FALSE]
  S <- c(S, ligne_md(cd, R_RUN[[cd]], paste(as.integer(t_), collapse = " | "),
                     if (length(m_)) paste(sprintf("%s (%d)", names(m_), as.integer(m_)), collapse = " ; ") else "aucun",
                     num(part_refus(cd), 5), num(part_sans(cd), 5),
                     sprintf("%d / %d = %s (%d)", sum(d$nb_excl), sum(d$n_sig), num(part_b_excl(cd), 5), sum(d$nb_echec)),
                     sprintf("%d / %d = %s", sum(d$nse_deg), sum(d$nb_adm), num(part_se_deg(cd), 5)),
                     sprintf("%d ; %d", sum(D$profil == cd & D$statut == "ok" & is.na(D$C2_90_bas)), sum(D$profil == cd & D$statut == "ok" & D$se_ext_deg %in% 1)),
                     sprintf("%d ; %d", sum(a$retires %in% 1), sum(a$plafond %in% 1))))
}
msgs <- unique(D$message[!is.na(D$message) & D$statut == "echec_autre"])
if (length(msgs)) S <- c(S, "", paste0("\u00c9checs rencontr\u00e9s : ", paste(utils::head(msgs, 10), collapse = " ; ")))
# Profils.
txt_w <- function(c_) { w <- PROFIL$w[[c_]]; r <- w$taux
  sprintf("%s : %s (P1 : %s %s, %s %s ; P2 : %s %s, %s %s ; seuil %s, chaque taux s\u00e9par\u00e9ment, valeurs non arrondies)", c_, if (w$wa) "W-a" else "W-b",
          rownames(r)[1], num(r[1, "P1"], 5), rownames(r)[2], num(r[2, "P1"], 5),
          rownames(r)[1], num(r[1, "P2"], 5), rownames(r)[2], num(r[2, "P2"], 5), num(SEUIL_W, 2)) }
S <- c(S, "", "### Profils de lecture pour D3, \u00e9valu\u00e9s m\u00e9caniquement, sans d\u00e9cision", "",
       entete_md(c("\u00c9l\u00e9ment", "Valeur")),
       ligne_md("K-610-3 (contr\u00f4les d'int\u00e9grit\u00e9)", if (PROFIL$k3) "rempli" else sprintf("en d\u00e9faut (%s)", paste(INTEGRITE, collapse = ", "))),
       ligne_md("\u03980 : au-del\u00e0 de 1 % sur P1 ou P2 (refus / tir\u00e9s ; triangles sans intervalle, union I1, I4, C1, C2 \u00e0 90 %, / admis ; b exclues / \u03c3* finis)",
                if (length(PROFIL$hors)) paste(PROFIL$hors, collapse = ", ") else
                  paste(vapply(PRINC, function(cd) sprintf("%s : %s ; %s ; %s", cd, num(part_refus(cd), 5), num(part_sans(cd), 5), num(part_b_excl(cd), 5)), ""), collapse = " | ")),
       ligne_md("classe \u00e0 90 % des candidats", paste(vapply(CAND, function(c_) sprintf("%s : P1 %s ; P2 %s", c_, lib_classe(PROFIL$cl[[c_]][["P1"]]), lib_classe(PROFIL$cl[[c_]][["P2"]])), ""), collapse = " | ")),
       ligne_md("candidat en distorsion de c\u00f4t\u00e9s oppos\u00e9s (\u03984)", if (length(PROFIL$opp)) paste(PROFIL$opp, collapse = ", ") else "aucun"),
       ligne_md("candidats \u00e9ligibles (\u03981)", if (length(PROFIL$elig)) paste(PROFIL$elig, collapse = ", ") else "aucun"),
       ligne_md("**Profil \u0398 (lecture propos\u00e9e)**", if (PROFIL$profil == "\u03980" && PROFIL$suite != "\u03980")
         sprintf("**\u03980** ; hors \u03980 : %s", PROFIL$suite) else sprintf("**%s**", PROFIL$profil)),
       ligne_md("Pr\u00e9f\u00e9rence (i) : deux queues \u00e0 90 % dans [\u03c1/4 ; 3\u03c1/4] sur P1 et P2 (comparaison sur les estimations ponctuelles des queues, lecture des classes du protocole : \u00ab classes sur les valeurs non arrondies \u00bb)",
                if (length(PROFIL$elig) < 2L) "sans objet (moins de deux candidats \u00e9ligibles)" else paste(sprintf("%s : %s", PROFIL$elig, ifelse(PROFIL$qi, "oui", "non")), collapse = " ; ")),
       ligne_md("Pr\u00e9f\u00e9rence (ii)", if (length(PROFIL$elig) < 2L) "sans objet (moins de deux candidats \u00e9ligibles)" else
         sprintf("(ii) non discriminante : co\u00fbts \u00e9gaux \u00e0 B2 = 199 (m\u00eames tirages, \u00d7 %s par run_engine() au pr\u00e9-vol) ; la r\u00e8gle renvoie \u00e0 la d\u00e9cision du mainteneur en dernier ressort. Pour information seulement : \u00d7 %s pour C2 \u00e0 B2 = 50. Le script ne d\u00e9signe aucun candidat pr\u00e9f\u00e9r\u00e9.",
                 num(COUT_PREVOL[["B2_199"]], 2), num(COUT_PREVOL[["B2_50"]], 2))),
       ligne_md("Modificateur W (sous \u03981, par candidat \u00e9ligible ; r\u00e8gle 3)",
                if (length(PROFIL$elig)) paste(vapply(PROFIL$elig, txt_w, ""), collapse = " | ") else "sans objet"),
       "", "Les profils sont des lectures propos\u00e9es : D3 revient au mainteneur.", "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%s)", paste(INTEGRITE, collapse = ", ")) else "OK"), "")
duree_cumulee <- sum(D$duree_s, na.rm = TRUE)
S_EXEC <- c("### Ex\u00e9cution (varie d'une ex\u00e9cution \u00e0 l'autre)", "",
            sprintf("- Lancement (JOURNAL) : %s ; fin : %s", J0$lancement, horodatage()),
            sprintf("- Processus : %d ; triangles calcul\u00e9s par cette ex\u00e9cution : %d, %d tranche(s), %s s d'horloge ; tranches reprises : %d",
                    OPT_PROC, N_CALC, N_TR_CALC, num(T_CALC, 0), length(FICHIERS_TR) - N_TR_CALC),
            sprintf("- Dur\u00e9e cumul\u00e9e des triangles (somme des processus) : %s s ; m\u00e9diane par triangle admis : %s s (externe %s, interne %s) ; dur\u00e9e totale : %s s",
                    num(duree_cumulee, 0), num(stats::median(ADM$duree_s), 2), num(stats::median(ADM$t_ext), 2),
                    num(stats::median(ADM$t_int + ADM$t_fig, na.rm = TRUE), 2), num(secs(t_debut), 0)), "")

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
                            sprintf("- Sortie %s : md5 %s", NOM_TSV, md5_fichier(f_tsv))), mode = "ab")
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
