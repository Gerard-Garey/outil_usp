###############################################################################
#  tests/puissance_t8.R  --  PUISSANCE A T = 8 DE SIX LIGNES DE usp_tests()
#  SOUS DES ALTERNATIVES CONSTRUITES SUR LE MODELE AJUSTE (issue #116)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (tools::md5sum() pour le controle d'integrite du depot et
#  les empreintes du code, #171 ; tools est livre avec R). Sortie en markdown sur la console (UTF-8) ;
#  fichiers ecrits SEULEMENT sur option explicite (--ecrire, --sortie).
#
#  Statut des valeurs : CONSTATS DE SIMULATION sous des alternatives choisies,
#  hors modele reglementaire (statut 4 de docs/exigences.md, par. 2 ; l'annexe
#  XVII suppose des annees independantes et un modele lognormal a beta
#  constant), sauf la puissance de Durbin-Watson sous AR(1) par la methode
#  d'Imhof : approximation numerique d'une quantite exacte (statut 3).
#  Specification : commentaire d'actuary du 30/09/2026 sur #116
#  (5904949481) ; decisions du mainteneur du meme jour (5904983887) : volet B
#  complet (cinq points, J1 et J2, R = 500, B = 999), puissance de DW par
#  Imhof laissee a l'appreciation de coder (calculee, non bloquante),
#  alternative V ajoutee, graine par defaut 20260930.
#
#  Lignes couvertes (cle du catalogue USP_CATALOGUE_MC -> ligne de
#  usp_tests()) : Runs (suites sur z_t), Runsr (suites sur ratios bruts u_t),
#  DW (Durbin-Watson sur z_t), DWr (Durbin-Watson sur ratios bruts ; volet B
#  seulement), MK (Mann-Kendall sur r_t), Smirnov (deux echantillons, partition
#  x_t > med(x)). Rejet : p-value < alpha (verdict ALERTE ou ECHEC).
#
#  Alternatives : le modele ajuste FIT0 au jeu (usp_ajuster()) est garde
#  (beta chapeau, pi chapeau_t, x_t) ; seul epsilon est remplace. Avec
#  mu_t = ln(beta x_t) - 1/(2 pi_t) et s_t = sqrt(1/pi_t) (usp_simuler()),
#  y*_t = exp(mu_t + s_t eps'_t), eps' = phi(e), e_1..e_8 i.i.d. N(0,1) ; les
#  amplitudes sont en unites de l'ecart-type de ln r_t (s_t) :
#    N (nulle)         : eps' = e, soit exactement usp_simuler(FIT0) (controle) ;
#    A (autocorr.)     : AR(1) stationnaire de variance unite,
#                        eps'_1 = e_1, eps'_t = rho eps'_{t-1} + sqrt(1 - rho^2) e_t,
#                        rho dans {-0,5 ; 0,3 ; 0,5 ; 0,7 ; 0,9} ; a pi constant,
#                        eps' = sqrt(1 - rho^2) u, u l'AR(1) de C1.a
#                        (tests/constats_puissance_t8.R) : meme loi des p ;
#    T (tendance)      : eps'_t = e_t + D (t - tbar) / (T - 1), tbar = (T + 1)/2,
#                        D dans {1, 2, 3} (derive centree de D ecarts-types entre
#                        la 1re et la 8e annee, specification) ; au volet A (pi
#                        constant, tests invariants par translation) le centrage
#                        est sans effet ; au volet B il ne l'est pas quand pi
#                        chapeau varie (J2 : le decalage s_t tbar D / 7 depend de
#                        t), d'ou le choix de la forme centree de la specification ;
#    R (rupture)       : eps'_t = e_t + Delta 1{t > t0}, (t0, Delta) dans
#                        {(4, 1), (4, 2), (4, 3), (6, 2)} ;
#    V (vol., A seul)  : eps'_t = kappa e_t si x_t > med(x), e_t sinon,
#                        kappa dans {2, 3}.
#  Nombres aleatoires communs : une seule matrice e par volet, tiree avant
#  tout calcul, ligne b = 8 tirages consecutifs (ordre de usp_simuler()).
#
#  VOLET A (principal, jeu J1 seul, 15 points, R = --R, alpha = 0,10 et 0,05) :
#    p exactes des fonctions du moteur, regime pi constant, SANS reajustement :
#    runs_p_exacte(l*) et runs_p_exacte(u*), dw_p_exacte(l*), mk_p_exacte(r*),
#    stats::ks.test() sur la partition de l* (l* aplati a TOL_EX_AEQUO comme
#    dans usp_tests()), avec r* = y*/x, l* = ln r* - moyenne(ln r*),
#    u* = r* - moyenne(r*). Ces lois sont invariantes par transformation
#    affine croissante et ln est croissant : sur J1 (pi chapeau constant, z
#    affine croissant de ln r), la p calculee est celle que retiendrait le
#    moteur a pi* constant (controle sur J1 observe ci-dessous). Puissance de
#    DW sous AR(1) par Imhof, a pi constant : P(DW <= d_bas) + P(DW >= d_haut)
#    sous eps' ~ N(0, Sigma_rho), d_bas et d_haut quantiles alpha/2 et
#    1 - alpha/2 de la loi nulle de dw_p_exacte(), chaque probabilite par
#    .imhof_p_sup0() sur les valeurs propres de
#    Sigma^(1/2) M (A - d I) M Sigma^(1/2) (M : centrage, A : matrice de DW).
#
#  VOLET B (controle, jeux J1 et J2, 5 points N, A(0,5), A(0,9), T(2),
#  R(t0 = 4, Delta = 2), R = --R-chaine, B = --B, alpha = 0,10) : p retenue
#  par la chaine reduite, pour chaque replication b :
#    1. usp_ajuster(x, y*) (reajustement complet ; en erreur : replication
#       ecartee, motif compte) ;
#    2. boucle bootstrap de usp_bootstrap() reduite aux six statistiques
#       (boucle_reduite(), catalogue en argument : reutilisable avec le
#       catalogue complet), sous engine_sous_graine(--graine-ic + 1000 b) :
#       usp_simuler() puis usp_ajuster_rapide() depuis l'optimum, replication
#       interne ecartee si le reajustement ou l'une des SIX statistiques
#       echoue. Ecart connu a usp_bootstrap(), qui ecarte aussi une
#       replication interne dont une AUTRE statistique du catalogue complet
#       echoue : non compte dans les replications (cout : catalogue complet
#       14,8 ms contre 0,97 ms pour les six, mesure du 30/09/2026, soit ~ +15 s
#       par replication a B = 999) ; controle seulement sur les jeux observes
#       (sigma_boot et z_boot identiques a ceux de usp_bootstrap()) et signale
#       dans la sortie (B3). Seul
#       usp_simuler() consomme de l'alea (usp_ajuster_rapide() et
#       usp_ajuster_contraint() sont deterministes) : les y** sont ceux de
#       usp_bootstrap() au bit pres (controle sur le jeu observe) ;
#    3. p Monte-Carlo par .mc_p_values() (engine_p_mc(), queue du catalogue,
#       conditions du catalogue evaluees sur l'observe) ;
#    4. p retenue et verdict par usp_tests() lui-meme (accord d'actuary du
#       30/09/2026), avec un objet bootstrap dont usp_tests() ne lit que les
#       champs stats_obs (catalogue complet, sur l'observe), p_mc, err_mc et
#       motif_mc ; seules les six p_mc, err_mc et motif_mc sont renseignes
#       (les autres NA, sans motif ; leurs lignes ne sont pas lues). La regle R7 (p exacte a
#       pi constant, Monte-Carlo sinon ; DWr toujours Monte-Carlo) et les
#       regles R1, R3 et R13 ne sont donc pas transcrites mais appliquees par
#       le moteur ; cout mesure de usp_tests() : 26 ms par appel (30/09/2026,
#       conteneur Linux, R 4.3.3), contre ~2,5 s pour la boucle a B = 999.
#    Ventilation : ALERTE et ECHEC, et regime du reajustement (delta chapeau*
#    au bord 1 : pi constant ; au bord 0 ; interieur).
#
#  Criteres BLOQUANTS (code de sortie 1 si l'un echoue) :
#    1. niveau du volet A : l'IC de Clopper-Pearson BILATERAL A 99,9 % du taux
#       de la ligne N contient la taille exacte, pour cinq verifications :
#       suites 4/70 (alpha = 0,10) ; DW alpha (0,10 et 0,05) ; Mann-Kendall
#       0,06101 et 0,03115 ; Smirnov 2/70 (meme evenement aux deux alpha,
#       verifie une fois). Tailles recalculees par enumeration avec les
#       fonctions du moteur et rapprochees de la specification. Le niveau
#       99,9 % par verification limite le risque de faux echec d'un controle
#       juste (decision d'actuary du 30/09/2026) ; la sortie publie l'IC a
#       95 %. Suites a alpha = 0,05 : test inoperant (regle R1, p_min = 4/70
#       >= 0,05), hors critere 1 ; assertion d'integrite : taux exactement 0 ;
#    2. identite Runs / Runsr au volet A, replication par replication ;
#    3. transcription contre run_engine() sur J1 et J2 observes (B = --B,
#       graine --graine-ic) : les six lignes de engine_table_tests() de la
#       chaine sont identiques a celles de run_engine() (identical(), sauf la
#       p exacte de DW : all.equal() a 1e-10), sigma_boot et z_boot
#       identiques ; volet A : p exactes sur l, u, r de J1 observe egales aux
#       p_exacte de run_engine() ; ligne N identique a usp_simuler(FIT0) ;
#    4. niveau du volet B : sur la ligne N, borne inferieure UNILATERALE A
#       99,9 % de Clopper-Pearson <= alpha pour chaque ligne (sinon constat de
#       sur-rejet : point d'arret, a remonter a actuary) ; evalue sur une
#       execution d'un seul tenant ou apres --combiner, jamais sur une tranche
#       seule ; si n est trop petit pour que la borne puisse depasser alpha
#       meme avec n rejets sur n, la ligne est dite "inoperant (n trop
#       petit)" et non "verifie" ;
#    5. aucune p manquante hors motif compte (une ligne de type test sans p
#       retenue ni motif Monte-Carlo fait echouer) ; une replication ecartee
#       ne compte ni comme rejet ni comme non-rejet ;
#    6. depot intact : aucune modification de R/ ni de tests/reference/ par
#       rapport a HEAD (git status) et empreintes md5 identiques au debut et a
#       la fin de l'execution.
#  Rapportes, non bloquants (decision du mainteneur) : compatibilite avec
#  C1.a (ecart normalise z, |z| <= 1,96) ; puissance de DW par Imhof dans
#  l'IC du volet A, ses controles (rho = 0 : alpha ; recoupement par
#  dw_p_exacte() aux points critiques) et ses echecs numeriques (uniroot()
#  ou integration) ; ventilation par regime. Aucun n'entre dans le code de
#  sortie.
#  Incertitude publiee : IC de Clopper-Pearson a 95 % (stats::binom.test()),
#  incertitude Monte-Carlo fonction de R ; elle ne dit rien de l'erreur
#  d'approximation en T.
#
#  Alea : tout tirage passe par engine_sous_graine() (generateur
#  ENGINE_RNG_KIND) : matrice e du volet A sous --graine, du volet B sous
#  --graine + 1 (la meme pour J1 et J2), boucle bootstrap de la replication b
#  (b = 1..R_chaine) sous --graine-ic + 1000 b (commune aux cinq points) ;
#  controles de transcription sur l'observe sous --graine-ic (graine de
#  run_engine()). Garde d'arret : les graines des matrices e (--graine et
#  --graine + 1) ne doivent pas figurer parmi --graine-ic + 1000 (0..R_chaine)
#  (flux identiques sinon) ; stop() explicite. Le resultat ne depend pas du
#  decoupage en tranches.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/puissance_t8.R [--volet tout|A|B] [--R 20000]
#          [--R-chaine 500] [--B 999] [--graine 20260930]
#          [--graine-ic 20260831] [--jeu tous|J1|J2] [--tranche i/K]
#          [--ecrire | --sortie DOSSIER]
#      Rscript tests/puissance_t8.R --combiner f1 f2 ... [--ecrire | --sortie DOSSIER]
#  --ecrire : ecrit docs/tableaux/<AAAAMMJJ>-issue116-exact-J1.md (volet A),
#  -chaine-J1.md et -chaine-J2.md (volet B), date du jour de l'execution, a
#  faire sur un arbre propre : --ecrire est REFUSE (code 1, rien d'ecrit) si
#  le commit (celui des tranches pour --combiner, et celui de la
#  combinaison elle-meme) porte "(arbre de travail modifie)", "(script non
#  suivi)" ou "inconnu", ou si tests/outils_tests.R ou le script executes
#  ne sont pas ceux du depot (empreintes "hors depot" ; empreintes du
#  combinateur imprimees en T0 ; #171, elargie : le critere 6 ne couvre que
#  R/ et tests/reference/) ; --sortie DOSSIER : memes noms dans DOSSIER, qui
#  doit etre HORS du depot (un dossier sous la racine du depot est refuse :
#  --ecrire est le seul chemin qui ecrit dans le depot).
#  Aucun fichier n'est ecrit si un critere bloquant echoue.
#  --tranche i/K (volet B, un seul jeu : --volet B --jeu J1 ou J2) : ne
#  traite que la i-eme de K tranches de replications consecutives et
#  imprime, apres les tableaux partiels, des lignes machine PARAMETRES,
#  TRANCHE, CONTEXTE, INTEGRITE, NCOMPTES, COMPTE, FIN (format de
#  tests/taux_franchissement_reperes.R). Rediriger chaque tranche vers un
#  fichier HORS du depot, puis --combiner additionne les comptes d'un meme
#  jeu. --combiner refuse (code 1, sans tableau) : une tranche sans ligne
#  INTEGRITE ou en ECHEC ; une sortie incomplete (FIN absente ou pas en
#  derniere ligne, nombre de COMPTE different de NCOMPTES ou de FIN) ; des
#  PARAMETRES ou un CONTEXTE differents (plateforme de calcul comprise :
#  R, systeme, machine, BLAS, LAPACK, #171 ; empreintes md5 de R/engine.R,
#  de tests/outils_tests.R charge et du script execute, #171 elargie) ; des
#  tranches qui ne couvrent pas 1..R exactement une fois.
#  Fonctions reprises par copie declaree (ces scripts executent leur calcul au
#  chargement et ne peuvent pas etre sources) :
#    - de tests/taux_franchissement_reperes.R : lire_option(), ligne_md(),
#      entete_md(), ecrire_console(), lire_j2() (copies) ; lire_comptes() et
#      refuser() (copies adaptees : cles de CONTEXTE propres a ce script) ;
#      l'analyse de --combiner (copie adaptee : la liste des fichiers peut
#      etre suivie de --ecrire ou --sortie DOSSIER) ;
#    - de tests/constats_puissance_t8.R : commit_depot() (copie adaptee :
#      nom du script, git factorise dans git_depot()), num(), ecart_z(),
#      compat() et les valeurs publiees de C1 (copies) ; ic_cp() et txt_ic()
#      (copies adaptees : niveau de confiance en argument, n = 0 admis) ;
#    - de tests/calibration_mc_t8.R : plateforme_calcul() (copie, #171),
#      empreintes_code() (copie adaptee : aucun fichier lu en plus) et
#      motifs_non_versionnable() (copie) ;
#    - de R/engine.R, dw_p_exacte() : construction des matrices A (differences
#      de DW) et M (centrage) dans dw_puissance_imhof() (copie).
#  Duree mesuree (conteneur Linux, R 4.3.3, 30/09/2026, petits R ; les
#  executions completes consignent la leur dans T0 et dans le bilan) :
#  volet A 1,4 a 1,6 ms par serie et par point (15 points x 20 000 : de
#  l'ordre de 7 a 8 min) ; volet B 2,5 a 2,8 s par replication et par point
#  a B = 999 (5 points x 500 : de l'ordre de 1,8 h par jeu en sequentiel,
#  soit ~ 14 min par tranche en 8 tranches paralleles) ; controles de
#  transcription : un run_engine() par jeu, ~ 20 s.
#  Critere de recette (decision d'actuary du 30/09/2026) : --R 200
#  --R-chaine 2 rend le code 0 en moins de trois minutes, controles compris
#  (mesure : voir le compte rendu de #116 ; 106 a 114 s avant la reprise).
#  Code de sortie : 0 si les criteres bloquants tiennent, 1 sinon ; en mode
#  --combiner, 1 aussi si la combinaison est refusee.
###############################################################################

t_debut <- Sys.time()

# --- Options (lire_option() : copie de tests/taux_franchissement_reperes.R) ---
ARGS <- commandArgs(trailingOnly = TRUE)
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else {
  reste <- ARGS[-seq_len(i_comb)]
  # les options --ecrire et --sortie DOSSIER peuvent suivre la liste
  j <- match(c("--ecrire", "--sortie"), reste)
  fin <- if (all(is.na(j))) length(reste) else min(j, na.rm = TRUE) - 1L
  reste[seq_len(fin)]
}
if (!is.na(i_comb) && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
OPT_VOLET     <- lire_option("--volet", "tout")
OPT_R         <- as.integer(lire_option("--R", "20000"))
OPT_R_CHAINE  <- as.integer(lire_option("--R-chaine", "500"))
OPT_B         <- as.integer(lire_option("--B", "999"))
OPT_GRAINE    <- as.numeric(lire_option("--graine", "20260930"))
OPT_GRAINE_IC <- as.numeric(lire_option("--graine-ic", "20260831"))
OPT_JEU       <- lire_option("--jeu", "tous")
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
OPT_ECRIRE    <- "--ecrire" %in% ARGS
OPT_SORTIE    <- lire_option("--sortie", NA_character_)
if (!OPT_VOLET %in% c("tout", "A", "B")) stop("--volet : tout, A ou B")
if (!OPT_JEU %in% c("tous", "J1", "J2")) stop("--jeu : tous, J1 ou J2")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_R_CHAINE) || OPT_R_CHAINE < 1L) stop("--R-chaine : entier >= 1")
if (!is.finite(OPT_GRAINE) || !is.finite(OPT_GRAINE_IC)) stop("--graine, --graine-ic : nombres")
if (OPT_ECRIRE && !is.na(OPT_SORTIE)) stop("--ecrire et --sortie sont exclusifs")
if (!is.na(OPT_SORTIE) && !dir.exists(OPT_SORTIE)) stop("--sortie : dossier introuvable : ", OPT_SORTIE)
# Garde de graines (voir l'en-tete) : les flux des matrices e ne doivent pas
# etre ceux d'une boucle bootstrap (graine_ic + 1000 b, b = 0 pour
# l'observe).
local({
  g_boot <- OPT_GRAINE_IC + 1000 * (0:OPT_R_CHAINE)
  g_e <- OPT_GRAINE + 0:1
  if (any(g_e %in% g_boot))
    stop(sprintf(paste("graines en collision : la graine %s des matrices e (--graine %s, --graine + 1)",
                       "est aussi celle d'une boucle bootstrap (--graine-ic + 1000 b, b = 0..%d) ;",
                       "changer --graine ou --graine-ic"),
                 paste(format(g_e[g_e %in% g_boot], scientific = FALSE), collapse = ", "),
                 format(OPT_GRAINE, scientific = FALSE), OPT_R_CHAINE))
})
if (!is.na(OPT_TRANCHE)) {
  if (OPT_VOLET != "B" || OPT_JEU == "tous")
    stop("--tranche : volet B et un seul jeu (--volet B --jeu J1 ou J2)")
  if (OPT_ECRIRE || !is.na(OPT_SORTIE))
    stop("--tranche : sortie partielle, --ecrire et --sortie reserves a --combiner")
}

# Configuration de run_engine() reproduite (cas de reference "premium" ; sans
# effet sur les six lignes).
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; ALPHA2 <- 0.05; THETA_EQUIV <- 0.10
T_ <- 8L

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))
if (!is.finite(OPT_B) || OPT_B < B_MIN_USAGE)
  stop(sprintf("--B : entier >= B_MIN_USAGE = %d (minimum admis par run_engine())", B_MIN_USAGE))

# --- Outils (copies declarees, voir l'en-tete) -----------------------------------
git_depot <- function(...) tryCatch(suppressWarnings(system2("git", c("-C", RACINE, ...), stdout = TRUE,
                                                             stderr = FALSE)),
                                    error = function(e) NULL)
# Commit du depot, complete de "(arbre de travail modifie)" et de "(script non
# suivi)" (definition de tests/constats_puissance_t8.R).
commit_depot <- function() {
  h <- git_depot("rev-parse", "HEAD")
  if (length(h) != 1L || !grepl("^[0-9a-f]{40}$", h)) return("inconnu")
  if (length(git_depot("status", "--porcelain", "--untracked-files=no"))) h <- paste(h, "(arbre de travail modifi\u00e9)")
  suivi <- tryCatch(suppressWarnings(system2("git", c("-C", RACINE, "ls-files", "--error-unmatch",
                                                      "tests/puissance_t8.R"),
                                             stdout = FALSE, stderr = FALSE)),
                    error = function(e) 1L)
  if (!identical(as.integer(suivi), 0L)) h <- paste(h, "(script non suivi)")
  h
}
# Plateforme de calcul (#171) : R, systeme, machine, BLAS, LAPACK (copie de
# tests/calibration_mc_t8.R). Ligne de T0 des deux volets ; au volet B, champ
# du contexte : des tranches calculees sur des plateformes differentes ne se
# combinent pas (les reajustements dependent de l'optimiseur).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseign\u00e9" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}
# Empreintes md5 du code execute (#171, elargie par le mainteneur le
# 30/09/2026 ; copie adaptee de empreintes_code() de
# tests/calibration_mc_t8.R : script lu dans --file=, aucun fichier lu en
# plus) : moteur du depot, tests/outils_tests.R effectivement charge (celui
# du dossier du script), script execute ; "depot" ou "hors depot" selon que
# le fichier charge est celui du depot. Champ du contexte : un code different
# au meme commit (copie modifiee de outils_tests.R ou du moteur) change le
# contexte, et --combiner refuse. Lues au debut du calcul.
empreintes_code <- function(script_depot) {
  fichier <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  fichier <- if (length(fichier) == 1L) fichier else NA_character_
  meme <- function(a, b) !is.na(a) && file.exists(a) && file.exists(b) &&
    identical(normalizePath(a), normalizePath(b))
  md5 <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
  lieu <- function(f, ref) if (meme(f, file.path(RACINE, ref))) "d\u00e9p\u00f4t" else "hors d\u00e9p\u00f4t"
  outils <- file.path(DOSSIER_SCRIPT, "outils_tests.R")
  paste(c(sprintf("R/engine.R %s", md5(file.path(RACINE, "R", "engine.R"))),
          sprintf("tests/outils_tests.R charg\u00e9 (%s) %s", lieu(outils, "tests/outils_tests.R"), md5(outils)),
          sprintf("script ex\u00e9cut\u00e9 (%s) %s", lieu(fichier, script_depot), md5(fichier))), collapse = " ; ")
}
EMPREINTES <- empreintes_code("tests/puissance_t8.R")

# Motifs qui interdisent --ecrire (tableau versionne) : commit non propre ou
# code hors du depot (copie de tests/calibration_mc_t8.R).
motifs_non_versionnable <- function(commit, empreintes, quoi = "des tranches") {
  m <- character(0)
  if (!grepl("^[0-9a-f]{40}$", commit))
    m <- c(m, sprintf("commit %s \u00ab %s \u00bb (arbre de travail modifi\u00e9, script non suivi ou git indisponible)", quoi, commit))
  if (grepl("hors d\u00e9p\u00f4t", empreintes, fixed = TRUE))
    m <- c(m, sprintf("tests/outils_tests.R ou script ex\u00e9cut\u00e9s %s hors du d\u00e9p\u00f4t", quoi))
  m
}
# Chemin (existant) sous la racine du depot (copie de tests/calibration_mc_t8.R,
# constat R2 d'audit) : --sortie doit viser hors du depot ; --ecrire est le
# seul chemin qui ecrit dans le depot.
sous_depot <- function(chemin) {
  d <- normalizePath(chemin, mustWork = TRUE); r <- normalizePath(RACINE, mustWork = TRUE)
  identical(d, r) || startsWith(d, paste0(r, .Platform$file.sep))
}
if (!is.na(OPT_SORTIE) && sous_depot(OPT_SORTIE))
  stop("--sortie : dossier sous le depot refuse (--ecrire est le seul chemin qui ecrit dans le depot) : ", OPT_SORTIE)
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 3) if (is.na(x)) "\u2014" else sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
ic_cp <- function(k, n, niveau = 0.95) if (n > 0) {
  ci <- stats::binom.test(k, n, conf.level = niveau)$conf.int
  c(ci[1], ci[2])
} else c(NA_real_, NA_real_)
txt_ic <- function(ci) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1]), num(ci[2]))
taux <- function(k, n) if (n > 0) num(k / n) else "\u2014"
# Borne inferieure unilaterale de Clopper-Pearson (critere 4), NA si n = 0.
borne_inf <- function(k, n, niveau = 0.999) if (n > 0)
  stats::binom.test(k, n, alternative = "greater", conf.level = niveau)$conf.int[1] else NA_real_
# Ecart normalise entre deux estimations independantes d'une meme proportion
# (reproduction sur n tirages, publication sur R_PUB) ; compatible si |z| <= 1,96.
R_PUB <- 20000
ecart_z <- function(k, n, pub) {
  pbar <- (k + pub * R_PUB) / (n + R_PUB)
  (k / n - pub) / sqrt(pbar * (1 - pbar) * (1 / n + 1 / R_PUB))
}
compat <- function(pub, k, n) if (is.na(pub)) c("\u2014", "\u2014") else {
  z <- ecart_z(k, n, pub)
  c(sub(".", ",", sprintf("%+.2f", z), fixed = TRUE), if (abs(z) <= stats::qnorm(0.975)) "oui" else "**non**")
}
# Constat C1.a publie (commentaire d'actuary du 23/09/2026 sur #44 ; reproduit
# par tests/constats_puissance_t8.R), alpha = 0,10, AR(1) stationnaire.
C1_RHO    <- c(0.3, 0.5, 0.7, 0.9)
C1_SUITES <- c(0.080, 0.118, 0.175, 0.247)
C1_DW     <- c(0.163, 0.268, 0.395, 0.529)

INTEGRITE <- character(0)          # libelles des criteres en echec
DUREE_CONTROLES <- 0               # secondes passees dans les controles de transcription
CONTROLES <- character(0)          # lignes "libelle : OK / ECHEC"
# statut_ok : texte imprime a la place de "OK" (critere 4 inoperant) ;
# bloquant = FALSE : controle rapporte, sans effet sur le code de sortie.
controle <- function(ok, libelle, statut_ok = "OK", bloquant = TRUE) {
  ok <- isTRUE(ok)
  if (!ok && bloquant) INTEGRITE <<- c(INTEGRITE, libelle)
  CONTROLES <<- c(CONTROLES, sprintf("%s : %s", libelle,
                                     if (ok) statut_ok else if (bloquant) "ECHEC" else "ECHEC (non bloquant)"))
  invisible(ok)
}
# Texte du critere 4 (resultat de tableaux_chaine()).
texte_crit4 <- function(tb) {
  if (length(tb$echecs4))
    return(paste("ECHEC -- constat de sur-rejet, point d'arr\u00eat \u00e0 remonter \u00e0 actuary :",
                 paste(tb$echecs4, collapse = " ; ")))
  paste0(if (length(tb$ok4)) paste0("v\u00e9rifi\u00e9 (", paste(tb$ok4, collapse = ", "), ")") else "aucune ligne v\u00e9rifi\u00e9e",
         if (length(tb$inop4)) paste0(" ; inop\u00e9rant (n trop petit) : ", paste(tb$inop4, collapse = ", ")) else "")
}

# --- Critere 6 : depot intact (R/ et tests/reference/) ----------------------------
empreintes_depot <- function() {
  f <- c(list.files(file.path(RACINE, "R"), recursive = TRUE, full.names = TRUE),
         list.files(file.path(RACINE, "tests", "reference"), recursive = TRUE, full.names = TRUE))
  tools::md5sum(sort(f))
}
etat_git_depot <- function() {
  s <- git_depot("status", "--porcelain", "--", "R", "tests/reference")
  if (is.null(s)) NA_character_ else paste(s, collapse = " ; ")
}
verifier_depot <- function(md5_debut, moment) {
  g <- etat_git_depot()
  controle(!is.na(g) && !nzchar(g),
           sprintf("Crit\u00e8re 6, d\u00e9p\u00f4t intact (%s) : git status de R/ et tests/reference/ vide%s",
                   moment, if (is.na(g)) " (git indisponible)" else if (nzchar(g)) paste0(" (", g, ")") else ""))
  if (!is.null(md5_debut))
    controle(identical(md5_debut, empreintes_depot()),
             sprintf("Crit\u00e8re 6, d\u00e9p\u00f4t intact (%s) : md5 de R/ et tests/reference/ inchang\u00e9s depuis le d\u00e9but", moment))
}

# --- Lignes couvertes ------------------------------------------------------------
SIX <- c("Runs", "Runsr", "DW", "DWr", "MK", "Smirnov")
LIGNES <- c(
  Runs    = "Test des suites (aleatoire des signes)",
  Runsr   = "Test des suites sur ratios bruts",
  DW      = "Autocorrelation d'ordre 1 (Durbin-Watson)",
  DWr     = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
  MK      = "Tendance monotone du ratio S/P",
  Smirnov = "Egalite des lois petits vs gros volumes (2 ech.)")
LIB_COURT <- c(Runs = "Suites (z)", Runsr = "Suites (ratios bruts)", DW = "Durbin-Watson (z)",
               DWr = "Durbin-Watson (ratios bruts)", MK = "Mann-Kendall", Smirnov = "Smirnov")
REGIMES <- c(bord1 = "\u03b4\u0302* = 1 (\u03c0\u0302* constant)", bord0 = "\u03b4\u0302* = 0",
             interieur = "\u03b4\u0302* int\u00e9rieur")

# --- Alternatives ------------------------------------------------------------------
# Un point : cle ASCII, libelle, fonction e -> eps' (x_t du jeu en argument).
point <- function(cle, lib, phi) list(cle = cle, lib = lib, phi = phi)
ar1 <- function(rho) function(e, x) {
  v <- numeric(length(e)); v[1] <- e[1]
  for (t in 2:length(e)) v[t] <- rho * v[t - 1] + sqrt(1 - rho^2) * e[t]
  v
}
POINTS_A <- c(
  list(point("N", "N (nulle)", function(e, x) e)),
  lapply(c(-0.5, 0.3, 0.5, 0.7, 0.9), function(r)
    point(sprintf("A%+.1f", r), sprintf("A (AR(1), \u03c1 = %s)", num(r, 1)), ar1(r))),
  lapply(1:3, function(D) point(sprintf("T%d", D), sprintf("T (tendance, D = %d)", D),
                                function(e, x) e + D * (seq_along(e) - (length(e) + 1) / 2) / (length(e) - 1))),
  lapply(list(c(4, 1), c(4, 2), c(4, 3), c(6, 2)), function(p)
    point(sprintf("R%d_%d", p[1], p[2]), sprintf("R (rupture, t\u2080 = %d, \u0394 = %d)", p[1], p[2]),
          function(e, x) e + p[2] * (seq_along(e) > p[1]))),
  lapply(2:3, function(k) point(sprintf("V%d", k), sprintf("V (volume, \u03ba = %d)", k),
                                function(e, x) ifelse(x > stats::median(x), k * e, e))))
names(POINTS_A) <- vapply(POINTS_A, `[[`, "", "cle")
POINTS_B <- POINTS_A[c("N", "A+0.5", "A+0.9", "T2", "R4_2")]

# y* sous l'alternative : exp(mu + s eps'), memes operations que usp_simuler()
# (rnorm(T, mu, s) = mu + s * norm_rand() sous Inversion).
simuler_alt <- function(fit, eps) {
  mu <- log(fit$beta * fit$x) - 1 / (2 * fit$pi)
  exp(mu + sqrt(1 / fit$pi) * eps)
}
# Matrice e (R x T), ligne b = T tirages consecutifs, sous graine explicite.
tirer_e <- function(graine, R) engine_sous_graine(graine, matrix(stats::rnorm(R * T_), nrow = R, byrow = TRUE))

# --- Jeux (lire_j2() : copie de tests/taux_franchissement_reperes.R) ---------------
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
charger_jeu <- function(j) {
  jeu <- if (j == "J1")
    list(nom = "J1", x = .ln$xt, y = .ln$yt, libelle = "J1 : tests/donnees/donnees_ln.csv (jeu des cas de r\u00e9f\u00e9rence)") else
    c(list(nom = "J2"), lire_j2(), libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (\u03b4 estim\u00e9 int\u00e9rieur)")
  # Le protocole (tailles exactes, alternatives, partition) est ecrit pour T = 8.
  stopifnot(length(jeu$x) == T_, length(jeu$y) == T_)
  jeu
}
txt_modele <- function(fit) sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g ; \u03c0\u0302 constant : %s",
                                    fit$delta, fit$gamma, fit$beta, fit$sigma, usp_regime(fit$delta, fit$x)$pi_constant)
code_regime <- function(fit) if (fit$delta >= 1 - TOL_DELTA_BORD) "bord1" else
  if (fit$delta <= TOL_DELTA_BORD) "bord0" else "interieur"

# run_engine() sur le jeu observe (controles de transcription).
engine_observe <- function(jeu) run_engine(xt = jeu$x, yt = jeu$y, methode = METHODE, segment = SEGMENT,
                                           annexe = ANNEXE, nature_donnees = NATURE, B = OPT_B,
                                           alpha = ALPHA, theta_equiv = THETA_EQUIV, seed = OPT_GRAINE_IC)
lignes_six <- function(tab) {
  i <- match(LIGNES, tab$test)
  if (anyNA(i) || any(vapply(LIGNES, function(l) sum(tab$test == l), numeric(1)) != 1))
    stop("lignes de usp_tests() introuvables ou multiples : script a mettre a jour (LIGNES)")
  rownames(tab) <- NULL
  stats::setNames(lapply(i, function(k) tab[k, , drop = FALSE]), names(LIGNES))
}

# --- Criteres, empreintes du depot au debut -----------------------------------------
MD5_DEBUT <- if (!length(FICHIERS_COMB)) empreintes_depot() else NULL
if (!length(FICHIERS_COMB)) verifier_depot(NULL, "d\u00e9but")

# --- Ecriture des fichiers (seulement sur option et si tout est OK) ------------------
DATE_SORTIE <- format(Sys.Date(), "%Y%m%d")
# commit et empreintes : ceux du code qui a calcule le tableau (des tranches
# pour --combiner) ; --ecrire refuse s'ils ne sont pas ceux d'un commit propre
# du depot (#171, elargie) ; combinaison = TRUE : la combinaison elle-meme
# (commit et empreintes courants) doit l'etre aussi (constat R1 d'audit).
ecrire_fichier <- function(suffixe, lignes, commit = commit_depot(), empreintes = EMPREINTES,
                           combinaison = FALSE) {
  if (!OPT_ECRIRE && is.na(OPT_SORTIE)) return(invisible(NULL))
  if (OPT_ECRIRE) {
    nv <- c(motifs_non_versionnable(commit, empreintes, if (combinaison) "des tranches" else "de l'ex\u00e9cution"),
            if (combinaison) motifs_non_versionnable(commit_depot(), EMPREINTES, "de la combinaison"))
    if (length(nv)) {
      message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
              " -- aucun fichier ecrit ; relancer sur un arbre propre, ou --sortie DOSSIER hors du depot")
      quit(status = 1L)
    }
  }
  dossier <- if (OPT_ECRIRE) file.path(RACINE, "docs", "tableaux") else OPT_SORTIE
  if (!dir.exists(dossier)) stop("dossier de sortie introuvable : ", dossier)
  f <- file.path(dossier, sprintf("%s-issue116-%s.md", DATE_SORTIE, suffixe))
  con <- file(f, open = "wb")
  writeLines(enc2utf8(lignes), con, useBytes = TRUE)
  close(con)
  message("\u00e9crit : ", f)
}

###############################################################################
#  VOLET B : outils communs (execution directe, tranches et --combiner)
###############################################################################

# Boucle de usp_bootstrap() reduite aux statistiques de `catalogue`, sous
# engine_sous_graine(graine) : memes tirages (usp_simuler()), meme
# reajustement (usp_ajuster_rapide() depuis l'optimum). Une replication
# interne est ecartee si le reajustement echoue ou si l'une des statistiques
# de `catalogue` echoue ; usp_bootstrap() l'ecarte aussi quand une AUTRE
# statistique du catalogue complet echoue, cas que cette boucle ne voit pas
# avec les six statistiques (non compte : cout, voir l'en-tete ; controle
# sur les jeux observes seulement). Avec le catalogue complet, les regles
# d'ecartement sont celles de usp_bootstrap(). Rend sim (B x statistiques),
# sigma et z des replications (NA si ecartee), pour le controle d'integrite
# contre usp_bootstrap().
boucle_reduite <- function(fit, graine, B, catalogue) {
  engine_sous_graine(graine, {
    sim <- matrix(NA_real_, B, length(catalogue), dimnames = list(NULL, names(catalogue)))
    sig <- rep(NA_real_, B)
    zb <- matrix(NA_real_, B, length(fit$x))
    for (b in seq_len(B)) {
      yb <- usp_simuler(fit)
      fb <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(fb, "try-error")) next
      sb <- try(.mc_evaluer(catalogue, .usp_contexte_mc(fit$x, yb, fb$z)), silent = TRUE)
      if (inherits(sb, "try-error")) next
      sim[b, ] <- sb
      zb[b, ] <- fb$z
      sig[b] <- fb$sigma
    }
    list(sim = sim, sigma_boot = sig[is.finite(sig)], z_boot = zb)
  })
}

# Chaine reduite d'une replication : reajustement, boucle reduite, p_mc des
# six statistiques, usp_tests(). Rend NULL + motif si le reajustement echoue.
chaine <- function(x, y, graine, B) {
  fb <- tryCatch(usp_ajuster(x, y), error = function(e) e)
  if (inherits(fb, "error")) return(list(ecart = "usp_ajuster() en erreur"))
  e_obs <- .usp_contexte_mc(fb$x, fb$y, fb$z)
  so <- tryCatch(.mc_evaluer(USP_CATALOGUE_MC, e_obs), error = function(e) e)
  if (inherits(so, "error")) return(list(ecart = "statistiques observ\u00e9es en erreur"))
  bt <- boucle_reduite(fb, graine, B, USP_CATALOGUE_MC[SIX])
  mc <- .mc_p_values(bt$sim, so[SIX], USP_CATALOGUE_MC, e_obs)
  p_mc <- err_mc <- so * NA_real_
  motif <- stats::setNames(rep(NA_character_, length(so)), names(so))
  p_mc[SIX] <- mc$p_mc; err_mc[SIX] <- mc$err_mc; motif[SIX] <- mc$motif_mc
  boot <- list(stats_obs = as.list(so), p_mc = p_mc, err_mc = err_mc, motif_mc = motif)
  tt <- usp_tests(fb, boot, ALPHA, theta_equiv = THETA_EQUIV, methode = METHODE)
  list(fit = fb, tests = tt, lignes = lignes_six(engine_table_tests(list(tests = tt))),
       motif_mc = mc$motif_mc, boucle = bt, regime = code_regime(fb))
}

# Comptes d'une replication (cles "|" ; aucun tabulateur).
nettoyer_cle <- function(s) gsub("[|\t\r\n]", " ", s)
compter_chaine <- function(cpt, pt, ch) {
  ajoute <- function(cle, v = 1) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
  ajoute(paste0("n|", pt))
  if (!is.null(ch$ecart)) { ajoute(paste0("ecart|", pt, "|", nettoyer_cle(ch$ecart))); return(cpt) }
  ajoute(paste0("reg|", pt, "|", ch$regime))
  ajoute(paste0("bperdu|", pt), sum(!is.finite(ch$boucle$z_boot[, 1])))
  for (k in SIX) {
    l <- ch$lignes[[k]]
    # Motif Monte-Carlo compte des qu'il existe, p retenue ou non (B3).
    if (!is.na(ch$motif_mc[[k]])) ajoute(sprintf("mmc|%s|%s|%s", pt, k, nettoyer_cle(ch$motif_mc[[k]])))
    if (is.finite(l$p_retenue)) {
      ajoute(sprintf("v|%s|%s|%s|%s", pt, k, ch$regime, l$verdict))
      nat <- if (identical(l$nature_p, "exacte")) "exacte"
             else if (startsWith(l$nature_p, "Monte-Carlo")) "mc" else "autre"
      ajoute(sprintf("nat|%s|%s|%s", pt, k, nat))
    } else {
      m <- ch$motif_mc[[k]]
      motif <- if (!identical(l$type, "test"))
        sprintf("ligne %s : %s", l$type, substr(sub("[.;:].*$", "", l$commentaire), 1, 80))
      else if (!is.na(m)) sprintf("Monte-Carlo : %s", m) else NA_character_
      if (is.na(motif)) ajoute(sprintf("sansmotif|%s|%s", pt, k))
      else ajoute(sprintf("na|%s|%s|%s", pt, k, nettoyer_cle(motif)))
    }
  }
  cpt
}

# Tableaux du volet B a partir des comptes ; rend aussi les echecs des
# criteres 4 et 5 (evalues seulement si `complet`).
tableaux_chaine <- function(cpt, R, B, complet) {
  g <- function(n) if (n %in% names(cpt)) cpt[[n]] else 0
  kv <- function(pt, k, reg = names(REGIMES), v) sum(vapply(reg, function(r)
    sum(vapply(v, function(vv) g(sprintf("v|%s|%s|%s|%s", pt, k, r, vv)), numeric(1))), numeric(1)))
  L <- c("### B1 -- taux de rejet de la p retenue (p < \u03b1 = 0,10 : verdict ALERTE ou ECHEC)", "",
         entete_md(c("Point", "Ligne", "n", "Rejets", "Taux", "IC 95 % (C-P)", "dont ALERTE", "dont ECHEC",
                     "p exacte / Monte-Carlo / autre", "p manquantes (motif en B3)")))
  echecs4 <- inop4 <- ok4 <- character(0)
  crit4 <- character(0)
  for (pt in names(POINTS_B)) for (k in SIX) {
    n <- kv(pt, k, v = c("OK", "ALERTE", "ECHEC")); ka <- kv(pt, k, v = "ALERTE"); ke <- kv(pt, k, v = "ECHEC")
    ci <- ic_cp(ka + ke, n)
    na_k <- sum(cpt[grepl(sprintf("^(na|sansmotif)\\|%s\\|%s(\\||$)", gsub("([.+])", "\\\\\\1", pt), k), names(cpt))])
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, LIB_COURT[[k]], n, ka + ke, taux(ka + ke, n), txt_ic(ci), ka, ke,
                       paste(vapply(c("exacte", "mc", "autre"), function(nt) sprintf("%.0f", g(sprintf("nat|%s|%s|%s", pt, k, nt))), ""),
                             collapse = " / "), na_k))
    if (complet && pt == "N") {
      # Critere 4 : borne inferieure unilaterale a 99,9 % ; inoperant si
      # meme n rejets sur n ne la porteraient pas au-dessus de alpha.
      lb <- borne_inf(ka + ke, n); lb_max <- borne_inf(n, n)
      st <- if (n == 0 || lb_max <= ALPHA) "inop\u00e9rant (n trop petit)"
            else if (lb > ALPHA) "**ECHEC** (sur-rejet)" else "v\u00e9rifi\u00e9"
      crit4 <- c(crit4, ligne_md(LIB_COURT[[k]], n, ka + ke, num(lb, 4), num(lb_max, 4), st))
      if (n == 0 || lb_max <= ALPHA) inop4 <- c(inop4, LIB_COURT[[k]])
      else if (lb > ALPHA) echecs4 <- c(echecs4, sprintf("%s (borne inf\u00e9rieure %s > \u03b1)", LIB_COURT[[k]], num(lb, 4)))
      else ok4 <- c(ok4, LIB_COURT[[k]])
    }
  }
  L <- c(L, "", sprintf(paste("n : r\u00e9plications (sur %d par point) o\u00f9 la ligne a une p retenue ; une r\u00e9plication",
                              "\u00e9cart\u00e9e ou une p manquante ne compte ni comme rejet ni comme non-rejet.",
                              "IC : incertitude Monte-Carlo sur le taux (fonction de R), pas l'erreur",
                              "d'approximation en T. La p retenue est exacte \u00e0 \u03c0\u0302* constant (r\u00e8gle R7 ;",
                              "jamais pour les ratios bruts de Durbin-Watson), Monte-Carlo \u00e0 B = %d sinon."), R, B), "",
         "### B2 -- ventilation par r\u00e9gime du r\u00e9ajustement (taux de rejet, rejets / n)", "",
         entete_md(c("Point", "R\u00e9gime", "R\u00e9plications", LIB_COURT[SIX])))
  for (pt in names(POINTS_B)) for (r in names(REGIMES)) {
    nr <- g(sprintf("reg|%s|%s", pt, r))
    cel <- vapply(SIX, function(k) {
      n <- kv(pt, k, r, c("OK", "ALERTE", "ECHEC")); kk <- kv(pt, k, r, c("ALERTE", "ECHEC"))
      if (n > 0) sprintf("%s (%.0f / %.0f)", num(kk / n), kk, n) else "\u2014"
    }, "")
    L <- c(L, ligne_md(POINTS_B[[pt]]$lib, REGIMES[[r]], nr, paste(cel, collapse = " | ")))
  }
  L <- c(L, "", "### B3 -- r\u00e9plications \u00e9cart\u00e9es et p manquantes (motifs compt\u00e9s)", "")
  cles_m <- grep("^(ecart|na|sansmotif)\\|", names(cpt), value = TRUE)
  if (!length(cles_m)) L <- c(L, "Aucune r\u00e9plication \u00e9cart\u00e9e, aucune p manquante.")
  else {
    L <- c(L, entete_md(c("Nature", "Point", "Ligne", "Motif", "Nombre")))
    for (cl in cles_m) {
      p <- strsplit(cl, "|", fixed = TRUE)[[1]]
      L <- c(L, switch(p[1],
        ecart = ligne_md("r\u00e9plication \u00e9cart\u00e9e", POINTS_B[[p[2]]]$lib, "toutes", p[3], cpt[[cl]]),
        na = ligne_md("p manquante", POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], p[4], cpt[[cl]]),
        sansmotif = ligne_md("**p manquante sans motif**", POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], "\u2014", cpt[[cl]])))
    }
  }
  cles_mmc <- grep("^mmc\\|", names(cpt), value = TRUE)
  L <- c(L, "", "Motifs Monte-Carlo (motif_mc non NA, que la p retenue existe ou non) :", "")
  if (!length(cles_mmc)) L <- c(L, "aucun.")
  else {
    L <- c(L, entete_md(c("Point", "Ligne", "Motif", "Nombre")))
    for (cl in cles_mmc) {
      p <- strsplit(cl, "|", fixed = TRUE)[[1]]
      L <- c(L, ligne_md(POINTS_B[[p[2]]]$lib, LIB_COURT[[p[3]]], p[4], cpt[[cl]]))
    }
  }
  bp <- sum(cpt[grep("^bperdu\\|", names(cpt))])
  L <- c(L, "", sprintf(paste("R\u00e9plications internes du bootstrap \u00e9cart\u00e9es (r\u00e9ajustement ou l'une des six",
                              "statistiques en erreur), tous points confondus : %.0f. \u00c9cart connu \u00e0 usp_bootstrap(),",
                              "non compt\u00e9 : une r\u00e9plication interne o\u00f9 une autre statistique du catalogue complet",
                              "\u00e9chouerait est gard\u00e9e ici et \u00e9cart\u00e9e par usp_bootstrap() (identit\u00e9 contr\u00f4l\u00e9e sur",
                              "les jeux observ\u00e9s seulement)."), bp), "")
  if (complet)
    L <- c(L, "### B4 -- crit\u00e8re 4 : niveau de la ligne N (borne inf\u00e9rieure unilat\u00e9rale de Clopper-Pearson \u00e0 99,9 % \u2264 \u03b1)", "",
           entete_md(c("Ligne", "n", "Rejets", "Borne inf. 99,9 %", "Borne max. (n rejets sur n)", "Statut")),
           crit4, "",
           "Inop\u00e9rant (n trop petit) : m\u00eame n rejets sur n ne porteraient pas la borne au-dessus de \u03b1 ; la ligne n'est pas v\u00e9rifi\u00e9e.", "")
  echecs5 <- grep("^sansmotif\\|", names(cpt), value = TRUE)
  list(lignes = L, echecs4 = echecs4, inop4 = inop4, ok4 = ok4, echecs5 = echecs5)
}

statut_b <- function() paste(
  "Statut : **constat de simulation sous des alternatives choisies, hors mod\u00e8le r\u00e9glementaire** (issue #116,",
  "volet B, contr\u00f4le). Chaque r\u00e9plication suit la cha\u00eene du moteur, r\u00e9duite : usp_ajuster(), boucle",
  "bootstrap de usp_bootstrap() r\u00e9duite aux six statistiques, p Monte-Carlo par engine_p_mc(), p retenue et",
  "verdict par usp_tests(). Alternatives sur le mod\u00e8le ajust\u00e9 au jeu (\u03b2\u0302, \u03c0\u0302_t, x_t gard\u00e9s ; \u03b5",
  "remplac\u00e9, amplitudes en \u00e9carts-types de ln r_t) : protocole dans l'en-t\u00eate de tests/puissance_t8.R.",
  "La ligne N donne le niveau observ\u00e9 de la p retenue.")

LIBELLES_CONTEXTE <- c(
  jeu = "Jeu", modele = "Mod\u00e8le ajust\u00e9 (usp_ajuster())", configuration = "Configuration",
  points = "Points", graines = "Graines", B = "B du bootstrap", generateur = "G\u00e9n\u00e9rateur",
  commit = "Commit", plateforme = "Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)",
  empreintes = "Empreintes md5 du code ex\u00e9cut\u00e9")

# --- Mode --combiner (lire_comptes(), refuser() : copies adaptees de
# tests/taux_franchissement_reperes.R) -------------------------------------------------
refuser <- function(...) {
  message("--combiner : REFUS -- ", ...)
  quit(status = 1L)
}
lire_comptes <- function(f) {
  if (!file.exists(f)) refuser(f, " introuvable")
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  champs <- function(etq) strsplit(sub(paste0("^", etq, "\t"), "", grep(paste0("^", etq, "\t"), l, value = TRUE)), "\t")
  unique1 <- function(etq) {
    x <- champs(etq)
    if (length(x) != 1L) refuser(f, " : ", length(x), " ligne(s) ", etq, " (une attendue) -- sortie de tranche incomplete ?")
    x[[1]]
  }
  par <- unique1("PARAMETRES")
  tr <- unique1("TRANCHE")
  integ <- champs("INTEGRITE")
  if (length(integ) != 1L) refuser(f, " : ligne INTEGRITE absente ou multiple")
  if (!identical(integ[[1]], "OK")) refuser(f, " : controle d'integrite de la tranche en ECHEC (INTEGRITE\t", integ[[1]][1], ")")
  n_ann <- suppressWarnings(as.integer(unique1("NCOMPTES")))
  fin <- unique1("FIN")
  non_vides <- l[nzchar(trimws(l))]
  if (!length(non_vides) || !startsWith(non_vides[length(non_vides)], "FIN\t"))
    refuser(f, " : la ligne FIN n'est pas la derniere ligne -- sortie tronquee ou modifiee")
  cp <- champs("COMPTE")
  if (is.na(n_ann) || length(cp) != n_ann || !identical(as.integer(fin), n_ann))
    refuser(f, sprintf(" : %d ligne(s) COMPTE lue(s), NCOMPTES = %s, FIN = %s -- sortie tronquee ou modifiee",
                       length(cp), n_ann, fin))
  if (any(lengths(cp) != 2L) || anyNA(suppressWarnings(as.numeric(vapply(cp, `[`, "", 2L)))))
    refuser(f, " : ligne COMPTE illisible")
  ctx <- champs("CONTEXTE")
  if (!length(ctx) || any(lengths(ctx) != 2L)) refuser(f, " : lignes CONTEXTE absentes ou illisibles")
  ctx <- stats::setNames(vapply(ctx, `[`, "", 2L), vapply(ctx, `[`, "", 1L))
  if (!setequal(names(ctx), names(LIBELLES_CONTEXTE)) || anyDuplicated(names(ctx)))
    refuser(f, " : lignes CONTEXTE incompletes (attendues : ", paste(names(LIBELLES_CONTEXTE), collapse = ", "), ")")
  list(parametres = par, debut = as.integer(tr[1]), fin = as.integer(tr[2]), contexte = ctx[names(LIBELLES_CONTEXTE)],
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), vapply(cp, `[`, "", 1L)))
}
lignes_contexte <- function(ctx) vapply(names(LIBELLES_CONTEXTE), function(k)
  ligne_md(LIBELLES_CONTEXTE[[k]], ctx[[k]]), "")

if (length(FICHIERS_COMB)) {
  parts <- lapply(FICHIERS_COMB, lire_comptes)
  par <- unique(vapply(parts, `[[`, "", "parametres"))
  if (length(par) != 1L) refuser("parametres differents entre les fichiers (un seul jeu par combinaison)")
  ctx <- unique(lapply(parts, `[[`, "contexte"))
  if (length(ctx) != 1L) {
    k_diff <- names(LIBELLES_CONTEXTE)[vapply(names(LIBELLES_CONTEXTE), function(k)
      length(unique(vapply(parts, function(p) p$contexte[[k]], ""))) > 1L, logical(1))]
    refuser("contexte (T0) different entre les tranches : ", paste(k_diff, collapse = ", "))
  }
  ctx <- ctx[[1]]
  R_tot <- as.integer(sub("^.*;R_chaine=([0-9]+);.*$", "\\1", par))
  jeu_c <- sub("^.*jeu=(J[12]);.*$", "\\1", par)
  idx <- unlist(lapply(parts, function(p) seq.int(p$debut, p$fin)))
  if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
    refuser("les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
  cles <- unique(unlist(lapply(parts, function(p) names(p$comptes))))
  cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(parts, function(p)
    if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
  B_c <- as.integer(sub("^.*;B=([0-9]+);.*$", "\\1", par))
  tb <- tableaux_chaine(cpt, R_tot, B_c, TRUE)
  ok4 <- !length(tb$echecs4); ok5 <- !length(tb$echecs5)
  sortie <- c(sprintf("## Puissance \u00e0 T = 8, volet B (cha\u00eene r\u00e9duite), jeu %s -- combinaison de %d tranche(s) (issue #116)",
                      jeu_c, length(parts)), "",
              sprintf("Param\u00e8tres : %s", par), "", statut_b(), "",
              "### T0 -- contexte (identique dans toutes les tranches, v\u00e9rifi\u00e9)", "",
              entete_md(c("Grandeur", "Valeur")),
              lignes_contexte(ctx),
              ligne_md("R\u00e9plications par point", sprintf("%d (%d tranche(s) : %s)", R_tot, length(parts),
                                                             paste(vapply(parts, function(p) sprintf("%d-%d", p$debut, p$fin), ""),
                                                                   collapse = ", "))),
              ligne_md("Commit de la combinaison", commit_depot()),
              ligne_md("Empreintes md5 du combinateur", EMPREINTES),
              ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9 des tranches (crit\u00e8res 3, 5, 6 ; ligne N = usp_simuler())",
                       sprintf("OK dans les %d tranche(s)", length(parts))), "",
              tb$lignes,
              "### Crit\u00e8res bloquants \u00e9valu\u00e9s \u00e0 la combinaison", "",
              sprintf("- Crit\u00e8re 4, niveau du volet B (ligne N, borne inf\u00e9rieure unilat\u00e9rale 99,9 %% \u2264 \u03b1) : %s",
                      texte_crit4(tb)),
              sprintf("- Crit\u00e8re 5, aucune p manquante hors motif compt\u00e9 : %s",
                      if (ok5) "OK" else paste("ECHEC :", paste(tb$echecs5, collapse = " ; "))), "")
  ecrire_console(sortie)
  if (ok4 && ok5) ecrire_fichier(paste0("chaine-", jeu_c), sortie, ctx[["commit"]], ctx[["empreintes"]],
                                 combinaison = TRUE)
  quit(status = if (ok4 && ok5) 0L else 1L)
}

###############################################################################
#  VOLET A
###############################################################################
SORTIE_A <- NULL
RES_OBS <- list()                  # run_engine() par jeu, partage avec le volet B
if (OPT_VOLET %in% c("tout", "A")) {
  t_a <- Sys.time()
  JEU_A <- charger_jeu("J1")
  X <- JEU_A$x
  FIT_A <- usp_ajuster(X, JEU_A$y)
  controle(isTRUE(usp_regime(FIT_A$delta, X)$pi_constant),
           "Volet A, pr\u00e9requis : \u03c0\u0302 constant sur J1 (usp_regime())")
  GRP <- X > stats::median(X)

  # Tailles exactes a T = 8 sans ex aequo, par enumeration avec les fonctions
  # du moteur, rapprochees de la specification (5 decimales).
  cmb <- utils::combn(T_, T_ / 2)
  taille_runs <- function(a) mean(apply(cmb, 2, function(c) {
    v <- rep(-1, T_); v[c] <- 1
    runs_p_exacte(v + seq_len(T_) * 1e-3) < a
  }))
  taille_sm <- function(a) mean(apply(cmb, 2, function(c) {
    g <- seq_len(T_) %in% c
    stats::ks.test(seq_len(T_)[g], seq_len(T_)[!g])$p.value < a
  }))
  taille_mk <- function(a) {
    d <- .mk_loi_exacte(T_)
    p <- vapply(d$S, function(s) sum(d$prob[abs(d$S) >= abs(s) - 1e-9]), numeric(1))
    sum(d$prob[p < a])
  }
  TAILLE <- rbind(
    Runs    = c(taille_runs(ALPHA), taille_runs(ALPHA2)),
    DW      = c(ALPHA, ALPHA2),
    MK      = c(taille_mk(ALPHA), taille_mk(ALPHA2)),
    Smirnov = c(taille_sm(ALPHA), taille_sm(ALPHA2)))
  TAILLE_SPEC <- rbind(Runs = c(4 / 70, 0), DW = c(0.100, 0.050), MK = c(0.06101, 0.03115),
                       Smirnov = c(2 / 70, 2 / 70))
  controle(all(abs(TAILLE - TAILLE_SPEC) < 5e-6),
           "Volet A, tailles exactes \u00e9num\u00e9r\u00e9es \u00e9gales \u00e0 celles de la sp\u00e9cification (\u00e0 5e-6)")

  # p exactes d'une serie y (regime pi constant, sans reajustement).
  p_exactes_a <- function(y) {
    r <- y / X; lr <- log(r); l <- lr - mean(lr); u <- r - mean(r)
    la <- engine_aplatir_ex_aequo(l)
    c(Runs = runs_p_exacte(l), Runsr = runs_p_exacte(u), DW = dw_p_exacte(l), MK = mk_p_exacte(r),
      Smirnov = if (anyDuplicated(la)) NA_real_ else
        suppressWarnings(stats::ks.test(la[GRP], la[!GRP])$p.value))
  }

  # Critere 3 (volet A) : p sur J1 observe = p_exacte de run_engine().
  t_ca <- Sys.time()
  RES_OBS$J1 <- engine_observe(JEU_A)
  l_obs <- lignes_six(engine_table_tests(RES_OBS$J1))
  p_obs <- p_exactes_a(JEU_A$y)
  controle(identical(unname(p_obs[["Runs"]]), l_obs$Runs$p_exacte) &&
             identical(unname(p_obs[["Runsr"]]), l_obs$Runsr$p_exacte) &&
             isTRUE(all.equal(unname(p_obs[["DW"]]), l_obs$DW$p_exacte, tolerance = 1e-10)) &&
             identical(unname(p_obs[["MK"]]), l_obs$MK$p_exacte) &&
             identical(unname(p_obs[["Smirnov"]]), l_obs$Smirnov$p_exacte),
           "Crit\u00e8re 3, volet A : p exactes sur l, u, r de J1 observ\u00e9 = p_exacte de run_engine() (DW \u00e0 1e-10)")

  # Matrice e unique, tiree avant tout calcul ; ligne N = usp_simuler(FIT_A).
  E_A <- tirer_e(OPT_GRAINE, OPT_R)
  Y_N <- t(apply(E_A, 1, function(e) simuler_alt(FIT_A, e)))
  controle(identical(Y_N, engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT_A),
                                                                   numeric(T_))))),
           "Crit\u00e8re 3, volet A : ligne N identique \u00e0 usp_simuler(FIT0) (m\u00eame graine, au bit pr\u00e8s)")
  DUREE_CONTROLES <- DUREE_CONTROLES + as.numeric(difftime(Sys.time(), t_ca, units = "secs"))

  t_rep_a <- Sys.time()
  KA <- list()
  n_runsr_diff <- 0
  for (pt in names(POINTS_A)) {
    phi <- POINTS_A[[pt]]$phi
    P <- vapply(seq_len(OPT_R), function(b) p_exactes_a(simuler_alt(FIT_A, phi(E_A[b, ], X))), numeric(5))
    n_runsr_diff <- n_runsr_diff + sum(!mapply(identical, P["Runs", ], P["Runsr", ]))
    KA[[pt]] <- list(
      n  = apply(P, 1, function(p) sum(is.finite(p))),
      k1 = apply(P, 1, function(p) sum(p[is.finite(p)] < ALPHA)),
      k2 = apply(P, 1, function(p) sum(p[is.finite(p)] < ALPHA2)))
  }
  duree_rep_a <- as.numeric(difftime(Sys.time(), t_rep_a, units = "secs"))
  controle(n_runsr_diff == 0,
           sprintf("Crit\u00e8re 2, identit\u00e9 Runs / Runsr r\u00e9plication par r\u00e9plication (%.0f diff\u00e9rence(s) sur %d)",
                   n_runsr_diff, OPT_R * length(POINTS_A)))
  n_na_a <- sum(vapply(KA, function(k) sum(OPT_R - k$n), numeric(1)))
  controle(n_na_a == 0, sprintf("Crit\u00e8re 5, volet A : aucune p exacte manquante (%.0f manquante(s))", n_na_a))

  # Critere 1 : niveau de la ligne N.
  # IC bilateral a 99,9 % par verification (decision d'actuary du
  # 30/09/2026) ; la sortie publie aussi l'IC a 95 %. Cinq verifications :
  # suites a alpha = 0,05 inoperant (R1, p_min = 4/70), remplace par une
  # assertion d'integrite (taux exactement 0) ; Smirnov : meme evenement aux
  # deux alpha (taille 2/70), verifie une fois.
  niv <- character(0)
  for (k in rownames(TAILLE)) for (j in 1:2) {
    kk <- if (j == 1) KA$N$k1[[k]] else KA$N$k2[[k]]
    nn <- KA$N$n[[k]]
    a_txt <- num(c(ALPHA, ALPHA2)[j], 2)
    if (k == "Runs" && j == 2) {
      niv <- c(niv, ligne_md(LIB_COURT[[k]], a_txt, "inop\u00e9rant (R1, p_min = 4/70)\u00b9",
                             sprintf("%.0f / %.0f", kk, nn), num(kk / nn, 4), "\u2014", "\u2014", "hors crit\u00e8re 1"))
      controle(kk == 0, sprintf("Volet A, suites \u00e0 \u03b1 = 0,05 (inop\u00e9rant, R1) : taux exactement 0 (%.0f / %.0f)", kk, nn))
      next
    }
    ci95 <- ic_cp(kk, nn); ci <- ic_cp(kk, nn, 0.999)
    dans <- TAILLE[k, j] >= ci[1] && TAILLE[k, j] <= ci[2]
    verifie <- !(k == "Smirnov" && j == 2)
    niv <- c(niv, ligne_md(LIB_COURT[[k]], a_txt, num(TAILLE[k, j], 5),
                           sprintf("%.0f / %.0f", kk, nn), num(kk / nn, 4), txt_ic(ci95), txt_ic(ci),
                           if (!verifie) "m\u00eame \u00e9v\u00e9nement qu'\u00e0 \u03b1 = 0,10" else if (dans) "oui" else "**non**"))
    if (verifie)
      controle(dans, sprintf("Crit\u00e8re 1, niveau du volet A : %s, \u03b1 = %s, taille exacte %s dans l'IC \u00e0 99,9 %% %s",
                             LIB_COURT[[k]], a_txt, num(TAILLE[k, j], 5), txt_ic(ci)))
  }

  # Puissance de DW sous AR(1) par Imhof (statut 3 ; non bloquant, decision
  # du mainteneur : rapportee, hors code de sortie). A et M : copie de la
  # construction de dw_p_exacte() (R/engine.R). Un echec numerique
  # (uniroot(), integration) est rapporte, sans erreur R.
  DW_A <- local({
    A <- diag(c(1, rep(2, T_ - 2), 1))
    for (i in 1:(T_ - 1)) { A[i, i + 1] <- -1; A[i + 1, i] <- -1 }
    A
  })
  DW_M <- diag(T_) - matrix(1 / T_, T_, T_)
  DW_EIG <- eigen(DW_M %*% DW_A %*% DW_M, symmetric = TRUE)
  DW_LAM <- DW_EIG$values[1:(T_ - 1)]         # decroissantes ; valeur nulle ecartee
  # Points critiques de la loi nulle : P0(DW <= d_bas) = P0(DW >= d_haut) = a/2.
  dw_points_critiques <- function(a) {
    p0_sup <- function(d) .imhof_p_sup0(DW_LAM - d)
    lo <- min(DW_LAM) + 1e-9; hi <- max(DW_LAM) - 1e-9
    c(bas  = stats::uniroot(function(d) (1 - p0_sup(d)) - a / 2, c(lo, hi), tol = 1e-12)$root,
      haut = stats::uniroot(function(d) p0_sup(d) - a / 2, c(lo, hi), tol = 1e-12)$root)
  }
  # Vecteur construit de statistique DW = d : combinaison des vecteurs propres
  # extremes de M A M (DW = lambda_min cos^2 + lambda_max sin^2).
  vecteur_dw <- function(d) {
    lmin <- DW_LAM[T_ - 1]; lmax <- DW_LAM[1]
    s2 <- (d - lmin) / (lmax - lmin)
    sqrt(1 - s2) * DW_EIG$vectors[, T_ - 1] + sqrt(s2) * DW_EIG$vectors[, 1]
  }
  dw_puissance_imhof <- function(rho, dc) {
    n <- T_
    S <- outer(seq_len(n), seq_len(n), function(i, j) rho^abs(i - j))
    es <- eigen(S, symmetric = TRUE)
    S12 <- es$vectors %*% diag(sqrt(es$values)) %*% t(es$vectors)
    p_sup <- function(d) {
      h <- eigen(S12 %*% DW_M %*% (DW_A - d * diag(n)) %*% DW_M %*% S12, symmetric = TRUE, only.values = TRUE)$values
      .imhof_p_sup0(h[abs(h) > 1e-12])
    }
    (1 - p_sup(dc[["bas"]])) + p_sup(dc[["haut"]])
  }
  pts_ar <- c("N", grep("^A", names(POINTS_A), value = TRUE))
  rho_de <- function(pt) if (pt == "N") 0 else as.numeric(sub("^A", "", pt))
  IMHOF_ERREUR <- NULL
  DC <- tryCatch(dw_points_critiques(ALPHA), error = function(e) { IMHOF_ERREUR <<- conditionMessage(e); NULL })
  imhof <- stats::setNames(rep(NA_real_, length(pts_ar)), pts_ar)
  if (!is.null(DC)) {
    imhof <- vapply(pts_ar, function(pt) tryCatch(dw_puissance_imhof(rho_de(pt), DC),
                                                  error = function(e) NA_real_), numeric(1))
    # Recoupement : dw_p_exacte() aux points critiques rend alpha.
    p_rec <- c(dw_p_exacte(vecteur_dw(DC[["bas"]])), dw_p_exacte(vecteur_dw(DC[["haut"]])))
    controle(all(is.finite(p_rec)) && all(abs(p_rec - ALPHA) < 1e-6),
             sprintf(paste("Volet A, Imhof : recoupement par dw_p_exacte() sur des vecteurs construits de statistique",
                           "d_bas = %.6f et d_haut = %.6f : p = %s et %s (attendu \u03b1)"),
                     DC[["bas"]], DC[["haut"]], num(p_rec[1], 8), num(p_rec[2], 8)), bloquant = FALSE)
  }
  controle(is.null(IMHOF_ERREUR), sprintf("Volet A, Imhof : points critiques par uniroot()%s",
                                          if (is.null(IMHOF_ERREUR)) "" else paste0(" en \u00e9chec (", IMHOF_ERREUR, ")")),
           bloquant = FALSE)
  controle(all(is.finite(imhof)), sprintf("Volet A, Imhof : puissances calcul\u00e9es (%d / %d finies)",
                                          sum(is.finite(imhof)), length(imhof)), bloquant = FALSE)
  controle(isTRUE(abs(imhof[["N"]] - ALPHA) < 1e-6),
           sprintf("Volet A, puissance de DW par Imhof \u00e0 \u03c1 = 0 \u00e9gale \u00e0 \u03b1 (%s)", num(imhof[["N"]], 6)),
           bloquant = FALSE)

  # Sortie du volet A.
  cols_a <- c("Point", unlist(lapply(c("Runs", "DW", "MK", "Smirnov"), function(k)
    c(paste0(LIB_COURT[[k]], " : taux"), "IC 95 % (C-P)"))))
  tab_a <- function(j) c(entete_md(cols_a), vapply(names(POINTS_A), function(pt) {
    kk <- if (j == 1) KA[[pt]]$k1 else KA[[pt]]$k2
    v <- unlist(lapply(c("Runs", "DW", "MK", "Smirnov"), function(k)
      if (k == "Runs" && j == 2) c("inop\u00e9rant (R1, p_min = 4/70)\u00b9", "\u2014")
      else c(taux(kk[[k]], KA[[pt]]$n[[k]]), txt_ic(ic_cp(kk[[k]], KA[[pt]]$n[[k]])))))
    ligne_md(POINTS_A[[pt]]$lib, paste(v, collapse = " | "))
  }, ""))
  c1 <- vapply(seq_along(C1_RHO), function(i) {
    pt <- sprintf("A%+.1f", C1_RHO[i]); K <- KA[[pt]]
    ligne_md(num(C1_RHO[i], 1), taux(K$k1[["Runs"]], K$n[["Runs"]]), num(C1_SUITES[i]),
             paste(compat(C1_SUITES[i], K$k1[["Runs"]], K$n[["Runs"]]), collapse = " | "),
             taux(K$k1[["DW"]], K$n[["DW"]]), num(C1_DW[i]),
             paste(compat(C1_DW[i], K$k1[["DW"]], K$n[["DW"]]), collapse = " | "))
  }, "")
  im <- vapply(pts_ar, function(pt) {
    K <- KA[[pt]]; ci <- ic_cp(K$k1[["DW"]], K$n[["DW"]])
    ligne_md(POINTS_A[[pt]]$lib, if (is.finite(imhof[[pt]])) num(imhof[[pt]], 4) else "\u00e9chec num\u00e9rique",
             taux(K$k1[["DW"]], K$n[["DW"]]), txt_ic(ci),
             if (!is.finite(imhof[[pt]])) "\u2014" else if (imhof[[pt]] >= ci[1] && imhof[[pt]] <= ci[2]) "oui" else "**non**")
  }, "")
  duree_a <- as.numeric(difftime(Sys.time(), t_a, units = "secs"))
  SORTIE_A <- c(
    "## Puissance \u00e0 T = 8 sous le mod\u00e8le ajust\u00e9, volet A : p exactes, r\u00e9gime \u03c0\u0302 constant, jeu J1 (issue #116)", "",
    sprintf("Param\u00e8tres : R=%d ; graine=%s ; \u03b1=0,10 (principal) et 0,05 ; T=%d", OPT_R,
            format(OPT_GRAINE, scientific = FALSE), T_), "",
    paste("Statut : **constat de simulation sous des alternatives choisies, hors mod\u00e8le r\u00e9glementaire**,",
          "sauf la colonne Imhof du tableau A5 (approximation num\u00e9rique d'une quantit\u00e9 exacte). p exactes des",
          "fonctions du moteur (runs_p_exacte(), dw_p_exacte(), mk_p_exacte(), ks.test() sur la partition",
          "x_t > m\u00e9d(x)) appliqu\u00e9es \u00e0 l* = ln r* \u2212 moyenne, u* = r* \u2212 moyenne et r*, sans r\u00e9ajustement : c'est",
          "la p que retiendrait le moteur \u00e0 \u03c0\u0302* constant (v\u00e9rifi\u00e9 sur J1 observ\u00e9). Rejet si p < \u03b1.",
          "Alternatives sur le mod\u00e8le ajust\u00e9 (\u03b2\u0302, \u03c0\u0302_t, x_t gard\u00e9s ; \u03b5 remplac\u00e9, amplitudes en",
          "\u00e9carts-types de ln r_t) : protocole dans l'en-t\u00eate de tests/puissance_t8.R. Nombres al\u00e9atoires",
          "communs aux quinze points. IC : incertitude Monte-Carlo (fonction de R), pas l'erreur d'approximation en T."), "",
    "### T0 -- contexte", "",
    entete_md(c("Grandeur", "Valeur")),
    ligne_md("Jeu", JEU_A$libelle),
    ligne_md("Mod\u00e8le ajust\u00e9 (usp_ajuster())", txt_modele(FIT_A)),
    ligne_md("Partition de Smirnov (x_t > m\u00e9d(x))", paste0("{", paste(which(GRP), collapse = ", "), "}")),
    ligne_md("Plateforme de calcul (R, syst\u00e8me, machine, BLAS, LAPACK)", plateforme_calcul()),
    ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
    ligne_md("Graine de la matrice e", format(OPT_GRAINE, scientific = FALSE)),
    ligne_md("Commit", commit_depot()),
    ligne_md("R\u00e9plications par point", as.character(OPT_R)),
    ligne_md("Dur\u00e9e (s)", sprintf("r\u00e9plications %.1f (%.2f ms par s\u00e9rie et par point) ; volet A total %.1f",
                                      duree_rep_a, 1000 * duree_rep_a / (OPT_R * length(POINTS_A)), duree_a)), "",
    "### A1 -- taux de rejet, \u03b1 = 0,10", "", tab_a(1), "",
    "La ligne des suites sur ratios bruts (Runsr) est identique \u00e0 celle des suites sur z r\u00e9plication par r\u00e9plication (crit\u00e8re 2) : elle n'est pas r\u00e9p\u00e9t\u00e9e.", "",
    "### A2 -- taux de rejet, \u03b1 = 0,05 (compl\u00e9ment)", "", tab_a(2), "", "\u00b9 Suites \u00e0 \u03b1 = 0,05 : test inop\u00e9rant (r\u00e8gle R1) ; \u00e0 T = 8 sans ex aequo, p_min = 4/70 = 0,0571 \u2265 0,05, aucune valeur observ\u00e9e ne peut donner p < 0,05 (le moteur restitue la ligne en diagnostic INFO) ; taux nul par construction, v\u00e9rifi\u00e9 (taux exactement 0) sur la ligne N, hors crit\u00e8re 1.", "",
    "### A3 -- niveau : ligne N contre la taille exacte (crit\u00e8re 1)", "",
    entete_md(c("Ligne", "\u03b1", "Taille exacte", "Rejets / n", "Taux", "IC 95 % (C-P)", "IC 99,9 % (C-P)",
                "Taille dans l'IC \u00e0 99,9 %")),
    niv, "", "\u00b9 Suites \u00e0 \u03b1 = 0,05 : test inop\u00e9rant (r\u00e8gle R1) ; \u00e0 T = 8 sans ex aequo, p_min = 4/70 = 0,0571 \u2265 0,05, aucune valeur observ\u00e9e ne peut donner p < 0,05 (le moteur restitue la ligne en diagnostic INFO) ; taux nul par construction, v\u00e9rifi\u00e9 (taux exactement 0) sur la ligne N, hors crit\u00e8re 1.", "",
    paste("Crit\u00e8re 1 : cinq v\u00e9rifications (suites \u00e0 0,10 ; Durbin-Watson \u00e0 0,10 et 0,05 ; Mann-Kendall \u00e0 0,10",
          "et 0,05 ; Smirnov une fois, m\u00eame \u00e9v\u00e9nement aux deux \u03b1), chacune par l'IC bilat\u00e9ral de Clopper-Pearson",
          "\u00e0 99,9 %, qui limite le risque de faux \u00e9chec d'un contr\u00f4le juste ; l'IC \u00e0 95 % est donn\u00e9 pour la lecture."), "",
    "Tailles exactes par \u00e9num\u00e9ration des 70 partitions (suites, Smirnov) et de la loi mahonienne (Mann-Kendall) \u00e0 T = 8 sans ex aequo ; Durbin-Watson : loi continue, taille \u03b1.", "",
    "### A4 -- compatibilit\u00e9 avec le constat C1.a (AR(1) stationnaire, \u03b1 = 0,10 ; non bloquant)", "",
    entete_md(c("\u03c1", "Suites : taux", "C1.a", "z", "Compatible", "DW : taux", "C1.a", "z", "Compatible")),
    c1, "",
    "\u00c0 \u03c0\u0302 constant, l'alternative A est l'AR(1) de C1.a \u00e0 un facteur positif pr\u00e8s (m\u00eame loi des p) ; z : \u00e9cart normalis\u00e9 de deux proportions ind\u00e9pendantes (C1.a sur 20 000 tirages), compatible si |z| \u2264 1,96, comparaisons non corrig\u00e9es pour la multiplicit\u00e9.", "",
    "### A5 -- puissance de Durbin-Watson sous AR(1) par Imhof (\u03b1 = 0,10 ; non bloquant)", "",
    entete_md(c("Point", "Imhof", "Volet A : taux", "IC 95 % (C-P)", "Imhof dans l'IC")),
    im, "",
    paste("Imhof : P(DW \u2264 d_bas) + P(DW \u2265 d_haut) sous \u03b5' ~ N(0, \u03a3_\u03c1), \u03a3_\u03c1 = (\u03c1^|i\u2212j|), d_bas et d_haut",
          "quantiles \u03b1/2 et 1 \u2212 \u03b1/2 de la loi nulle de dw_p_exacte(), chaque probabilit\u00e9 par .imhof_p_sup0()",
          "sur les valeurs propres de \u03a3^(1/2) M (A \u2212 d I) M \u03a3^(1/2) : approximation num\u00e9rique (int\u00e9gration",
          "d'Imhof) d'une quantit\u00e9 exacte, statut 3."), "")
  ecrire_console(SORTIE_A)
}

###############################################################################
#  VOLET B
###############################################################################
SORTIES_B <- list()
if (OPT_VOLET %in% c("tout", "B")) {
  jeux_b <- if (OPT_JEU == "tous") c("J1", "J2") else OPT_JEU
  E_B <- tirer_e(OPT_GRAINE + 1, OPT_R_CHAINE)
  for (jn in jeux_b) {
    t_b <- Sys.time()
    JEU <- charger_jeu(jn)
    X <- JEU$x
    FIT0 <- usp_ajuster(X, JEU$y)
    n_int0 <- length(INTEGRITE)
    # Tranche
    if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R_CHAINE } else {
      m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
      if (length(m) != 3L) stop("--tranche : forme i/K attendue")
      i <- as.integer(m[2]); K <- as.integer(m[3])
      if (K < 1L || i < 1L || i > K || K > OPT_R_CHAINE) stop("--tranche : 1 <= i <= K <= R-chaine")
      DEBUT <- as.integer(floor((i - 1) * OPT_R_CHAINE / K)) + 1L; FIN <- as.integer(floor(i * OPT_R_CHAINE / K))
    }
    # Critere 3 : chaine sur le jeu observe contre run_engine().
    t_c <- Sys.time()
    if (is.null(RES_OBS[[jn]])) RES_OBS[[jn]] <- engine_observe(JEU)
    res <- RES_OBS[[jn]]
    controle(isTRUE(res$ok), sprintf("Crit\u00e8re 3, %s : run_engine() sur le jeu observ\u00e9 ok", jn))
    ch0 <- chaine(X, JEU$y, OPT_GRAINE_IC, OPT_B)
    l_re <- lignes_six(engine_table_tests(res))
    ok_l <- vapply(SIX, function(k) {
      a <- l_re[[k]]; b <- ch0$lignes[[k]]
      cols <- setdiff(names(a), "p_exacte")
      identical(unname(as.list(a[cols])), unname(as.list(b[cols]))) &&
        (if (k == "DW") isTRUE(all.equal(a$p_exacte, b$p_exacte, tolerance = 1e-10))
         else identical(a$p_exacte, b$p_exacte))
    }, logical(1))
    controle(all(ok_l), sprintf(paste("Crit\u00e8re 3, %s : six lignes de engine_table_tests() de la cha\u00eene r\u00e9duite",
                                      "identiques \u00e0 celles de run_engine() (B = %d, graine %s)%s"),
                                jn, OPT_B, format(OPT_GRAINE_IC, scientific = FALSE),
                                if (all(ok_l)) "" else paste0(" ; diff\u00e9rentes : ", paste(SIX[!ok_l], collapse = ", "))))
    controle(identical(ch0$boucle$sigma_boot, res$bootstrap$sigma_boot) &&
               identical(ch0$boucle$z_boot, res$bootstrap$z_boot),
             sprintf("Crit\u00e8re 3, %s : sigma_boot et z_boot de la boucle r\u00e9duite identiques \u00e0 ceux de usp_bootstrap()", jn))
    Y_N <- t(apply(E_B, 1, function(e) simuler_alt(FIT0, e)))
    controle(identical(Y_N, engine_sous_graine(OPT_GRAINE + 1, t(vapply(seq_len(OPT_R_CHAINE),
                                                                         function(b) usp_simuler(FIT0), numeric(T_))))),
             sprintf("Crit\u00e8re 3, %s : ligne N identique \u00e0 usp_simuler(FIT0) (m\u00eame graine, au bit pr\u00e8s)", jn))
    t_controle <- as.numeric(difftime(Sys.time(), t_c, units = "secs"))
    DUREE_CONTROLES <- DUREE_CONTROLES + t_controle

    # Replications.
    t_r <- Sys.time()
    cpt <- numeric(0)
    for (b in seq.int(DEBUT, FIN)) for (pt in names(POINTS_B)) {
      y <- simuler_alt(FIT0, POINTS_B[[pt]]$phi(E_B[b, ], X))
      cpt <- compter_chaine(cpt, pt, chaine(X, y, OPT_GRAINE_IC + 1000 * b, OPT_B))
    }
    t_rep <- as.numeric(difftime(Sys.time(), t_r, units = "secs"))
    n_rep <- (FIN - DEBUT + 1L) * length(POINTS_B)
    complet <- is.na(OPT_TRANCHE)
    tb <- tableaux_chaine(cpt, FIN - DEBUT + 1L, OPT_B, complet)
    # Critere 5 (toujours) ; critere 4 (execution d'un seul tenant seulement).
    controle(!length(tb$echecs5), sprintf("Crit\u00e8re 5, %s : aucune p manquante hors motif compt\u00e9%s", jn,
                                          if (length(tb$echecs5)) paste0(" (", paste(tb$echecs5, collapse = ", "), ")") else ""))
    if (complet)
      controle(!length(tb$echecs4), sprintf(paste("Crit\u00e8re 4, %s : niveau du volet B (ligne N, borne inf\u00e9rieure",
                                                  "unilat\u00e9rale 99,9 %% \u2264 \u03b1)%s"), jn,
                                            if (length(tb$echecs4)) paste(" --", texte_crit4(tb)) else ""),
               statut_ok = texte_crit4(tb))
    PAR <- sprintf("jeu=%s;R_chaine=%d;graine=%.0f;graine_ic=%.0f;B=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g",
                   jn, OPT_R_CHAINE, OPT_GRAINE, OPT_GRAINE_IC, OPT_B, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA)
    CTX <- c(
      jeu = JEU$libelle, modele = txt_modele(FIT0),
      configuration = sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, \u03b1 = %g (sans effet sur les six lignes hors \u03b1)",
                              METHODE, SEGMENT, ANNEXE, NATURE, ALPHA),
      points = paste(vapply(POINTS_B, `[[`, "", "lib"), collapse = " ; "),
      graines = sprintf("matrice e %.0f ; bootstrap de la r\u00e9plication b : %.0f + 1000 b ; observ\u00e9 : %.0f", OPT_GRAINE + 1, OPT_GRAINE_IC, OPT_GRAINE_IC),
      B = as.character(OPT_B), generateur = paste(ENGINE_RNG_KIND, collapse = ", "), commit = commit_depot(),
      plateforme = plateforme_calcul(), empreintes = EMPREINTES)
    stopifnot(identical(names(CTX), names(LIBELLES_CONTEXTE)))
    ok_jeu <- length(INTEGRITE) == n_int0
    duree_b <- as.numeric(difftime(Sys.time(), t_b, units = "secs"))
    S <- c(sprintf("## Puissance \u00e0 T = 8, volet B (cha\u00eene r\u00e9duite), jeu %s (issue #116)", jn), "",
           sprintf("Param\u00e8tres : %s", PAR), "", statut_b(), "",
           "### T0 -- contexte", "", entete_md(c("Grandeur", "Valeur")), lignes_contexte(CTX),
           ligne_md("R\u00e9plications par point", sprintf("%d (trait\u00e9es : %d \u00e0 %d)", OPT_R_CHAINE, DEBUT, FIN)),
           ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4les %.1f ; r\u00e9plications %.1f (%.2f s par r\u00e9plication et par point) ; total du jeu %.1f",
                                             t_controle, t_rep, t_rep / n_rep, duree_b)),
           ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9 du jeu", if (ok_jeu) "OK" else "\u00c9CHEC"), "")
    if (!complet) S <- c(S, "Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", "")
    S <- c(S, tb$lignes)
    SORTIES_B[[jn]] <- S
    ecrire_console(S)
    # Lignes machine d'une tranche, imprimees en fin d'execution, apres le
    # critere 6 de fin, que la ligne INTEGRITE couvre donc aussi.
    if (!complet) MACHINE <- list(PAR = PAR, CTX = CTX, cpt = cpt)
  }
}

# --- Fin : critere 6, controles, ecriture ----------------------------------------------
verifier_depot(MD5_DEBUT, "fin")
duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
BILAN <- c("### Contr\u00f4les d'int\u00e9grit\u00e9 et crit\u00e8res bloquants (toute l'ex\u00e9cution)", "", paste("-", CONTROLES), "",
           sprintf(paste("Dur\u00e9e totale : %.0f s, dont contr\u00f4les de transcription (run_engine() et cha\u00eene",
                         "sur les jeux observ\u00e9s, ligne N) %.0f s et hors contr\u00f4les %.0f s. Bilan : %s"),
                   duree, DUREE_CONTROLES, duree - DUREE_CONTROLES,
                   if (length(INTEGRITE)) sprintf("\u00c9CHEC (%d crit\u00e8re(s))", length(INTEGRITE)) else "OK"), "")
if (is.na(OPT_TRANCHE)) {
  ecrire_console(BILAN)
  if (!length(INTEGRITE)) {
    if (!is.null(SORTIE_A)) ecrire_fichier("exact-J1", c(SORTIE_A, BILAN))
    for (jn in names(SORTIES_B)) ecrire_fichier(paste0("chaine-", jn), c(SORTIES_B[[jn]], BILAN))
  }
} else {
  # Tranche : bilan, puis lignes machine (FIN en derniere ligne).
  ecrire_console(BILAN)
  ecrire_console(c(paste0("PARAMETRES\t", MACHINE$PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                   sprintf("CONTEXTE\t%s\t%s", names(MACHINE$CTX), MACHINE$CTX),
                   paste0("INTEGRITE\t", if (!length(INTEGRITE)) "OK" else "ECHEC"),
                   sprintf("NCOMPTES\t%d", length(MACHINE$cpt)),
                   sprintf("COMPTE\t%s\t%.0f", names(MACHINE$cpt), MACHINE$cpt),
                   sprintf("FIN\t%d", length(MACHINE$cpt))))
}
quit(status = if (length(INTEGRITE)) 1L else 0L)
