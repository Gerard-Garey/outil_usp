###############################################################################
#  tests/puissance_mw_t8.R  --  PUISSANCE A T = 8 DES LIGNES M1 A M4 DE
#  MERZ-WUTHRICH ET NIVEAU DES CANDIDATS DE #300 ET #301 (issue #309)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R :
#  utils::sessionInfo(), tools::md5sum(), parallel::mclapply()). Il ne
#  modifie ni R/engine.R ni tests/reference/. Sortie en markdown sur la
#  console (UTF-8, y compris sous LC_ALL=C : la categorie LC_CTYPE est
#  basculee sur une locale UTF-8 au demarrage si necessaire, #113, #242) ;
#  fichiers ecrits SEULEMENT sur option explicite (--sortie-tranche,
#  --ecrire, --sortie, --brut). Tous les libelles non ASCII du script sont
#  ecrits en echappements \u (fichier source ASCII).
#
#  Protocole : docs/specifications/fi-merz-wuthrich-puissance.md, par. 2
#  (#309) et 3 a 4 (candidats de #301 et #300), AVEC l'encadre des decisions
#  du mainteneur du 19/10/2026 (point d'arret D1-Fi) et son complement du
#  19/10/2026 (plan P3, effectifs, graines), qui l'emportent sur le corps.
#  Renvois :
#    par. 2.2 : plans P1 (DGP de #206), P2 (premiere colonne amplifiee,
#               kappa = 3,4), P3 (P2 permutee, pi = (1, 7, 5, 3, 2, 4, 6, 0)) ;
#    par. 2.3 : scenarios H0, CST10, CST20, EXP0, EXP2, DFI (generateur), CAL7,
#               CAL4, DCAL, LIG, CEL4, CEL6, CELx4 (increments du triangle
#               simule sous H0, recumules) ; cellule ciblee (2, 1) ;
#    par. 2.4 : statistiques mesurees : les 13 de MW_CATALOGUE_MC et les
#               candidats FWb, FWr (#301), MinP, MinP4, TMax (#300), plus la
#               pente relative de #307 (PenteRel, Q-D1-Fi-9, SANS decision),
#               injectes dans MW_CATALOGUE_MC de l'environnement du moteur
#               (restaure par finally) ; la boucle de tirage de
#               mw_bootstrap() n'est JAMAIS recopiee (constat de #340) ;
#    par. 2.5 : volet A (niveau des candidats, plan et graines de #206 ;
#               catalogue reduit {BP, Grubbs, FWb, FWr, MinP, MinP4, TMax} et
#               PenteRel) ; controle K0-t (p_mc de BP et de Grubbs identiques
#               aux colonnes pR:BP et pR:Grubbs du brut de #206) ;
#    par. 2.6 : volet B (puissance, loi N, B = 999, 13 statistiques et
#               candidats), effectifs R, graines, controles (a), (i2), (c),
#               K0-x, K0-t, K0-c, (i2') ;
#    par. 2.7 : sorties T0 a T7 et criteres K-301 et K-300, recopies tels
#               quels (TEXTE_CRITERES_309, controle (t)) et evalues
#               mecaniquement SANS CONCLURE ;
#    par. 3.1 et 4.1 : definitions de FWb, FWr, MinP, MinP4, TMax (regles
#               d'exclusion et de gel du point 3, option (iii) du point 4,
#               Q-D1-Fi-8) ; par. 6 : grandeurs pour Fj (T7).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS UN PLAN (modele de Mack
#  ajuste a reserve2, geometrie 8 x 8), pas un resultat general. Aucun
#  theoreme ne couvre ces tests bootstrap a T = 8.
#
#  Modes (un seul par execution) :
#      Rscript tests/puissance_mw_t8.R --volet A --loi N|E|A --b b1:b2
#          [--coeurs N] [--sortie-tranche FICHIER [--reprendre PARTIELLE]]
#      Rscript tests/puissance_mw_t8.R --volet B --plan P1|P2|P3 --cellule CODE
#          --b b1:b2 [--coeurs N] [--sortie-tranche FICHIER [--reprendre
#          PARTIELLE]]
#      Rscript tests/puissance_mw_t8.R --oracle --volet A --loi N|E|A
#          [--N0 20000] [--coeurs N] [--sortie-tranche FICHIER [--reprendre
#          PARTIELLE]]
#      Rscript tests/puissance_mw_t8.R --oracle --volet B --plan P2|P3 [...]
#      Rscript tests/puissance_mw_t8.R --lister
#      Rscript tests/puissance_mw_t8.R --controles [--coeurs N]
#      Rscript tests/puissance_mw_t8.R --essai [--n N] [--coeurs N]
#      Rscript tests/puissance_mw_t8.R --controle-i2prime --cle-moteur CLE
#          --candidat NOM [--marques N] [--coeurs N]
#      Rscript tests/puissance_mw_t8.R --combiner f1 f2 ... | DOSSIER
#          [--reduit] [--journal JOURNAL.md] [--explication-k0t FICHIER]
#          [--ecrire [--remplacer] --brut FICHIER --journal JOURNAL.md
#           | --sortie DOSSIER [--brut FICHIER]]
#  Les options --provisoire et --B n'existent que pour la mise au point : une
#  sortie provisoire (arbre non propre admis, B reduit) est marquee en T0 et
#  refusee par --combiner --ecrire.
#
#  Tranche : volet A, loi N ou E : b de 1 a 2 000 (E : 2 000 ; A : 1 000) ;
#  volet B : b de 1 a R de la cellule (CELLULES). Une tranche REFUSE (code 1,
#  avant tout calcul) un commit non propre ou un code hors du depot
#  (motifs_non_versionnable()), sauf --essai, --provisoire. Plan des tranches
#  (une tranche de 250 triangles au plus, un fichier d'oracle par jeu) :
#  --lister, au format de tests/outillage/lancer_tranches.sh (le lanceur
#  passe --sortie-tranche et --reprendre ; --coeurs se transmet apres "--").
#  --coeurs N : processus (parallel::mclapply, mc.preschedule = FALSE),
#  defaut min(4, detectCores()) ; 1 sous Windows. Le resultat d'un triangle ne
#  depend ni du nombre de processus ni de l'ordre (tout tirage passe par
#  engine_sous_graine(), graines explicites). Les triangles d'une tranche sont
#  calcules par lots de N (un par processus) ; chaque lot est ecrit AU FIL DE
#  L'EAU (flush) : une reprise (--reprendre) ne perd que le lot en cours.
#  --sortie-tranche FICHIER : sortie complete (lignes machine et markdown)
#  HORS du depot, jamais ecrasee : en-tete (PARAMETRES, TRANCHE, CONTEXTE,
#  CLES, COLS) apres les controles generaux, une ligne de donnees par
#  triangle (REP) ou d'oracle (ORA), puis le markdown, DUREE, REPRISE
#  eventuelle, MD5_VALEURS (oracle), INTEGRITE, NLIG et FIN (derniere ligne).
#  Une ligne ne depend que de (mode, cellule, b) et de ses graines.
#  Un controle general en echec arrete la tranche (code 1) AVANT la boucle,
#  sauf --essai. Une ligne au statut erreur rend la sortie NON TERMINEE : le
#  controle (erreurs) est bloquant (INTEGRITE ECHEC), la sortie est close
#  sans NLIG ni FIN (le lanceur la signale \u00ab non terminee \u00bb et la reprend :
#  --reprendre ne reprend que les lignes admises ou refusees, donc ne
#  recalcule que les lignes en erreur).
#  --reprendre PARTIELLE (avec --sortie-tranche NOUVEAU) : relit une sortie
#  sans FIN (jamais modifiee), exige un en-tete identique, reprend ses lignes
#  de donnees completes et ne calcule que les manquantes ; une derniere ligne
#  non terminee par un saut de ligne est ecartee et recalculee ; la derniere
#  ligne reprise et un echantillon regulier de lignes reprises sont
#  recalcules et doivent redonner la ligne reprise hors durees (controle
#  (reprise), INTEGRITE ECHEC sinon).
#  --essai : imprime la DUREE PAR TRIANGLE de chaque cellule (n triangles par
#  cellule, b = 1..n, defaut 1) et l'extrapole au plan complet (volets A et
#  B, oracles) ; ecrit aucun fichier. --controles : controles generaux seuls
#  (reserve2 : (a), (i2), (c) ; (t), (b), (g), (graines), (sc), (copie)).
#  --controle-i2prime : (i2'), a lancer par audit apres #301 puis apres #300
#  (voir CONTROLE (i2')) ; par defaut sur TOUS les triangles marques (i2) des
#  volets A et B (b multiple de 50), --marques n pour la mise au point.
#  --combiner : voir plus bas.
#  --combiner : lit les sorties (chemins, ou un DOSSIER dont il prend les
#  fichiers va-*.txt, vb-*.txt et ora-*.txt), recalcule les tableaux T0 a T7
#  et les evaluations de K0-c, K0-x, K0-t, K-301 et K-300. Couverture exacte
#  (une fois chacun) de 1..R de chaque cellule et de l'oracle (N0 = 20 000)
#  de chaque jeu, sauf --reduit (essais : couverture lue sur les sorties,
#  refuse par --ecrire). REFUS (code 1, sans tableau) : sortie sans INTEGRITE
#  OK ou sans FIN en derniere ligne, nombre de lignes different de NLIG ;
#  (\u00ab meme commit \u00bb est exige ENTRE LES SORTIES, non pour la combinaison, qui
#  peut etre faite a un autre commit cite au T0 ; l'empreinte sans
#  commentaires de R/engine.R (i3) doit en revanche etre la meme) ;
#  ligne au statut erreur ; PARAMETRES, commit, plateforme, empreintes,
#  generateur, DGP ou correspondance statistique <-> sens differents ;
#  invariants (d) faux ; md5 des valeurs de l'oracle different de
#  MD5_VALEURS ; avec --journal : ligne "- Sortie <nom> : md5 <md5>" absente,
#  multiple ou de md5 different. Lignes attendues au JOURNAL (une chacune) :
#  "- Debit : <texte>", "- Empreinte sans commentaires : <md5>", et une par
#  sortie : "- Sortie <nom> : md5 <md5>[, suite libre]" (format de
#  tests/outillage/synchroniser_sauvegarde.sh).
#  K0-t non tenu (au moins une difference avec le brut de #206) : listee au
#  T0 ; --ecrire est alors refuse sauf --explication-k0t FICHIER (texte de
#  l'explication, copie au T0).
#  --ecrire (avec --combiner, --brut et --journal obligatoires) : ecrit dans
#  docs/tableaux/ (date du jour), nouveaux et jamais patches :
#    <AAAAMMJJ>-issue309-puissance-mw.md et -puissance-mw-brut.tsv,
#    <AAAAMMJJ>-issue309-journal-mesure.md (copie du JOURNAL de la mesure),
#    <AAAAMMJJ>-issue309-journal-combinaison.md (journal de la combinaison)
#  (pieces versionnees fixees par le second complement du 19/10/2026).
#  Copie des valeurs brutes hors du depot (--brut) ecrite AVANT les fichiers
#  versionnes. --ecrire REFUSE : commit de la combinaison ou des sorties non
#  propre, code hors du depot, sortie provisoire, --reduit, garde_ecrasement()
#  (#173) sans --remplacer, chemin absolu ou /tmp dans un fichier a ecrire
#  (D-a de #242). Gardes anticipees (#205). --sortie DOSSIER : memes fichiers
#  HORS du depot (jamais ecrases), ecrits par lot (#248).
#
#  Fonctions reprises par COPIE DECLAREE de tests/calibration_mc_mw_t8.R (ce
#  script execute son calcul au chargement, il ne peut etre source) : outils
#  de sortie, de lecture d'un taux et de McNemar (taille_lissee(), lecture(),
#  cellule(), mcnemar(), ic_cp(), ...), DGP de #206 (gen_triangle_h0(),
#  admettre(), tireur()), ecriture par lot, reprise. La copie est CONTROLEE
#  mecaniquement : controle (copie), les formals et le corps de chaque
#  fonction copiee sont compares (identical()) a ceux du fichier relu par
#  parse(), jamais execute. commit_depot(), motifs_non_versionnable(),
#  garde_ecrasement(), ligne_remplacement(), inserer_t0(),
#  empreinte_sans_commentaires(), executer_cas(), comparer_objets() :
#  tests/outils_tests.R.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon ; en mode
#  --combiner, 0 si la combinaison est acceptee, 1 si elle est refusee.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/puissance_mw_t8.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113, critere de #242) -------------
LOCALE_ORIGINE <- Sys.getlocale("LC_CTYPE")
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break
LOCALE_TRAVAIL <- Sys.getlocale("LC_CTYPE")

# --- Plan de la mesure (constantes sans lien avec le moteur) -----------------
# Cellules du volet B (par. 2.6 et complement du 19/10/2026). rang : rang c de
# la cellule dans les graines (P1 puis P2 : 1 a 19 ; P3 : c3 = 1, 2, 3).
CELLULES <- data.frame(
  plan = c(rep("P1", 13), rep("P2", 6), rep("P3", 3)),
  code = c("H0", "CST20", "EXP2", "CEL4", "CEL6", "CST10", "EXP0", "DFI", "CAL7", "CAL4", "DCAL", "LIG", "CELx4",
           "H0", "CST20", "EXP2", "CST10", "EXP0", "DFI",
           "H0", "CST20", "DFI"),
  R = c(1000, 1000, 1000, 1000, 1000, 500, 500, 500, 500, 500, 500, 500, 500,
        1000, 1000, 1000, 500, 500, 500,
        1000, 1000, 500),
  rang = c(1:13, 14:19, 1:3), stringsAsFactors = FALSE)
CELLULES$id <- paste(CELLULES$plan, CELLULES$code, sep = ".")
LOIS <- c("N", "E", "A")
R_A <- c(N = 2000, E = 2000, A = 1000)       # volet A (plan de #206, niveau L0)
N0_SPEC <- 20000L
TAILLE_TRANCHE <- 250L
PLANS <- c("P1", "P2", "P3")

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--volet", "--loi", "--plan", "--cellule", "--b", "--N0", "--sortie-tranche", "--reprendre", "--journal",
                    "--sortie", "--brut", "--coeurs", "--n", "--B", "--cle-moteur", "--candidat", "--marques",
                    "--explication-k0t")
OPTIONS_DRAPEAU <- c("--oracle", "--essai", "--provisoire", "--controles", "--controle-i2prime", "--lister", "--ecrire",
                     "--remplacer", "--reduit")
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
OPT_VOLET     <- lire_option("--volet", NA_character_)
OPT_LOI       <- lire_option("--loi", NA_character_)
OPT_PLAN      <- lire_option("--plan", NA_character_)
OPT_CELLULE   <- lire_option("--cellule", NA_character_)
OPT_B         <- lire_option("--b", NA_character_)
OPT_N0        <- lire_option("--N0", NA_character_)
OPT_SORTIE_TR <- lire_option("--sortie-tranche", NA_character_)
OPT_REPRENDRE <- lire_option("--reprendre", NA_character_)
OPT_JOURNAL   <- lire_option("--journal", NA_character_)
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
OPT_BRUT      <- lire_option("--brut", NA_character_)
OPT_COEURS    <- lire_option("--coeurs", NA_character_)
OPT_N_ESSAI   <- lire_option("--n", "1")
OPT_B_REDUIT  <- lire_option("--B", NA_character_)
OPT_CLE_MOTEUR <- lire_option("--cle-moteur", NA_character_)
OPT_CANDIDAT  <- lire_option("--candidat", NA_character_)
OPT_MARQUES   <- lire_option("--marques", NA_character_)
OPT_EXPL_K0T  <- lire_option("--explication-k0t", NA_character_)
OPT_ORACLE    <- "--oracle" %in% ARGS
OPT_ESSAI     <- "--essai" %in% ARGS
OPT_PROVISOIRE <- "--provisoire" %in% ARGS
OPT_CONTROLES <- "--controles" %in% ARGS
OPT_I2PRIME   <- "--controle-i2prime" %in% ARGS
OPT_LISTER    <- "--lister" %in% ARGS
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_REDUIT    <- "--reduit" %in% ARGS

# --remplacer sans --ecrire : refus d'usage, avant tout (libelle commun aux
# scripts de mesure qui ont --ecrire, #173 ; tests/unitaires/test_garde_ecrasement.R).
if (OPT_REMPLACER && !OPT_ECRIRE) stop("--remplacer : reserve a --ecrire (remplacement d'un tableau suivi par git, #173)")
MODE <- if (MODE_COMBINER) "combiner" else if (OPT_LISTER) "lister" else if (OPT_CONTROLES) "controles" else
  if (OPT_ESSAI) "essai" else if (OPT_I2PRIME) "i2prime" else if (OPT_ORACLE) "oracle" else
  if (!is.na(OPT_VOLET)) "tranche" else NA_character_
if (is.na(MODE)) stop("aucun mode : --volet (tranche), --oracle, --lister, --controles, --essai, --controle-i2prime ou --combiner")
n_modes <- sum(MODE_COMBINER, OPT_LISTER, OPT_CONTROLES, OPT_ESSAI, OPT_I2PRIME, OPT_ORACLE)
if (n_modes > 1L) stop("un mode et un seul : --oracle, --lister, --controles, --essai, --controle-i2prime, --combiner")
if (MODE == "tranche" && n_modes > 0L) stop("une tranche (--volet) n'accepte aucun autre mode")
reserve <- function(opts, modes) for (o in opts) if (o %in% ARGS && !MODE %in% modes)
  stop(o, " : reserve au(x) mode(s) ", paste(modes, collapse = ", "))
reserve(c("--volet"), c("tranche", "oracle"))
reserve(c("--loi"), c("tranche", "oracle"))
reserve(c("--plan", "--cellule"), c("tranche", "oracle"))
reserve(c("--b"), c("tranche"))
reserve(c("--N0"), c("oracle"))
reserve(c("--sortie-tranche", "--reprendre"), c("tranche", "oracle"))
reserve(c("--journal", "--sortie", "--brut", "--reduit", "--explication-k0t"), c("combiner"))
reserve(c("--ecrire", "--remplacer"), c("combiner"))
reserve(c("--coeurs"), c("tranche", "oracle", "controles", "essai", "i2prime"))
reserve(c("--n"), c("essai"))
reserve(c("--cle-moteur", "--candidat", "--marques"), c("i2prime"))
reserve(c("--provisoire"), c("tranche", "oracle"))
reserve(c("--B"), c("tranche", "oracle", "essai"))
if (MODE == "combiner" && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
if (OPT_ECRIRE && OPT_REDUIT) stop("--ecrire : refuse avec --reduit (parametres reduits, non versionnables)")
if (OPT_ECRIRE && is.na(OPT_BRUT)) stop("--ecrire : --brut FICHIER obligatoire (copie des valeurs brutes hors du depot)")
if (OPT_ECRIRE && is.na(OPT_JOURNAL)) stop("--ecrire : --journal FICHIER obligatoire (debit et empreinte #231 du JOURNAL)")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
if (MODE %in% c("tranche", "oracle")) {
  if (is.na(OPT_VOLET) || !OPT_VOLET %in% c("A", "B")) stop("--volet A ou B obligatoire")
  if (OPT_VOLET == "A") {
    if (is.na(OPT_LOI) || !OPT_LOI %in% LOIS) stop("--volet A : --loi N, E ou A obligatoire")
    if (!is.na(OPT_PLAN) || !is.na(OPT_CELLULE)) stop("--volet A : ni --plan ni --cellule")
  } else {
    if (!is.na(OPT_LOI)) stop("--volet B : loi N imposee, pas de --loi")
    if (MODE == "tranche") {
      if (is.na(OPT_PLAN) || is.na(OPT_CELLULE) || !paste(OPT_PLAN, OPT_CELLULE, sep = ".") %in% CELLULES$id)
        stop("--volet B : --plan et --cellule d'une cellule du plan (", paste(CELLULES$id, collapse = ", "), ")")
    } else {
      if (is.na(OPT_PLAN) || !OPT_PLAN %in% c("P2", "P3")) stop("--oracle --volet B : --plan P2 ou P3 (l'oracle de P1 est celui du volet A, loi N)")
      if (!is.na(OPT_CELLULE)) stop("--oracle : pas de --cellule")
    }
  }
}
if (MODE == "tranche" && is.na(OPT_B)) stop("--b b1:b2 obligatoire")
if (MODE == "oracle" && !is.na(OPT_B)) stop("--oracle : pas de --b (N0 triangles)")
R_CELLULE <- if (MODE == "tranche") {
  if (OPT_VOLET == "A") R_A[[OPT_LOI]] else CELLULES$R[CELLULES$id == paste(OPT_PLAN, OPT_CELLULE, sep = ".")]
} else NA_real_
B1 <- B2 <- NA_integer_
if (!is.na(OPT_B)) {
  m <- regmatches(OPT_B, regexec("^([0-9]+):([0-9]+)$", OPT_B))[[1]]
  if (length(m) != 3L) stop("--b : forme b1:b2 attendue")
  B1 <- as.integer(m[2]); B2 <- as.integer(m[3])
  if (B1 < 1L || B2 < B1 || B2 > R_CELLULE) stop("--b : 1 <= b1 <= b2 <= ", R_CELLULE, " (R de la cellule)")
}
N_COEURS <- if (is.na(OPT_COEURS)) NA_integer_ else suppressWarnings(as.integer(OPT_COEURS))
if (!is.na(OPT_COEURS) && (is.na(N_COEURS) || N_COEURS < 1L)) stop("--coeurs : entier >= 1")
N0 <- if (is.na(OPT_N0)) N0_SPEC else suppressWarnings(as.integer(OPT_N0))
if (is.na(N0) || N0 < 1L || N0 > N0_SPEC) stop("--N0 : entier de 1 a 20 000")
if (!is.na(OPT_N0) && !OPT_PROVISOIRE && N0 != N0_SPEC) stop("--N0 inferieur a 20 000 : reserve a --provisoire")
B_BOOT <- 999       # double, comme le B par defaut de run_engine() (voir calibration_mc_mw_t8.R)
if (!is.na(OPT_B_REDUIT)) {
  B_BOOT <- suppressWarnings(as.numeric(OPT_B_REDUIT))
  if (is.na(B_BOOT) || B_BOOT < 19 || B_BOOT != round(B_BOOT) || B_BOOT >= 999) stop("--B : entier de 19 a 998 (mise au point)")
  if (!(OPT_PROVISOIRE || OPT_ESSAI)) stop("--B : reserve a --provisoire ou --essai")
}
N_ESSAI <- suppressWarnings(as.integer(OPT_N_ESSAI))
if (is.na(N_ESSAI) || N_ESSAI < 1L) stop("--n : entier >= 1")
if (MODE == "i2prime" && (is.na(OPT_CLE_MOTEUR) || is.na(OPT_CANDIDAT))) stop("--controle-i2prime : --cle-moteur et --candidat obligatoires")
N_MARQUES <- if (is.na(OPT_MARQUES)) NA_integer_ else suppressWarnings(as.integer(OPT_MARQUES))
if (!is.na(OPT_MARQUES) && (is.na(N_MARQUES) || N_MARQUES < 0L)) stop("--marques : entier >= 0")
if (!is.na(OPT_REPRENDRE)) {
  if (is.na(OPT_SORTIE_TR)) stop("--reprendre : --sortie-tranche FICHIER obligatoire (nouveau fichier)")
  if (!file.exists(OPT_REPRENDRE)) stop("--reprendre : fichier introuvable : ", OPT_REPRENDRE)
  if (file.exists(OPT_SORTIE_TR) && normalizePath(OPT_REPRENDRE) == normalizePath(OPT_SORTIE_TR))
    stop("--reprendre : --sortie-tranche doit designer un autre fichier que la sortie partielle")
}
PROVISOIRE <- OPT_PROVISOIRE || OPT_ESSAI || !is.na(OPT_B_REDUIT) || !identical(N0, N0_SPEC)

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else
  if (file.exists("tests/outils_tests.R")) "tests" else "."
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils (copies declarees de tests/calibration_mc_mw_t8.R, controle (copie)) ---
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
D_IC <- 5L
txt_ic <- function(ci, d = D_IC) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
chemin_cite <- function(f) {
  if (is.na(f) || !file.exists(f)) return(basename(as.character(f)))
  a <- normalizePath(f, winslash = "/", mustWork = TRUE)
  r <- normalizePath(RACINE, winslash = "/", mustWork = TRUE)
  if (startsWith(a, paste0(r, "/"))) substring(a, nchar(r) + 2L) else basename(a)
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
chemins_absolus <- function(lignes) {
  k <- grepl("/tmp", lignes, fixed = TRUE) |
    grepl("(^|[ (|`'\"=])(/(home|root|usr|var|mnt|opt|Users|private|srv|media)/|[A-Za-z]:[\\\\/])", lignes, perl = TRUE)
  lignes[k]
}

SPEC <- file.path("docs", "specifications", "fi-merz-wuthrich-puissance.md")
SPEC_206 <- "tests/calibration_mc_mw_t8.R"
BRUT_206_REL <- file.path("docs", "tableaux", "20261011-issue206-calibration-mw-brut.tsv")

###############################################################################
#  GARDES ANTICIPEES (#205, #173) : evaluees AVANT tout calcul (le premier
#  calcul est l'ajustement de reserve2 du DGP, plus bas), et reprises avant
#  d'ecrire. --ecrire : commit et code de la combinaison, dossier
#  docs/tableaux/, garde d'ecrasement des quatre cibles ; --brut, --sortie ;
#  sortie de calcul : commit propre et code du depot (sauf --essai,
#  --provisoire), --sortie-tranche hors du depot et jamais ecrasee.
###############################################################################
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
NOMS_SORTIE <- c(md = sprintf("%s-issue309-puissance-mw.md", DATE_SORTIE),
                 brut = sprintf("%s-issue309-puissance-mw-brut.tsv", DATE_SORTIE),
                 journal = sprintf("%s-issue309-journal-mesure.md", DATE_SORTIE),
                 jcomb = sprintf("%s-issue309-journal-combinaison.md", DATE_SORTIE))
CIBLES <- file.path(RACINE, "docs", "tableaux", NOMS_SORTIE); names(CIBLES) <- names(NOMS_SORTIE)
if (MODE == "combiner" && OPT_ECRIRE) {
  nv0 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPEC), "de la combinaison")
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
if (MODE %in% c("tranche", "oracle")) {
  if (!PROVISOIRE) {
    nvt <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPEC), "de la sortie")
    if (length(nvt)) {
      message("sortie refusee : ", paste(nvt, collapse = " ; "), " -- lancer dans un git worktree au commit propre cite, ou --provisoire")
      quit(status = 1L)
    }
  }
  if (!is.na(OPT_SORTIE_TR)) {
    if (!dir.exists(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : dossier introuvable")
    if (sous_depot(dirname(OPT_SORTIE_TR))) stop("--sortie-tranche : chemin sous le depot refuse")
    if (file.exists(OPT_SORTIE_TR)) stop("--sortie-tranche : fichier existant, jamais ecrase")
  }
}

# Environnement ou le moteur est charge (injection du catalogue) ; affecte
# apres les gardes anticipees (#205).
ENV_MOTEUR <- environment(mw_bootstrap)

###############################################################################
#  PROTOCOLE (constantes de la specification)
###############################################################################
METHODE <- "reserve2"; SEGMENT <- 1; ANNEXE <- "II"
ALPHA <- 0.10; SEUILS <- c(0.10, 0.05); IA <- c("a10", "a05")
IDX_LOI <- c(N = 1L, E = 2L, A = 3L)
# Graines du volet A : celles de #206 (par. 2.5), toutes sous engine_sous_graine().
GRAINE_TRI <- 20840000; GRAINE_BOOT <- 20870000; GRAINE_ORA <- 20900000
PAS_LOI <- 10000; PAS_LOI_ORA <- 20000
GRAINE_R2 <- 20260831            # cas reserve2 de tests/outils_tests.R (controles (a), (i2), (c))
graine_tri  <- function(loi, b) GRAINE_TRI + PAS_LOI * (IDX_LOI[[loi]] - 1L) + b
graine_boot <- function(loi, b) GRAINE_BOOT + PAS_LOI * (IDX_LOI[[loi]] - 1L) + b
graine_ora  <- function(loi, k) GRAINE_ORA + PAS_LOI_ORA * (IDX_LOI[[loi]] - 1L) + k
# Graines du volet B (par. 2.6) : P1 et P2, cellule de rang c (1 a 19) ; P3
# (complement du 19/10/2026), cellule de rang c3 (1 a 3) ; oracles P2 et P3.
GRAINES_B <- list(P1 = c(tri = 32000000, boot = 32500000), P2 = c(tri = 32000000, boot = 32500000),
                  P3 = c(tri = 34000000, boot = 34200000))
PAS_CELLULE <- 20000
GRAINE_ORA_B <- c(P2 = 33000000, P3 = 34400000)
graine_tri_B  <- function(plan, rang, b) GRAINES_B[[plan]][["tri"]] + PAS_CELLULE * (rang - 1L) + b
graine_boot_B <- function(plan, rang, b) GRAINES_B[[plan]][["boot"]] + PAS_CELLULE * (rang - 1L) + b
graine_ora_B  <- function(plan, k) GRAINE_ORA_B[[plan]] + k
SEUIL_REFUS <- 0.01; NIVEAU_HOLM <- 0.05; SEUIL_K4 <- 0.01
# Parametres des scenarios (par. 2.3 et Q-D1-Fi-2).
THETA <- 0.10                    # chocs calendaires CAL7 et CAL4
GAMMA <- 0.20                    # derive de f_j en i (DFI)
DELTA <- c(CST10 = 0.10, CST20 = 0.20)
KAPPA <- c(EXP0 = 0, EXP2 = 2)
LAMBDA <- c(CEL4 = 4, CEL6 = 6)
CIBLE_CEL <- c(i = 2L, j = 1L)   # cellule ciblee, en coordonnees de residus de Mack (par. 2.3)
KAPPA_P2 <- 3.4                  # amplification de la premiere colonne (P2)
PERM_P3 <- c(2, 8, 6, 4, 3, 5, 7, 1)   # C3 <- C2[PERM_P3] : pi = (1, 7, 5, 3, 2, 4, 6, 0) en indices 0..7
BORNES_K0C <- c(0.22, 0.28)      # K0-c : moyenne des CV de j = 0 a 3
# Comptes publies de la forme "bas" (T2 de docs/tableaux/20261016-issue276-calendaire.md,
# theta = 0,10, seuil 0,10, R = 1 000) : 401 / 1 000 (CAL7, dernier exercice t = 7)
# et 319 / 1 000 (CAL4, exercice median t = 4) ; K0-x : test exact de Fisher
# bilateral contre le taux mesure, tenu si p >= SEUIL_K0X (second complement du
# 19/10/2026).
PUBLIE_K0X <- c(CAL7 = 401L, CAL4 = 319L); N_PUBLIE_K0X <- 1000L
SEUIL_K0X <- 0.025               # 0,05 / 2 (Bonferroni sur deux cellules)
# Sens de rejet des treize cles au moteur de ce commit (Calendrier : "bas" depuis #276).
SENS_SPEC <- c(PenteIntra = "deux", Origine = "haut", HomogF = "haut", Courbure = "haut", Alpha = "haut",
               BP = "haut", ExpVar = "haut", Calendrier = "bas", KruskalAcc = "haut", CorrDev = "deux",
               DW = "deux", Runs = "deux", Grubbs = "haut")
CLES <- names(MW_CATALOGUE_MC)
NS <- length(CLES)
QUEUE <- vapply(CLES, function(s) MW_CATALOGUE_MC[[s]]$queue, "")
CAND <- c("FWb", "FWr", "MinP", "MinP4", "TMax", "PenteRel")
QUEUE_CAND <- c(FWb = "haut", FWr = "haut", MinP = "bas", MinP4 = "bas", TMax = "haut", PenteRel = "deux")
STATS_B <- c(CLES, CAND)                       # volet B et oracles : 19 statistiques
STATS_A <- c("BP", "Grubbs", CAND)              # volet A : catalogue reduit (+ PenteRel, Q-D1-Fi-9)
QUEUE_ALL <- c(QUEUE, QUEUE_CAND)
TEM_A <- c("BP", "Grubbs")                      # temoins du volet A (K0-t)
NS_B <- length(STATS_B)
CODES_MOTIF <- c(o = MOTIF_MC_OBS_NON_FINIE, z = MOTIF_MC_AUCUNE_REPLIC, i = MOTIF_MC_REPLIC_INSUFFISANTES,
                 d = MOTIF_MC_DISPERSION_NULLE, c = MOTIF_MC_CONDITION, a = MOTIF_MC_ATOME_HORS_OBS)
LIB_MOTIF <- c(o = "obs. non finie", z = "B eff. = 0", i = "B eff. < B_MIN_DEGENERESCENCE", d = "dispersion nulle",
               c = "condition du catalogue", a = "atome hors obs.", "?" = "motif inconnu")
code_motif <- function(m) ifelse(is.na(m), "-", ifelse(m %in% CODES_MOTIF, names(CODES_MOTIF)[match(m, CODES_MOTIF)], "?"))

# --- Texte des criteres (par. 2.7), reporte SANS MODIFICATION (controle (t)) --
TEXTE_CRITERES_309 <- c(
  "- **K-301 (choix de la variante de BP)** :",
  "  1. FWr est retenue si, sous N et E, aux deux seuils, sa classe est compatible, \u00e9cart mineur ou distorsion conservatrice, sans distorsion mat\u00e9rielle lib\u00e9rale sous A ;",
  "  2. \u00e0 d\u00e9faut, FWb aux m\u00eames conditions ;",
  "  3. \u00e0 d\u00e9faut, arr\u00eat D2-Fi.",
  "- **K-300 (choix de la statistique de M4)**. Un candidat est \u00e9ligible si :",
  "  - (i) son niveau Monte-Carlo n'a aucune distorsion mat\u00e9rielle lib\u00e9rale sous N, E et A ;",
  "  - (ii) sous P1, son taux de rejet est au moins celui de Grubbs \u00e0 0,10, \u00e0 CEL6 et CELx4, et strictement plus grand \u00e0 0,05 (McNemar exact \u00e0 0,05).",
  "",
  "  Entre MinP et MinP4 \u00e9ligibles, on retient celui que le McNemar favorise \u00e0 CEL4 et CEL6 ; \u00e0 \u00e9galit\u00e9, MinP, qui couvre plus de cellules. TMax n'est retenu que s'il domine les deux. Aucun candidat \u00e9ligible : arr\u00eat D2-Fi, et Grubbs reste en l'\u00e9tat.",
  "- Les autres grandeurs sont descriptives, sans seuil.")

# Precisions d'implementation de l'evaluation MECANIQUE de K-301 et K-300 :
# elles ne modifient pas le texte ci-dessus (recopie), n'en tirent aucune
# conclusion (le choix revient au point D2-Fi) et sont soumises a actuary.
TEXTE_PRECISIONS_309 <- c(
  "**Lecture m\u00e9canique de K-301** (lettre du texte, second compl\u00e9ment du 19/10/2026) : pour une variante V, \u00ab condition remplie \u00bb si, pour \u2113 \u2208 {N, E} et aux deux seuils, la classe de #166 de V (volet A, p Monte-Carlo) est *compatible*, *\u00e9cart mineur* ou *distorsion mat\u00e9rielle conservatrice* (un *\u00e9cart non tranch\u00e9* ne l'est pas ; son c\u00f4t\u00e9, conservateur si le taux est sous \u03c1/2 et lib\u00e9ral s'il est au-dessus de 3\u03c1/2, est affich\u00e9 pour D2-Fi), et si, sous A, aucune des deux classes n'est une *distorsion mat\u00e9rielle lib\u00e9rale*. FWr, puis FWb \u00e0 d\u00e9faut ; sinon \u00ab arr\u00eat D2-Fi \u00bb.",
  "**Lecture m\u00e9canique de K-300** (second compl\u00e9ment du 19/10/2026) : (i) aucune distorsion mat\u00e9rielle *lib\u00e9rale* du candidat sous N, E et A, aux deux seuils (volet A). (ii) sous P1, aux cellules CEL6 et CELx4 (volet B) : \u00e0 0,10, taux du candidat \u2265 celui de Grubbs (non-inf\u00e9riorit\u00e9 ponctuelle) ; \u00e0 0,05, taux strictement plus grand que celui de Grubbs et McNemar exact bilat\u00e9ral < 0,05 en sa faveur (sup\u00e9riorit\u00e9 \u00e9tablie ; asym\u00e9trie voulue). \u00ab Le McNemar favorise X contre Y \u00bb : \u00e0 CEL4 **et** \u00e0 CEL6, au moins un des deux seuils (0,10 ; 0,05) donne un McNemar exact bilat\u00e9ral < 0,05 en faveur de X (n01 > n10), et aucun des quatre couples (CEL4, CEL6) \u00d7 (0,10 ; 0,05) ne le donne en faveur de Y. MinP4 n'est retenu contre MinP que s'il est favoris\u00e9, sinon MinP. TMax domine s'il est \u00e9ligible et favoris\u00e9 contre MinP **et** contre MinP4 ; un TMax \u00e9ligible qui ne domine pas, seul \u00e9ligible, rel\u00e8ve de D2-Fi.",
  "**K0-x** (second compl\u00e9ment du 19/10/2026) : test exact de Fisher bilat\u00e9ral entre le taux mesur\u00e9 de la colonne Calendrier (R = 500, 0,10) et le taux publi\u00e9 du T2 de #276 (401 / 1 000 et 319 / 1 000), tenu si p \u2265 0,025 par cellule (Bonferroni sur deux cellules).")

# Echelle des classes de #166 (copie declaree de calibration_mc_mw_t8.R).
CLASSES <- c("compatible", "\u00e9cart mineur", "\u00e9cart non tranch\u00e9", "distorsion mat\u00e9rielle")

###############################################################################
#  DGP (par. 2.2) : plans P1, P2, P3, generateurs, scenarios (par. 2.3)
###############################################################################
AJ0 <- mw_ajuster(.tri)
JD0 <- .mw_colonnes_degenerees(AJ0)
POOL0 <- .mw_pool_residus(AJ0, JD0)
SD_POP0 <- sqrt(mean((POOL0 - mean(POOL0))^2))
POOL_E <- POOL0 / SD_POP0
# Tireur des epsilon de la loi (moyenne 0, variance 1) -- copie declaree.
tireur <- function(loi) switch(loi,
  N = function(n) stats::rnorm(n),
  E = function(n) sample(POOL_E, n, replace = TRUE),
  A = function(n) (stats::qgamma(stats::runif(n), 2) - 2) / sqrt(2))
# Generateur du DGP de #206 -- copie declaree (memes operations, meme ordre
# de consommation des epsilon, meme arret au premier cumul invalide).
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
# Admission d'un triangle simule -- copie declaree.
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

# Plans de dispersion. f et sigma2 sont ceux de reserve2 (non reestimes) ;
# seule la premiere colonne fixee change (par. 2.2).
C0_P1 <- AJ0$tri[, 1]
C0_P2 <- mean(C0_P1) + KAPPA_P2 * (C0_P1 - mean(C0_P1))
C0_P3 <- C0_P2[PERM_P3]
COL0 <- list(P1 = C0_P1, P2 = C0_P2, P3 = C0_P3)
aj_plan <- function(plan) { a <- AJ0; a$tri[, 1] <- COL0[[plan]]; a }
AJ_PLAN <- lapply(stats::setNames(nm = PLANS), aj_plan)

# Generateur des scenarios de moyenne, de variance et de derive (CST, EXP,
# DFI) : meme recursion et meme ordre de consommation des epsilon que
# gen_triangle_h0() (un tirage de longueur n_j par colonne), moyenne
#   E[C(i,j+1) | C] = a_j + (f_j (1 - delta) + gamma (sigma_j / sqrt(Cb_j)) (i - ib_j)) C,
#   a_j = delta f_j Cb_j, ib_j = (I - j - 1) / 2,
# variance sigma_j^2 C^kappa Cb_j^(1 - kappa) ; Cb_j : moyenne des C(0..I-j-1, j)
# SIMULES de la colonne (par. 2.3). Les parametres par defaut (0, 1, 0)
# redonnent H0 (controle (sc)).
gen_triangle_scen <- function(aj, tirer, delta = 0, kappa = 1, gamma = 0) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- tirer(length(idx))
    Cij <- tri[idx + 1, j + 1]
    Cb <- mean(Cij)
    mu <- delta * aj$f[j + 1] * Cb + (aj$f[j + 1] * (1 - delta) + gamma * (sg / sqrt(Cb)) * (idx - (I - j - 1) / 2)) * Cij
    nv <- mu + e * sg * sqrt(Cij^kappa * Cb^(1 - kappa))
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
# Scenarios sur les INCREMENTS du triangle simule sous H0, puis recumul le
# long de chaque ligne (par. 2.3 ; forme de tests/mesure_calendaire_t8.R,
# premiere colonne comprise pour les chocs calendaires). X(i, k) = C(i, k) -
# C(i, k - 1), X(i, 0) = C(i, 0). Triangle incomplet (cumul simule invalide,
# #257) rendu tel quel : admettre() le refuse.
#   CAL7, CAL4 : X(i, k) x (1 + THETA) si i + k = 7, 4 ;
#   DCAL       : X(i, k) x 1,05^max(0, i + k - 3) ;
#   LIG        : X(2, k) x 1,5 pour k >= 2 ;
#   CEL4, CEL6 : X(2, 2) + lambda sigma_1 sqrt(C(2, 1)) (sigma_1 de reserve2,
#                C(2, 1) simule) : F(2, 1) deplace de lambda ecarts-types de bruit ;
#   CELx4      : X(2, 2) x 4.
facteurs_increments <- function(scen, i, k) {
  t <- i + k
  switch(scen,
    CAL7 = if (t == 7) 1 + THETA else 1,
    CAL4 = if (t == 4) 1 + THETA else 1,
    DCAL = 1.05^max(0, t - 3),
    LIG = if (i == 2 && k >= 2) 1.5 else 1,
    CELx4 = if (i == 2 && k == 2) 4 else 1,
    CEL4 = 1, CEL6 = 1,
    stop("scenario inconnu : ", scen))
}
appliquer_increments <- function(tri, scen, aj_dgp = AJ0) {
  if (.mw_triangle_incomplet(tri)) return(tri)
  out <- tri
  for (i in 0:(nrow(tri) - 1)) {
    k <- 0:(ncol(tri) - 1 - i)
    C <- tri[i + 1, k + 1]
    X <- c(C[1], diff(C))
    fac <- vapply(k, function(kk) facteurs_increments(scen, i, kk), 1)
    X <- X * fac
    if (scen %in% names(LAMBDA) && i == CIBLE_CEL[["i"]] && length(k) > CIBLE_CEL[["j"]] + 1L) {
      kk <- CIBLE_CEL[["j"]] + 1L                       # increment X(2, 2) : colonne 2
      X[kk + 1L] <- X[kk + 1L] + LAMBDA[[scen]] * sqrt(aj_dgp$sigma2[CIBLE_CEL[["j"]] + 1L]) * sqrt(C[CIBLE_CEL[["j"]] + 1L])
    }
    out[i + 1, k + 1] <- cumsum(X)
  }
  out
}
# Triangle d'une cellule du volet B pour la graine g : generateur (DGP du
# plan, scenario de generateur) ou H0 puis scenario d'increments.
triangle_cellule <- function(plan, code, g) {
  aj <- AJ_PLAN[[plan]]
  engine_sous_graine(g, {
    if (code == "H0") gen_triangle_h0(aj, tireur("N"))
    else if (code %in% names(DELTA)) gen_triangle_scen(aj, tireur("N"), delta = DELTA[[code]])
    else if (code %in% names(KAPPA)) gen_triangle_scen(aj, tireur("N"), kappa = KAPPA[[code]])
    else if (code == "DFI") gen_triangle_scen(aj, tireur("N"), gamma = GAMMA)
    else appliquer_increments(gen_triangle_h0(aj, tireur("N")), code, AJ0)
  })
}
moments <- function(x) {
  m <- mean(x); s <- sqrt(mean((x - m)^2))
  c(n = length(x), moyenne = m, ecart_type = s, asymetrie = mean((x - m)^3) / s^3,
    exces_kurtosis = mean((x - m)^4) / s^4 - 3, min = min(x), max = max(x))
}

###############################################################################
#  CANDIDATS (par. 2.4, 3.1 et 4.1) : entrees injectees dans MW_CATALOGUE_MC
###############################################################################
# Chaque candidat est une entree .mc_entree() du moteur, calculee sur le
# contexte e de .mw_contexte_mc() (aj, res, r, figes). Toute erreur de
# calcul est rendue NA : une erreur ferait ecarter par mw_bootstrap() les
# treize statistiques de la replication (try() autour de .mw_stats()).

# --- FWb et FWr (#301, par. 3.1) -------------------------------------------
# LM = n [1 - SCR(y ~ facteur(j) + C) / SCR(y ~ facteur(j))] par partialisation
# (Frisch-Waugh) : n (Sxy)^2 / (Sxx Syy) sur variables centrees par colonne.
#   FWb : y = r^2, toutes les cellules de e$res (27 sur reserve2) ;
#   FWr : y = r^2 / (1 - h), 1 - h = S_sans / S (.mw_sommes_autres(), #46),
#         colonnes de n_j >= 3 seulement (n = 25 sur reserve2).
# NA si SCR(y ~ facteur(j)) = 0 ou si C est constant dans chaque colonne
# retenue.
# ATTENTION pour #301 : l'implementation de FWr / FWb dans le moteur devra
# reproduire EXACTEMENT cette algebre (centrage par colonne y - ave(y, g) et
# x - ave(x, g), sommes par sum(), n sxy^2 / (sxx syy), meme ordre des
# operations), pour que le controle (i2') soit identical() ; un centrage
# pondere equivalent (.mw_centrage_pondere() avec w = 1) changerait des bits.
# Aucun assistant de centrage non pondere du moteur n'est utilise ici.
stat_fw <- function(aj, res, redresse, n_min) {
  if (!nrow(res)) return(NA_real_)
  y <- res$residu^2
  if (redresse) {
    umh <- numeric(nrow(res))
    for (j in unique(res$j)) {
      sel <- res$j == j
      col <- aj$tri[seq_len(aj$I - j), j + 1]
      umh[sel] <- .mw_sommes_autres(col)[res$i[sel] + 1] / sum(col)
    }
    y <- y / umh
  }
  nj <- as.vector(table(res$j)[as.character(res$j)])
  k <- nj >= n_min
  if (sum(k) < 3L) return(NA_real_)
  y <- y[k]; x <- res$C[k]; g <- res$j[k]
  yc <- y - stats::ave(y, g); xc <- x - stats::ave(x, g)
  syy <- sum(yc^2); sxx <- sum(xc^2); sxy <- sum(xc * yc)
  if (!(is.finite(syy) && syy > 0 && is.finite(sxx) && sxx > 0)) return(NA_real_)
  length(y) * sxy^2 / (sxx * syy)
}

# --- Pente intra-colonne relative (#307, Q-D1-Fi-9, mesuree SANS decision) --
# Regression de F / f_j sur (C - Cb_j) / Cb_j avec effets de colonne et poids
# C f_j^2 / sigma_j^2 ; statistique : t de la pente (bilatere). Meme algebre
# que .mw_lm_intra() ; le centrage pondere par colonne est celui du moteur,
# .mw_centrage_pondere() (forme stable par differences deux a deux, #233 et
# #278). NA si une colonne a un sigma_j non fini ou nul, si Sxx = 0 ou sans
# degre de liberte.
stat_pente_rel <- function(res) {
  if (nrow(res) < 4) return(NA_real_)
  if (any(!is.finite(res$sigma_j)) || any(res$sigma_j <= 0)) return(NA_real_)
  Cb <- stats::ave(res$C, res$j)
  x <- (res$C - Cb) / Cb
  y <- res$F / res$f_chapeau
  w <- res$C * res$f_chapeau^2 / res$sigma_j^2
  w <- w * 2^-floor(log2(max(w)))
  xt <- yt <- numeric(length(w))
  for (g in split(seq_along(w), res$j)) {
    sw <- sum(w[g])
    xt[g] <- .mw_centrage_pondere(x[g], w[g], sw)
    yt[g] <- .mw_centrage_pondere(y[g], w[g], sw)
  }
  sxx <- sum(w * xt^2)
  if (!(is.finite(sxx) && sxx > 0)) return(NA_real_)
  b <- sum(w * xt * yt) / sxx
  ddl <- length(w) - length(unique(res$j)) - 1L
  if (ddl < 1L) return(NA_real_)
  se <- sqrt(sum(w * (yt - b * xt)^2) / ddl / sxx)
  if (!(is.finite(se) && se > 0)) return(NA_real_)
  b / se
}

# --- MinP, MinP4, TMax (#300, par. 4.1) --------------------------------------
# t(i,j) : residu studentise externe de la regression ponderee de C(.,j+1) sur
# C(.,j) sans constante, poids 1/C(.,j) : t = DFBETAS sqrt((1 - h) / h), avec
# (1 - h) / h = S_sans / C(i,j), S_sans = .mw_sommes_autres() de la colonne
# (forme stable de #233). Un seul appel a mw_influence(aj) par replication,
# mis en cache (cle : le triangle de la replication).
influence_t <- function(aj, cache) {
  if (!is.null(cache$tri) && identical(cache$tri, aj$tri)) return(cache$inf)
  inf <- mw_influence(aj)
  t <- rep(NA_real_, nrow(inf))
  for (j in unique(inf$j)) {
    sel <- which(inf$j == j)
    t[sel] <- inf$dfbetas[sel] * sqrt(.mw_sommes_autres(inf$C[sel]) / inf$C[sel])
  }
  inf$t <- t
  inf$nj <- stats::ave(inf$j, inf$j, FUN = length)
  cache$tri <- aj$tri; cache$inf <- inf
  inf
}
# Cellules retenues : colonnes de n_j >= n_min hors figes$degeneres (n_min = 3
# pour MinP et TMax, 4 pour MinP4) ; N_t = leur nombre, fixe par la
# configuration observee. p_ij = 2 F_t(n_j - 2)(-|t|). obs = TRUE (triangle
# observe) : cellule a influence non bornee (dfbetas_non_borne) -> statistique
# NON DEFINIE, NA (option (iii), Q-D1-Fi-8) ; replication : p_ij = 0 et
# |t| = .Machine$double.xmax (valeur finie pour que la replication reste dans
# B effectif, p_ij = 0 etant la limite de |t| -> infini). Colonne retenue
# degeneree dans la replication (t NA sans non-borne) : statistique NA, la
# replication sort de B effectif (volet 2 de #56).
cellules_t <- function(aj, figes, n_min, obs, cache) {
  na <- list(M = NA_real_, T = NA_real_, nt = NA_integer_, i = NA_integer_, j = NA_integer_, t_min = NA_real_,
             iT = NA_integer_, jT = NA_integer_)
  inf <- influence_t(aj, cache)
  k <- inf$nj >= n_min & !(inf$j %in% figes$degeneres)
  if (!any(k)) return(na)
  d <- inf[k, , drop = FALSE]
  nb <- d$dfbetas_non_borne
  if (any(is.na(d$t) & !nb)) return(na)
  if (any(nb) && obs) return(na)
  tv <- d$t; tv[nb] <- .Machine$double.xmax
  p <- 2 * stats::pt(-abs(tv), d$nj - 2); p[nb] <- 0
  im <- which.min(p); iT <- which.max(abs(tv))
  list(M = min(p), T = max(abs(tv)), nt = nrow(d), i = d$i[im], j = d$j[im], t_min = tv[im], iT = d$i[iT], jT = d$j[iT])
}

# Entrees du catalogue des candidats, pour le triangle observe aj_obs : le
# triangle de la replication est reconnu observe si son tableau est identique
# a celui de aj_obs (identical()). Cache de mw_influence() propre a ce jeu
# d'entrees (une replication a la fois).
catalogue_candidats <- function(aj_obs, noms = CAND) {
  cache <- new.env()
  tri_obs <- aj_obs$tri
  est_obs <- function(e) identical(e$aj$tri, tri_obs)
  sur <- function(f) function(e) tryCatch(f(e), error = function(err) NA_real_)
  tout <- list(
    FWb = .mc_entree(sur(function(e) stat_fw(e$aj, e$res, FALSE, 1L)), "haut"),
    FWr = .mc_entree(sur(function(e) stat_fw(e$aj, e$res, TRUE, 3L)), "haut"),
    MinP = .mc_entree(sur(function(e) cellules_t(e$aj, e$figes, 3L, est_obs(e), cache)$M), "bas"),
    MinP4 = .mc_entree(sur(function(e) cellules_t(e$aj, e$figes, 4L, est_obs(e), cache)$M), "bas"),
    TMax = .mc_entree(sur(function(e) cellules_t(e$aj, e$figes, 3L, est_obs(e), cache)$T), "haut"),
    PenteRel = .mc_entree(sur(function(e) stat_pente_rel(e$res)), "deux"))
  tout[noms]
}

# Injection d'un catalogue dans l'environnement du moteur, restaure par
# finally (technique de calibration_mc_mw_t8.R, mode --controle-289) ; la
# boucle de tirage de mw_bootstrap() n'est pas recopiee (#340).
CAT_ORIG <- get("MW_CATALOGUE_MC", envir = ENV_MOTEUR)
avec_catalogue <- function(cat, expr) {
  assign("MW_CATALOGUE_MC", cat, envir = ENV_MOTEUR)
  tryCatch(expr, finally = assign("MW_CATALOGUE_MC", CAT_ORIG, envir = ENV_MOTEUR))
}
catalogue_restaure <- function() identical(get("MW_CATALOGUE_MC", envir = ENV_MOTEUR), CAT_ORIG)
# Catalogue du volet : A (catalogue reduit {BP, Grubbs} + candidats) ou B
# (13 cles + candidats), pour le triangle observe aj.
catalogue_volet <- function(volet, aj) {
  if (volet == "A") c(CAT_ORIG[TEM_A], catalogue_candidats(aj)) else c(CAT_ORIG, catalogue_candidats(aj))
}
stats_volet <- function(volet) if (volet == "A") STATS_A else STATS_B
bootstrap_volet <- function(volet, aj, graine, B = B_BOOT)
  avec_catalogue(catalogue_volet(volet, aj), mw_bootstrap(aj, B = B, seed = graine))
# Statistiques d'un triangle comme une observee (oracle, par. 4 de #206) : les
# 19 statistiques, sans bootstrap, ensembles figes de aj.
stats_oracle <- function(aj) {
  figes <- .mw_ensembles_figes(aj, .mw_colonnes_degenerees(aj))
  v <- .mc_evaluer(c(CAT_ORIG, catalogue_candidats(aj)), .mw_contexte_mc(aj, figes))
  v[STATS_B]
}

###############################################################################
#  GRANDEURS OBSERVEES D'UN TRIANGLE (Rosner, cellules designees, T5, T7, CV)
###############################################################################
CV_COLS <- paste0("cv", 0:6)
OR_COLS <- paste0("orp", 0:4)
# CV intra-colonne de C(0..I-j-1, j) : sd / moyenne (n_j >= 2), NA sinon.
cv_colonnes <- function(aj) vapply(0:(aj$J - 1L), function(j) {
  x <- aj$tri[seq_len(aj$I - j), j + 1L]
  if (length(x) < 2L) NA_real_ else stats::sd(x) / mean(x)
}, 1)
# Decomposition de BP (par. 3.4, T5) : r^2 ~ C sur les cellules de e$res ;
# sommes entre colonnes (moyennes de colonne) et intra colonne. Meme algebre de
# centrage par colonne (ave()) que stat_fw() : toute reprise dans le moteur
# (#301) la reproduira telle quelle pour que (i2') et le controle de T5 restent
# a 1e-10 (cf. stat_fw()).
decomposition_bp <- function(res) {
  na <- c(n = NA_real_, sxx_e = NA_real_, sxx_i = NA_real_, sxy_e = NA_real_, sxy_i = NA_real_, syy = NA_real_, dev_col = NA_real_)
  if (nrow(res) < 4) return(na)
  y <- res$residu^2; x <- res$C; g <- res$j
  xm <- ave(x, g); ym <- ave(y, g); nj <- ave(x, g, FUN = length)
  c(n = length(y), sxx_e = sum((xm - mean(x))^2), sxx_i = sum((x - xm)^2),
    sxy_e = sum((xm - mean(x)) * (ym - mean(y))), sxy_i = sum((x - xm) * (y - ym)), syy = sum((y - mean(y))^2),
    dev_col = max(abs(ym - (nj - 1) / nj)))
}
# Grandeurs observees d'un triangle admis (aj) : tout est calcule avec les
# fonctions du moteur et celles des candidats, ensembles figes de aj.
grandeurs_obs <- function(aj) {
  figes <- .mw_ensembles_figes(aj)
  res <- mw_residus(aj, figes$degeneres); r <- res$residu
  cache <- new.env()
  c3 <- cellules_t(aj, figes, 3L, TRUE, cache); c4 <- cellules_t(aj, figes, 4L, TRUE, cache)
  gr <- test_grubbs(r)
  gi <- if (is.finite(gr$idx) && gr$idx <= nrow(res)) c(res$i[gr$idx], res$j[gr$idx]) else c(NA_real_, NA_real_)
  ro <- function(a) tryCatch(test_rosner(r, alpha = a)$nb_outliers, error = function(e) NA_real_)
  org <- tryCatch(mw_test_ordonnee_origine(aj, figes$degeneres, figes$origine_non_identifiables)$detail, error = function(e) NULL)
  orp <- rep(NA_real_, 5L)
  if (!is.null(org) && nrow(org)) orp[org$j + 1L] <- org$p
  db <- decomposition_bp(res)
  list(figes = figes, k10 = ro(0.10), k05 = ro(0.05),
       gi = gi[1], gj = gi[2], mi = c3$i, mj = c3$j, m4i = c4$i, m4j = c4$j, ti = c3$iT, tj = c3$jT,
       nt3 = c3$nt, nt4 = c4$nt, db = db, orp = orp, cv = cv_colonnes(aj),
       gp = gr$p)
}

###############################################################################
#  COLONNES DES LIGNES MACHINE
###############################################################################
# Ligne de tranche (une par triangle) : meme jeu de colonnes de base aux deux
# volets, puis obs:, p:, B:, m: des statistiques du volet (STATS_A ou STATS_B).
COLS_BASE <- c("b", "statut", "motif", "jd", "duree", CV_COLS, "k10", "k05", "gi", "gj", "mi", "mj", "m4i", "m4j", "ti", "tj",
               "nt3", "nt4", "n", "sxx_e", "sxx_i", "sxy_e", "sxy_i", "syy", "dev_col", OR_COLS, "gp", "cum", "plaf", "ctl")
cols_tranche <- function(volet) {
  S <- stats_volet(volet)
  c(COLS_BASE, paste0("obs:", S), paste0("p:", S), paste0("B:", S), paste0("m:", S))
}
COLS <- list(tranche_A = cols_tranche("A"), tranche_B = cols_tranche("B"), oracle = c("k", "statut", "motif", "jd", paste0("obs:", STATS_B)))
cols_mode <- function(mode, volet) if (mode == "oracle") COLS$oracle else COLS[[paste0("tranche_", volet)]]
ETQ <- c(tranche = "REP", oracle = "ORA")
CARACTERE <- c("statut", "motif", "jd", "ctl", paste0("m:", STATS_B))
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
# Invariants (d) d'une p : B_eff <= B ; p sur la grille k/(B_eff + 1) (x 2 en
# bilateral, plafonnee a 1) -- copie declaree, B passe en argument.
sur_grille <- function(p, B, queue, Bmax = 999) {
  if (!is.finite(p)) return(TRUE)
  if (!is.finite(B) || B < 1 || B > Bmax) return(FALSE)
  k <- if (queue == "deux") 2 else 1
  x <- p * (B + 1) / k
  p == 1 || abs(x - round(x)) < 1e-6
}

###############################################################################
#  CALCUL D'UN TRIANGLE (tranche) ET D'UN TRIANGLE D'ORACLE
###############################################################################
# Specification d'un jeu de triangles : volet A (loi) ou cellule du volet B.
spec_cellule <- function(volet, cle) {
  if (volet == "A") list(volet = "A", loi = cle, id = paste0("A-", cle))
  else { r <- CELLULES[CELLULES$id == cle, ]; list(volet = "B", plan = r$plan, code = r$code, rang = r$rang, id = cle) }
}
triangle_spec <- function(sp, b) {
  if (sp$volet == "A") list(tri = engine_sous_graine(graine_tri(sp$loi, b), gen_triangle_h0(AJ0, tireur(sp$loi))), g = graine_boot(sp$loi, b))
  else list(tri = triangle_cellule(sp$plan, sp$code, graine_tri_B(sp$plan, sp$rang, b)), g = graine_boot_B(sp$plan, sp$rang, b))
}
# Identite de l'injection (controle (i2)) : sur les cles communes, p_mc,
# B_effectif, motif_mc et stats_obs identiques, ainsi que sigma_boot, B et les
# booleens du retirage, entre mw_bootstrap() sans injection et avec le
# catalogue injecte.
identite_injection <- function(plein, inj, cles) {
  ch <- c("p_mc", "err_mc", "B_effectif", "motif_mc", "granularite_stat", "p_min_mc")
  ok_ch <- all(vapply(ch, function(h) identical(plein[[h]][cles], inj[[h]][cles]), logical(1)))
  ok_so <- identical(plein$stats_obs[cles], inj$stats_obs[cles])
  ok_gl <- all(vapply(c("sigma_boot", "B", "granularite", "cumuls_retires", "plafond_cumuls"), function(h) identical(plein[[h]], inj[[h]]), logical(1)))
  ok_ch && ok_so && ok_gl
}
CTL_PERIODE <- 50L          # controle (i2) sur un triangle sur 50 (b multiple de 50)
traiter_triangle <- function(sp, b) {
  t0 <- Sys.time()
  tg <- triangle_spec(sp, b)
  ad <- admettre(tg$tri)
  if (!ad$ok) return(list(statut = "refuse", motif = ad$motif, duree = secondes(t0)))
  aj <- ad$aj
  go <- grandeurs_obs(aj)
  bt <- bootstrap_volet(sp$volet, aj, tg$g)
  out <- list(statut = "admis", motif = NA_character_, go = go, bt = bt, ctl = "-")
  if (b %% CTL_PERIODE == 0L) {
    plein <- mw_bootstrap(aj, B = B_BOOT, seed = tg$g)
    out$ctl <- if (identite_injection(plein, bt, intersect(names(plein$p_mc), names(bt$p_mc))) && catalogue_restaure()) "OK" else "ECHEC"
  }
  out$duree <- secondes(t0)
  out
}
champs_tranche <- function(volet, b, r) {
  cols <- cols_mode("tranche", volet); S <- stats_volet(volet)
  v <- stats::setNames(rep("NA", length(cols)), cols)
  v[["b"]] <- as.character(b); v[["statut"]] <- r$statut; v[["duree"]] <- sprintf("%.3f", r$duree)
  v[["motif"]] <- nettoyer_champ(if (is.na(r$motif)) "-" else r$motif)
  v[["jd"]] <- "-"; v[["ctl"]] <- "-"
  v[paste0("m:", S)] <- "-"
  if (r$statut != "admis") return(unname(v))
  go <- r$go; bt <- r$bt
  v[["jd"]] <- if (length(go$figes$degeneres)) paste(go$figes$degeneres, collapse = ",") else "-"
  v[CV_COLS] <- f17(go$cv)
  for (h in c("k10", "k05", "gi", "gj", "mi", "mj", "m4i", "m4j", "ti", "tj", "nt3", "nt4", "gp")) v[[h]] <- f17(as.numeric(go[[h]]))
  v[c("n", "sxx_e", "sxx_i", "sxy_e", "sxy_i", "syy", "dev_col")] <- f17(go$db[c("n", "sxx_e", "sxx_i", "sxy_e", "sxy_i", "syy", "dev_col")])
  v[OR_COLS] <- f17(go$orp)
  v[["cum"]] <- if (isTRUE(bt$cumuls_retires)) "1" else "0"
  v[["plaf"]] <- if (isTRUE(bt$plafond_cumuls)) "1" else "0"
  v[["ctl"]] <- r$ctl
  v[paste0("obs:", S)] <- f17(vapply(S, function(s) as.numeric(bt$stats_obs[[s]]), 1))
  v[paste0("p:", S)] <- f17(bt$p_mc[S])
  v[paste0("B:", S)] <- sprintf("%.0f", bt$B_effectif[S])
  v[paste0("m:", S)] <- code_motif(bt$motif_mc[S])
  unname(v)
}
# Oracle (par. 4 de #206) : statistiques d'un triangle comme une observee.
traiter_oracle <- function(id, k) {
  if (id %in% LOIS) tri <- engine_sous_graine(graine_ora(id, k), gen_triangle_h0(AJ0, tireur(id)))
  else tri <- engine_sous_graine(graine_ora_B(id, k), gen_triangle_h0(AJ_PLAN[[id]], tireur("N")))
  ad <- admettre(tri)
  if (!ad$ok) return(unname(c(k, "refuse", ad$motif, "-", rep("NA", NS_B))))
  jd <- .mw_colonnes_degenerees(ad$aj)
  unname(c(k, "admis", "-", if (length(jd)) paste(jd, collapse = ",") else "-", f17(unname(stats_oracle(ad$aj)))))
}
# Champ d'erreur (statut "erreur") : la sortie continue, --combiner refuse.
champs_erreur <- function(cols, b, msg, duree) {
  v <- rep("NA", length(cols)); v[1] <- b; v[2] <- "erreur"; v[3] <- nettoyer_champ(if (nzchar(msg)) msg else "(message vide)")
  if ("duree" %in% cols) v[match("duree", cols)] <- sprintf("%.3f", duree)
  v
}

###############################################################################
#  CONTROLES GENERAUX
###############################################################################
COMMIT <- commit_depot(SCRIPT)
EMPREINTES <- empreintes_code(SCRIPT, SPEC)
EMPREINTE_SC <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
MD5_MOTEUR <- md5_fichier(file.path(RACINE, "R", "engine.R"))
INTEGRITE <- character(0); CONTROLES <- character(0)
controle <- function(ok, libelle) {
  ok <- isTRUE(ok)
  if (!ok) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle, if (ok) "OK" else "\u00c9CHEC"))
  invisible(ok)
}
# (graines) : plages du volet B et de P3 disjointes entre elles et de celles du
# volet A (plan de #206) ; aucun litteral de graine du depot (nombres de huit
# chiffres, suffixe L compris, dans R/engine.R, tests/*.R hors ce script et
# tests/unitaires/*.R ; ecriture scientifique non recherchee) dont
# l'intervalle [L ; L + 20 000] touche une plage NOUVELLE (celles du volet A
# reprennent volontairement les graines de #206, comparees a leurs constantes
# par le controle (copie)) ; SEED_LOI_NULLE_SW, graine de reserve2 et reseau
# 20260831 + 1000 k <= 20760831 de tests/puissance_t8.R hors des plages.
PLAGES_A <- rbind(triangles = c(graine_tri("N", 1), graine_tri("A", R_A[["N"]])),
                  bootstrap = c(graine_boot("N", 1), graine_boot("A", R_A[["N"]])),
                  oracle = c(graine_ora("N", 1), graine_ora("A", N0_SPEC)))
PLAGES_B <- rbind(`B triangles` = c(32000001, 32380000), `B bootstrap` = c(32500001, 32880000), `B oracle P2` = c(33000001, 33020000),
                  `P3 triangles` = c(34000001, 34060000), `P3 bootstrap` = c(34200001, 34260000), `P3 oracle` = c(34400001, 34420000))
DECALAGE_MAX <- 20000
controle_graines <- function() {
  fs <- c(file.path(RACINE, "R", "engine.R"), list.files(file.path(RACINE, "tests"), pattern = "\\.R$", full.names = TRUE),
          list.files(file.path(RACINE, "tests", "unitaires"), pattern = "\\.R$", full.names = TRUE))
  fs <- fs[basename(fs) != basename(SCRIPT)]
  lit <- sort(unique(as.numeric(unlist(lapply(fs, function(f) {
    l <- readLines(f, warn = FALSE)
    regmatches(l, gregexpr("(?<![0-9A-Za-z.])[1-9][0-9]{7}(?=L?(?![0-9A-Za-z.]))", l, perl = TRUE))
  })))))
  touche <- function(a, b, P) any(a <= P[, 2] & b >= P[, 1])
  coll <- lit[vapply(lit, function(v) touche(v, v + DECALAGE_MAX, PLAGES_B), logical(1))]
  # plages bornees par les cellules reelles : (graine max) <= borne declaree
  borne_ok <- max(vapply(seq_len(nrow(CELLULES)), function(i) graine_tri_B(CELLULES$plan[i], CELLULES$rang[i], CELLULES$R[i]), 1)[CELLULES$plan != "P3"]) <= PLAGES_B[1, 2] &&
    max(vapply(seq_len(nrow(CELLULES)), function(i) graine_boot_B(CELLULES$plan[i], CELLULES$rang[i], CELLULES$R[i]), 1)[CELLULES$plan != "P3"]) <= PLAGES_B[2, 2] &&
    max(vapply(seq_len(nrow(CELLULES)), function(i) graine_tri_B(CELLULES$plan[i], CELLULES$rang[i], CELLULES$R[i]), 1)[CELLULES$plan == "P3"]) <= PLAGES_B[4, 2] &&
    max(vapply(seq_len(nrow(CELLULES)), function(i) graine_boot_B(CELLULES$plan[i], CELLULES$rang[i], CELLULES$R[i]), 1)[CELLULES$plan == "P3"]) <= PLAGES_B[5, 2] &&
    graine_ora_B("P2", N0_SPEC) <= PLAGES_B[3, 2] && graine_ora_B("P3", N0_SPEC) <= PLAGES_B[6, 2] &&
    min(c(graine_tri_B("P1", 1, 1), graine_boot_B("P1", 1, 1), graine_ora_B("P2", 1), graine_tri_B("P3", 1, 1), graine_boot_B("P3", 1, 1), graine_ora_B("P3", 1))) ==
      min(PLAGES_B[, 1])
  tous <- rbind(PLAGES_A, PLAGES_B)
  o <- tous[order(tous[, 1]), , drop = FALSE]
  disj <- all(o[-1, 1] > o[-nrow(o), 2])
  ext <- c(SEED_LOI_NULLE_SW, GRAINE_R2, 20260831 + 1000 * 500)
  hors_ext <- !any(vapply(ext, function(v) touche(v, v, tous), logical(1)))
  list(ok = disj && !length(coll) && hors_ext && borne_ok,
       txt = sprintf("plages du volet A (celles de #206) triangles %.0f-%.0f, bootstrap %.0f-%.0f, oracle %.0f-%.0f ; plages du volet B triangles %.0f-%.0f, bootstrap %.0f-%.0f, oracle P2 %.0f-%.0f ; plages de P3 triangles %.0f-%.0f, bootstrap %.0f-%.0f, oracle %.0f-%.0f ; les neuf plages sont disjointes deux \u00e0 deux : %s ; graines r\u00e9elles des cellules dans les plages d\u00e9clar\u00e9es : %s ; %d litt\u00e9raux de graine de huit chiffres dans %d fichiers (R/engine.R, tests/*.R hors ce script, tests/unitaires/*.R), de %.0f \u00e0 %.0f ; litt\u00e9raux L dont [L ; L + %.0f] touche une plage du volet B ou de P3 : %s ; SEED_LOI_NULLE_SW %.0f, graine de reserve2 %.0f et r\u00e9seau 20260831 + 1000 k \u2264 20760831 de tests/puissance_t8.R hors des plages : %s",
                     PLAGES_A[1, 1], PLAGES_A[1, 2], PLAGES_A[2, 1], PLAGES_A[2, 2], PLAGES_A[3, 1], PLAGES_A[3, 2],
                     PLAGES_B[1, 1], PLAGES_B[1, 2], PLAGES_B[2, 1], PLAGES_B[2, 2], PLAGES_B[3, 1], PLAGES_B[3, 2],
                     PLAGES_B[4, 1], PLAGES_B[4, 2], PLAGES_B[5, 1], PLAGES_B[5, 2], PLAGES_B[6, 1], PLAGES_B[6, 2],
                     if (disj) "oui" else "NON", if (borne_ok) "oui" else "NON", length(lit), length(fs), min(lit), max(lit), DECALAGE_MAX,
                     if (length(coll)) paste(sprintf("%.0f", coll), collapse = ", ") else "aucun",
                     SEED_LOI_NULLE_SW, GRAINE_R2, if (hors_ext) "oui" else "NON"))
}
# (g) : generateur identique a mw_simuler_triangle() (100 graines) ; fonctions
# du moteur identiques a celles du fichier relu hors injection -- copie
# declaree de calibration_mc_mw_t8.R (volet sous pool dilate, #271, compris).
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
           ".mw_pool_residus", "mw_bootstrap", "mw_influence", ".mw_sommes_autres")
  ok_fns <- all(vapply(fns, meme, logical(1)))
  list(ok = all(ok) && all(dil["identique", ]) && any(dil["incomplet", ]) && ok_fns,
       txt = sprintf("gen_triangle_h0() (\u03b5 tir\u00e9s par sample(pool)) = mw_simuler_triangle() sous la m\u00eame graine, identical(), sur %d / 100 graines (graines des triangles N du volet A, b = 1..100) ; sous pool dilat\u00e9 %g fois (#271) : %d / 100, dont %d triangle(s) \u00e0 cumul simul\u00e9 non fini ou \u2264 0 (au moins un exig\u00e9) ; %s de l'environnement identiques (formals, body) \u00e0 celles de R/engine.R relu : %s",
                     sum(ok), FACTEUR_G_DILATE, sum(dil["identique", ]), sum(dil["incomplet", ]), paste(fns, collapse = ", "), if (ok_fns) "oui" else "NON"))
}
# (copie) : les fonctions et constantes reprises de calibration_mc_mw_t8.R
# sont identiques (formals, corps ; valeur) a celles du fichier, relu par
# parse() et jamais execute.
COPIES_FONCTIONS <- c("plateforme_calcul", "meme_fichier", "empreintes_code", "sous_depot", "utf8", "ecrire_console", "ligne_md",
                      "entete_md", "num", "ic_cp", "txt_ic", "md5_fichier", "chemin_cite", "nettoyer_champ", "refuser", "secondes",
                      "f17", "liste_cel", "fmt_p", "chemins_absolus", "lire_option", "tireur", "gen_triangle_h0", "admettre",
                      "graine_tri", "graine_boot", "graine_ora",
                      "taille_lissee", "lecture", "txt_lec", "txt_classe", "mcnemar", "cellule", "ecriture_par_lot",
                      "ecart_journal_sortie", "lignes_recalcul_reprise", "md5_lignes")
COPIES_CONSTANTES <- c("GRAINE_TRI", "GRAINE_BOOT", "GRAINE_ORA", "PAS_LOI", "PAS_LOI_ORA", "D_IC", "CLASSES", "SEUIL_REFUS",
                       "NIVEAU_HOLM", "SEUIL_K4", "IDX_LOI", "ALPHA", "SEUILS", "IA", "METHODE", "SEGMENT", "ANNEXE", "GRAINE_R2",
                       "AJ0", "JD0", "POOL0", "SD_POP0", "POOL_E", "N_ECH_REPRISE_ORACLE", "N_ECH_REPRISE_TRANCHE")
controle_copie <- function() {
  f <- file.path(RACINE, SPEC_206)
  ex <- tryCatch(parse(f, keep.source = FALSE, encoding = "UTF-8"), error = function(e) NULL)
  if (is.null(ex)) return(list(ok = FALSE, txt = sprintf("%s illisible : copie non contr\u00f4lable", SPEC_206)))
  defs <- list()
  for (e in ex) if (is.call(e) && as.character(e[[1]])[1] %in% c("<-", "=") && is.name(e[[2]])) defs[[as.character(e[[2]])]] <- e[[3]]
  genv <- globalenv()
  ko_f <- COPIES_FONCTIONS[!vapply(COPIES_FONCTIONS, function(nm) {
    d <- defs[[nm]]; if (is.null(d)) return(FALSE)
    a <- tryCatch(eval(d, envir = genv), error = function(e) NULL); b <- get(nm, envir = genv)
    is.function(a) && identical(formals(a), formals(b)) && identical(body(a), body(b))
  }, logical(1))]
  ko_c <- COPIES_CONSTANTES[!vapply(COPIES_CONSTANTES, function(nm) {
    d <- defs[[nm]]; if (is.null(d)) return(FALSE)
    a <- tryCatch(eval(d, envir = genv), error = function(e) NULL)
    identical(a, get(nm, envir = genv))
  }, logical(1))]
  # N_ECH_REPRISE : celui de #206 porte aussi la sous-mesure N (sm = 0L), absente ici ;
  # comparaison explicite des elements tranche et oracle.
  a_n <- tryCatch(eval(defs[["N_ECH_REPRISE"]], envir = genv), error = function(e) NULL)
  ko_n <- if (!is.null(a_n) && identical(a_n[c("tranche", "oracle")], N_ECH_REPRISE[c("tranche", "oracle")])) character(0) else "N_ECH_REPRISE"
  list(ok = !length(ko_f) && !length(ko_c) && !length(ko_n),
       txt = sprintf("%d fonctions et %d constantes de %s (md5 %s) identiques (formals, corps ; valeur) \u00e0 celles de ce script, et N_ECH_REPRISE (tranche %d, oracle %d : #248) identique pour ces deux \u00e9l\u00e9ments%s",
                     length(COPIES_FONCTIONS), length(COPIES_CONSTANTES), SPEC_206, md5_fichier(f), N_ECH_REPRISE_TRANCHE, N_ECH_REPRISE_ORACLE,
                     if (length(c(ko_f, ko_c, ko_n))) paste0(" ; DIFF\u00c9RENTES OU ABSENTES : ", paste(c(ko_f, ko_c, ko_n), collapse = ", ")) else ""))
}
# (sc) : controles des scenarios sur des triangles construits, par une
# ecriture independante des definitions du par. 2.3.
controle_scenarios <- function() {
  I <- AJ0$I; J <- AJ0$J; f <- AJ0$f; s2 <- AJ0$sigma2
  rel <- function(a, b) max(abs(a - b) / pmax(abs(b), 1e-300))
  res <- c()
  # (1) parametres neutres = H0, au bit pres
  id0 <- all(vapply(1:20, function(i) {
    g <- graine_tri_B("P1", 1L, i)
    identical(engine_sous_graine(g, gen_triangle_scen(AJ_PLAN$P1, tireur("N"))), engine_sous_graine(g, gen_triangle_h0(AJ_PLAN$P1, tireur("N"))))
  }, logical(1)))
  # (2) moyenne et ecart-type du generateur (epsilon nuls, puis egaux a 1) : ecriture cellule par cellule
  gen_ref <- function(e1, delta, kappa, gamma) {
    tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- AJ0$tri[, 1]
    for (j in 0:(J - 1)) {
      n <- I - j; Cb <- sum(tri[1:n, j + 1]) / n
      for (i in 0:(n - 1)) {
        C <- tri[i + 1, j + 1]
        mu <- delta * f[j + 1] * Cb + f[j + 1] * (1 - delta) * C + gamma * sqrt(s2[j + 1]) / sqrt(Cb) * (i - (n - 1) / 2) * C
        sd <- sqrt(s2[j + 1]) * sqrt(C^kappa * Cb^(1 - kappa))
        tri[i + 1, j + 2] <- mu + e1 * sd
      }
    }
    tri
  }
  err_gen <- c()
  for (e1 in c(0, 1)) for (p in list(c(DELTA[["CST10"]], 1, 0), c(DELTA[["CST20"]], 1, 0), c(0, KAPPA[["EXP0"]], 0), c(0, KAPPA[["EXP2"]], 0), c(0, 1, GAMMA))) {
    a <- gen_triangle_scen(AJ0, function(n) rep(e1, n), delta = p[1], kappa = p[2], gamma = p[3])
    b <- gen_ref(e1, p[1], p[2], p[3])
    k <- !is.na(a)
    err_gen <- c(err_gen, if (identical(is.na(a), is.na(b))) rel(a[k], b[k]) else Inf)
  }
  # (3) scenarios d'increments sur le triangle observe de reserve2
  X <- function(tri) { out <- tri; for (i in 0:I) { k <- 0:(J - i); out[i + 1, k + 1] <- c(tri[i + 1, 1], diff(tri[i + 1, k + 1])) }; out }
  X0 <- X(.tri)
  err_inc <- c(); ok_cel <- TRUE
  for (sc in c("CAL7", "CAL4", "DCAL", "LIG", "CELx4", "CEL4", "CEL6")) {
    X1 <- X(appliquer_increments(.tri, sc, AJ0))
    attendu <- X0
    for (i in 0:I) for (k in 0:(J - i)) attendu[i + 1, k + 1] <- attendu[i + 1, k + 1] * switch(sc,
      CAL7 = if (i + k == 7) 1.10 else 1, CAL4 = if (i + k == 4) 1.10 else 1, DCAL = 1.05^max(0, i + k - 3),
      LIG = if (i == 2 && k >= 2) 1.5 else 1, CELx4 = if (i == 2 && k == 2) 4 else 1, 1)
    if (sc %in% names(LAMBDA)) attendu[3, 3] <- attendu[3, 3] + LAMBDA[[sc]] * sqrt(s2[2]) * sqrt(.tri[3, 2])
    k <- !is.na(attendu)
    err_inc <- c(err_inc, rel(X1[k], attendu[k]))
    if (sc %in% names(LAMBDA)) {
      tn <- appliquer_increments(.tri, sc, AJ0)
      ok_cel <- ok_cel && abs(((tn[3, 3] / tn[3, 2] - .tri[3, 3] / .tri[3, 2]) * sqrt(.tri[3, 2]) / sqrt(s2[2])) - LAMBDA[[sc]]) < 1e-10 &&
        identical(tn[-3, ], .tri[-3, ])
    }
  }
  # (4) plans : P2 equidistante de 204 a 476, P3 = P2 permutee, pi permutation de 0..7
  ok_plan <- abs(C0_P2[1] - 204) < 1e-9 && abs(C0_P2[8] - 476) < 1e-9 && abs(mean(C0_P2) - mean(C0_P1)) < 1e-9 &&
    identical(sort(PERM_P3), 1:8 + 0) && identical(COL0$P3, C0_P2[c(2, 8, 6, 4, 3, 5, 7, 1)]) &&
    all(abs(diff(C0_P2) - diff(C0_P2)[1]) < 1e-9) && isTRUE(all(AJ_PLAN$P3$tri[, 1] == COL0$P3)) &&
    identical(AJ_PLAN$P3$f, AJ0$f) && identical(AJ_PLAN$P3$sigma2, AJ0$sigma2)
  # (5) CAL7, CAL4 et DCAL de appliquer_increments() identiques (identical()) a
  # appliquer_effet() de tests/mesure_calendaire_t8.R (Fd), dont facteur_exercice()
  # et appliquer_effet() sont lues par parse() et evaluees SEULES (le script de Fd
  # n'est pas execute), sur 20 triangles H0 de P1 : "dernier" et "median" a 0,10,
  # "derive" a 0,05. Un echec est bloquant (controle (sc), puis arret de la tranche).
  f_fd <- file.path(RACINE, "tests", "mesure_calendaire_t8.R")
  ex_fd <- tryCatch(parse(f_fd, keep.source = FALSE, encoding = "UTF-8"), error = function(e) NULL)
  defs_fd <- list()
  if (!is.null(ex_fd)) for (e in ex_fd) if (is.call(e) && as.character(e[[1]])[1] %in% c("<-", "=") && is.name(e[[2]]) &&
                                              as.character(e[[2]]) %in% c("facteur_exercice", "appliquer_effet")) defs_fd[[as.character(e[[2]])]] <- e[[3]]
  ok_fd <- FALSE; n_fd <- 0L; n_inc <- NA_integer_
  if (length(defs_fd) == 2L) {
    env_fd <- new.env(parent = globalenv())
    for (nm in names(defs_fd)) assign(nm, eval(defs_fd[[nm]], env_fd), envir = env_fd)
    tris_fd <- lapply(1:20, function(i) engine_sous_graine(graine_tri_B("P1", 1L, i), gen_triangle_h0(AJ_PLAN$P1, tireur("N"))))
    n_inc <- sum(vapply(tris_fd, .mw_triangle_incomplet, logical(1)))
    r_fd <- vapply(tris_fd, function(tri) c(
      identical(appliquer_increments(tri, "CAL7"), env_fd$appliquer_effet(tri, "dernier", THETA)),
      identical(appliquer_increments(tri, "CAL4"), env_fd$appliquer_effet(tri, "median", THETA)),
      identical(appliquer_increments(tri, "DCAL"), env_fd$appliquer_effet(tri, "derive", 0.05))), logical(3))
    ok_fd <- all(r_fd); n_fd <- ncol(r_fd)
  }
  tol <- 1e-12
  list(ok = id0 && max(err_gen) < tol && max(err_inc) < tol && ok_cel && ok_plan && ok_fd,
       txt = sprintf("param\u00e8tres neutres de gen_triangle_scen() = gen_triangle_h0() (identical(), 20 graines) : %s ; moyenne et \u00e9cart-type des g\u00e9n\u00e9rateurs CST10, CST20, EXP0, EXP2, DFI (\u03b5 = 0 puis \u03b5 = 1) contre une \u00e9criture ind\u00e9pendante cellule par cellule : \u00e9cart relatif maximal %s ; sc\u00e9narios d'incr\u00e9ments CAL7, CAL4, DCAL, LIG, CELx4, CEL4, CEL6 sur le triangle observ\u00e9 de reserve2 contre une \u00e9criture ind\u00e9pendante : \u00e9cart relatif maximal %s ; CEL4 et CEL6 d\u00e9placent F(2, 1) de \u03bb \u00e9carts-types de bruit et laissent les autres lignes identiques : %s ; plans P2 (204 \u00e0 476, mean inchang\u00e9e, \u00e9quidistante) et P3 (P2[c(2, 8, 6, 4, 3, 5, 7, 1)], \u03c0 = (1, 7, 5, 3, 2, 4, 6, 0)) : %s ; CAL7, CAL4 et DCAL de appliquer_increments() identical() \u00e0 appliquer_effet(\"dernier\", 0,10), (\"median\", 0,10) et (\"derive\", 0,05) de tests/mesure_calendaire_t8.R (md5 %s ; fonctions lues par parse(), script non ex\u00e9cut\u00e9) sur %d triangles H0 de P1 (dont %s incomplets, rendus tels quels par les deux) : %s",
                     if (id0) "oui" else "NON", formatC(max(err_gen), format = "e", digits = 2), formatC(max(err_inc), format = "e", digits = 2),
                     if (ok_cel) "oui" else "NON", if (ok_plan) "oui" else "NON", md5_fichier(f_fd), n_fd, n_inc, if (ok_fd) "oui" else "NON"))
}

###############################################################################
#  FONCTIONS REPRISES PAR COPIE DECLAREE de tests/calibration_mc_mw_t8.R
#  (controle (copie)) : reference rho, lecture d'un taux, McNemar, ecriture par lot,
#  reprise. Texte extrait mecaniquement du fichier d'origine.
###############################################################################
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
mcnemar <- function(d1, d2) {
  n01 <- sum(d1 & !d2); n10 <- sum(!d1 & d2); n <- n01 + n10
  c(n01 = n01, n10 = n10, p = if (n) stats::binom.test(n01, n, 0.5)$p.value else 1)
}
cellule <- function(p, a, ref) {
  fin <- is.finite(p); k <- sum(fin & p < a)
  x <- lecture(k, length(p), ref)
  x$absentes <- sum(!fin); x$taux_def <- if (any(fin)) k / sum(fin) else NA_real_
  x
}
md5_lignes <- function(l) {
  f <- tempfile("md5_"); on.exit(unlink(f))
  con <- file(f, open = "wb"); writeLines(utf8(l), con, useBytes = TRUE); close(con)
  unname(tools::md5sum(f))
}
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
ecart_journal_sortie <- function(jl, nom, md5) {
  m <- regmatches(jl, regexec("^- Sortie (\\S+) : md5 ([0-9a-f]{32})([,[:space:]]|$)", jl))
  m <- Filter(function(x) length(x) && identical(x[2], nom), m)
  if (length(m) != 1L)
    return(sprintf("%d ligne(s) \"- Sortie %s : md5 <md5>\" au JOURNAL (une attendue)", length(m), nom))
  if (!identical(m[[1]][3], md5))
    return(sprintf("md5 de %s au JOURNAL (%s) different de celui du fichier (%s)", nom, m[[1]][3], md5))
  NULL
}
lignes_recalcul_reprise <- function(b_ok, mode) {
  if (!length(b_ok)) return(integer(0))
  bo <- sort(b_ok); n <- min(N_ECH_REPRISE[[mode]], length(bo))
  ech <- if (n > 0L) bo[unique(round(seq(1, length(bo), length.out = n)))] else integer(0)
  unique(c(b_ok[length(b_ok)], ech))
}

###############################################################################
#  LECTURE D'UNE SORTIE (--combiner, --reprendre)
###############################################################################
CLES_CONTEXTE <- c("mode", "cle", "dgp", "configuration", "graines", "collisions", "generateur", "commit", "plateforme",
                   "empreintes", "empreinte_sc", "reference", "candidats", "scenarios", "copie", "essai", "locale")
CLES_COMMUNES <- c("dgp", "configuration", "graines", "collisions", "generateur", "commit", "plateforme", "empreintes",
                   "empreinte_sc", "reference", "candidats", "scenarios", "copie", "essai")
LIBELLES_CONTEXTE <- c(
  mode = "Mode", cle = "Jeu de triangles", dgp = "DGP sous H0 et plans (par. 2.2)", configuration = "Configuration",
  graines = "Graines (par. 2.5 et 2.6, compl\u00e9ment du 19/10/2026)",
  collisions = "Graines : recherche des collisions (plages de P3 comprises)",
  generateur = "G\u00e9n\u00e9rateur", commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9 (moteur, outils, script)",
  empreinte_sc = "Empreinte sans commentaires de R/engine.R (#231) et md5 du fichier entier",
  reference = "Contr\u00f4le (a) : reserve2 contre tests/reference/reserve2.rds",
  candidats = "Contr\u00f4le (c) : candidats sur reserve2 (graine 20260831, B = 999)",
  scenarios = "Contr\u00f4le (sc) : sc\u00e9narios et plans, \u00e9criture ind\u00e9pendante",
  copie = "Contr\u00f4le (copie) : fonctions reprises de tests/calibration_mc_mw_t8.R",
  essai = "Provisoire (--provisoire, --essai, --B, --N0 r\u00e9duit : non versionnable)",
  locale = "Locale LC_CTYPE (origine \u2192 travail)")
# Echantillons de recalcul a la reprise : valeurs de #248 (N_ECH_REPRISE_TRANCHE
# = 10, N_ECH_REPRISE_ORACLE = 50 dans calibration_mc_mw_t8.R), comparees par
# le controle (copie) ; pas de sous-mesure N ici.
N_ECH_REPRISE_ORACLE <- 50L
N_ECH_REPRISE_TRANCHE <- 10L
N_ECH_REPRISE <- c(tranche = N_ECH_REPRISE_TRANCHE, oracle = N_ECH_REPRISE_ORACLE)
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
  if (!mode %in% names(ETQ)) refuser(nf, " : mode illisible dans PARAMETRES")
  volet <- sub("^.*;volet=([AB]);.*$", "\\1", par)
  cle <- sub("^.*;cle=([^;]+);.*$", "\\1", par)
  Bpar <- suppressWarnings(as.numeric(sub("^.*;B=([0-9]+);.*$", "\\1", par)))
  tr <- unique1("TRANCHE")
  if (length(tr) != 3L) refuser(nf, " : ligne TRANCHE illisible")
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(nf, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), CLES_CONTEXTE) || anyDuplicated(names(ctx))) refuser(nf, " : lignes CONTEXTE incompletes")
  cl <- unique1("CLES"); co <- unique1("COLS")
  if (!identical(cl, sprintf("%s=%s", STATS_B, QUEUE_ALL[STATS_B]))) refuser(nf, " : CLES differentes du catalogue (13 cles de MW_CATALOGUE_MC de ce moteur et candidats)")
  if (!identical(co, cols_mode(mode, volet))) refuser(nf, " : COLS differentes de celles du script")
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
  list(fichier = f, nom = nf, parametres = par, mode = mode, volet = volet, cle = cle, B = Bpar,
       debut = as.integer(tr[1]), fin = as.integer(tr[2]), contexte = ctx[CLES_CONTEXTE], donnees = rp, duree = du,
       md5 = md5_fichier(f), md5_valeurs = md5v, reprise = vapply(champs("REPRISE"), paste, "", collapse = " "))
}
# Invariants (d) d'une sortie, lus sur les champs BRUTS : seul le marqueur
# "NA" est admis comme absence ; toute autre valeur d'une colonne de p doit
# etre un decimal de [0, 1] ; B effectif <= B ; p sur la grille ; motifs
# connus ; statut connu ; controle (i2) des lignes ctl.
RE_NOMBRE <- "^-?[0-9]+(\\.[0-9]+)?([eE][-+]?[0-9]+)?$"
cols_p01 <- function(volet) c(OR_COLS, "gp", paste0("p:", stats_volet(volet)))
p_hors_01 <- function(donnees, cols_mode_, cols) {
  if (!length(donnees) || !length(cols)) return(character(0))
  M <- do.call(rbind, donnees); colnames(M) <- cols_mode_
  cols[vapply(cols, function(k) {
    x <- M[, k]; ab <- x == "NA"
    v <- suppressWarnings(as.numeric(x))
    any(!ab & (!grepl(RE_NOMBRE, x) | is.na(v) | v < 0 | v > 1))
  }, logical(1))]
}
invariants_sortie <- function(p) {
  err <- character(0)
  D <- en_table(p$donnees, cols_mode(p$mode, p$volet))
  b <- if (p$mode == "oracle") D$k else D$b
  if (!identical(as.integer(sort(b)), seq.int(p$debut, p$fin))) err <- c(err, "indices des lignes differents de debut..fin")
  if (!all(D$statut %in% c("admis", "refuse"))) err <- c(err, "statut inconnu")
  if (p$mode == "tranche") {
    h01 <- p_hors_01(p$donnees, COLS[[paste0("tranche_", p$volet)]], cols_p01(p$volet))
    if (length(h01)) err <- c(err, sprintf("p hors de [0, 1] ou illisible (%s)", paste(h01, collapse = ", ")))
    A <- D[D$statut == "admis", , drop = FALSE]
    if (nrow(A)) {
      S <- stats_volet(p$volet)
      ok <- all(vapply(S, function(s) all(mapply(sur_grille, A[[paste0("p:", s)]], A[[paste0("B:", s)]], MoreArgs = list(queue = QUEUE_ALL[[s]], Bmax = p$B))), logical(1)))
      if (!ok) err <- c(err, "invariant (d) faux (B_eff > B ou p hors grille)")
      M <- as.matrix(A[, paste0("m:", S)])
      if (!all(M %in% c(names(CODES_MOTIF), "-"))) err <- c(err, "motif d'absence inconnu")
      if (any(A$ctl == "ECHEC")) err <- c(err, "controle (i2) en echec sur une ligne ctl")
    }
  }
  err
}

###############################################################################
#  REFERENCE rho, TAUX, TABLEAUX (tranche partielle et --combiner)
###############################################################################
SEUIL_RHO_APPROCHE <- 0.01
# Oracle : statistiques finies, rho (taille lissee a B, regle unique), diagnostics d'atomes.
resume_oracle <- function(O, B) {
  adm <- O[O$statut == "admis", , drop = FALSE]
  n_adm <- nrow(adm)
  lapply(stats::setNames(nm = STATS_B), function(s) {
    S <- adm[[paste0("obs:", s)]]; S <- S[is.finite(S)]
    tab <- if (length(S)) table(S) else integer(0)
    list(n_adm = n_adm, n_fin = length(S), n_nonfini = n_adm - length(S), distinctes = length(tab),
         atome = if (length(S)) max(tab) / length(S) else NA_real_,
         rho = vapply(SEUILS, function(a) taille_lissee(S, QUEUE_ALL[[s]], B, a, n_adm), 1))
  })
}
rho_approche <- function(o) o$n_adm > 0 && o$n_nonfini / o$n_adm > SEUIL_RHO_APPROCHE
# Oracle d'un jeu de triangles : volet A, loi L -> ORA-A-L ; volet B, P1 -> oracle de la loi N du
# volet A ; P2, P3 -> leur oracle propre.
cle_oracle <- function(cle) if (startsWith(cle, "A-")) paste0("ORA-", cle) else {
  plan <- sub("^B-(P[123])\\..*$", "\\1", cle)
  if (plan == "P1") "ORA-A-N" else paste0("ORA-B-", plan)
}
rho_de <- function(OR, cle, s, ia) {
  o <- OR[[cle_oracle(cle)]]
  if (is.null(o)) NA_real_ else o[[s]]$rho[match(ia, IA)]
}
adm_de <- function(D) if (is.null(D)) NULL else D[D$statut == "admis", , drop = FALSE]
dec <- function(D, s, a) { p <- D[[paste0("p:", s)]]; is.finite(p) & p < a }
# Classe affichee avec son cote (code propre a ce script ; txt_classe(), copie
# declaree, n'est pas modifiee) : distorsion materielle -> cote de l'IC ;
# ecart non tranche -> cote lu sur le taux (conservateur si taux < rho/2,
# liberal si taux > 3 rho/2), pour D2-Fi. Decision mecanique inchangee.
cote_non_tranche <- function(c_, ref) {
  if (!identical(c_$classe, CLASSES[3]) || !is.finite(c_$taux) || !is.finite(ref)) return(NA_character_)
  if (c_$taux < ref / 2) "conservateur" else if (c_$taux > 3 * ref / 2) "lib\u00e9ral" else NA_character_
}
txt_classe_309 <- function(c_) {
  if (c_$disj) return(txt_classe(c_))
  cote <- cote_non_tranche(c_, if (is.null(c_$ref_lu)) NA_real_ else c_$ref_lu)
  if (!is.na(cote)) sprintf("%s (c\u00f4t\u00e9 %s)", c_$classe, cote) else c_$classe
}
lib_ia <- function(ia) c(a10 = "0,10", a05 = "0,05")[[ia]]
lib_stat <- function(s) sprintf("%s (%s)", s, QUEUE_ALL[[s]])
lib_cellule <- function(cle) {
  if (startsWith(cle, "A-")) sprintf("volet A, loi %s (P1, H0)", sub("^A-", "", cle))
  else { id <- sub("^B-", "", cle); sprintf("%s", id) }
}

tableau_rho <- function(OR, titre = "### R\u00e9f\u00e9rence \u03c1 et diagnostics des oracles") {
  L <- c(titre, "",
         paste("\u03c1 : taille liss\u00e9e \u00e0 B du test de Monte-Carlo id\u00e9al tirant ses r\u00e9pliques dans F0 (r\u00e8gle \u00ab \u2265 \u00bb d'engine_p_mc(), r\u00e8gle unique",
               "de #206 pour les 19 statistiques, aucune classification a priori) ; statistique oracle non finie compt\u00e9e comme non-rejet. Un oracle par jeu :",
               "ORA-A-N (loi N du volet A, **aussi l'oracle de P1** du volet B), ORA-A-E, ORA-A-A, ORA-B-P2, ORA-B-P3 (N0 triangles i.i.d. du m\u00eame DGP).",
               "Erreur de \u03c1 due \u00e0 N0 : de l'ordre de 0,002 \u00e0 \u03b1 = 0,10 [H], distincte de l'IC sur \u03c4 (fonction de R) et de err_mc (fonction de B).",
               "\u03c1 marqu\u00e9 \u00ab approch\u00e9 \u00bb au-del\u00e0 de 1 % de statistiques oracle non finies pour la statistique."), "",
         entete_md(c("Oracle", "Statistique (sens)", "admis", "non finies", "valeurs distinctes", "masse du plus gros atome", "\u03c1 0,10", "\u03c1 0,05")))
  for (k in names(OR)) for (s in STATS_B) {
    o <- OR[[k]][[s]]
    ap <- if (rho_approche(o)) " (**approch\u00e9**)" else ""
    L <- c(L, ligne_md(k, lib_stat(s), o$n_adm, o$n_nonfini, o$distinctes, num(o$atome, 5), paste0(num(o$rho[1], 5), ap), paste0(num(o$rho[2], 5), ap)))
  }
  c(L, "")
}
cles_rho_approche <- function(OR) unlist(lapply(names(OR), function(k)
  vapply(Filter(function(s) rho_approche(OR[[k]][[s]]), STATS_B), function(s)
    sprintf("%s %s (%d / %d non finies)", k, s, OR[[k]][[s]]$n_nonfini, OR[[k]][[s]]$n_adm), "")))

# Niveau (T1) : taux par (jeu, statistique, seuil) contre rho.
cellules_niveau <- function(DS, OR, cles, stats_de) {
  out <- list()
  for (cle in cles) {
    D <- adm_de(DS$tr[[cle]]); if (is.null(D)) next
    for (s in stats_de(cle)) for (ia in IA) {
      ref <- rho_de(OR, cle, s, ia)
      c_ <- cellule(D[[paste0("p:", s)]], SEUILS[match(ia, IA)], ref); c_$ref_lu <- ref
      out[[length(out) + 1L]] <- list(cle = cle, s = s, ia = ia, ref = ref, c = c_)
    }
  }
  out
}
tableau_niveau <- function(CEL, titre, intro) {
  L <- c(titre, "", intro, "",
         entete_md(c("Jeu", "Statistique (sens)", "n", "abs. 0,10", "\u03c1 0,10", "k 0,10", "taux [IC] 0,10", "classe 0,10", "taux d\u00e9f. 0,10",
                     "abs. 0,05", "\u03c1 0,05", "k 0,05", "taux [IC] 0,05", "classe 0,05", "taux d\u00e9f. 0,05")))
  cle <- vapply(CEL, function(x) paste(x$cle, x$s), "")
  for (u in unique(cle)) {
    x <- CEL[cle == u]
    cols <- unlist(lapply(x, function(z) c(z$c$absentes, num(z$ref, 5), z$c$k, txt_lec(z$c), txt_classe_309(z$c), num(z$c$taux_def, D_IC))))
    L <- c(L, ligne_md(lib_cellule(x[[1]]$cle), lib_stat(x[[1]]$s), x[[1]]$c$n, paste(cols, collapse = " | ")))
  }
  c(L, "")
}
# Puissance (T2) : taux de rejet par (cellule, statistique, seuil), sans rho ; Rosner : P(k >= 1).
tableau_puissance <- function(DS) {
  L <- c("### T2 \u2014 puissance : taux de rejet (p_mc < \u03b1) par cellule, statistique et seuil", "",
         paste("Volet B, loi N, B = 999, triangles admis de chaque cellule (plan P1, P2 ou P3 \u00d7 sc\u00e9nario) ; p absente compt\u00e9e comme non-rejet ;",
               "k / n, taux et IC de Clopper-Pearson \u00e0 95 % (5 d\u00e9cimales). La ligne H0 de chaque plan est le niveau de la cellule (voir T1 pour \u03c1 et la classe).",
               "Rosner : proc\u00e9dure \u00e0 niveau \u03b1 sans p-value ; taux de triangles \u00e0 \u2265 1 cellule d\u00e9clar\u00e9e (k\u0302 \u2265 1) au seuil \u03b1 de la ligne, sur les m\u00eames triangles.",
               "Constat de simulation sous un plan, non g\u00e9n\u00e9ral."), "",
         entete_md(c("Plan", "Sc\u00e9nario", "Statistique (sens)", "n", "abs. 0,10", "k 0,10", "taux [IC] 0,10", "abs. 0,05", "k 0,05", "taux [IC] 0,05")))
  for (i in seq_len(nrow(CELLULES))) {
    cle <- paste0("B-", CELLULES$id[i]); D <- adm_de(DS$tr[[cle]]); if (is.null(D) || !nrow(D)) next
    for (s in STATS_B) {
      cs <- lapply(SEUILS, function(a) cellule(D[[paste0("p:", s)]], a, NA_real_))
      L <- c(L, ligne_md(CELLULES$plan[i], CELLULES$code[i], lib_stat(s), nrow(D), cs[[1]]$absentes, cs[[1]]$k, txt_lec(cs[[1]]),
                         cs[[2]]$absentes, cs[[2]]$k, txt_lec(cs[[2]])))
    }
    for (a in c("k10", "k05")) {
      k <- sum(D[[a]] >= 1, na.rm = TRUE); x <- lecture(k, nrow(D), NA_real_)
      vide <- c("\u2014", "\u2014", "\u2014")
      L <- c(L, ligne_md(CELLULES$plan[i], CELLULES$code[i], sprintf("Rosner, k\u0302 \u2265 1 (\u03b1 = %s)", if (a == "k10") "0,10" else "0,05"), nrow(D),
                         if (a == "k10") paste(c(sum(is.na(D[[a]])), k, txt_lec(x)), collapse = " | ") else paste(vide, collapse = " | "),
                         if (a == "k05") paste(c(sum(is.na(D[[a]])), k, txt_lec(x)), collapse = " | ") else paste(vide, collapse = " | ")))
    }
  }
  c(L, "")
}
# McNemar exact (T3) sur les paires de decision, memes triangles et memes repliques.
PAIRES <- list(c("MinP", "Grubbs"), c("MinP4", "Grubbs"), c("TMax", "Grubbs"), c("MinP", "MinP4"), c("MinP", "TMax"), c("TMax", "MinP4"),
              c("FWr", "FWb"), c("FWr", "BP"), c("FWb", "BP"))
mc_paire <- function(D, pr, a) mcnemar(dec(D, pr[1], a), dec(D, pr[2], a))
tableau_mcnemar <- function(DS) {
  L <- c("### T3 \u2014 McNemar exact sur les paires de d\u00e9cision (paires discordantes, m\u00eames triangles et m\u00eames r\u00e9pliques)", "",
         paste("D = 1 si p_mc < \u03b1 (p absente : non-rejet). n01 : la **premi\u00e8re** statistique de la paire rejette, la seconde non ; n10 : l'inverse ;",
               "p : test binomial exact bilat\u00e9ral de param\u00e8tre 1/2 sur n01 + n10 (p = 1 sans paire discordante). Aucune correction de multiplicit\u00e9 :",
               "les paires lues par K-300 sont CEL4, CEL6 et CELx4 (P1) et les niveaux du volet A."), "",
         entete_md(c("Jeu", "Paire", "n", "taux 1\u00e8re / 2nde 0,10", "n01 / n10 0,10", "p 0,10", "taux 1\u00e8re / 2nde 0,05", "n01 / n10 0,05", "p 0,05")))
  cles <- c(paste0("A-", LOIS), paste0("B-", CELLULES$id))
  for (cle in cles) {
    D <- adm_de(DS$tr[[cle]]); if (is.null(D) || !nrow(D)) next
    for (pr in PAIRES) {
      r <- lapply(SEUILS, function(a) mc_paire(D, pr, a))
      tx <- lapply(SEUILS, function(a) c(mean(dec(D, pr[1], a)), mean(dec(D, pr[2], a))))
      L <- c(L, ligne_md(lib_cellule(cle), paste(pr, collapse = " / "), nrow(D),
                         sprintf("%s / %s", num(tx[[1]][1], 4), num(tx[[1]][2], 4)), sprintf("%d / %d", r[[1]][["n01"]], r[[1]][["n10"]]), fmt_p(r[[1]][["p"]]),
                         sprintf("%s / %s", num(tx[[2]][1], 4), num(tx[[2]][2], 4)), sprintf("%d / %d", r[[2]][["n01"]], r[[2]][["n10"]]), fmt_p(r[[2]][["p"]])))
    }
  }
  c(L, "")
}
# T4 : cellule designee par les statistiques de M4.
DESIGNATION <- list(Grubbs = c("gi", "gj"), MinP = c("mi", "mj"), MinP4 = c("m4i", "m4j"), TMax = c("ti", "tj"))
tableau_designation <- function(DS) {
  L <- c("### T4 \u2014 cellule d\u00e9sign\u00e9e par chaque statistique de M4 (cellule vis\u00e9e : (i, j) = (2, 1), coordonn\u00e9es de r\u00e9sidus de Mack)", "",
         paste("Part des triangles admis dont la cellule d\u00e9sign\u00e9e \u00e0 l'observ\u00e9 est (2, 1) : Grubbs (r\u00e9sidu de plus grande valeur absolue centr\u00e9e),",
               "MinP et MinP4 (cellule de p_ij minimale), TMax (cellule de |t| maximal) ; IC de Clopper-Pearson \u00e0 95 %. H0 : r\u00e9f\u00e9rence de d\u00e9signation par",
               "hasard (la cellule n'est pas ciblee). \u00ab Parmi les rejets \u00bb : m\u00eame part sur les triangles o\u00f9 la statistique rejette \u00e0 0,10",
               "(p_mc < 0,10)."), "",
         entete_md(c("Cellule", "n", "Statistique", "d\u00e9signe (2, 1) [IC]", "rejets \u00e0 0,10", "d\u00e9signe (2, 1) parmi les rejets [IC]")))
  for (id in c("P1.H0", "P1.CEL4", "P1.CEL6", "P1.CELx4")) {
    D <- adm_de(DS$tr[[paste0("B-", id)]]); if (is.null(D) || !nrow(D)) next
    for (s in names(DESIGNATION)) {
      ij <- DESIGNATION[[s]]
      h <- (D[[ij[1]]] %in% CIBLE_CEL[["i"]]) & (D[[ij[2]]] %in% CIBLE_CEL[["j"]])
      rej <- dec(D, s, 0.10)
      x <- lecture(sum(h), nrow(D), NA_real_); y <- lecture(sum(h & rej), sum(rej), NA_real_)
      L <- c(L, ligne_md(id, nrow(D), s, txt_lec(x), sum(rej), if (sum(rej)) txt_lec(y) else "\u2014"))
    }
  }
  c(L, "")
}
# T5 : decomposition de BP sous H0 (par. 3.4).
tableau_bp <- function(DS) {
  L <- c("### T5 \u2014 d\u00e9composition de BP sous H0 (par. 3.4)", "",
         paste("R\u00e9gression r\u00b2 ~ C sur les cellules de e$res (27 sur reserve2). S_xx entre colonnes = \u03a3 n_j (C\u0304_j \u2212 C\u0304)\u00b2 ; S_xy entre colonnes =",
               "\u03a3 n_j (C\u0304_j \u2212 C\u0304)(r\u0304\u00b2_j \u2212 r\u0304\u00b2) ; intra colonne : somme des produits des \u00e9carts \u00e0 la moyenne de colonne. nR\u00b2 de BP = n S_xy\u00b2 / (S_xx S_yy) ;",
               "\u00ab nR\u00b2 entre \u00bb et \u00ab nR\u00b2 intra \u00bb : la m\u00eame forme avec S_xy entre (resp. intra) seul(e) (les deux ne s'additionnent pas : terme crois\u00e9) ;",
               "\u00ab part de S_xy entre \u00bb : S_xy entre / S_xy. \u00ab \u00c9cart de contrainte \u00bb : max_j |moyenne de colonne de r\u00b2 \u2212 (n_j \u2212 1)/n_j| (identit\u00e9 exacte \u03a3_i r(i,j)\u00b2 = n_j \u2212 1, attendue ~ 1e-15).",
               "\u00ab \u00c9cart au BP observ\u00e9 \u00bb : max |n S_xy\u00b2 / (S_xx S_yy) \u2212 obs:BP| sur les triangles du jeu (contr\u00f4le, seuil 1e-10 : un d\u00e9passement fait refuser la combinaison).",
               "Moyenne [\u00e9cart-type] sur les triangles admis du jeu. Le m\u00e9canisme de #301 est une hypoth\u00e8se [H] que ce tableau confirme ou non."), "",
         entete_md(c("Jeu", "n triangles", "part de S_xx entre colonnes", "part de S_xy entre", "S_xy entre", "S_xy intra", "nR\u00b2 de BP", "nR\u00b2 entre", "nR\u00b2 intra",
                     "\u00e9cart de contrainte max", "\u00e9cart au BP observ\u00e9 max")))
  ms <- function(x) sprintf("%s [%s]", num(mean(x, na.rm = TRUE), 4), num(stats::sd(x, na.rm = TRUE), 4))
  for (cle in c("A-N", "A-E", "A-A", "B-P1.H0", "B-P2.H0", "B-P3.H0")) {
    D <- adm_de(DS$tr[[cle]]); if (is.null(D) || !nrow(D)) next
    sxx <- D$sxx_e + D$sxx_i; sxy <- D$sxy_e + D$sxy_i
    L <- c(L, ligne_md(lib_cellule(cle), nrow(D), ms(D$sxx_e / sxx), ms(D$sxy_e / sxy), ms(D$sxy_e), ms(D$sxy_i), ms(D$n * sxy^2 / (sxx * D$syy)),
                       ms(D$n * D$sxy_e^2 / (sxx * D$syy)), ms(D$n * D$sxy_i^2 / (sxx * D$syy)), formatC(max(D$dev_col, na.rm = TRUE), format = "e", digits = 2),
                       formatC(ecart_bp(D), format = "e", digits = 2)))
  }
  c(L, "")
}
# Ecart maximal entre le nR2 recompose de la decomposition et BP observe (T5).
ecart_bp <- function(D) {
  if (is.null(D) || !nrow(D)) return(NA_real_)
  sxx <- D$sxx_e + D$sxx_i; sxy <- D$sxy_e + D$sxy_i
  max(abs(D$n * sxy^2 / (sxx * D$syy) - D[["obs:BP"]]), na.rm = TRUE)
}
# T6 : niveau des p non simulees (volet A).
PNN <- list(BP = "chi2(1)", FWb = "chi2(1)", FWr = "chi2(1)", Grubbs = "Student + Bonferroni (test_grubbs())", MinP = "Bonferroni N_t M", MinP4 = "Bonferroni N_t M")
pnn_de <- function(D, s) switch(s,
  BP = , FWb = , FWr = stats::pchisq(D[[paste0("obs:", s)]], 1, lower.tail = FALSE),
  Grubbs = D$gp,
  MinP = pmin(1, D$nt3 * D[["obs:MinP"]]),
  MinP4 = pmin(1, D$nt4 * D[["obs:MinP4"]]))
tableau_pnn <- function(DS) {
  L <- c("### T6 \u2014 niveau des p non simul\u00e9es (volet A) : \u03c7\u00b2(1) des variantes de #301, Bonferroni de #300, Grubbs", "",
         paste("Taux k / n de rejets p < \u03b1 sur les triangles admis, IC de Clopper-Pearson \u00e0 95 % ; r\u00e9f\u00e9rence **nominale \u03b1** (une p non simul\u00e9e n'a pas",
               "d'oracle) ; classe de #166 contre \u03b1 \u00e0 titre descriptif. Ces p ne sont **jamais retenues** (#181) : la p retenue est la p Monte-Carlo (T1)."), "",
         entete_md(c("Loi", "p non simul\u00e9e", "loi de r\u00e9f\u00e9rence", "n", "abs. 0,10", "taux [IC] 0,10", "classe vs 0,10", "abs. 0,05", "taux [IC] 0,05", "classe vs 0,05")))
  for (l in LOIS) {
    D <- adm_de(DS$tr[[paste0("A-", l)]]); if (is.null(D) || !nrow(D)) next
    for (s in names(PNN)) {
      p <- pnn_de(D, s)
      cs <- lapply(SEUILS, function(a) { x <- cellule(p, a, a); x$ref_lu <- a; x })
      L <- c(L, ligne_md(l, s, PNN[[s]], nrow(D), cs[[1]]$absentes, txt_lec(cs[[1]]), txt_classe_309(cs[[1]]), cs[[2]]$absentes, txt_lec(cs[[2]]), txt_classe_309(cs[[2]])))
    }
  }
  c(L, "")
}
# T7 : grandeurs pour Fj (par. 6).
STATS_FJ <- c("Origine", "PenteIntra", "Courbure", "HomogF", "ExpVar", "BP", "FWb", "FWr", "PenteRel")
SCEN_FJ <- c("H0", "CST10", "CST20", "EXP0", "EXP2", "DFI")
tableau_fj <- function(DS) {
  L <- c("### T7 \u2014 grandeurs pour Fj (par. 6 ; #308, #307)", "",
         "**(a) CV intra-colonne r\u00e9alis\u00e9 par colonne** (sd / moyenne de C(0..I\u2212j\u22121, j), moyenne sur les triangles admis de la cellule H0 de chaque plan) ; colonnes j = 0 \u00e0 5 (j = 6 : une cellule).", "",
         entete_md(c("Plan", "n", paste0("j = ", 0:5), "moyenne j = 0 \u00e0 3")))
  for (pl in PLANS) {
    D <- adm_de(DS$tr[[paste0("B-", pl, ".H0")]]); if (is.null(D) || !nrow(D)) next
    m <- vapply(CV_COLS[1:6], function(h) mean(D[[h]], na.rm = TRUE), 1)
    L <- c(L, ligne_md(pl, nrow(D), paste(vapply(m, num, "", d = 4), collapse = " | "), num(mean(m[1:4]), 4)))
  }
  r <- function(v) num(v, 3)
  cor_sp <- function(x, n) { y <- seq_len(n) - 1; c(stats::cor(y, x[seq_len(n)]), stats::cor(y, x[seq_len(n)], method = "spearman")) }
  L <- c(L, "", "**(b) Colin\u00e9arit\u00e9 volume / ann\u00e9e** (par. 2.2) : corr\u00e9lation de Pearson et de Spearman entre l'ann\u00e9e de survenance i et C(i, 0) de la premi\u00e8re colonne fix\u00e9e, lignes 0..7 puis 0..6 (celles qui portent un facteur de j = 0).", "",
        entete_md(c("Plan", "Pearson, lignes 0..7", "Spearman, lignes 0..7", "Pearson, lignes 0..6", "Spearman, lignes 0..6")))
  for (pl in PLANS) {
    a <- cor_sp(COL0[[pl]], 8); b <- cor_sp(COL0[[pl]], 7)
    L <- c(L, ligne_md(pl, r(a[1]), r(a[2]), r(b[1]), r(b[2])))
  }
  L <- c(L, "", "**(c) Puissance de M1, M2 et des variantes de BP contre CST, EXP et DFI selon le plan** (taux de rejet p_mc < 0,10 [IC de Clopper-Pearson], cellules des plans P1, P2, P3 ; \u2014 : cellule non mesur\u00e9e).", "",
        entete_md(c("Statistique", "Sc\u00e9nario", "P1", "P2", "P3")))
  cel <- function(pl, sc, s) { D <- adm_de(DS$tr[[paste0("B-", pl, ".", sc)]]); if (is.null(D) || !nrow(D)) "\u2014" else txt_lec(cellule(D[[paste0("p:", s)]], 0.10, NA_real_)) }
  for (s in STATS_FJ) for (sc in SCEN_FJ) L <- c(L, ligne_md(lib_stat(s), sc, cel("P1", sc, s), cel("P2", sc, s), cel("P3", sc, s)))
  L <- c(L, "", "**(d) Taux de rejet par colonne du t de Student de l'ordonn\u00e9e \u00e0 l'origine \u00e0 l'observ\u00e9** (mw_test_ordonnee_origine()$detail$p, p < \u03b1 ; colonnes j = 0 \u00e0 4), \u00e0 confronter aux effets minimaux d\u00e9tectables de #308 (20, 16, 26, 36 et 67 %).", "",
        entete_md(c("Cellule", "\u03b1", "n", paste0("j = ", 0:4))))
  for (i in seq_len(nrow(CELLULES))) {
    D <- adm_de(DS$tr[[paste0("B-", CELLULES$id[i])]]); if (is.null(D) || !nrow(D)) next
    for (a in SEUILS) L <- c(L, ligne_md(CELLULES$id[i], lib_ia(IA[match(a, SEUILS)]), nrow(D),
                                         paste(vapply(OR_COLS, function(h) { p <- D[[h]]; txt_lec(lecture(sum(is.finite(p) & p < a), nrow(D), NA_real_)) }, ""), collapse = " | ")))
  }
  c(L, "")
}
# T5 bis : refus, B effectif, retirage, durees.
tableau_refus <- function(DS) {
  L <- c("### T8 \u2014 triangles refus\u00e9s, B effectif, retirage de #257, dur\u00e9es", "",
         entete_md(c("Jeu", "triangles", "admis", "refus\u00e9s", "part refus\u00e9e", "motifs de refus", "B eff. minimal", "part des (triangle, statistique) \u00e0 B eff. < B",
                     "triangles \u00e0 triangle retir\u00e9 / plafond atteint", "dur\u00e9e par triangle admis (s) : moy. [m\u00e9d. ; max]")))
  for (cle in names(DS$tr)) {
    D <- DS$tr[[cle]]; A <- adm_de(D); rf <- D$statut == "refuse"
    mo <- if (any(rf)) { t <- table(D$motif[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun"
    S <- if (startsWith(cle, "A-")) STATS_A else STATS_B
    Bm <- as.matrix(A[, paste0("B:", S)])
    L <- c(L, ligne_md(lib_cellule(cle), nrow(D), nrow(A), sum(rf), num(mean(rf), 5), mo, if (nrow(A)) sprintf("%.0f", min(Bm)) else "\u2014",
                       if (nrow(A)) num(mean(Bm < B_COMB), 5) else "\u2014", sprintf("%d / %d", sum(A$cum == 1), sum(A$plaf == 1)),
                       if (nrow(A)) sprintf("%s [%s ; %s]", num(mean(A$duree), 1), num(stats::median(A$duree), 1), num(max(A$duree), 1)) else "\u2014"))
  }
  for (k in names(DS$ora)) {
    O <- DS$ora[[k]]; rf <- O$statut == "refuse"
    mo <- if (any(rf)) { t <- table(O$motif[rf]); paste(sprintf("%s (%d)", names(t), as.integer(t)), collapse = " ; ") } else "aucun"
    L <- c(L, ligne_md(sprintf("oracle %s", k), nrow(O), sum(O$statut == "admis"), sum(rf), num(mean(rf), 5), mo, "\u2014", "\u2014", "\u2014", "\u2014"))
  }
  c(L, "")
}

###############################################################################
#  EVALUATION MECANIQUE DE K0-c, K0-x, K0-t, K-301 ET K-300 (SANS CONCLURE)
###############################################################################
# K0-c (par. 2.2) : moyenne, pour j = 0 a 3, du CV intra-colonne realise sur
# les triangles admis de la cellule H0, dans [0,22 ; 0,28] ; evalue
# SEPAREMENT sur P2 et sur P3 (complement du 19/10/2026) ; P1 : descriptif.
eval_k0c <- function(DS) {
  r <- lapply(c("P2", "P3"), function(pl) {
    D <- adm_de(DS$tr[[paste0("B-", pl, ".H0")]])
    if (is.null(D) || !nrow(D)) return(list(plan = pl, ok = NA, m = NA_real_))
    m <- mean(vapply(CV_COLS[1:4], function(h) mean(D[[h]], na.rm = TRUE), 1))
    list(plan = pl, ok = m >= BORNES_K0C[1] && m <= BORNES_K0C[2], m = m)
  })
  list(r = r, ok = all(vapply(r, function(x) isTRUE(x$ok), logical(1))),
       txt = paste(vapply(r, function(x) sprintf("%s : %s (%s)", x$plan, num(x$m, 4), if (is.na(x$ok)) "non \u00e9valuable" else if (x$ok) "tenu" else "**NON TENU**"), ""), collapse = " ; "))
}
# K0-x (par. 2.3 et second complement du 19/10/2026) : sous P1, la colonne
# Calendrier de CAL7 et CAL4 a 0,10 est compatible avec le taux publie de la
# forme bas (T2 de #276, 401 / 1 000 et 319 / 1 000) : test exact de Fisher
# bilateral sur la table 2 x 2 (rejets, non-rejets) mesure / publie, tenu si
# p >= 0,025 par cellule (Bonferroni sur deux cellules). Les deux IC de
# Clopper-Pearson et la p sont imprimes.
eval_k0x <- function(DS) {
  r <- lapply(names(PUBLIE_K0X), function(cd) {
    D <- adm_de(DS$tr[[paste0("B-P1.", cd)]])
    if (is.null(D) || !nrow(D)) return(list(code = cd, ok = NA, p = NA_real_, txt = sprintf("%s : non \u00e9valuable", cd)))
    x <- cellule(D[["p:Calendrier"]], 0.10, NA_real_)
    k_pub <- PUBLIE_K0X[[cd]]
    pf <- stats::fisher.test(matrix(c(x$k, x$n - x$k, k_pub, N_PUBLIE_K0X - k_pub), 2))$p.value
    ok <- pf >= SEUIL_K0X
    list(code = cd, ok = ok, p = pf,
         txt = sprintf("%s : mesur\u00e9 %d / %d, %s ; publi\u00e9 %d / %d, %s ; Fisher bilat\u00e9ral p = %s (%s)", cd, x$k, x$n, txt_lec(x),
                       k_pub, N_PUBLIE_K0X, txt_lec(lecture(k_pub, N_PUBLIE_K0X, NA_real_)), fmt_p(pf), if (ok) "tenu" else "**NON TENU**"))
  })
  list(r = r, ok = all(vapply(r, function(x) isTRUE(x$ok), logical(1))),
       txt = paste(c(vapply(r, `[[`, "", "txt"), sprintf("seuil %s par cellule (Bonferroni sur deux cellules)", num(SEUIL_K0X, 3))), collapse = " ; "))
}
# K0-t (par. 2.5) : p_mc de BP et de Grubbs du volet A identiques aux colonnes
# pR:BP et pR:Grubbs du brut de #206, triangle par triangle (|ecart| <= 1e-12
# et B effectifs egaux) ; les triangles refuses doivent l'etre dans les deux.
eval_k0t <- function(DS, B) {
  f <- file.path(RACINE, BRUT_206_REL)
  if (B != 999) return(list(ok = NA, txt = "non \u00e9valuable (B \u2260 999)", dif = NULL, n = 0L))
  if (!file.exists(f)) return(list(ok = NA, txt = sprintf("brut de #206 introuvable (%s)", BRUT_206_REL), dif = NULL, n = 0L))
  br <- utils::read.delim(f, sep = "\t", header = TRUE, quote = "", colClasses = "character", check.names = FALSE)
  br <- br[br$type == "rep", , drop = FALSE]
  dif <- list(); n <- 0L; n_ref_diff <- 0L
  for (l in LOIS) {
    D <- DS$tr[[paste0("A-", l)]]; if (is.null(D)) next
    for (i in seq_len(nrow(D))) {
      k <- which(br$loi == l & br$b == as.character(D$b[i]))
      if (length(k) != 1L) { dif[[length(dif) + 1L]] <- data.frame(loi = l, b = D$b[i], s = "-", p_ref = NA_real_, p_new = NA_real_, B_ref = NA_real_, B_new = NA_real_, note = "triangle absent du brut de #206"); next }
      if (!identical(D$statut[i] == "admis", br$statut[k] == "admis")) { n_ref_diff <- n_ref_diff + 1L
        dif[[length(dif) + 1L]] <- data.frame(loi = l, b = D$b[i], s = "-", p_ref = NA_real_, p_new = NA_real_, B_ref = NA_real_, B_new = NA_real_, note = sprintf("statut %s contre %s", D$statut[i], br$statut[k])); next }
      if (D$statut[i] != "admis") next
      for (s in TEM_A) {
        pn <- D[[paste0("p:", s)]][i]; bn <- D[[paste0("B:", s)]][i]
        pr <- suppressWarnings(as.numeric(br[[paste0("pR:", s)]][k])); brf <- suppressWarnings(as.numeric(br[[paste0("BR:", s)]][k]))
        n <- n + 1L
        egal <- (is.na(pn) && is.na(pr)) || (!is.na(pn) && !is.na(pr) && abs(pn - pr) <= 1e-12)
        if (!(egal && identical(bn, brf))) dif[[length(dif) + 1L]] <- data.frame(loi = l, b = D$b[i], s = s, p_ref = pr, p_new = pn, B_ref = brf, B_new = bn, note = "")
      }
    }
  }
  dif <- if (length(dif)) do.call(rbind, dif) else NULL
  ok <- is.null(dif)
  list(ok = ok, dif = dif, n = n,
       txt = sprintf("%d (triangle, t\u00e9moin) compar\u00e9s (BP et Grubbs, volet A) : %s", n,
                     if (ok) "p_mc et B effectifs identiques \u00e0 pR: et BR: du brut de #206 (|\u00e9cart| \u2264 1e-12)" else sprintf("**%d diff\u00e9rence(s) \u00e0 expliquer**", nrow(dif))))
}
tableau_k0t <- function(K) {
  if (is.null(K$dif)) return(character(0))
  d <- K$dif
  c(sprintf("### Diff\u00e9rences K0-t avec le brut de #206 (%d%s)", nrow(d), if (nrow(d) > 60L) ", 60 premi\u00e8res" else ""), "",
    entete_md(c("Loi", "b", "T\u00e9moin", "p (#206)", "p (cette mesure)", "B effectif (#206)", "B effectif (cette mesure)", "note")),
    vapply(seq_len(min(nrow(d), 60L)), function(i) ligne_md(d$loi[i], d$b[i], d$s[i], fmt_p(d$p_ref[i]), fmt_p(d$p_new[i]), d$B_ref[i], d$B_new[i], d$note[i]), ""), "")
}
# K-301 (lettre du texte, TEXTE_PRECISIONS_309) a partir des classes de #166 du volet A.
classe_niveau <- function(NIV, loi, s, ia) {
  k <- which(vapply(NIV, function(x) x$cle == paste0("A-", loi) && x$s == s && x$ia == ia, logical(1)))
  if (length(k) != 1L) NULL else { x <- NIV[[k]]$c; x$ref_lu <- NIV[[k]]$ref; x }
}
cond_k301 <- function(NIV, v) {
  ok_ne <- TRUE; ko <- character(0)
  for (l in c("N", "E")) for (ia in IA) {
    c_ <- classe_niveau(NIV, l, v, ia)
    bon <- !is.null(c_) && c_$evaluable && (c_$classe %in% CLASSES[1:2] || (c_$disj && identical(c_$cote, "conservateur")))
    if (!bon) { ok_ne <- FALSE; ko <- c(ko, sprintf("%s %s : %s", l, lib_ia(ia), if (is.null(c_)) "absente" else txt_classe_309(c_))) }
  }
  ok_a <- TRUE
  for (ia in IA) {
    c_ <- classe_niveau(NIV, "A", v, ia)
    if (is.null(c_) || !c_$evaluable || (c_$disj && identical(c_$cote, "lib\u00e9ral"))) { ok_a <- FALSE; ko <- c(ko, sprintf("A %s : %s", lib_ia(ia), if (is.null(c_)) "absente" else txt_classe_309(c_))) }
  }
  list(ok = ok_ne && ok_a, ko = ko)
}
eval_k301 <- function(NIV) {
  r <- lapply(c("FWr", "FWb"), function(v) c(list(v = v), cond_k301(NIV, v)))
  retenue <- if (r[[1]]$ok) "FWr" else if (r[[2]]$ok) "FWb" else "arr\u00eat D2-Fi"
  list(r = r, retenue = retenue,
       txt = sprintf("%s ; \u00e9tat m\u00e9canique (sans conclure) : %s", paste(vapply(r, function(x) sprintf("%s : condition %s%s", x$v, if (x$ok) "remplie" else "non remplie",
               if (length(x$ko)) sprintf(" (%s)", paste(x$ko, collapse = " ; ")) else ""), ""), collapse = " ; "), retenue))
}
# K-300 (lectures du second complement du 19/10/2026).
# Couples (cellule, seuil) de la comparaison d'une paire : CEL4 et CEL6 x 0,10 et 0,05.
couples_paire <- function(DS, X, Y) {
  out <- list()
  for (cd in c("CEL4", "CEL6")) {
    D <- adm_de(DS$tr[[paste0("B-P1.", cd)]])
    for (a in SEUILS) {
      m <- if (is.null(D) || !nrow(D)) c(n01 = NA_real_, n10 = NA_real_, p = NA_real_) else mc_paire(D, c(X, Y), a)
      out[[length(out) + 1L]] <- data.frame(cellule = cd, seuil = a, n01 = m[["n01"]], n10 = m[["n10"]], p = m[["p"]],
                                            pour_X = isTRUE(m[["p"]] < 0.05 && m[["n01"]] > m[["n10"]]),
                                            pour_Y = isTRUE(m[["p"]] < 0.05 && m[["n01"]] < m[["n10"]]), stringsAsFactors = FALSE)
    }
  }
  do.call(rbind, out)
}
# \u00ab Le McNemar favorise X contre Y \u00bb : a CEL4 ET a CEL6, au moins un seuil donne
# p < 0,05 en faveur de X, et aucun des quatre couples ne le donne en faveur de Y.
favorise_xy <- function(DS, X, Y) {
  cp <- couples_paire(DS, X, Y)
  ok <- all(vapply(c("CEL4", "CEL6"), function(cd) any(cp$pour_X[cp$cellule == cd]), logical(1))) && !any(cp$pour_Y)
  list(ok = ok, couples = cp)
}
eval_k300 <- function(NIV, DS) {
  cands <- c("MinP", "MinP4", "TMax")
  elig_i <- function(v) {
    ko <- character(0)
    for (l in LOIS) for (ia in IA) {
      c_ <- classe_niveau(NIV, l, v, ia)
      if (is.null(c_) || !c_$evaluable || (c_$disj && identical(c_$cote, "lib\u00e9ral"))) ko <- c(ko, sprintf("%s %s : %s", l, lib_ia(ia), if (is.null(c_)) "absente" else txt_classe_309(c_)))
    }
    list(ok = !length(ko), ko = ko)
  }
  elig_ii <- function(v) {
    ko <- character(0)
    for (cd in c("CEL6", "CELx4")) {
      D <- adm_de(DS$tr[[paste0("B-P1.", cd)]])
      if (is.null(D) || !nrow(D)) { ko <- c(ko, sprintf("%s : non mesur\u00e9e", cd)); next }
      t10 <- c(sum(dec(D, v, 0.10)), sum(dec(D, "Grubbs", 0.10)))
      if (!(t10[1] >= t10[2])) ko <- c(ko, sprintf("%s 0,10 : %d contre %d (Grubbs)", cd, t10[1], t10[2]))
      t05 <- c(sum(dec(D, v, 0.05)), sum(dec(D, "Grubbs", 0.05))); m <- mc_paire(D, c(v, "Grubbs"), 0.05)
      if (!(t05[1] > t05[2] && m[["p"]] < 0.05 && m[["n01"]] > m[["n10"]])) ko <- c(ko, sprintf("%s 0,05 : %d contre %d (Grubbs), McNemar n01 / n10 = %d / %d, p = %s", cd, t05[1], t05[2], m[["n01"]], m[["n10"]], fmt_p(m[["p"]])))
    }
    list(ok = !length(ko), ko = ko)
  }
  el <- lapply(stats::setNames(cands, cands), function(v) { a <- elig_i(v); b <- elig_ii(v); list(v = v, i = a, ii = b, ok = a$ok && b$ok) })
  f_4m <- favorise_xy(DS, "MinP4", "MinP"); f_tm <- favorise_xy(DS, "TMax", "MinP"); f_t4 <- favorise_xy(DS, "TMax", "MinP4")
  eligibles <- cands[vapply(el, function(x) x$ok, logical(1))]
  tmax_domine <- "TMax" %in% eligibles && f_tm$ok && f_t4$ok
  mm <- intersect(c("MinP", "MinP4"), eligibles)
  choix <- if (!length(eligibles)) "arr\u00eat D2-Fi (aucun candidat \u00e9ligible ; Grubbs reste en l'\u00e9tat)" else
    if (tmax_domine) "TMax" else
    if (length(mm) == 2L) (if (f_4m$ok) "MinP4" else "MinP") else
    if (length(mm) == 1L) mm else
    "D2-Fi : TMax seul \u00e9ligible, sans dominer MinP et MinP4 (non retenu par K-300 ; d\u00e9cision du mainteneur)"
  list(el = el, eligibles = eligibles, choix = choix, f_4m = f_4m, f_tm = f_tm, f_t4 = f_t4, tmax_domine = tmax_domine)
}
txt_couples <- function(nom, f) {
  cp <- f$couples
  sprintf("%s : %s ; favoris\u00e9 : %s", nom, paste(sprintf("%s %s : %s / %s, p = %s", cp$cellule, vapply(cp$seuil, function(a) lib_ia(IA[match(a, SEUILS)]), ""), cp$n01, cp$n10, vapply(cp$p, fmt_p, "")), collapse = " ; "),
          if (f$ok) "oui" else "non")
}
txt_k300 <- function(K) {
  e <- vapply(K$el, function(x) sprintf("%s : (i) %s%s ; (ii) %s%s", x$v, if (x$i$ok) "remplie" else "non remplie",
                                         if (length(x$i$ko)) sprintf(" [%s]", paste(x$i$ko, collapse = " ; ")) else "",
                                         if (x$ii$ok) "remplie" else "non remplie", if (length(x$ii$ko)) sprintf(" [%s]", paste(x$ii$ko, collapse = " ; ")) else ""), "")
  sprintf("%s ; McNemar (n01 / n10 de X contre Y, par couple cellule et seuil) \u2014 %s \u2014 %s \u2014 %s ; TMax domine : %s ; \u00e9tat m\u00e9canique (sans conclure) : %s",
          paste(e, collapse = " ; "), txt_couples("MinP4 contre MinP", K$f_4m), txt_couples("TMax contre MinP", K$f_tm), txt_couples("TMax contre MinP4", K$f_t4),
          if (K$tmax_domine) "oui" else "non", K$choix)
}

###############################################################################
#  MODE --combiner
###############################################################################
MOTIF_FICHIERS <- "^(va-[NEA]-[0-9]{4}-[0-9]{4}|vb-P[123]-[A-Za-z0-9]+-[0-9]{4}-[0-9]{4}|ora-(A-[NEA]|B-P[23]))\\.txt$"
CLES_TRANCHES_ATTENDUES <- c(paste0("A-", LOIS), paste0("B-", CELLULES$id))
CLES_ORACLES_ATTENDUES <- c("ORA-A-N", "ORA-A-E", "ORA-A-A", "ORA-B-P2", "ORA-B-P3")
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
  cles_p <- vapply(parts, `[[`, "", "cle")
  for (g in unique(cles_p)) {
    pg <- parts[cles_p == g]
    if (length(unique(vapply(pg, `[[`, "", "parametres"))) != 1L) refuser("PARAMETRES differents entre les sorties de ", g)
  }
  for (p in parts) { e <- invariants_sortie(p); if (length(e)) refuser(p$nom, " : ", paste(e, collapse = " ; ")) }
  B_COMB <- unique(vapply(parts, `[[`, 1, "B"))
  if (length(B_COMB) != 1L || is.na(B_COMB)) refuser("B different entre les sorties ou illisible")
  # JOURNAL : md5 de chaque sortie, debit, empreinte (#231).
  TXT_JOURNAL <- "non fourni"; TXT_DEBIT <- "non fourni (--journal absent)"; TXT_EMP_J <- "non fourni (--journal absent)"
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
    TXT_DEBIT <- gsub("|", "\\|", ld[[1]][3], fixed = TRUE)
    TXT_EMP_J <- sprintf("%s, \u00e9gale \u00e0 celle des sorties (contr\u00f4le (i3))", le[[1]][2])
    TXT_JOURNAL <- sprintf("%s (md5 %s) : md5 des %d sorties conformes ; lignes du d\u00e9bit et de l'empreinte (#231) lues",
                           basename(OPT_JOURNAL), md5_fichier(OPT_JOURNAL), length(parts))
  }
  # Donnees par jeu et couverture.
  DS <- list(tr = list(), ora = list())
  ctx1 <- parts[[1]]$contexte
  for (cle in unique(cles_p)) {
    pg <- parts[cles_p == cle]
    if (pg[[1]]$mode == "tranche") {
      D <- en_table(do.call(c, lapply(pg, `[[`, "donnees")), cols_mode("tranche", pg[[1]]$volet))
      if (anyDuplicated(D$b)) refuser(cle, " : triangles en double entre tranches")
      DS$tr[[cle]] <- D[order(D$b), , drop = FALSE]
    } else {
      if (length(pg) > 1L) refuser(cle, " : plusieurs oracles")
      O <- en_table(pg[[1]]$donnees, COLS$oracle)
      DS$ora[[cle]] <- O[order(O$k), , drop = FALSE]
    }
  }
  couvre <- function(b, R) !anyDuplicated(b) && setequal(b, seq_len(R))
  R_ATTENDU <- c(stats::setNames(R_A, paste0("A-", names(R_A))), stats::setNames(CELLULES$R, paste0("B-", CELLULES$id)))
  if (!OPT_REDUIT) {
    if (!setequal(names(DS$tr), CLES_TRANCHES_ATTENDUES)) refuser("jeux de triangles (", paste(setdiff(CLES_TRANCHES_ATTENDUES, names(DS$tr)), collapse = ", "), " absents ; ",
                                                                  paste(setdiff(names(DS$tr), CLES_TRANCHES_ATTENDUES), collapse = ", "), " en trop) differents du plan complet")
    for (cle in names(DS$tr)) if (!couvre(DS$tr[[cle]]$b, R_ATTENDU[[cle]])) refuser(cle, " : les tranches ne couvrent pas 1..", R_ATTENDU[[cle]], " exactement une fois")
    if (!setequal(names(DS$ora), CLES_ORACLES_ATTENDUES)) refuser("oracles (", paste(setdiff(CLES_ORACLES_ATTENDUES, names(DS$ora)), collapse = ", "), " absents) differents du plan complet")
    for (k in names(DS$ora)) if (nrow(DS$ora[[k]]) != N0_SPEC || !couvre(DS$ora[[k]]$k, N0_SPEC)) refuser(k, " : oracle de ", nrow(DS$ora[[k]]), " triangles (", N0_SPEC, " attendus, une fois chacun)")
    if (B_COMB != 999) refuser("B = ", B_COMB, " : le plan complet exige B = 999 (--reduit pour un essai)")
  } else {
    for (cle in names(DS$tr)) if (!couvre(DS$tr[[cle]]$b, max(DS$tr[[cle]]$b))) refuser(cle, " (--reduit) : couverture de 1..", max(DS$tr[[cle]]$b), " incomplete ou multiple")
    for (k in names(DS$ora)) if (!couvre(DS$ora[[k]]$k, max(DS$ora[[k]]$k))) refuser(k, " (--reduit) : couverture de l'oracle incomplete ou multiple")
  }
  # (i3) et motifs de non-versionnement.
  COMMIT_COMB <- commit_depot(SCRIPT)
  EMPREINTES_COMB <- empreintes_code(SCRIPT, SPEC)
  EMP_COMB <- empreinte_sans_commentaires(file.path(RACINE, "R", "engine.R"))
  # Calculs.
  OR <- lapply(DS$ora, resume_oracle, B = B_COMB)
  NIV_A <- cellules_niveau(DS, OR, paste0("A-", LOIS), function(cle) STATS_A)
  NIV_H0 <- cellules_niveau(DS, OR, paste0("B-", c("P1.H0", "P2.H0", "P3.H0")), function(cle) STATS_B)
  K0C <- eval_k0c(DS); K0X <- eval_k0x(DS); K0T <- eval_k0t(DS, B_COMB)
  EXPL_K0T <- if (!is.na(OPT_EXPL_K0T)) { if (!file.exists(OPT_EXPL_K0T)) refuser("--explication-k0t introuvable"); readLines(OPT_EXPL_K0T, warn = FALSE, encoding = "UTF-8") } else character(0)
  K301 <- eval_k301(NIV_A); K300 <- eval_k300(NIV_A, DS)
  # Controle de T5 : n S_xy^2 / (S_xx S_yy) recompose de la decomposition = BP observe, a 1e-10 pres.
  ECART_BP <- vapply(DS$tr, ecart_bp, 1)
  if (any(ECART_BP > 1e-10, na.rm = TRUE)) refuser("T5 : n S_xy^2 / (S_xx S_yy) differe de BP observe de plus de 1e-10 (jeu(x) ", paste(names(ECART_BP)[which(ECART_BP > 1e-10)], collapse = ", "), ")")
  k0t_ok <- isTRUE(K0T$ok) || (is.na(K0T$ok)) || (identical(K0T$ok, FALSE) && length(EXPL_K0T) > 0L)
  nv <- c(motifs_non_versionnable(ctx1[["commit"]], ctx1[["empreintes"]]),
          motifs_non_versionnable(COMMIT_COMB, EMPREINTES_COMB, "de la combinaison"),
          if (!startsWith(ctx1[["empreinte_sc"]], EMP_COMB)) sprintf("empreinte (#231) de la combinaison %s diff\u00e9rente de celle des sorties", EMP_COMB),
          if (!identical(ctx1[["essai"]], "non")) "sorties provisoires (--provisoire, --essai, --B, --N0 r\u00e9duit)",
          if (OPT_REDUIT) "param\u00e8tres r\u00e9duits (--reduit)",
          if (!isTRUE(K0C$ok)) "K0-c non tenu ou non \u00e9valuable",
          if (!isTRUE(K0X$ok)) "K0-x non tenu ou non \u00e9valuable",
          if (!k0t_ok) "K0-t non tenu : diff\u00e9rences avec le brut de #206 \u00e0 expliquer (--explication-k0t FICHIER)",
          if (is.na(K0T$ok)) "K0-t non \u00e9valuable")
  if (OPT_ECRIRE && length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "))
  # Valeurs brutes : lignes de donnees des tranches (l'echantillon oracle n'est pas versionne ; md5 de ses valeurs en T0).
  cols_B <- COLS$tranche_B
  COLS_BRUT <- c("type", "cle", cols_B)
  brut_tr <- unlist(lapply(sort(names(DS$tr)), function(cle) {
    pg <- parts[cles_p == cle]; volet <- pg[[1]]$volet
    x <- do.call(c, lapply(pg, `[[`, "donnees")); x <- x[order(as.integer(vapply(x, `[`, "", 1L)))]
    vapply(x, function(r) { v <- stats::setNames(rep("NA", length(cols_B)), cols_B); v[cols_mode("tranche", volet)] <- r
      paste(c("rep", cle, v), collapse = "\t") }, "")
  }))
  BRUT <- c(paste(COLS_BRUT, collapse = "\t"), brut_tr)
  F_BRUT_TMP <- tempfile("mw309_brut_", fileext = ".tsv")
  con <- file(F_BRUT_TMP, open = "wb"); writeLines(utf8(BRUT), con, useBytes = TRUE); close(con)
  MD5_BRUT <- md5_fichier(F_BRUT_TMP)
  # T0
  tr_noms <- names(DS$tr)
  plan_txt <- sprintf("volet A : %s (oracle N0 = %s par loi) ; volet B : %s ; oracles P2 et P3 : N0 = %s ; l'oracle de P1 est celui de la loi N du volet A",
                      paste(sprintf("%s R = %d", sub("^A-", "", intersect(paste0("A-", LOIS), tr_noms)), vapply(intersect(paste0("A-", LOIS), tr_noms), function(k) nrow(DS$tr[[k]]), 1L)), collapse = ", "),
                      paste(unique(vapply(DS$ora, nrow, 1L)), collapse = "/"),
                      paste(sprintf("%s R = %d", sub("^B-", "", intersect(paste0("B-", CELLULES$id), tr_noms)), vapply(intersect(paste0("B-", CELLULES$id), tr_noms), function(k) nrow(DS$tr[[k]]), 1L)), collapse = ", "),
                      paste(unique(vapply(DS$ora[intersect(c("ORA-B-P2", "ORA-B-P3"), names(DS$ora))], nrow, 1L)), collapse = "/"))
  refus_txt <- paste(vapply(tr_noms, function(k) { r <- mean(DS$tr[[k]]$statut == "refuse")
    sprintf("%s %d / %d (%s)%s", k, sum(DS$tr[[k]]$statut == "refuse"), nrow(DS$tr[[k]]), num(r, 5), if (r > SEUIL_REFUS) " **SIGNAL\u00c9**" else "") }, ""), collapse = " ; ")
  ctl_n <- sum(vapply(DS$tr, function(D) sum(D$ctl %in% c("OK", "ECHEC")), 1)); ctl_ok <- sum(vapply(DS$tr, function(D) sum(D$ctl == "OK"), 1))
  refus_ora <- paste(vapply(names(DS$ora), function(k) { r <- mean(DS$ora[[k]]$statut == "refuse")
    sprintf("%s %d / %d (%s)%s", k, sum(DS$ora[[k]]$statut == "refuse"), nrow(DS$ora[[k]]), num(r, 5), if (r > SEUIL_REFUS) " **SIGNAL\u00c9**" else "") }, ""), collapse = " ; ")
  t0 <- c(entete_md(c("Grandeur", "Valeur")),
          vapply(CLES_COMMUNES, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], ctx1[[k]]), ""),
          ligne_md("Locale LC_CTYPE des sorties (origine \u2192 travail)", paste(unique(vapply(parts, function(p) p$contexte[["locale"]], "")), collapse = " ; ")),
          ligne_md("Plan et effectifs R (par. 2.5, 2.6 et compl\u00e9ment du 19/10/2026)", plan_txt),
          ligne_md("D\u00e9bit (ligne du JOURNAL)", TXT_DEBIT),
          ligne_md("Triangles refus\u00e9s par jeu (DGP, par. 2.2 : signal\u00e9 au-del\u00e0 de 1 %)", refus_txt),
          ligne_md("Contr\u00f4le (i2) en tranche (b multiple de 50 : bootstrap plein rejou\u00e9 sans injection)", sprintf("%d triangle(s) contr\u00f4l\u00e9(s), %d identique(s) (identical()) pour p_mc, B effectif, motif et stats_obs des cl\u00e9s communes", ctl_n, ctl_ok)),
          ligne_md("Triangles d'oracle refus\u00e9s", if (length(DS$ora)) refus_ora else "\u2014 (oracle absent)"),
          ligne_md("\u03c1 approch\u00e9 (plus de 1 % de statistiques oracle non finies pour la statistique)", if (!length(DS$ora)) "\u2014 (oracle absent)" else liste_cel(cles_rho_approche(OR), 39)),
          ligne_md("CV intra-colonne r\u00e9alis\u00e9 par colonne (moyenne sur les triangles admis de la cellule H0 de chaque plan ; j = 0 \u00e0 5 ; d\u00e9tail au T7 (a))",
                   paste(vapply(PLANS, function(pl) { D <- adm_de(DS$tr[[paste0("B-", pl, ".H0")]])
                     if (is.null(D) || !nrow(D)) sprintf("%s : \u2014", pl) else sprintf("%s : %s", pl, paste(vapply(CV_COLS[1:6], function(h) num(mean(D[[h]], na.rm = TRUE), 4), ""), collapse = " ; ")) }, ""), collapse = " / ")),
          ligne_md("K0-c (CV r\u00e9alis\u00e9, moyenne de j = 0 \u00e0 3 dans [0,22 ; 0,28], P2 et P3 s\u00e9par\u00e9ment)", K0C$txt),
          ligne_md("K0-x : test exact de Fisher bilat\u00e9ral, seuil 0,025 par cellule (Bonferroni sur deux cellules) ; Calendrier de CAL7 et CAL4 \u00e0 0,10 contre le T2 de #276", K0X$txt),
          ligne_md("K0-t (BP et Grubbs du volet A : identiques au brut de #206)", K0T$txt),
          ligne_md("Explication de K0-t (--explication-k0t)", if (length(EXPL_K0T)) nettoyer_champ(paste(EXPL_K0T, collapse = " ")) else "\u2014"),
          ligne_md("Facteur confondant de P2 contre P3 (compl\u00e9ment du 19/10/2026)", "la diff\u00e9rence de profil de CV r\u00e9alis\u00e9 entre P2 et P3 (T7 (a)) est un facteur confondant r\u00e9siduel de la comparaison P2 / P3 ; K0-c y est \u00e9valu\u00e9 s\u00e9par\u00e9ment"),
          ligne_md("Sorties combin\u00e9es (nom, md5, plage)",
                   paste(vapply(parts, function(p) sprintf("%s %s (%s %s, %d-%d%s)", p$nom, p$md5, p$mode, p$cle, p$debut, p$fin,
                                                           if (length(p$reprise)) sprintf(", reprise : %s", p$reprise) else ""), ""), collapse = " ; ")),
          ligne_md("\u00c9chantillons oracle (non versionn\u00e9s, r\u00e9g\u00e9n\u00e9rables par leurs graines) : md5 des valeurs",
                   if (length(DS$ora)) paste(vapply(parts[vapply(parts, function(p) p$mode == "oracle", logical(1))], function(p) sprintf("%s : %s (fichier %s)", p$cle, p$md5_valeurs, p$md5), ""), collapse = " ; ") else "aucun"),
          ligne_md("JOURNAL", TXT_JOURNAL),
          ligne_md("Journaux versionn\u00e9s de la mesure (second compl\u00e9ment du 19/10/2026)",
                   sprintf("docs/tableaux/%s (copie du JOURNAL) ; docs/tableaux/%s (journal de la combinaison)", NOMS_SORTIE[["journal"]], NOMS_SORTIE[["jcomb"]])),
          ligne_md("Commit des sorties et commit de la combinaison", "un m\u00eame commit est exig\u00e9 ENTRE LES SORTIES (contexte \u00ab commit \u00bb identique), non pour la combinaison, qui peut \u00eatre faite \u00e0 un autre commit, cit\u00e9 ci-dessous ; l'empreinte sans commentaires de R/engine.R (#231) doit \u00eatre la m\u00eame dans les sorties et \u00e0 la combinaison"),
          ligne_md("Empreinte sans commentaires (#231) du JOURNAL", TXT_EMP_J),
          ligne_md("Commit de la combinaison", COMMIT_COMB), ligne_md("Empreintes md5 du combinateur (moteur, outils, script)", EMPREINTES_COMB),
          ligne_md("Empreinte sans commentaires de R/engine.R \u00e0 la combinaison (#231)", EMP_COMB),
          ligne_md("Valeurs brutes", sprintf("%s : md5 %s, %d lignes (copie hors du d\u00e9p\u00f4t : --brut)", NOMS_SORTIE[["brut"]], MD5_BRUT, length(BRUT) - 1L)),
          ligne_md("Versionnable (--ecrire)", if (length(nv)) paste("non :", paste(nv, collapse = " ; ")) else "oui"),
          ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", sprintf("OK dans les %d sorties ; invariants (d) relus sur les champs ; couvertures exactes%s ; (i3) : empreinte \u00e9gale dans les sorties%s",
                                                          length(parts), if (OPT_REDUIT) " (--reduit : couverture lue sur les sorties)" else "",
                                                          if (startsWith(ctx1[["empreinte_sc"]], EMP_COMB)) " et \u00e0 la combinaison" else ", DIFF\u00c9RENTE \u00e0 la combinaison")))
  titre <- "## Mesure #309 : puissance \u00e0 T = 8 des lignes M1 \u00e0 M4 de Merz-W\u00fcthrich et niveau des candidats de #300 et #301"
  aide <- c("### Aide \u00e0 la lecture", "",
            paste("Statut : **constat de simulation sous un plan** (mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2, g\u00e9om\u00e9trie 8 \u00d7 8, plans de dispersion P1, P2, P3), pas un",
                  "r\u00e9sultat g\u00e9n\u00e9ral ; il ne se transpose ni \u00e0 une autre g\u00e9om\u00e9trie de triangle ni \u00e0 un autre param\u00e9trage. Aucun th\u00e9or\u00e8me ne couvre ces tests",
                  "bootstrap \u00e0 T = 8. IC : Clopper-Pearson \u00e0 95 %, incertitude Monte-Carlo sur le taux (fonction de R), distincte de l'erreur de \u03c1",
                  "(fonction de N0) et de err_mc (fonction de B = 999). Bande de Bradley : convention de lecture (#166), pas th\u00e9or\u00e8me. La puissance est",
                  "lue **pour les sc\u00e9narios, param\u00e8tres et plans fix\u00e9s** (\u03b8 = 0,10, \u03b3 = 0,20, \u03bb = 4 et 6, cellule vis\u00e9e (2, 1) ; \u03ba = 3,4 pour P2) ; les statistiques",
                  "FWb, FWr, MinP, MinP4, TMax sont des **candidats mesur\u00e9s** de #301 et #300, PenteRel celui de #307 (Q-D1-Fi-9) : aucune d\u00e9cision n'est prise ici",
                  "(point d'arr\u00eat D2-Fi)."), "")
  crit <- c("### Crit\u00e8res K-301 et K-300, fix\u00e9s avant toute ex\u00e9cution", "",
            "Texte recopi\u00e9 tel quel de la sp\u00e9cification (par. 2.7), identique dans le script (TEXTE_CRITERES_309, contr\u00f4le (t)) et au T0 ; \u00e9valu\u00e9 m\u00e9caniquement, **sans conclure**.", "",
            paste(">", TEXTE_CRITERES_309), "",
            "Pr\u00e9cisions d'impl\u00e9mentation de l'\u00e9valuation m\u00e9canique (fix\u00e9es avant ex\u00e9cution, distinctes du texte ci-dessus, soumises \u00e0 actuary) :", "",
            paste("-", TEXTE_PRECISIONS_309), "")
  evalu <- c("### \u00c9valuation m\u00e9canique de K0-c, K0-x, K0-t, K-301 et K-300 (sans conclusion)", "",
             entete_md(c("Crit\u00e8re", "\u00c9tat m\u00e9canique", "D\u00e9tail")),
             ligne_md("K0-c", if (isTRUE(K0C$ok)) "tenu" else "**non tenu**", K0C$txt),
             ligne_md("K0-x (Fisher bilat\u00e9ral, seuil 0,025 par cellule)", if (isTRUE(K0X$ok)) "tenu" else "**non tenu ou non \u00e9valuable**", K0X$txt),
             ligne_md("K0-t", if (isTRUE(K0T$ok)) "tenu" else if (is.na(K0T$ok)) "non \u00e9valuable" else "**non tenu**", K0T$txt),
             ligne_md("K-301", K301$retenue, K301$txt),
             ligne_md("K-300", K300$choix, txt_k300(K300)), "")
  sortie <- c(sprintf("%s -- combinaison de %d sortie(s)", titre, length(parts)), "",
              "### T0 \u2014 provenance (identique dans toutes les sorties, v\u00e9rifi\u00e9)", "", t0, "", aide, crit, evalu, tableau_k0t(K0T),
              tableau_rho(OR),
              tableau_niveau(NIV_A, "### T1 \u2014 niveau des candidats (volet A : loi \u00d7 statistique \u00d7 seuil)",
                             paste("Par seuil : n triangles admis, p absentes (compt\u00e9es comme non-rejet), \u03c1 (taille liss\u00e9e de l'oracle de la loi), k rejets (p_mc < \u03b1), taux k / n et IC de",
                                   "Clopper-Pearson \u00e0 95 % (5 d\u00e9cimales), classe de #166 contre \u03c1 (c\u00f4t\u00e9 en gras si l'IC est disjoint de la bande [\u03c1/2 ; 3\u03c1/2]),",
                                   "taux sur les seules p d\u00e9finies (descriptif). Plan et graines de #206 ; catalogue r\u00e9duit {BP, Grubbs, FWb, FWr, MinP, MinP4, TMax} et PenteRel.")),
              tableau_niveau(NIV_H0, "### T1 bis \u2014 niveau sous H0 de chaque plan (volet B, loi N : P1, P2, P3), les 19 statistiques",
                             "M\u00eame lecture ; \u03c1 de P1 : oracle de la loi N du volet A (m\u00eame DGP) ; \u03c1 de P2 et de P3 : leur oracle propre."),
              tableau_puissance(DS), tableau_mcnemar(DS), tableau_designation(DS), tableau_bp(DS), tableau_pnn(DS), tableau_fj(DS), tableau_refus(DS))
  ecrire_console(sortie)
  ecrire <- function(f, lignes) { con <- file(f, open = "wb"); writeLines(utf8(lignes), con, useBytes = TRUE); close(con) }
  copier <- function(src, f, md5_attendu, ecraser = FALSE) {
    if (!file.copy(src, f, overwrite = ecraser) || !identical(md5_fichier(f), md5_attendu)) refuser("copie refusee ou md5 different : ", basename(f))
    message("ecrit (md5 ", md5_attendu, ") : ", basename(f))
  }
  journal_comb <- function(sorties) c("# Journal de la combinaison de la mesure #309", "",
    sprintf("- D\u00e9but (UTC) : %s ; fin (UTC) : %s", format(T_COMB0, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
    sprintf("- Commande : Rscript %s %s", SCRIPT, paste(vapply(ARGS, function(a) if (grepl("/", a, fixed = TRUE) || file.exists(a) || dir.exists(a)) basename(a) else a, ""), collapse = " ")),
    sprintf("- Commit de la combinaison : %s", COMMIT_COMB), sprintf("- Plateforme : %s", plateforme_calcul()),
    sprintf("- Locale LC_CTYPE : %s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL),
    sprintf("- Empreinte sans commentaires : %s", EMP_COMB),
    sprintf("- JOURNAL de la mesure : %s", TXT_JOURNAL),
    "- Sorties lues (toutes INTEGRITE OK, FIN en derni\u00e8re ligne, couvertures exactes, aucun refus) :",
    paste0("  - ", vapply(parts, function(p) sprintf("%s md5 %s", p$nom, p$md5), "")),
    "- Fichiers \u00e9crits :", paste0("  - ", sorties), "")
  # Les quatre contenus (tableau, valeurs brutes, copie du JOURNAL, journal de la
  # combinaison) sont PREPARES puis CONTROLES (chemin absolu ou /tmp refuse, D-a de
  # #242) AVANT toute ecriture : un refus ne laisse aucun jeu partiel de fichiers.
  ecr_voulue <- OPT_ECRIRE || !is.na(OPT_SORTIE)
  rem <- NULL
  if (OPT_ECRIRE) {
    nv1 <- motifs_non_versionnable(commit_depot(SCRIPT), empreintes_code(SCRIPT, SPEC), "de la combinaison")
    if (length(nv1)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv1, collapse = " ; "))
    rem <- garde_ecrasement(CIBLES, OPT_REMPLACER, RACINE)
  }
  md_final <- if (OPT_ECRIRE) inserer_t0(sortie, c(ligne_remplacement(rem, CIBLES[["md"]]), ligne_remplacement(rem, CIBLES[["brut"]]),
                                                   ligne_remplacement(rem, CIBLES[["journal"]]), ligne_remplacement(rem, CIBLES[["jcomb"]]))) else sortie
  j_lignes <- if (!is.na(OPT_JOURNAL)) readLines(OPT_JOURNAL, warn = FALSE, encoding = "UTF-8") else character(0)
  ecr_md5 <- c(sprintf("%s md5 %s", NOMS_SORTIE[["md"]], md5_lignes(md_final)), sprintf("%s md5 %s", NOMS_SORTIE[["brut"]], MD5_BRUT),
               if (!is.na(OPT_JOURNAL)) sprintf("%s md5 %s", NOMS_SORTIE[["journal"]], md5_fichier(OPT_JOURNAL)))
  jc <- journal_comb(ecr_md5)
  abs_l <- chemins_absolus(c(md_final, j_lignes, jc))
  if (length(abs_l)) {
    message("--combiner : chemin absolu ou /tmp dans le tableau, le JOURNAL ou le journal de la combinaison (D-a de #242) : ", length(abs_l), " ligne(s)")
    if (ecr_voulue) refuser("ecriture refusee : chemin absolu ou /tmp dans un fichier a ecrire (rien d'ecrit)")
  }
  if (OPT_ECRIRE) {
    copier(F_BRUT_TMP, OPT_BRUT, MD5_BRUT)
    copier(F_BRUT_TMP, CIBLES[["brut"]], MD5_BRUT, ecraser = TRUE)
    ecrire(CIBLES[["md"]], md_final)
    copier(OPT_JOURNAL, CIBLES[["journal"]], md5_fichier(OPT_JOURNAL), ecraser = TRUE)
    ecrire(CIBLES[["jcomb"]], jc)
    if (!identical(md5_fichier(CIBLES[["md"]]), md5_lignes(md_final))) refuser("md5 du tableau ecrit different de celui annonce au journal de la combinaison")
    message("ecrit : ", paste(NOMS_SORTIE, collapse = ", "))
  } else if (!is.na(OPT_SORTIE) || !is.na(OPT_BRUT)) {
    # Ecriture par lot (#248) : tous produits dans des dossiers temporaires
    # voisins de leurs cibles, md5 controle, puis renommes ; une erreur ne
    # laisse aucun fichier.
    lot <- ecriture_par_lot()
    tryCatch({
      if (!is.na(OPT_BRUT)) lot$copier(F_BRUT_TMP, OPT_BRUT, MD5_BRUT)
      if (!is.na(OPT_SORTIE)) {
        cib <- file.path(OPT_SORTIE, NOMS_SORTIE); names(cib) <- names(NOMS_SORTIE)
        lot$copier(F_BRUT_TMP, cib[["brut"]], MD5_BRUT)
        lot$ecrire(cib[["md"]], md_final)
        if (!is.na(OPT_JOURNAL)) lot$copier(OPT_JOURNAL, cib[["journal"]], md5_fichier(OPT_JOURNAL))
        lot$ecrire(cib[["jcomb"]], jc)
      }
      lot$valider()
    }, error = function(e) { lot$annuler(); refuser("ecriture par lot annulee, rien d'ecrit : ", conditionMessage(e)) })
    for (f in lot$cibles()) message("ecrit (md5 ", md5_fichier(f), ") : ", basename(f))
  }
  unlink(F_BRUT_TMP)
  quit(status = 0L)
}

###############################################################################
#  PLAN DES TRANCHES (--lister)
###############################################################################
# Une ligne par sortie : nom de la sortie, TAB, arguments (format de
# tests/outillage/lancer_tranches.sh). Ordre de priorite : oracles et volet A
# (niveau des candidats, qui conditionne #301 et #300), puis le volet B (P1,
# puis P2 avec son oracle, puis P3 avec son oracle).
plan_tranches <- function() {
  blocs <- function(R) lapply(seq(1, R, by = TAILLE_TRANCHE), function(x) c(x, min(x + TAILLE_TRANCHE - 1, R)))
  out <- sprintf("ora-A-%s.txt\t--oracle --volet A --loi %s", LOIS, LOIS)
  for (l in LOIS) for (x in blocs(R_A[[l]])) out <- c(out, sprintf("va-%s-%04d-%04d.txt\t--volet A --loi %s --b %d:%d", l, x[1], x[2], l, x[1], x[2]))
  for (pl in PLANS) {
    if (pl != "P1") out <- c(out, sprintf("ora-B-%s.txt\t--oracle --volet B --plan %s", pl, pl))
    for (i in which(CELLULES$plan == pl)) for (x in blocs(CELLULES$R[i]))
      out <- c(out, sprintf("vb-%s-%s-%04d-%04d.txt\t--volet B --plan %s --cellule %s --b %d:%d", pl, CELLULES$code[i], x[1], x[2], pl, CELLULES$code[i], x[1], x[2]))
  }
  out
}
if (MODE == "lister") {
  writeLines(plan_tranches())
  quit(status = 0L)
}

###############################################################################
#  TEXTES DE PROVENANCE (DGP, configuration, graines)
###############################################################################
virgule <- function(x) sub(".", ",", x, fixed = TRUE)
TXT_DGP <- sprintf("mod\u00e8le de Mack ajust\u00e9 \u00e0 reserve2 (mw_ajuster(), tests/donnees/triangle_mw.csv), I = J = %d ; f\u0302 = (%s) ; \u03c3\u0302\u00b2 = (%s), non r\u00e9estim\u00e9s sous P2 et P3 ; plans de la premi\u00e8re colonne fix\u00e9e (lignes 0..7) : P1 = (%s), P2 = C\u0304\u2080 + %s (C\u2080 \u2212 C\u0304\u2080) = (%s), P3 = P2[c(2, 8, 6, 4, 3, 5, 7, 1)] (\u03c0 = (1, 7, 5, 3, 2, 4, 6, 0)) = (%s) ; colonnes d\u00e9g\u00e9n\u00e9r\u00e9es de reserve2 : %s ; loi N (stats::rnorm) sous le volet B ; volet A : N, E (loi uniforme sur les %d valeurs de .mw_pool_residus(aj0, jd0) divis\u00e9es par leur \u00e9cart-type de population %s), A ((G \u2212 2)/\u221a2, G ~ Gamma(2) par inversion) ; g\u00e9n\u00e9rateurs gen_triangle_h0() (H0 de #206) et gen_triangle_scen() (CST, EXP, DFI) ; sc\u00e9narios d'incr\u00e9ments recumul\u00e9s CAL7, CAL4 (\u03b8 = %s), DCAL (1,05^max(0, t \u2212 3)), LIG (\u00d7 1,5 pour j \u2265 2, ligne 2), CEL4 et CEL6 (\u03bb = 4 et 6), CELx4 ; CST10, CST20 (\u03b4 = %s), EXP0, EXP2 (\u03ba = 0 ; 2), DFI (\u03b3 = %s) ; cellule vis\u00e9e (i, j) = (%d, %d)",
                   AJ0$I, paste(virgule(sprintf("%.5f", AJ0$f)), collapse = " ; "), paste(virgule(sprintf("%.5g", AJ0$sigma2)), collapse = " ; "),
                   paste(virgule(sprintf("%.4f", C0_P1)), collapse = " ; "), virgule(format(KAPPA_P2)), paste(virgule(sprintf("%.4f", C0_P2)), collapse = " ; "),
                   paste(virgule(sprintf("%.4f", C0_P3)), collapse = " ; "), if (length(JD0)) paste(JD0, collapse = ", ") else "aucune",
                   length(POOL0), num(SD_POP0, 4), virgule(format(THETA)), paste(virgule(format(DELTA)), collapse = " ; "), virgule(format(GAMMA)),
                   CIBLE_CEL[["i"]], CIBLE_CEL[["j"]])
TXT_CONFIG <- sprintf("m\u00e9thode %s, segment %d de l'annexe %s ; B = %d (donn\u00e9e du test calibr\u00e9) ; seuils mesur\u00e9s 0,10 et 0,05 ; chemin mesur\u00e9 mw_bootstrap(aj, B, seed) avec entr\u00e9es des candidats inject\u00e9es dans MW_CATALOGUE_MC (restaur\u00e9 par finally), catalogue complet (volet B : 13 cl\u00e9s + 6 candidats) ou r\u00e9duit (volet A : BP, Grubbs + 6 candidats) ; la boucle de tirage n'est pas recopi\u00e9e ; B_MIN_DEGENERESCENCE = %d ; FACTEUR_B_MAX_MW = %g ; un bootstrap plein est rejou\u00e9 sans injection pour b multiple de %d (contr\u00f4le (i2))",
                      METHODE, SEGMENT, ANNEXE, B_BOOT, B_MIN_DEGENERESCENCE, FACTEUR_B_MAX_MW, CTL_PERIODE)
TXT_GRAINES <- sprintf("volet A (graines de #206) : triangle b, loi \u2113 : %.0f + %.0f (\u2113 \u2212 1) + b ; bootstrap : %.0f + %.0f (\u2113 \u2212 1) + b ; oracle k : %.0f + %.0f (\u2113 \u2212 1) + k ; \u2113 = 1 (N), 2 (E), 3 (A) ; volet B, P1 et P2, cellule de rang c (P1 : 1 \u00e0 13, P2 : 14 \u00e0 19, dans l'ordre de CELLULES) : triangle %.0f + %.0f (c \u2212 1) + b, bootstrap %.0f + %.0f (c \u2212 1) + b, oracle de P2 : %.0f + k ; P3, c3 = 1 (H0), 2 (CST20), 3 (DFI) : triangle %.0f + %.0f (c3 \u2212 1) + b, bootstrap %.0f + %.0f (c3 \u2212 1) + b, oracle %.0f + k ; contr\u00f4les sur reserve2 : %.0f ; tous les tirages sous engine_sous_graine()",
                       GRAINE_TRI, PAS_LOI, GRAINE_BOOT, PAS_LOI, GRAINE_ORA, PAS_LOI_ORA,
                       GRAINES_B$P1[["tri"]], PAS_CELLULE, GRAINES_B$P1[["boot"]], PAS_CELLULE, GRAINE_ORA_B[["P2"]],
                       GRAINES_B$P3[["tri"]], PAS_CELLULE, GRAINES_B$P3[["boot"]], PAS_CELLULE, GRAINE_ORA_B[["P3"]], GRAINE_R2)

###############################################################################
#  CONTROLES GENERAUX SUR reserve2 : (t), (b), (copie), (graines), (g), (sc),
#  (i3), (a), (c), (i2)
###############################################################################
# Valeurs des candidats sur reserve2 (graine 20260831, B = 999) recopiees des
# par. 3.2 et 4.4 de la specification : statistique (4 decimales) et p_mc (3).
ATTENDU_C <- list(BP = c(6502, 103), FWb = c(17598, 214), FWr = c(14373, 285), MinP = c(1033, 944), MinP4 = c(1033, 898), TMax = c(27242, 944))
ATTENDU_MIN <- list(i = 0L, j = 2L, t = -2.318, nt = 25L, nt4 = 22L)
TXT_SPEC_309 <- if (file.exists(file.path(RACINE, SPEC))) readLines(file.path(RACINE, SPEC), warn = FALSE, encoding = "UTF-8") else character(0)
present_bloc <- function(bloc) {
  i <- which(TXT_SPEC_309 == bloc[1])
  any(vapply(i, function(k) k + length(bloc) - 1L <= length(TXT_SPEC_309) && identical(TXT_SPEC_309[k:(k + length(bloc) - 1L)], bloc), logical(1)))
}
B_REF <- 999   # reserve2 et sa reference sont a B = 999, quel que soit --B (mise au point)
controles_generaux <- function(volets) {
  controle(present_bloc(TEXTE_CRITERES_309),
           sprintf("(t) texte des crit\u00e8res K-301 et K-300 (%d lignes) identique \u00e0 %s (md5 %s)", length(TEXTE_CRITERES_309), SPEC, md5_fichier(file.path(RACINE, SPEC))))
  controle(NS == 13L && setequal(CLES, names(SENS_SPEC)) && identical(unname(QUEUE[names(SENS_SPEC)]), unname(SENS_SPEC)) &&
             identical(names(QUEUE_CAND), CAND) && all(names(CAT_ORIG) == CLES),
           sprintf("(b) %d cl\u00e9s lues dans MW_CATALOGUE_MC (%s), sens conformes \u00e0 ceux de ce moteur (Calendrier : bas depuis #276) ; candidats %s", NS,
                   paste(sprintf("%s %s", CLES, QUEUE), collapse = ", "), paste(sprintf("%s %s", CAND, QUEUE_CAND), collapse = ", ")))
  cc <- controle_copie(); controle(cc$ok, paste("(copie)", cc$txt))
  cgr <- controle_graines(); controle(cgr$ok, paste("(graines)", cgr$txt))
  cg <- controle_g(); controle(cg$ok, paste("(g)", cg$txt))
  csc <- controle_scenarios(); controle(csc$ok, paste("(sc)", csc$txt))
  TXT_I3 <- sprintf("empreinte sans commentaires de R/engine.R %s ; md5 de R/engine.R %s, de %s %s, de tests/outils_tests.R %s",
                    EMPREINTE_SC, MD5_MOTEUR, SCRIPT, md5_fichier(FICHIER_SCRIPT), md5_fichier(file.path(DOSSIER_SCRIPT, "outils_tests.R")))
  controle(grepl("^[0-9a-f]{32}$", EMPREINTE_SC), paste("(i3)", TXT_I3))
  # (a) reserve2 contre la reference, et bootstraps injectes de (c) et (i2) :
  # taches independantes, calculees en parallele quand --coeurs > 1 (le
  # catalogue injecte vit dans le processus fils, qui rend aussi la
  # restauration verifiee par catalogue_restaure()).
  aj_r2 <- mw_ajuster(.tri)
  rt <- appliquer(c(list("a"), as.list(volets)), function(k) if (identical(k, "a")) executer_cas("reserve2") else
    list(bt = bootstrap_volet(k, aj_r2, GRAINE_R2, B = B_REF), restaure = catalogue_restaure()))
  if (en_erreur(rt[[1]])) stop("controle (a) : reserve2 en erreur : ", rt[[1]]$msg)
  RES_A <- rt[[1]]
  cmp_a <- comparer_objets(neutraliser_instables(readRDS(chemin_reference("reserve2"))), neutraliser_instables(RES_A), tol = TOLERANCE)
  TXT_A <- sprintf("%s ; %d feuille(s), %d non strictement identique(s), \u00e9cart maximal %s", if (cmp_a$conforme) "conforme" else "NON CONFORME",
                   cmp_a$n_feuilles, cmp_a$n_differentes, formatC(cmp_a$ecart_max, format = "e", digits = 3))
  controle(cmp_a$conforme && identical(unlist(RES_A$metadata[c("B", "alpha", "seed")]), c(B = as.numeric(B_REF), alpha = ALPHA, seed = GRAINE_R2)),
           sprintf("(a) reserve2, run_engine(seed = %.0f), conforme \u00e0 tests/reference/reserve2.rds (comparer_objets(), tol\u00e9rance %g) ; B, \u03b1 et graine = ceux du script : %s",
                   GRAINE_R2, TOLERANCE, TXT_A))
  go_r2 <- grandeurs_obs(aj_r2)
  # (c) et (i2) sur reserve2, pour chaque volet demande.
  txt_c <- NULL
  for (iv in seq_along(volets)) {
    v <- volets[iv]; r_v <- rt[[iv + 1L]]
    if (en_erreur(r_v)) stop("controles (c) et (i2) : bootstrap injecte du volet ", v, " en erreur : ", r_v$msg)
    bt <- r_v$bt
    S <- stats_volet(v); cles_v <- intersect(CLES, S)
    ok_i2 <- identite_injection(RES_A$bootstrap, bt, cles_v) && isTRUE(r_v$restaure) &&
      identical(unname(bt$B_effectif[cles_v]), unname(RES_A$bootstrap$B_effectif[cles_v]))
    controle(ok_i2, sprintf("(i2) reserve2 (graine %.0f), volet %s : sur les cl\u00e9s %s, p_mc, err_mc, B_effectif, motif_mc, granularite_stat, p_min_mc et stats_obs, ainsi que sigma_boot, B, granularite et les bool\u00e9ens du retirage, identiques (identical()) \u00e0 ceux de run_engine() / mw_bootstrap() sans injection ; MW_CATALOGUE_MC restaur\u00e9 (identical())",
                            GRAINE_R2, v, paste(cles_v, collapse = ", ")))
    # (c) : valeurs des candidats
    val <- lapply(names(ATTENDU_C), function(s) c(round(as.numeric(bt$stats_obs[[s]]) * 1e4), round(bt$p_mc[[s]] * 1e3)))
    names(val) <- names(ATTENDU_C)
    ok_val <- all(vapply(names(val), function(s) identical(as.numeric(val[[s]]), as.numeric(ATTENDU_C[[s]])), logical(1)))
    c3 <- cellules_t(aj_r2, go_r2$figes, 3L, TRUE, new.env()); c4 <- cellules_t(aj_r2, go_r2$figes, 4L, TRUE, new.env())
    ok_min <- c3$i == ATTENDU_MIN$i && c3$j == ATTENDU_MIN$j && abs(c3$t_min - ATTENDU_MIN$t) < 5e-4 && c3$nt == ATTENDU_MIN$nt && c4$nt == ATTENDU_MIN$nt4
    # oracle rstudent()
    mx <- 0
    infr <- influence_t(aj_r2, new.env())
    for (j in 0:4) {
      idx <- 0:(aj_r2$I - j - 1)
      C0 <- aj_r2$tri[idx + 1, j + 1]; C1 <- aj_r2$tri[idx + 1, j + 2]
      mx <- max(mx, max(abs(unname(stats::rstudent(stats::lm(C1 ~ 0 + C0, weights = 1 / C0))) - infr$t[infr$j == j])))
    }
    ok_rs <- is.finite(mx) && mx < 1e-10
    txt_c <- sprintf("%s ; PenteRel (informatif, issue #307 : t = 1,73 ; p_mc = 0,090) : t = %s, p_mc = %s",
                     paste(vapply(names(val), function(s) sprintf("%s %s / %s", s, num(val[[s]][1] / 1e4, 4), num(val[[s]][2] / 1e3, 3)), ""), collapse = " ; "),
                     num(as.numeric(bt$stats_obs[["PenteRel"]]), 3), num(bt$p_mc[["PenteRel"]], 3))
    controle(ok_val, sprintf("(c) reserve2, volet %s : valeurs des candidats (statistique \u00e0 4 d\u00e9cimales / p_mc \u00e0 3 d\u00e9cimales) \u00e9gales \u00e0 celles des par. 3.2 et 4.4 (FWb 1,7598 / 0,214 ; FWr 1,4373 / 0,285 ; BP 0,6502 / 0,103 ; MinP 0,1033 / 0,944 ; MinP4 0,1033 / 0,898 ; TMax 2,7242 / 0,944) : %s",
                             v, txt_c))
    controle(ok_min, sprintf("(c) reserve2, volet %s : minimum des p_ij en (i, j) = (%s, %s), t = %s, N_t = %s (MinP) et %s (MinP4) ; attendu (0, 2), t = \u22122,318, 25 et 22", v,
                             c3$i, c3$j, num(c3$t_min, 3), c3$nt, c4$nt))
    controle(ok_rs, sprintf("(c) reserve2, volet %s : t(i, j) = DFBETAS \u221a((1 \u2212 h) / h) \u00e9gal \u00e0 stats::rstudent() de la r\u00e9gression pond\u00e9r\u00e9e de C(.,j+1) sur C(.,j) sans constante, poids 1/C(.,j), colonnes j = 0 \u00e0 4 : \u00e9cart maximal %s (seuil 1e-10)",
                             v, formatC(mx, format = "e", digits = 2)))
  }
  list(a = TXT_A, collisions = cgr$txt, candidats = txt_c, scenarios = csc$txt, copie = cc$txt, ok_bt = RES_A)
}

###############################################################################
#  PARALLELISME (--coeurs)
###############################################################################
N_PROC <- if (.Platform$OS.type == "windows") 1L else if (is.na(N_COEURS)) max(1L, min(4L, parallel::detectCores())) else N_COEURS
if (.Platform$OS.type == "windows" && !is.na(N_COEURS) && N_COEURS > 1L) message("--coeurs ignore sous Windows (mclapply) : un processus")
# Applique f a chaque element de X, N_PROC processus (un element par processus a la fois,
# mc.preschedule = FALSE) ; un echec (erreur ou processus tue) devient un element d'erreur.
appliquer <- function(X, f, prescheduling = FALSE) {
  g <- function(x) tryCatch(f(x), error = function(e) structure(list(msg = conditionMessage(e)), class = "erreur_calcul"))
  r <- if (N_PROC > 1L && length(X) > 1L) parallel::mclapply(X, g, mc.cores = N_PROC, mc.preschedule = prescheduling) else lapply(X, g)
  lapply(r, function(x) if (is.list(x) && !inherits(x, "try-error")) x else structure(list(msg = "echec du processus"), class = "erreur_calcul"))
}
en_erreur <- function(x) inherits(x, "erreur_calcul")

###############################################################################
#  MODE --controles
###############################################################################
if (MODE == "controles") {
  t_c <- Sys.time()
  message("--controles : controles generaux sur reserve2 (volets A et B), ", N_PROC, " processus")
  cg_ <- controles_generaux(c("A", "B"))
  S <- c("## Contr\u00f4les g\u00e9n\u00e9raux de la mesure #309 (aucun fichier \u00e9crit)", "",
         sprintf("Commit : %s ; empreinte sans commentaires de R/engine.R : %s ; dur\u00e9e : %.0f s", COMMIT, EMPREINTE_SC, secondes(t_c)), "",
         paste("-", CONTROLES), "", sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
  ecrire_console(S)
  quit(status = if (length(INTEGRITE)) 1L else 0L)
}

###############################################################################
#  MODE --essai : duree par triangle de chaque cellule, extrapolee au plan complet
###############################################################################
if (MODE == "essai") {
  t_e <- Sys.time()
  taches <- c(lapply(LOIS, function(l) list(volet = "A", cle = l, id = paste0("A-", l), R = R_A[[l]])),
              lapply(seq_len(nrow(CELLULES)), function(i) list(volet = "B", cle = CELLULES$id[i], id = paste0("B-", CELLULES$id[i]), R = CELLULES$R[i])))
  X <- unlist(lapply(taches, function(t) lapply(seq_len(N_ESSAI), function(b) c(t, list(b = b)))), recursive = FALSE)
  message("--essai : ", length(X), " triangles (", N_ESSAI, " par cellule), B = ", B_BOOT, ", ", N_PROC, " processus")
  R_ <- appliquer(X, function(x) { sp <- spec_cellule(x$volet, x$cle); r <- traiter_triangle(sp, x$b)
    list(id = x$id, R = x$R, b = x$b, statut = r$statut, duree = r$duree) })
  err <- vapply(R_, en_erreur, logical(1))
  if (any(err)) { message("--essai : ", sum(err), " triangle(s) en erreur : ", paste(unique(vapply(R_[err], function(x) x$msg, "")), collapse = " ; ")); quit(status = 1L) }
  df <- data.frame(id = vapply(R_, `[[`, "", "id"), R = vapply(R_, `[[`, 1, "R"), statut = vapply(R_, `[[`, "", "statut"),
                   duree = vapply(R_, `[[`, 1, "duree"), stringsAsFactors = FALSE)
  par_id <- do.call(rbind, lapply(unique(df$id), function(i) { d <- df[df$id == i & df$statut == "admis", ]
    data.frame(id = i, R = df$R[df$id == i][1], n = nrow(d), duree = if (nrow(d)) mean(d$duree) else NA_real_, stringsAsFactors = FALSE) }))
  # duree du bootstrap plein rejoue pour b multiple de CTL_PERIODE (controle (i2)) et d'un triangle d'oracle
  t1 <- Sys.time(); aj_t <- admettre(triangle_spec(spec_cellule("A", "N"), 1L)$tri)$aj; invisible(mw_bootstrap(aj_t, B = B_BOOT, seed = 1L)); d_plein <- secondes(t1)
  t1 <- Sys.time(); invisible(lapply(seq_len(100), function(k) traiter_oracle("N", k))); d_ora <- secondes(t1) / 100
  d_moy <- mean(par_id$duree, na.rm = TRUE)
  par_id$duree[is.na(par_id$duree)] <- d_moy
  cpu_A <- sum(par_id$R[startsWith(par_id$id, "A-")] * par_id$duree[startsWith(par_id$id, "A-")])
  cpu_B <- sum(par_id$R[startsWith(par_id$id, "B-")] * par_id$duree[startsWith(par_id$id, "B-")])
  n_A <- sum(R_A); n_B <- sum(CELLULES$R)
  cpu_ctl_A <- n_A / CTL_PERIODE * d_plein; cpu_ctl_B <- n_B / CTL_PERIODE * d_plein
  n_sl_A <- sum(ceiling(R_A / TAILLE_TRANCHE)); n_sl_B <- sum(ceiling(CELLULES$R / TAILLE_TRANCHE))
  cpu_ora <- length(CLES_ORACLES_ATTENDUES) * N0_SPEC * d_ora
  t1 <- Sys.time(); invisible(controles_generaux("B")); d_cg <- secondes(t1)
  h <- function(s) s / 3600
  S <- c("## Essai de dur\u00e9e de la mesure #309 (aucun fichier \u00e9crit ; arbre non propre admis)", "",
         sprintf("Commit : %s ; B = %d ; %d processus concurrents ; %d triangle(s) par cellule (b = 1..%d).", COMMIT, B_BOOT, N_PROC, N_ESSAI, N_ESSAI), "",
         entete_md(c("Jeu", "R", "triangles mesur\u00e9s", "dur\u00e9e par triangle admis (s, sous concurrence)", "CPU extrapol\u00e9 (h)")),
         vapply(seq_len(nrow(par_id)), function(i) ligne_md(par_id$id[i], par_id$R[i], par_id$n[i], num(par_id$duree[i], 2), num(h(par_id$R[i] * par_id$duree[i]), 2)), ""), "",
         "Extrapolation au plan complet (somme des R \u00d7 dur\u00e9e par triangle ; dur\u00e9es mesur\u00e9es sous la concurrence de ce nombre de processus, d'o\u00f9 horloge = CPU / processus) :", "",
         entete_md(c("Poste", "CPU (h)", "horloge (h)")),
         ligne_md(sprintf("volet A : %d triangles", n_A), num(h(cpu_A), 2), num(h(cpu_A) / N_PROC, 2)),
         ligne_md(sprintf("volet B : %d triangles", n_B), num(h(cpu_B), 2), num(h(cpu_B) / N_PROC, 2)),
         ligne_md(sprintf("contr\u00f4le (i2), bootstrap plein rejou\u00e9 %d + %d fois (%s s par bootstrap)", n_A %/% CTL_PERIODE, n_B %/% CTL_PERIODE, num(d_plein, 1)), num(h(cpu_ctl_A + cpu_ctl_B), 2), num(h(cpu_ctl_A + cpu_ctl_B) / N_PROC, 2)),
         ligne_md(sprintf("5 oracles de N0 = %d triangles (%s s par triangle)", N0_SPEC, num(d_ora, 4)), num(h(cpu_ora), 2), num(h(cpu_ora) / N_PROC, 2)),
         ligne_md(sprintf("contr\u00f4les g\u00e9n\u00e9raux de chaque tranche (%s s en s\u00e9rie) \u00d7 %d tranches + 5 oracles", num(d_cg, 0), n_sl_A + n_sl_B), num(h(d_cg * (n_sl_A + n_sl_B + 5)), 2), num(h(d_cg * (n_sl_A + n_sl_B + 5)), 2)),
         ligne_md("**Total**", num(h(cpu_A + cpu_B + cpu_ctl_A + cpu_ctl_B + cpu_ora) + h(d_cg * (n_sl_A + n_sl_B + 5)), 2),
                  num(h(cpu_A + cpu_B + cpu_ctl_A + cpu_ctl_B + cpu_ora) / N_PROC + h(d_cg * (n_sl_A + n_sl_B + 5)), 2)), "",
         sprintf("Essai : %.0f s d'horloge. Sp\u00e9cification : 31 \u00e0 33 h d'horloge sur 4 c\u0153urs (plan (A) 22-24 h, volet A 4 h, P3 5 h) [H].", secondes(t_e)), "")
  ecrire_console(S)
  quit(status = 0L)
}

###############################################################################
#  MODE --controle-i2prime : (i2') -- a lancer par audit apres #301 puis #300
###############################################################################
# La p du moteur modifie (cle --cle-moteur, evaluee par mw_bootstrap() avec
# le catalogue du moteur tel que charge) est identique a celle du candidat
# retenu (entree --candidat de ce script, ajoutee sous le nom
# "<candidat>.script"), sur reserve2 et sur TOUS les triangles marques (i2) :
# b multiple de 50 des volets A (N, E, A : 100 triangles) et B (22 cellules :
# 320 triangles). Un seul bootstrap par triangle : la cle du moteur et le
# candidat sont evalues sur les memes repliques. Compare p_mc, B_effectif,
# motif_mc et stats_obs. Seul ecart admis, compte a part : motif du script =
# MOTIF_MC_OBS_NON_FINIE contre motif du moteur = texte du champ non_definie
# (statistique observee non definie, option (iii), Q-D1-Fi-8), avec p_mc et
# statistique NA des deux cotes. --marques n : n premiers triangles marques
# seulement (mise au point).
if (MODE == "i2prime") {
  t_i <- Sys.time()
  if (!OPT_CANDIDAT %in% CAND) stop("--candidat : un de ", paste(CAND, collapse = ", "))
  if (!OPT_CLE_MOTEUR %in% names(CAT_ORIG)) stop("--cle-moteur : cle absente de MW_CATALOGUE_MC du moteur charge (", paste(names(CAT_ORIG), collapse = ", "), ")")
  nom_s <- paste0(OPT_CANDIDAT, ".script")
  un <- function(aj, g) {
    cat <- c(CAT_ORIG, stats::setNames(catalogue_candidats(aj, OPT_CANDIDAT), nom_s))
    bt <- avec_catalogue(cat, mw_bootstrap(aj, B = B_BOOT, seed = g))
    k <- OPT_CLE_MOTEUR
    p_k <- unname(bt$p_mc[[k]]); p_s <- unname(bt$p_mc[[nom_s]]); s_k <- as.numeric(bt$stats_obs[[k]]); s_s <- as.numeric(bt$stats_obs[[nom_s]])
    m_k <- unname(bt$motif_mc[[k]]); m_s <- unname(bt$motif_mc[[nom_s]])
    egal_hors_motif <- identical(p_k, p_s) && identical(unname(bt$B_effectif[[k]]), unname(bt$B_effectif[[nom_s]])) && identical(s_k, s_s)
    egal <- egal_hors_motif && identical(m_k, m_s)
    ecart_motif <- egal_hors_motif && !identical(m_k, m_s) && is.na(p_k) && !is.finite(s_k) && identical(m_s, MOTIF_MC_OBS_NON_FINIE) && !is.na(m_k)
    list(egal = egal, ecart_motif = ecart_motif, p_moteur = p_k, p_script = p_s, stat_moteur = s_k, stat_script = s_s)
  }
  r2 <- un(mw_ajuster(.tri), GRAINE_R2)
  marques <- c(unlist(lapply(LOIS, function(l) lapply(seq(CTL_PERIODE, R_A[[l]], by = CTL_PERIODE), function(b) list(volet = "A", cle = l, b = b))), recursive = FALSE),
               unlist(lapply(seq_len(nrow(CELLULES)), function(i) lapply(seq(CTL_PERIODE, CELLULES$R[i], by = CTL_PERIODE), function(b) list(volet = "B", cle = CELLULES$id[i], b = b))), recursive = FALSE))
  if (!is.na(N_MARQUES)) marques <- utils::head(marques, N_MARQUES)
  message("--controle-i2prime : reserve2 puis ", length(marques), " triangles marques, ", N_PROC, " processus")
  R_ <- appliquer(marques, function(x) { tg <- triangle_spec(spec_cellule(x$volet, x$cle), x$b); ad <- admettre(tg$tri)
    if (!ad$ok) return(list(refuse = TRUE)); c(un(ad$aj, tg$g), list(refuse = FALSE)) })
  err <- vapply(R_, en_erreur, logical(1))
  ok_t <- R_[!err]
  n_ref <- sum(vapply(ok_t, function(x) x$refuse, logical(1)))
  n_id <- sum(vapply(ok_t, function(x) !x$refuse && isTRUE(x$egal), logical(1)))
  n_mot <- sum(vapply(ok_t, function(x) !x$refuse && !isTRUE(x$egal) && isTRUE(x$ecart_motif), logical(1)))
  n_dif <- sum(vapply(ok_t, function(x) !x$refuse && !isTRUE(x$egal) && !isTRUE(x$ecart_motif), logical(1)))
  ok <- !any(err) && (isTRUE(r2$egal) || isTRUE(r2$ecart_motif)) && n_dif == 0L
  S <- c(sprintf("## (i2') : cl\u00e9 %s du moteur contre le candidat %s du script", OPT_CLE_MOTEUR, OPT_CANDIDAT), "",
         sprintf("Commit : %s ; empreinte sans commentaires de R/engine.R : %s ; dur\u00e9e : %.0f s.", COMMIT, EMPREINTE_SC, secondes(t_i)), "",
         sprintf("- reserve2 (graine %.0f) : p du moteur %s, p du script %s, statistique du moteur %s, du script %s : %s", GRAINE_R2, fmt_p(r2$p_moteur), fmt_p(r2$p_script),
                 num(r2$stat_moteur, 6), num(r2$stat_script, 6), if (isTRUE(r2$egal)) "identiques" else if (isTRUE(r2$ecart_motif)) "identiques hors motif (statistique observ\u00e9e non d\u00e9finie)" else "**DIFF\u00c9RENTES**"),
         sprintf("- triangles marqu\u00e9s (b multiple de %d, volets A et B) : %d, dont %d refus\u00e9s du DGP, %d en erreur, %d identiques, %d \u00e0 \u00e9cart de motif admis (p et statistique NA des deux c\u00f4t\u00e9s ; motif du script \u00ab obs. non finie \u00bb contre texte non_definie du moteur), %d **diff\u00e9rents**",
                 CTL_PERIODE, length(marques), n_ref, sum(err), n_id, n_mot, n_dif), "",
         sprintf("Bilan (i2') : %s", if (ok) "OK" else "\u00c9CHEC"), "")
  ecrire_console(S)
  quit(status = if (ok) 0L else 1L)
}

###############################################################################
#  SORTIES DE CALCUL : tranche, oracle
###############################################################################
cg_ <- controles_generaux(OPT_VOLET)
if (length(INTEGRITE)) {
  message("tranche refusee : controle(s) general(aux) en echec avant la boucle (", length(INTEGRITE), ") : ", paste(substr(INTEGRITE, 1, 60), collapse = " ; "))
  quit(status = 1L)
}
t_ctrl <- secondes(t_debut)
VOLET <- OPT_VOLET
if (MODE == "oracle") {
  ID_ORA <- if (VOLET == "A") OPT_LOI else OPT_PLAN
  CLE_ORA <- if (VOLET == "A") paste0("ORA-A-", OPT_LOI) else paste0("ORA-B-", OPT_PLAN)
  DEBUT <- 1L; FIN <- N0
  CLE_SORTIE <- CLE_ORA
} else {
  SP <- if (VOLET == "A") spec_cellule("A", OPT_LOI) else spec_cellule("B", paste(OPT_PLAN, OPT_CELLULE, sep = "."))
  DEBUT <- B1; FIN <- B2
  CLE_SORTIE <- if (VOLET == "A") paste0("A-", OPT_LOI) else paste0("B-", SP$id)
}
PAR <- if (MODE == "oracle")
  sprintf("mode=oracle;volet=%s;cle=%s;B=%d;N0=%d;graine_oracle=%s;methode=%s;", VOLET, CLE_SORTIE, B_BOOT, N0,
          if (VOLET == "A") sprintf("%.0f+%.0f(l-1)+k", GRAINE_ORA, PAS_LOI_ORA) else sprintf("%.0f+k", GRAINE_ORA_B[[OPT_PLAN]]), METHODE) else
  sprintf("mode=tranche;volet=%s;cle=%s;B=%d;alpha=%g;graine_tri=%s;graine_boot=%s;methode=%s;segment=%d;annexe=%s;", VOLET, CLE_SORTIE, B_BOOT, ALPHA,
          if (VOLET == "A") sprintf("%.0f+%.0f(l-1)+b", GRAINE_TRI, PAS_LOI) else sprintf("%.0f+%.0f(c-1)+b", GRAINES_B[[SP$plan]][["tri"]], PAS_CELLULE),
          if (VOLET == "A") sprintf("%.0f+%.0f(l-1)+b", GRAINE_BOOT, PAS_LOI) else sprintf("%.0f+%.0f(c-1)+b", GRAINES_B[[SP$plan]][["boot"]], PAS_CELLULE),
          METHODE, SEGMENT, ANNEXE)
CTX <- c(mode = MODE, cle = CLE_SORTIE, dgp = TXT_DGP, configuration = TXT_CONFIG, graines = TXT_GRAINES, collisions = cg_$collisions,
         generateur = paste(ENGINE_RNG_KIND, collapse = ", "), commit = COMMIT, plateforme = plateforme_calcul(), empreintes = EMPREINTES,
         empreinte_sc = sprintf("%s (md5 du fichier entier %s)", EMPREINTE_SC, MD5_MOTEUR), reference = cg_$a, candidats = cg_$candidats,
         scenarios = cg_$scenarios, copie = cg_$copie, essai = if (PROVISOIRE) "oui" else "non",
         locale = sprintf("%s \u2192 %s", LOCALE_ORIGINE, LOCALE_TRAVAIL))
stopifnot(identical(names(CTX), CLES_CONTEXTE))
ENTETE <- utf8(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d\t%s", DEBUT, FIN, CLE_SORTIE),
                 sprintf("CONTEXTE\t%s\t%s", names(CTX), vapply(CTX, nettoyer_champ, "")),
                 paste0("CLES\t", paste(sprintf("%s=%s", STATS_B, QUEUE_ALL[STATS_B]), collapse = "\t")),
                 paste0("COLS\t", paste(cols_mode(MODE, VOLET), collapse = "\t"))))

# --- Reprise d'une sortie partielle (--reprendre) ------------------------------
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
  ok <- lengths(rp) == length(cols_mode(MODE, VOLET)) & !is.na(bs) & bs >= DEBUT & bs <= FIN &
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
DATA <- list(); ERREURS <- character(0)
N_REPRIS <- 0L; N_RECALC <- 0L; ECH_REPRISE <- character(0)
hors_duree <- function(mode) { cols <- cols_mode(mode, VOLET); !grepl("^duree", cols) }
TAILLE_LOT <- if (MODE == "oracle") max(N_PROC, 200L) else N_PROC
un_calcul <- function(b) {
  if (MODE == "oracle") list(ch = traiter_oracle(ID_ORA, b))
  else { r <- traiter_triangle(SP, b); list(ch = champs_tranche(VOLET, b, r)) }
}
for (lot in split(seq.int(DEBUT, FIN), ceiling(seq_len(FIN - DEBUT + 1L) / TAILLE_LOT))) {
  a_calc <- lot[vapply(lot, function(b) is.null(REPRIS[[as.character(b)]]) || b %in% B_RECALC_FORCE, logical(1))]
  res <- if (length(a_calc)) appliquer(a_calc, un_calcul, prescheduling = MODE == "oracle") else list()
  names(res) <- as.character(a_calc)
  for (b in lot) {
    ch_old <- REPRIS[[as.character(b)]]
    if (!is.null(ch_old) && !(b %in% B_RECALC_FORCE)) { ch <- ch_old; N_REPRIS <- N_REPRIS + 1L }
    else {
      r <- res[[as.character(b)]]
      if (en_erreur(r)) {
        ch <- champs_erreur(cols_mode(MODE, VOLET), b, r$msg, 0); ERREURS <- c(ERREURS, sprintf("%d : %s", b, ch[3]))
      } else {
        ch <- r$ch
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
}

# --- Controles de la sortie ----------------------------------------------------
D <- en_table(DATA, cols_mode(MODE, VOLET))
n_adm <- sum(D$statut == "admis"); n_ref <- sum(D$statut == "refuse"); n_err <- sum(D$statut == "erreur")
e_inv <- invariants_sortie(list(mode = MODE, volet = VOLET, donnees = DATA, debut = DEBUT, fin = FIN, B = B_BOOT))
if (MODE == "tranche") {
  n_ctl <- sum(D$ctl %in% c("OK", "ECHEC"))
  controle(!length(e_inv[!grepl("statut inconnu", e_inv)]),
           sprintf("(d) B_eff \u2264 B et p sur la grille k/(B_eff + 1) (\u00d7 2 en bilat\u00e9ral, plafonn\u00e9e \u00e0 1), p de [0, 1], motifs connus, sur les champs de chaque ligne REP ; admis + refus\u00e9s + en erreur = %d%s",
                   FIN - DEBUT + 1L, if (length(e_inv)) paste0(" : ", paste(e_inv, collapse = " ; ")) else ""))
  controle(!any(D$ctl == "ECHEC"), sprintf("(i2) %d triangle(s) de la tranche contr\u00f4l\u00e9(s) (b multiple de %d) : mw_bootstrap() sans injection identique (identical()) \u00e0 la p_mc, B effectif, motif et stats_obs des cl\u00e9s communes avec le catalogue inject\u00e9 ; MW_CATALOGUE_MC restaur\u00e9",
                                           n_ctl, CTL_PERIODE))
} else {
  controle(!length(e_inv[!grepl("statut inconnu", e_inv)]), sprintf("(d) lignes ORA : k = 1..%d, une fois chacune%s", N0, if (length(e_inv)) paste0(" : ", paste(e_inv, collapse = " ; ")) else ""))
}
if (!is.null(TXT_REPRISE))
  controle(!length(ECH_REPRISE), sprintf("(reprise) %s (md5 %s) : en-t\u00eate identique ; %d ligne(s) reprise(s) telle(s) quelle(s), %d recalcul\u00e9e(s) (derni\u00e8re ligne reprise et \u00e9chantillon r\u00e9gulier d'au plus %d lignes) et identique(s) hors dur\u00e9es, %d ligne(s) illisible(s), tronqu\u00e9e(s) ou en erreur ignor\u00e9e(s), dont %d derni\u00e8re ligne non termin\u00e9e par un saut de ligne \u00e9cart\u00e9e%s",
                                         TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC - length(ECH_REPRISE), N_ECH_REPRISE[[MODE]],
                                         N_IGNOREES, N_NON_TERMINEE, if (length(ECH_REPRISE)) paste0(" ; diff\u00e9rentes : ", paste(ECH_REPRISE, collapse = ", ")) else ""))
if (length(ECH_REPRISE))
  message("--reprendre : ECHEC -- ligne(s) reprise(s) differente(s) de leur recalcul hors durees (b = ", paste(ECH_REPRISE, collapse = ", "),
          ") : sortie partielle corrompue, INTEGRITE ECHEC")
# (erreurs) bloquant : une ligne au statut erreur rend la sortie NON TERMINEE
# (INTEGRITE ECHEC, ni NLIG ni FIN) ; le lanceur la signale \u00ab non terminee \u00bb et
# la reprend, --reprendre ne reprenant que les lignes admises ou refusees.
controle(n_err == 0L, sprintf("(erreurs) %d ligne(s) au statut erreur (sortie close sans NLIG ni FIN : non terminee, reprenable par --reprendre qui recalcule ces seules lignes)%s", n_err,
                              if (length(ERREURS)) paste0(" : ", paste(ERREURS, collapse = " ; ")) else ""))

# --- Markdown de la sortie -------------------------------------------------------
DUREE <- c(t_ctrl, secondes(t_debut))
titre <- if (MODE == "oracle") sprintf("oracle %s, N0 = %d", CLE_SORTIE, N0) else sprintf("tranche %s, b = %d..%d", CLE_SORTIE, DEBUT, FIN)
S <- c(sprintf("## Mesure #309 : puissance \u00e0 T = 8 des lignes M1 \u00e0 M4 de Merz-W\u00fcthrich -- %s", titre), "",
       sprintf("Param\u00e8tres : %s", PAR), "",
       "### T0 -- provenance", "", entete_md(c("Grandeur", "Valeur")),
       vapply(CLES_CONTEXTE, function(k) ligne_md(LIBELLES_CONTEXTE[[k]], nettoyer_champ(CTX[[k]])), ""),
       ligne_md("Triangles", sprintf("%d (admis %d, refus\u00e9s %d, en erreur %d)", FIN - DEBUT + 1L, n_adm, n_ref, n_err)),
       if (!is.null(TXT_REPRISE)) ligne_md("Reprise (--reprendre)", sprintf("%s (md5 %s) : %d ligne(s) reprise(s), %d recalcul\u00e9e(s), %d ignor\u00e9e(s)",
                                                                          TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC, N_IGNOREES)),
       ligne_md("Processus (mclapply)", as.character(N_PROC)),
       ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les g\u00e9n\u00e9raux %.0f ; total %.0f%s", DUREE[1], DUREE[2],
                                         if (MODE == "tranche" && n_adm) sprintf(" ; par triangle admis : moyenne %s", num(mean(D$duree[D$statut == "admis"]), 1)) else "")),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) "\u00c9CHEC" else "OK"), "",
       "Tableaux PARTIELS (une sortie, sans \u03c1 ni crit\u00e8res) : combiner les sorties par --combiner.", "")
if (PROVISOIRE) S <- c(S, "**Sortie provisoire (--provisoire, --essai, --B, --N0 r\u00e9duit) : non versionnable.**", "")
if (MODE == "tranche") {
  A <- D[D$statut == "admis", , drop = FALSE]
  if (nrow(A)) {
    S <- c(S, "### Taux de rejet partiels (p_mc < \u03b1, p absente = non-rejet)", "", entete_md(c("Statistique (sens)", "n", "k 0,10", "taux [IC] 0,10", "k 0,05", "taux [IC] 0,05")))
    for (s in stats_volet(VOLET)) {
      cs <- lapply(SEUILS, function(a) cellule(A[[paste0("p:", s)]], a, NA_real_))
      S <- c(S, ligne_md(lib_stat(s), nrow(A), cs[[1]]$k, txt_lec(cs[[1]]), cs[[2]]$k, txt_lec(cs[[2]])))
    }
    S <- c(S, "")
  }
} else {
  S <- c(S, tableau_rho(stats::setNames(list(resume_oracle(D, B_BOOT)), CLE_SORTIE), "### R\u00e9f\u00e9rence \u03c1 et diagnostics de l'oracle"))
}
S <- c(S, "### Contr\u00f4les d'int\u00e9grit\u00e9", "", paste("-", CONTROLES), "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d contr\u00f4le(s))", length(INTEGRITE)) else "OK"), "")
FIN_MACHINE <- c(paste0("DUREE\t", paste(sprintf("%.3f", DUREE), collapse = "\t")),
                 if (!is.null(TXT_REPRISE)) sprintf("REPRISE\t%s\t%s\t%d\t%d\t%d", TXT_REPRISE[1], TXT_REPRISE[2], N_REPRIS, N_RECALC, N_IGNOREES),
                 if (MODE == "oracle") sprintf("MD5_VALEURS\t%s", md5_lignes(paste0(ETQ[[MODE]], "\t", vapply(DATA, paste, "", collapse = "\t")))),
                 paste0("INTEGRITE\t", if (length(INTEGRITE)) "ECHEC" else "OK"),
                 if (n_err == 0L) sprintf("NLIG\t%d", length(DATA)), if (n_err == 0L) sprintf("FIN\t%d", length(DATA)))
emettre(c("", S, FIN_MACHINE))
if (!is.na(OPT_SORTIE_TR)) {
  close(CON)
  ecrire_console(S)
  message("ecrit (sortie, md5 ", md5_fichier(OPT_SORTIE_TR), ") : ", basename(OPT_SORTIE_TR))
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
