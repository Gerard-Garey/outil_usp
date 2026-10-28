###############################################################################
#  tests/couverture_ic_sigma_t8.R  --  COUVERTURE A T = 8 DE L'INTERVALLE
#  BOOTSTRAP DE SIGMA, METHODE LOGNORMALE (issue #305, branche Fn, etape 3)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats ; parallel, utils et tools (livres avec R) :
#  parallel::mclapply(), utils::sessionInfo(), tools::md5sum(). Il ne modifie
#  ni R/engine.R ni tests/reference/ : le moteur est charge par
#  tests/outils_tests.R (source(R/engine.R)), qui porte aussi commit_depot(),
#  motifs_non_versionnable(), garde_ecrasement(), empreinte_sans_commentaires()
#  et TOLERANCE (definitions uniques).
#
#  Protocole : specification d'actuary
#  docs/specifications/fn-incertitude-bootstrap.md, par. 2 (2.1 a 2.8),
#  approuvee par le mainteneur au point d'arret D1-Fn (27/10/2026) :
#  Q-D1-Fn-4 (plan, option (a) : chemin usp_bootstrap(), B = 999 ; critere
#  K-C1 a K-C4 et profils Psi0 a Psi4 approuves tels quels avant toute
#  execution), Q-D1-Fn-5 (I4 mesure comme candidat), Q-D1-Fn-6 (cible sigma0 ;
#  A1 et E[corr x sigma chapeau]/sigma0 descriptifs).
#
#  Statut des valeurs : CONSTAT DE SIMULATION SOUS DEUX MODELES AJUSTES (J1,
#  J2), pas un resultat general. Les classes et les profils sont evalues
#  mecaniquement, SANS CONCLURE : la lecture revient a actuary, la decision
#  (D2-Fn) au mainteneur.
#
#  Plan (par. 2.2) : J1 = tests/donnees/donnees_ln.csv (delta0 = 1, au bord),
#  J2 = tests/donnees/donnees_ln_interieur.csv (delta0 = 0,664, interieur) ;
#  T = 8, volumes x fixes ; fit0 = usp_ajuster() du jeu observe, sigma0 =
#  fit0$sigma. Pour chaque jeu simule r = 1..R :
#    1. y = usp_simuler(fit0) sous engine_sous_graine(G_ext(r)) ;
#    2. engine_valider_donnees(x, y) avec les arguments du cas premium
#       (methode premium, donnees brutes, segment 1 de l'annexe II) ;
#    3. usp_ajuster(x, y) ;
#    4. usp_valider_ajustement(fit, "premium") ; refus et echecs comptes a
#       part, couverture conditionnelle a l'acceptation ;
#    5. usp_bootstrap(fit, B = 999, seed = G_int(r)) : sigma* = $sigma_boot,
#       sigma*_r = $sigma_boot_restreint.
#  Graines declarees (R <= 50 000) : G_ext(r) = 305 200 000 + r (J1),
#  305 250 000 + r (J2) ; G_int(r) = 305 300 000 + r (J1), 305 350 000 + r
#  (J2) ; flux complementaire du moteur G_int(r) + 539 169. Chaque r porte
#  ses propres graines : le resultat ne depend ni du nombre de processus, ni
#  du decoupage en tranches.
#
#  Intervalles (par. 2.3), sur l'echelle de sigma, quantiles empiriques q_p de
#  type 7 de sigma* (ceux de res$ic_bootstrap), niveau 1 - 2 alpha :
#    I1 percentile [q_a, q_(1-a)] ; I2 "basic" [2 s - q_(1-a), 2 s - q_a] ;
#    I3 restreint, percentile de sigma*_r ; I4 "basic" sur l'echelle
#    logarithmique [s^2 / q_(1-a), s^2 / q_a] ; A1 percentile x corr,
#    corr = sqrt((T + 1)/(T - 1)) (usp_parametre()$correction_taille) ;
#  s = sigma chapeau du jeu simule ; niveaux 90 % (alpha = 0,05) et 95 %
#  (alpha = 0,025). Couverture : borne basse <= sigma0 <= borne haute.
#  Un intervalle n'est forme que si son echantillon bootstrap compte plus de
#  20 valeurs (regle de run_engine() pour ic_bootstrap et
#  ic_bootstrap_restreint) ; sigma* de 20 valeurs ou moins : echec compte a
#  part (echec_beff) ; sigma*_r de 20 valeurs ou moins : I3 absent du jeu.
#
#  Critere (par. 2.5) et profils (par. 2.6) : reportes SANS MODIFICATION dans
#  TEXTE_CRITERE_305 et TEXTE_PROFILS_305 (copie du texte de la
#  specification ; controle (t305) : presence a l'identique dans la
#  specification), evalues mecaniquement. IC de Clopper-Pearson a 95 % par
#  qbeta(), classes calculees sur les valeurs non arrondies.
#  Controles d'integrite K-C3 (un seul echec met INTEGRITE a ECHEC) :
#    (1) md5 de R/engine.R et SHA (git rev-parse HEAD) au debut et a la fin
#        du calcul, egaux entre eux, a ceux du JOURNAL de lancement et a ceux
#        portes par chaque tranche ;
#    (2) sigma0 de J1 et J2 egal a ajustement$sigma de
#        tests/reference/premium.rds et premium_interieur.rds a TOLERANCE
#        pres (relative) ;
#    (3) percentile du script (perc_script()), applique a l'expression du
#        moteur qui porte sigma* sur l'echelle de sigma_USP (lognormal :
#        cred x sigma* x corr + (1 - cred) x sigma_std ; Merz-Wuthrich :
#        cred x sigma* + (1 - cred) x sigma_std), identical() a
#        ic_bootstrap des six references ;
#    (4) sur le premier jeu accepte de chaque tranche, bornes des cinq
#        intervalles aux deux niveaux recalculees par une ecriture
#        independante (statistiques d'ordre et interpolation de type 7 en
#        clair, bornes_independantes()), egales a 1e-12 relatif pres ; une
#        tranche sans jeu accepte : controle non fait, ECHEC ;
#    (5) sans objet : option (b) non utilisee.
#  Controle de forme (t305), hors K-C3, ajoute a INTEGRITE : texte du critere
#  et des profils present a l'identique dans la specification ; verifie
#  avant la boucle de calcul (refus immediat sinon) et repris au tableau des
#  controles.
#
#  Modes :
#    --essai : R = 4 par jeu (--R pour changer), B = 199 ; sorties ecrites
#      dans un dossier temporaire (non versionnables) ; --ecrire refuse.
#    --prevol [--unites 5] : couts unitaires a 1, 2, 3 et 4 processus
#      concurrents (les memes UNITES jeux de J1 puis de J2 dans chaque
#      processus, graines du pre-vol GRAINES_PREVOL, disjointes de celles de
#      la mesure), puis choix du niveau L0 / L1 / L2 par la regle du par. 2.7
#      (premier niveau dont la duree planifiee tient dans 2 h d'horloge) ;
#      rien d'ecrit.
#    mesure : --R <n> obligatoire (fixe par le pre-vol, ecrit au JOURNAL de
#      lancement avant tout calcul) ; [--niveau Lk] (controle R = R du
#      niveau, consigne au JOURNAL) ; [--processus k] ; [--travail DOSSIER]
#      ; [--ecrire [--remplacer]].
#  Reprise (M42 (b)) : chaque tranche de TAILLE_TRANCHE jeux consecutifs d'un
#  jeu (J1 ou J2) est ecrite dans le dossier de travail (hors du depot) des
#  qu'elle est complete (ecriture dans un fichier temporaire, puis
#  renommage) ; une relance avec le meme dossier reprend aux tranches
#  absentes. Une tranche presente dont le contexte (B, SHA, md5 du moteur et
#  du script, plateforme) differe du contexte courant arrete le script : pas
#  de melange. Dossier de travail par defaut : <parent de la racine du
#  depot>/issue305-travail-R<R> (mesure) ; dossier temporaire hors du
#  tempdir() de la session, conserve a la sortie (essai).
#  Sorties (par. 2.8) : dans le dossier de travail, toujours ; avec --ecrire,
#  copiees dans docs/tableaux/ si INTEGRITE OK :
#    <AAAAMMJJ>-issue305-couverture-ic-sigma.md (tableaux),
#    <AAAAMMJJ>-issue305-couverture-ic-sigma-brut.tsv (une ligne par jeu
#    simule, valeurs en %.17g, sans duree),
#    <AAAAMMJJ>-issue305-journal-mesure.md (JOURNAL),
#  AAAAMMJJ : date (UTC) du premier lancement, lue au JOURNAL. --ecrire exige
#  un commit propre et le code du depot (motifs_non_versionnable()) et la
#  garde d'ecrasement (garde_ecrasement() ; --remplacer pour un fichier suivi).
#
#  Usage (depuis la racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/couverture_ic_sigma_t8.R --essai [--R 4] [--processus k]
#      Rscript tests/couverture_ic_sigma_t8.R --prevol [--unites 5]
#      Rscript tests/couverture_ic_sigma_t8.R --R 1000 [--niveau L1]
#          [--processus 4] [--travail DOSSIER] [--ecrire [--remplacer]]
#  Parallelisme : parallel::mclapply() sur r (fork ; un seul processus sous
#  Windows). Derniere ligne de la console : INTEGRITE OK ou INTEGRITE ECHEC.
#  Code de sortie : 0 si INTEGRITE OK, 1 sinon (et sur tout refus).
###############################################################################

t_debut <- Sys.time()

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
CONNUES <- c("--essai", "--prevol", "--R", "--processus", "--ecrire", "--remplacer",
             "--travail", "--niveau", "--unites")
AVEC_VALEUR <- c("--R", "--processus", "--travail", "--niveau", "--unites")
local({
  i <- 1L
  while (i <= length(ARGS)) {
    if (!ARGS[i] %in% CONNUES) stop("option inconnue : ", ARGS[i])
    i <- i + if (ARGS[i] %in% AVEC_VALEUR) 2L else 1L
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
refuser <- function(...) { message("REFUS : ", ...); quit(status = 1L) }
OPT_ESSAI   <- "--essai" %in% ARGS
OPT_PREVOL  <- "--prevol" %in% ARGS
OPT_ECRIRE  <- "--ecrire" %in% ARGS
OPT_REMPLACER <- "--remplacer" %in% ARGS
OPT_R_TXT   <- lire_option("--R", NA_character_)
OPT_NIVEAU  <- lire_option("--niveau", NA_character_)
OPT_TRAVAIL <- lire_option("--travail", NA_character_)
OPT_UNITES  <- suppressWarnings(as.integer(lire_option("--unites", "5")))
COEURS <- tryCatch(parallel::detectCores(), error = function(e) NA_integer_)
OPT_PROC    <- suppressWarnings(as.integer(lire_option("--processus",
                 as.character(if (.Platform$OS.type == "windows") 1L else max(1L, min(4L, COEURS, na.rm = TRUE))))))
MODE <- if (OPT_PREVOL) "prevol" else if (OPT_ESSAI) "essai" else "mesure"
if (OPT_PREVOL && OPT_ESSAI) refuser("--prevol et --essai sont exclusifs")
if (OPT_PREVOL && any(c("--R", "--ecrire", "--remplacer", "--travail", "--niveau", "--processus") %in% ARGS))
  refuser("--prevol : seule l'option --unites est admise")
if (MODE != "prevol" && "--unites" %in% ARGS) refuser("--unites : reserve a --prevol")
if (OPT_ESSAI && OPT_ECRIRE) refuser("--ecrire refuse sous --essai (sorties non versionnables, M41 (c))")
if (OPT_ESSAI && !is.na(OPT_NIVEAU)) refuser("--niveau : reserve a la mesure")
if (OPT_REMPLACER && !OPT_ECRIRE) refuser("--remplacer : reserve a --ecrire")
if (MODE == "mesure" && is.na(OPT_R_TXT)) refuser("mesure : --R <n> obligatoire (fixe par le pre-vol, par. 2.7)")
if (is.na(OPT_UNITES) || OPT_UNITES < 1L || OPT_UNITES > 1000L) refuser("--unites : entier de 1 a 1000")
if (is.na(OPT_PROC) || OPT_PROC < 1L) refuser("--processus : entier >= 1")
if (.Platform$OS.type == "windows" && OPT_PROC > 1L) refuser("--processus > 1 : fork indisponible sous Windows")

# --- Protocole (constantes de la specification, par. 2.2 a 2.7) -------------
B_MESURE <- 999L
B_ESSAI  <- 199L
R_ESSAI  <- 4L
R_MAX    <- 50000L
TAILLE_TRANCHE <- 100L
NIVEAUX_R <- c(L0 = 2000L, L1 = 1000L, L2 = 500L)        # par. 2.7
BUDGET_S  <- 2 * 3600                                     # 2 h d'horloge, 4 coeurs
ALPHA_NIV <- c("90" = 0.05, "95" = 0.025)                # alpha par queue
RHO_NIV   <- 2 * ALPHA_NIV                                # non-couverture nominale
TOL_IND   <- 1e-12                                        # K-C3 (4)
SEUIL_REFUS <- 0.02                                       # Psi0
CODES <- c("I1", "I2", "I3", "I4", "A1")
LIB_CODES <- c(I1 = "I1 percentile", I2 = "I2 \u00ab basic \u00bb", I3 = "I3 restreint (percentile de \u03c3*_r)",
               I4 = "I4 \u00ab basic \u00bb log", A1 = "A1 percentile \u00d7 corr")
JEUX <- c(J1 = "tests/donnees/donnees_ln.csv", J2 = "tests/donnees/donnees_ln_interieur.csv")
REF_JEUX <- c(J1 = "premium", J2 = "premium_interieur")
REFS_SIX <- c("premium", "reserve1", "reserve2", "premium_ii6", "premium_net", "premium_interieur")
GRAINES <- list(J1 = c(ext = 305200000, int = 305300000), J2 = c(ext = 305250000, int = 305350000))
# Graines du pre-vol (non fixees par la specification) : plages disjointes de
# celles de la mesure, de leurs flux complementaires et de celles du pilote.
GRAINES_PREVOL <- list(J1 = c(ext = 305600000, int = 305700000), J2 = c(ext = 305650000, int = 305750000))
SPEC <- file.path("docs", "specifications", "fn-incertitude-bootstrap.md")
SCRIPT_DEPOT <- "tests/couverture_ic_sigma_t8.R"
STATUTS <- c("ok", "refus_donnees", "refus_ajustement", "echec_ajustement", "echec_bootstrap",
             "echec_beff", "echec_autre")

# --- Chargement du moteur et des outils --------------------------------------
FICHIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) f else NA_character_
})
DOSSIER_SCRIPT <- if (!is.na(FICHIER_SCRIPT)) dirname(FICHIER_SCRIPT) else "tests"
# tests/outils_tests.R fait source(R/engine.R) (local = TRUE, ici
# l'environnement global) et definit RACINE, TOLERANCE, commit_depot(),
# motifs_non_versionnable(), garde_ecrasement(), empreinte_sans_commentaires().
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# --- Outils de forme ---------------------------------------------------------
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)
# Ecriture des fichiers en binaire (fins de ligne LF sur toutes les
# plateformes) : ecrasement ("wb") ou ajout ("ab").
ecrire_fichier <- function(f, lignes, mode = "wb") {
  con <- file(f, open = mode); on.exit(close(con))
  writeLines(enc2utf8(lignes), con, sep = "\n", useBytes = TRUE)
}
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
num <- function(x, d = 4) if (length(x) != 1L || is.na(x)) "\u2014" else
  sub(".", ",", sprintf(paste0("%.", d, "f"), x), fixed = TRUE)
txt_ic <- function(ci, d = 4) if (anyNA(ci)) "\u2014" else sprintf("[%s ; %s]", num(ci[1], d), num(ci[2], d))
md5_fichier <- function(f) if (is.na(f) || !file.exists(f)) "absent" else unname(tools::md5sum(f))
secs <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))
horodatage <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
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
# Chemin absolu d'un chemin existant ou non : plus proche ancetre existant
# normalise, puis composantes restantes (le dossier de travail est controle
# avant sa creation).
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

# --- Contexte au debut du calcul (K-C3 (1)) ----------------------------------
MD5_MOTEUR_DEBUT <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_DEBUT <- sha_head()
COMMIT_DEBUT <- commit_depot(SCRIPT_DEPOT)
MD5_SCRIPT <- md5_fichier(FICHIER_SCRIPT)
PLATEFORME <- plateforme_calcul()
EMPREINTES <- empreintes_code()

###############################################################################
#  ESSAI ET MESURE : PARAMETRES, GARDES DE --ecrire ET JOURNAL DE LANCEMENT
#  (avant tout appel couteux : refus de --ecrire et garde d'ecrasement des
#  sorties evalues avant tout calcul, #205)
###############################################################################
if (MODE != "prevol") {
  B_RUN <- if (OPT_ESSAI) B_ESSAI else B_MESURE
  R_RUN <- suppressWarnings(as.integer(if (is.na(OPT_R_TXT)) R_ESSAI else OPT_R_TXT))
  if (is.na(R_RUN) || R_RUN < 1L || R_RUN > R_MAX) refuser("--R : entier de 1 a ", R_MAX)
  if (!is.na(OPT_NIVEAU)) {
    if (!OPT_NIVEAU %in% names(NIVEAUX_R)) refuser("--niveau : L0, L1 ou L2")
    if (NIVEAUX_R[[OPT_NIVEAU]] != R_RUN) refuser("--niveau ", OPT_NIVEAU, " : R = ", NIVEAUX_R[[OPT_NIVEAU]], ", et non ", R_RUN)
  }
  # Gardes de --ecrire, avant tout calcul (reprises avant d'ecrire).
  if (OPT_ECRIRE) {
    nv <- motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")
    if (length(nv)) refuser("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
                           " -- lancer depuis un worktree au commit propre")
    if (!dir.exists(file.path(RACINE, "docs", "tableaux")))
      refuser("dossier de sortie introuvable : ", file.path(RACINE, "docs", "tableaux"))
  }
  # Dossier de travail : hors du depot pour la mesure ; temporaire pour l'essai.
  TRAVAIL <- if (!is.na(OPT_TRAVAIL)) OPT_TRAVAIL else if (OPT_ESSAI) tempfile("essai305_", tmpdir = dirname(tempdir())) else
    file.path(dirname(normalizePath(RACINE, winslash = "/")), sprintf("issue305-travail-R%d", R_RUN))
  if (sous_depot(TRAVAIL)) refuser("--travail : dossier sous le depot refuse : ", TRAVAIL)
  if (!dir.exists(TRAVAIL)) dir.create(TRAVAIL, recursive = TRUE)
  TRAVAIL <- normalizePath(TRAVAIL, winslash = "/")

  # --- JOURNAL de lancement (R ecrit avant tout calcul) -------------------------
  JOURNAL_T <- file.path(TRAVAIL, "JOURNAL.md")
  CTX <- c(B = B_RUN, sha = SHA_DEBUT, md5_moteur = MD5_MOTEUR_DEBUT, md5_script = MD5_SCRIPT,
           plateforme = PLATEFORME, essai = if (OPT_ESSAI) "oui" else "non", taille_tranche = TAILLE_TRANCHE)
  txt_ctx <- function(ctx) paste(names(ctx), ctx, sep = "=", collapse = " || ")
  lire_journal <- function() {
    jl <- readLines(JOURNAL_T, warn = FALSE, encoding = "UTF-8")
    champ <- function(cle) {
      m <- regmatches(jl, regexec(paste0("^- ", cle, " : (.*)$"), jl))
      v <- vapply(m[lengths(m) == 2L], `[`, "", 2L)
      if (length(v)) v[1] else NA_character_
    }
    list(lignes = jl, R = champ("R par jeu"), sha = champ("SHA \\(git rev-parse HEAD\\) au lancement"),
         md5 = champ("md5 R/engine\\.R au lancement"), date = champ("Date des sorties"),
         ctx = champ("Contexte des tranches"))
  }
  if (!file.exists(JOURNAL_T)) {
    jl <- c(sprintf("# JOURNAL de la mesure #305 (Fn, \u00e9tape 3 : couverture \u00e0 T = 8 de l'intervalle bootstrap de \u03c3)%s",
                    if (OPT_ESSAI) " -- ESSAI, non versionnable" else ""),
            "",
            sprintf("- Lancement : %s", horodatage()),
            sprintf("- Date des sorties : %s", format(Sys.time(), "%Y%m%d", tz = "UTC")),
            sprintf("- R par jeu : %d", R_RUN),
            sprintf("- Niveau : %s", if (is.na(OPT_NIVEAU)) "non d\u00e9clar\u00e9 (--niveau absent)" else
              sprintf("%s (pr\u00e9-vol, sp\u00e9cification par. 2.7)", OPT_NIVEAU)),
            sprintf("- B : %d", B_RUN),
            sprintf("- Processus : %d ; taille des tranches : %d", OPT_PROC, TAILLE_TRANCHE),
            sprintf("- SHA (git rev-parse HEAD) au lancement : %s", SHA_DEBUT),
            sprintf("- Commit (commit_depot()) : %s", COMMIT_DEBUT),
            sprintf("- md5 R/engine.R au lancement : %s", MD5_MOTEUR_DEBUT),
            sprintf("- Empreinte sans commentaires de R/engine.R : %s", empreinte_sans_commentaires()),
            sprintf("- Empreintes md5 du code ex\u00e9cut\u00e9 : %s", EMPREINTES),
            sprintf("- md5 sp\u00e9cification (%s) : %s", SPEC, md5_fichier(file.path(RACINE, SPEC))),
            sprintf("- Plateforme : %s", PLATEFORME),
            sprintf("- Locale : LC_ALL=%s ; LC_CTYPE=%s", Sys.getenv("LC_ALL"), Sys.getlocale("LC_CTYPE")),
            sprintf("- Dossier de travail : %s", TRAVAIL),
            sprintf("- Commande : Rscript %s %s", SCRIPT_DEPOT, paste(ARGS, collapse = " ")),
            sprintf("- Contexte des tranches : %s", txt_ctx(CTX)))
    ecrire_fichier(JOURNAL_T, jl)
  } else {
    J0 <- lire_journal()
    if (!identical(J0$R, as.character(R_RUN))) refuser("reprise : R du JOURNAL (", J0$R, ") different de --R ", R_RUN)
    if (!identical(J0$ctx, txt_ctx(CTX))) refuser("reprise : contexte du JOURNAL different du contexte courant (B, SHA, md5, plateforme) -- autre --travail")
    ecrire_fichier(JOURNAL_T, sprintf("- Reprise : %s ; commande : Rscript %s %s", horodatage(), SCRIPT_DEPOT,
                                      paste(ARGS, collapse = " ")), mode = "ab")
  }
  J0 <- lire_journal()
  DATE_SORTIES <- J0$date
  NOM_MD  <- sprintf("%s-issue305-couverture-ic-sigma.md", DATE_SORTIES)
  NOM_TSV <- sprintf("%s-issue305-couverture-ic-sigma-brut.tsv", DATE_SORTIES)
  NOM_JNL <- sprintf("%s-issue305-journal-mesure.md", DATE_SORTIES)
  CIBLES <- file.path(RACINE, "docs", "tableaux", c(NOM_MD, NOM_TSV, NOM_JNL))
  REMPLACES <- NULL
  if (OPT_ECRIRE) REMPLACES <- garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)

}

# Disjonction des plages de graines (par. 2.2, [V, arithmetique] de la
# specification), verifiee ici par usp_graine_flux_regime() du moteur :
# externes, internes et flux complementaires de la mesure (r <= R_MAX), du
# pre-vol (u <= 1000) et du pilote (305 000 000 + r et 305 100 000 + r,
# r <= 300, flux compris). Garde de programmation (arret si faux).
local({
  plage <- function(base, n) c(base + 1, base + n)
  flux <- function(p) c(usp_graine_flux_regime(p[1]), usp_graine_flux_regime(p[2]))
  P <- list()
  for (j in names(GRAINES)) {
    P[[paste0("ext_", j)]] <- plage(GRAINES[[j]][["ext"]], R_MAX)
    P[[paste0("int_", j)]] <- plage(GRAINES[[j]][["int"]], R_MAX)
    P[[paste0("flux_", j)]] <- flux(P[[paste0("int_", j)]])
    P[[paste0("pv_ext_", j)]] <- plage(GRAINES_PREVOL[[j]][["ext"]], 1000)
    P[[paste0("pv_int_", j)]] <- plage(GRAINES_PREVOL[[j]][["int"]], 1000)
    P[[paste0("pv_flux_", j)]] <- flux(P[[paste0("pv_int_", j)]])
  }
  P$pilote_ext <- plage(305000000, 300); P$pilote_int <- plage(305100000, 300)
  P$pilote_flux <- flux(P$pilote_int)
  M <- do.call(rbind, P)
  for (a in seq_len(nrow(M) - 1L)) for (b in (a + 1L):nrow(M))
    if (M[a, 1] <= M[b, 2] && M[b, 1] <= M[a, 2])
      stop("plages de graines non disjointes : ", rownames(M)[a], " et ", rownames(M)[b])
})

# --- Jeux et modeles ajustes (fit0) ------------------------------------------
lire_jeu <- function(j) {
  d <- utils::read.csv(file.path(RACINE, JEUX[[j]]))
  fit0 <- usp_ajuster(d$xt, d$yt)
  list(x = d$xt, y = d$yt, fit0 = fit0, sigma0 = fit0$sigma)
}
PLAN <- lapply(c(J1 = "J1", J2 = "J2"), lire_jeu)

# --- Intervalles (par. 2.3) --------------------------------------------------
# Percentile du script : quantiles de type 7 (ceux de res$ic_bootstrap).
perc_script <- function(s, p) stats::quantile(s, p, type = 7, names = FALSE)
# Bornes des cinq intervalles aux deux niveaux, dans l'ordre
# NOMS_BORNES ; s : sigma*, sr : sigma*_r, sh : sigma chapeau, corr.
NOMS_BORNES <- unlist(lapply(CODES, function(k) unlist(lapply(names(ALPHA_NIV), function(n)
  paste(k, n, c("bas", "haut"), sep = "_")))))
assembler_bornes <- function(q, qr, sh, corr) {
  # q, qr : quantiles aux probabilites c(a95, a90, 1 - a90, 1 - a95)
  b <- setNames(rep(NA_real_, length(NOMS_BORNES)), NOMS_BORNES)
  for (n in names(ALPHA_NIV)) {
    lo <- if (n == "90") q[2] else q[1]; hi <- if (n == "90") q[3] else q[4]
    b[paste0("I1_", n, "_", c("bas", "haut"))] <- c(lo, hi)
    b[paste0("I2_", n, "_", c("bas", "haut"))] <- c(2 * sh - hi, 2 * sh - lo)
    b[paste0("I4_", n, "_", c("bas", "haut"))] <- c(sh^2 / hi, sh^2 / lo)
    b[paste0("A1_", n, "_", c("bas", "haut"))] <- c(corr * lo, corr * hi)
    if (!anyNA(qr)) {
      lor <- if (n == "90") qr[2] else qr[1]; hir <- if (n == "90") qr[3] else qr[4]
      b[paste0("I3_", n, "_", c("bas", "haut"))] <- c(lor, hir)
    }
  }
  b
}
PROBS <- c(ALPHA_NIV[["95"]], ALPHA_NIV[["90"]], 1 - ALPHA_NIV[["90"]], 1 - ALPHA_NIV[["95"]])
bornes_intervalles <- function(s, sr, sh, corr) {
  q <- perc_script(s, PROBS)
  qr <- if (length(sr) > 20L) perc_script(sr, PROBS) else rep(NA_real_, 4L)
  assembler_bornes(q, qr, sh, corr)
}
# Ecriture independante (K-C3 (4)) : statistiques d'ordre et interpolation
# de type 7 en clair, h = (n - 1) p + 1, x_(j) + (h - j)(x_(j+1) - x_(j)).
q7_clair <- function(v, p) {
  x <- sort(v); n <- length(x)
  vapply(p, function(pp) {
    h <- (n - 1) * pp + 1; j <- floor(h)
    if (j >= n) x[n] else x[j] + (h - j) * (x[j + 1L] - x[j])
  }, numeric(1))
}
# Assemblage des bornes ecrit a part (sans assembler_bornes()) : I4 sous la
# forme exp(2 log s - log q) du par. 2.3, corr = sqrt((T + 1)/(T - 1)) avec
# T = nombre d'annees du jeu.
bornes_independantes <- function(s, sr, sh, T_) {
  cr <- sqrt((T_ + 1) / (T_ - 1))
  out <- numeric(0)
  for (k in CODES) for (n in names(ALPHA_NIV)) {
    a <- ALPHA_NIV[[n]]
    src <- if (k == "I3") sr else s
    if (length(src) <= 20L) { out <- c(out, NA_real_, NA_real_); next }
    ql <- q7_clair(src, a); qh <- q7_clair(src, 1 - a)
    out <- c(out, switch(k,
      I1 = c(ql, qh), I3 = c(ql, qh),
      I2 = c(sh + (sh - qh), sh + (sh - ql)),
      I4 = exp(2 * log(sh) - log(c(qh, ql))),
      A1 = cr * c(ql, qh)))
  }
  setNames(out, NOMS_BORNES)
}
ecart_relatif_max <- function(a, b) {
  if (!identical(is.na(a), is.na(b))) return(Inf)
  k <- !is.na(a)
  if (!any(k)) return(0)
  e <- abs(a[k] - b[k]) / pmax(abs(a[k]), abs(b[k]))
  e[a[k] == b[k]] <- 0
  max(e)
}

# --- Un jeu simule (chemin du par. 2.2) --------------------------------------
COLONNES <- c("jeu", "r", "g_ext", "g_int", "statut", "sigma_hat", "delta_hat", "gamma_hat", "regime",
              "variante", "tirages", "B_eff", "B_eff_r", "n_echec_restreint", "moy_sigma_star", "rang",
              "corr", NOMS_BORNES, "ecart_ind", "duree_s", "message")
COLONNES_BRUT <- setdiff(COLONNES, "duree_s")
COL_TEXTE <- c("jeu", "statut", "regime", "variante", "message")
un_jeu <- function(j, r, B, graines = GRAINES) {
  t1 <- proc.time()[["elapsed"]]
  P <- PLAN[[j]]
  g_ext <- graines[[j]][["ext"]] + r; g_int <- graines[[j]][["int"]] + r
  L <- setNames(as.list(rep(NA, length(COLONNES))), COLONNES)
  L$jeu <- j; L$r <- r; L$g_ext <- g_ext; L$g_int <- g_int
  fin <- function(statut, msg = NA_character_) {
    L$statut <- statut; L$message <- msg
    L$duree_s <- proc.time()[["elapsed"]] - t1
    L
  }
  res <- tryCatch({
    y <- engine_sous_graine(g_ext, usp_simuler(P$fit0))
    va <- engine_valider_donnees(P$x, y, methode = "premium", nature_donnees = "brutes",
                                 segment = 1, annexe = "II")
    if (!isTRUE(va$ok)) return(fin("refus_donnees", paste(va$erreurs, collapse = " / ")))
    fit <- try(usp_ajuster(P$x, y), silent = TRUE)
    if (inherits(fit, "try-error")) return(fin("echec_ajustement", conditionMessage(attr(fit, "condition"))))
    L$sigma_hat <- fit$sigma; L$delta_hat <- fit$delta; L$gamma_hat <- fit$gamma
    reg <- usp_regime(fit$delta, P$x)
    L$regime <- if (is.na(reg$delta_au_bord)) NA_character_ else if (!reg$delta_au_bord) "interieur" else
      if (fit$delta >= 0.5) "bord1" else "bord0"
    vaj <- usp_valider_ajustement(fit, "premium")
    if (!isTRUE(vaj$ok)) return(fin("refus_ajustement", paste(vaj$erreurs, collapse = " / ")))
    bo <- try(usp_bootstrap(fit, B = B, seed = g_int), silent = TRUE)
    if (inherits(bo, "try-error")) return(fin("echec_bootstrap", conditionMessage(attr(bo, "condition"))))
    s <- bo$sigma_boot; sr <- bo$sigma_boot_restreint
    L$variante <- bo$p_mc_regime$variante; L$tirages <- bo$p_mc_regime$tirages
    L$B_eff <- length(s); L$B_eff_r <- length(sr); L$n_echec_restreint <- bo$n_echec_restreint
    if (length(s) <= 20L) return(fin("echec_beff"))
    L$moy_sigma_star <- mean(s); L$rang <- mean(s < fit$sigma)
    corr <- usp_parametre(fit, sigma_standard = 0.10)$correction_taille
    L$corr <- corr
    b <- bornes_intervalles(s, sr, fit$sigma, corr)
    for (nm in NOMS_BORNES) L[[nm]] <- b[[nm]]
    L$ecart_ind <- ecart_relatif_max(b, bornes_independantes(s, sr, fit$sigma, length(P$x)))
    fin("ok")
  }, error = function(e) fin("echec_autre", conditionMessage(e)))
  res
}

# --- Ecriture et lecture des lignes ------------------------------------------
format_val <- function(v, col) {
  if (col %in% COL_TEXTE) {
    v <- if (is.null(v) || is.na(v)) "NA" else gsub("[\t\r\n]+", " ", as.character(v))
    return(v)
  }
  if (is.null(v) || is.na(v)) "NA" else sprintf("%.17g", as.numeric(v))
}
format_ligne <- function(L, cols = COLONNES) paste(vapply(cols, function(c) format_val(L[[c]], c), ""), collapse = "\t")
lire_lignes <- function(lignes, cols = COLONNES) {
  if (!length(lignes)) return(NULL)
  m <- do.call(rbind, strsplit(lignes, "\t", fixed = TRUE))
  if (ncol(m) != length(cols)) stop("nombre de colonnes inattendu")
  df <- as.data.frame(m, stringsAsFactors = FALSE); names(df) <- cols
  for (c in setdiff(cols, COL_TEXTE)) df[[c]] <- suppressWarnings(as.numeric(df[[c]]))
  for (c in intersect(cols, COL_TEXTE)) df[[c]][df[[c]] == "NA"] <- NA_character_
  df
}

###############################################################################
#  MODE --prevol (par. 2.7)
###############################################################################
if (MODE == "prevol") {
  U <- OPT_UNITES
  ecrire_console(c("## Pr\u00e9-vol de la mesure #305 (Fn, \u00e9tape 3) -- rien d'\u00e9crit", "",
                   sprintf("Commit : %s ; md5 R/engine.R : %s ; plateforme : %s ; c\u0153urs (parallel::detectCores()) : %s ; d\u00e9but %s",
                           COMMIT_DEBUT, MD5_MOTEUR_DEBUT, PLATEFORME, COEURS, horodatage()), "",
                   sprintf(paste("Chemin de la mesure (usp_bootstrap(), B = %d), %d jeu(x) de J1 puis %d de J2 par processus,",
                                 "les m\u00eames dans chaque processus (graines du pr\u00e9-vol : J1 %.0f + u et %.0f + u ;",
                                 "J2 %.0f + u et %.0f + u, u = 1..%d)."), B_MESURE, U, U,
                           GRAINES_PREVOL$J1[["ext"]], GRAINES_PREVOL$J1[["int"]],
                           GRAINES_PREVOL$J2[["ext"]], GRAINES_PREVOL$J2[["int"]], U), ""))
  unite <- function(i) {
    out <- list()
    for (j in c("J1", "J2")) for (u in seq_len(U)) {
      L <- un_jeu(j, u, B_MESURE, graines = GRAINES_PREVOL)
      out[[length(out) + 1L]] <- data.frame(jeu = j, u = u, d = L$duree_s, statut = L$statut,
                                            variante = if (is.na(L$variante)) "-" else L$variante,
                                            stringsAsFactors = FALSE)
    }
    do.call(rbind, out)
  }
  CB <- list(); MUR <- numeric(4)
  for (k in 1:4) {
    t0 <- Sys.time()
    res <- parallel::mclapply(seq_len(k), unite, mc.cores = k, mc.preschedule = FALSE)
    MUR[k] <- secs(t0)
    if (any(vapply(res, function(x) !is.data.frame(x), logical(1)))) stop("--prevol : processus en erreur (k = ", k, ")")
    CB[[k]] <- cbind(k = k, do.call(rbind, res))
  }
  c_j <- vapply(c("J1", "J2"), function(j) mean(CB[[1]]$d[CB[[1]]$jeu == j]), 1)
  P_k <- vapply(1:4, function(k) k * mean(CB[[1]]$d) / mean(CB[[k]]$d), 1)
  # Duree planifiee a k processus : R x (c_J1 + c_J2) / P_k (debit lineaire
  # par jeu, hypothese [H] ; queues de tranche non comptees).
  duree_plan <- function(R, k) R * sum(c_j) / P_k[k]
  k_ret <- which.min(vapply(1:4, function(k) duree_plan(1, k), 1))
  plan <- vapply(names(NIVEAUX_R), function(l) duree_plan(NIVEAUX_R[[l]], k_ret), 1)
  tient <- plan <= BUDGET_S
  niveau <- if (any(tient)) names(NIVEAUX_R)[which(tient)[1]] else NA_character_
  st <- table(factor(do.call(rbind, CB)$statut, levels = STATUTS))
  ecrire_console(c("### Co\u00fbts unitaires (secondes par jeu simul\u00e9, chemin complet)", "",
                   entete_md(c("processus concurrents", "dur\u00e9e murale de la phase (s)", "J1 : moyenne [min ; max]",
                               "J2 : moyenne [min ; max]", "d\u00e9bit agr\u00e9g\u00e9 P_k")),
                   vapply(1:4, function(k) {
                     d <- CB[[k]]
                     f <- function(j) sprintf("%s [%s ; %s]", num(mean(d$d[d$jeu == j]), 2), num(min(d$d[d$jeu == j]), 2),
                                              num(max(d$d[d$jeu == j]), 2))
                     ligne_md(k, num(MUR[k], 1), f("J1"), f("J2"), num(P_k[k], 3))
                   }, ""), "",
                   sprintf("Variantes des bootstraps au pr\u00e9-vol (un processus) : J1 %s ; J2 %s. Statuts (toutes phases) : %s.",
                           paste(names(table(CB[[1]]$variante[CB[[1]]$jeu == "J1"])), table(CB[[1]]$variante[CB[[1]]$jeu == "J1"]), sep = " ", collapse = ", "),
                           paste(names(table(CB[[1]]$variante[CB[[1]]$jeu == "J2"])), table(CB[[1]]$variante[CB[[1]]$jeu == "J2"]), sep = " ", collapse = ", "),
                           paste(names(st), as.integer(st), sep = " ", collapse = ", ")), "",
                   sprintf("c_J1 = %s s, c_J2 = %s s (un processus). Processus retenus : %d (dur\u00e9e planifi\u00e9e minimale).",
                           num(c_j[["J1"]], 2), num(c_j[["J2"]], 2), k_ret), "",
                   "### Niveaux (par. 2.7 : premier niveau dont la dur\u00e9e planifi\u00e9e tient dans 2 h d'horloge sur 4 c\u0153urs)", "",
                   entete_md(c("Niveau", "R par jeu", sprintf("dur\u00e9e planifi\u00e9e \u00e0 %d processus (h)", k_ret), "dans le budget")),
                   vapply(names(NIVEAUX_R), function(l) ligne_md(l, NIVEAUX_R[[l]], num(plan[[l]] / 3600, 2),
                                                                if (tient[[l]]) "oui" else "non"), ""), "",
                   if (!is.na(niveau))
                     sprintf("**Niveau retenu : %s, R = %d par jeu, dur\u00e9e planifi\u00e9e %s h \u00e0 %d processus** (hypoth\u00e8se [H] : d\u00e9bit lin\u00e9aire, queues de tranche non compt\u00e9es).",
                             niveau, NIVEAUX_R[[niveau]], num(plan[[niveau]] / 3600, 2), k_ret)
                   else "**Aucun niveau ne tient dans 2 h** : choix du mainteneur entre les segments de M42 (b) et l'option (b) de Q-D1-Fn-4 (par. 2.7).",
                   "", sprintf("Commande de la mesure : LC_ALL=C.UTF-8 Rscript %s --R %s --niveau %s --processus %d --ecrire", SCRIPT_DEPOT,
                               if (is.na(niveau)) "?" else NIVEAUX_R[[niveau]], if (is.na(niveau)) "?" else niveau, k_ret),
                   "", sprintf("PREVOL305\t%.4f\t%.4f\t%s\t%d\t%s\t%s", c_j[["J1"]], c_j[["J2"]],
                               paste(sprintf("%.4f", P_k), collapse = "\t"), k_ret,
                               if (is.na(niveau)) "NA" else niveau, if (is.na(niveau)) "NA" else NIVEAUX_R[[niveau]]),
                   sprintf("Dur\u00e9e du pr\u00e9-vol : %s s.", num(secs(t_debut), 0))))
  quit(status = 0L)
}

###############################################################################
#  ESSAI ET MESURE : CALCUL PAR TRANCHES
###############################################################################
# (t305) : texte du critere et des profils present a l'identique dans la
# specification (copie du par. 2.5 et du par. 2.6) ; controle de forme, hors
# K-C3, fait avant la boucle de calcul (refus immediat si la specification
# ne concorde pas) et repris au tableau des controles.
TEXTE_CRITERE_305 <- c(
  "### 2.5 Crit\u00e8re, fix\u00e9 avant toute ex\u00e9cution",
  "",
  "Report\u00e9 sans modification dans le script et au T0. Taux de non-couverture \u03c4 de chaque (jeu, intervalle, niveau), compar\u00e9 au nominal \u03c1 = 0,10 (90 %) ou 0,05 (95 %). Classes de #166, #206 et Fk, avec une bande **ferm\u00e9e** [\u03c1/2 ; 3\u03c1/2] (couverture dans [0,85 ; 0,95] \u00e0 90 %, dans [0,925 ; 0,975] \u00e0 95 %) :",
  "",
  "| Classe | Condition |",
  "|---|---|",
  "| compatible | \u03c1 \u2208 IC(\u03c4) |",
  "| \u00e9cart mineur | \u03c4\u0302 dans la bande, sans \u00eatre compatible |",
  "| non tranch\u00e9 | \u03c4\u0302 hors de la bande, et IC qui la recoupe |",
  "| distorsion mat\u00e9rielle lib\u00e9rale (sous-couverture) | IC disjoint de la bande, au-dessus |",
  "| distorsion mat\u00e9rielle conservatrice | IC disjoint de la bande, au-dessous |",
  "",
  "- **R\u00e8gle de fronti\u00e8re** : classes calcul\u00e9es sur les valeurs non arrondies ; une estimation sur un bord de la bande est dans la bande ; **aucune extension de R apr\u00e8s lecture des r\u00e9sultats** (pas d'arr\u00eat optionnel) : R est fix\u00e9 par le pr\u00e9-vol et \u00e9crit au JOURNAL avant le lancement ; un \u00ab non tranch\u00e9 \u00bb reste non tranch\u00e9.",
  "- **K-C1** (principal) : classe \u00e0 90 % de I1, I2 et I4 sur J1 et J2.",
  "- **K-C2** (descriptif) : classes \u00e0 95 % ; queues s\u00e9par\u00e9es, par rapport \u00e0 \u03c1/2 ; I3, A1 et B1.",
  "- **K-C3** (int\u00e9grit\u00e9 ; un seul \u00e9chec met INTEGRITE \u00e0 ECHEC) : (1) md5 de `R/engine.R` et SHA consign\u00e9s, identiques au d\u00e9but et \u00e0 la fin ; (2) \u03c30 de J1 et J2 \u00e9gal \u00e0 `ajustement$sigma` de `premium` et `premium_interieur`, \u00e0 `TOLERANCE` pr\u00e8s ; (3) percentile du script, port\u00e9 sur l'\u00e9chelle de \u03c3_USP par l'expression du moteur, `identical()` \u00e0 `ic_bootstrap` des six r\u00e9f\u00e9rences ; (4) sur le premier jeu de chaque tranche, bornes recalcul\u00e9es par une \u00e9criture ind\u00e9pendante (statistiques d'ordre et interpolation de type 7 en clair), \u00e9gales \u00e0 1e-12 relatif pr\u00e8s ; (5) sous l'option (b) seulement : \u03c3\\* et \u03c3\\*_r de la boucle all\u00e9g\u00e9e `identical()` \u00e0 ceux d'`usp_bootstrap()` sur le premier jeu de chaque tranche.",
  "- **K-C4** (fronti\u00e8re, descriptif) : pour chaque classe, dire si l'IC touche un bord de la bande."
)
TEXTE_PROFILS_305 <- c(
  "### 2.6 Profils de lecture pour D2-Fn",
  "",
  "`actuary` propose, le mainteneur tranche. Ordre d'\u00e9valuation : \u03a80, puis \u03a84, puis \u03a81 \u00e0 \u03a83.",
  "",
  "| Profil | Condition | Lecture propos\u00e9e |",
  "|---|---|---|",
  "| \u03a80 | K-C3 en d\u00e9faut, ou refus et \u00e9checs au-del\u00e0 de 2 % de R sur un jeu sans explication | lecture suspendue ; mesure \u00e0 reprendre |",
  "| \u03a84 | I1 en distorsion de c\u00f4t\u00e9s oppos\u00e9s entre J1 et J2 | d\u00e9cision du mainteneur ; aucune correction calibr\u00e9e sur un seul plan |",
  "| \u03a81 | I1 compatible ou en \u00e9cart mineur sur J1 et J2 | percentile conserv\u00e9 ; couverture \u00e9crite dans la fiche ; \u00ab basic \u00bb non restitu\u00e9 par d\u00e9faut (le mainteneur peut le restituer en regard) |",
  "| \u03a82 | I1 ni compatible ni en \u00e9cart mineur sur au moins un jeu, et au moins un des intervalles I2 ou I4 compatible ou en \u00e9cart mineur sur les deux | **d\u00e9cision du mainteneur** : restituer en regard le ou les intervalles \u00ab basic \u00bb qui satisfont la condition ; libell\u00e9 du percentile requalifi\u00e9 (\u00ab niveau nominal 90 % ; couverture mesur\u00e9e \u2026 \u00bb) |",
  "| \u03a83 | I1 dans ce m\u00eame cas, et aucun des intervalles I2 ou I4 compatible ou en \u00e9cart mineur sur les deux jeux | **d\u00e9cision du mainteneur** : aucun \u00ab basic \u00bb restitu\u00e9 ; libell\u00e9 du percentile requalifi\u00e9 ; issue propos\u00e9e pour un autre intervalle |",
  "",
  "D2-Fn est **toujours tenu** : la d\u00e9cision sur le \u00ab basic \u00bb revient au mainteneur (Q-42-10). \u03c3_USP n'est jamais touch\u00e9."
)
t305_present <- local({
  spec <- readLines(file.path(RACINE, SPEC), warn = FALSE, encoding = "UTF-8")
  present <- function(bloc) {
    i <- which(spec == bloc[1])
    any(vapply(i, function(k) k + length(bloc) - 1L <= length(spec) &&
                 identical(spec[k:(k + length(bloc) - 1L)], bloc), logical(1)))
  }
  c(critere = present(TEXTE_CRITERE_305), profils = present(TEXTE_PROFILS_305))
})
if (!all(t305_present))
  refuser("(t305) : texte du par. 2.5 ou du par. 2.6 absent ou modifie dans ", SPEC,
          " -- le critere reporte dans le script ne concorde plus avec la specification")

# --- Tranches ----------------------------------------------------------------
tranches <- lapply(seq(1L, R_RUN, by = TAILLE_TRANCHE), function(a) c(a, min(a + TAILLE_TRANCHE - 1L, R_RUN)))
fichier_tranche <- function(j, tr) file.path(TRAVAIL, sprintf("%s-r%06d-%06d.tsv", j, tr[1], tr[2]))
lire_tranche <- function(f, j, tr) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  n <- tr[2] - tr[1] + 1L
  if (length(l) != n + 3L || l[1] != paste0("#CONTEXTE\t", txt_ctx(CTX)) || l[2] != paste(COLONNES, collapse = "\t") ||
      l[length(l)] != sprintf("#FIN\t%d", n))
    refuser("tranche ", basename(f), " : contexte, en-tete ou fin differents du calcul courant -- pas de melange (autre --travail)")
  df <- lire_lignes(l[3:(n + 2L)])
  if (!identical(df$jeu, rep(j, n)) || !identical(as.integer(df$r), seq.int(tr[1], tr[2])))
    refuser("tranche ", basename(f), " : jeux simules inattendus")
  df
}
N_CALC <- 0L; N_TR_CALC <- 0L; T_CALC <- 0
for (j in names(JEUX)) for (tr in tranches) {
  f <- fichier_tranche(j, tr)
  if (file.exists(f)) next
  t0 <- Sys.time()
  rs <- seq.int(tr[1], tr[2])
  res <- parallel::mclapply(rs, function(r) un_jeu(j, r, B_RUN), mc.cores = OPT_PROC, mc.preschedule = FALSE)
  ok <- vapply(res, function(L) is.list(L) && identical(L$jeu, j), logical(1))
  if (!all(ok)) stop("tranche ", basename(f), " : processus en erreur (r = ", paste(rs[!ok], collapse = ", "), ") ; relancer pour reprendre")
  tmp <- paste0(f, ".tmp")
  ecrire_fichier(tmp, c(paste0("#CONTEXTE\t", txt_ctx(CTX)), paste(COLONNES, collapse = "\t"),
                       vapply(res, format_ligne, ""), sprintf("#FIN\t%d", length(rs))))
  if (!file.rename(tmp, f)) stop("renommage impossible : ", tmp)
  N_CALC <- N_CALC + length(rs); N_TR_CALC <- N_TR_CALC + 1L; T_CALC <- T_CALC + secs(t0)
  message(sprintf("%s : %s calculee (%d jeux, %.0f s)", horodatage(), basename(f), length(rs), secs(t0)))
}
TR <- list(); FICHIERS_TR <- character(0)
for (j in names(JEUX)) for (tr in tranches) {
  f <- fichier_tranche(j, tr)
  TR[[length(TR) + 1L]] <- cbind(lire_tranche(f, j, tr), tranche = basename(f), stringsAsFactors = FALSE)
  FICHIERS_TR <- c(FICHIERS_TR, f)
}
D <- do.call(rbind, TR)

###############################################################################
#  CONTROLES D'INTEGRITE
###############################################################################
INTEGRITE <- character(0)
CTRL <- list()
controle <- function(code, ok, detail) {
  CTRL[[length(CTRL) + 1L]] <<- list(code = code, ok = isTRUE(ok), detail = detail)
  if (!isTRUE(ok)) INTEGRITE <<- c(INTEGRITE, code)
}

# K-C3 (2) : sigma0 contre ajustement$sigma des references.
for (j in names(JEUX)) {
  ref <- readRDS(file.path(RACINE, "tests", "reference", paste0(REF_JEUX[[j]], ".rds")))$ajustement$sigma
  s0 <- PLAN[[j]]$sigma0
  e <- abs(s0 - ref) / abs(ref)
  controle(sprintf("K-C3 (2) %s", j), is.finite(e) && e <= TOLERANCE,
           sprintf("\u03c30 = %.10g ; %s.rds : ajustement$sigma = %.10g ; \u00e9cart relatif %.3e (TOLERANCE %g)",
                   s0, REF_JEUX[[j]], ref, e, TOLERANCE))
}
# K-C3 (3) : percentile du script sur l'expression du moteur, six references.
local({
  det <- character(0); tout <- TRUE
  for (nm in REFS_SIX) {
    rr <- readRDS(file.path(RACINE, "tests", "reference", paste0(nm, ".rds")))
    pf <- rr$parametre_final; s <- rr$bootstrap$sigma_boot
    usp_b <- if (identical(nm, "reserve2"))
      pf$credibilite * s + (1 - pf$credibilite) * pf$sigma_standard else
      pf$credibilite * s * pf$correction_taille + (1 - pf$credibilite) * pf$sigma_standard
    q <- perc_script(usp_b, c(.025, .05, .5, .95, .975))
    ok <- !is.null(rr$ic_bootstrap) && identical(q, unname(as.numeric(rr$ic_bootstrap)))
    tout <- tout && ok
    det <- c(det, sprintf("%s %s", nm, if (ok) "identical" else "DIFF\u00c9RENT"))
  }
  controle("K-C3 (3)", tout, paste(det, collapse = " ; "))
})
# K-C3 (4) : premier jeu accepte de chaque tranche.
local({
  det <- character(0); tout <- TRUE
  for (tn in unique(D$tranche)) {
    d <- D[D$tranche == tn & D$statut == "ok", , drop = FALSE]
    if (!nrow(d)) {
      # controle non fait : ECHEC
      tout <- FALSE
      det <- c(det, sprintf("%s : aucun jeu accept\u00e9, contr\u00f4le non fait", tn)); next
    }
    e <- d$ecart_ind[1]
    ok <- is.finite(e) && e <= TOL_IND
    tout <- tout && ok
    det <- c(det, sprintf("%s (r = %d) : %.2e", tn, as.integer(d$r[1]), e))
  }
  controle("K-C3 (4)", tout, paste(det, collapse = " ; "))
})
local({
  a <- t305_present[["critere"]]; b <- t305_present[["profils"]]
  controle("(t305) contr\u00f4le de forme, hors K-C3", a && b,
           sprintf("par. 2.5 %s ; par. 2.6 %s dans %s (v\u00e9rifi\u00e9 avant la boucle de calcul)",
                   if (a) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9",
                   if (b) "pr\u00e9sent \u00e0 l'identique" else "ABSENT OU MODIFI\u00c9", SPEC))
})

###############################################################################
#  AGREGATION (par. 2.4 et 2.5)
###############################################################################
# IC de Clopper-Pearson a 95 % (qbeta), valeurs non arrondies.
ic_cp <- function(k, n) {
  if (n <= 0) return(c(NA_real_, NA_real_))
  c(if (k == 0) 0 else stats::qbeta(0.025, k, n - k + 1), if (k == n) 1 else stats::qbeta(0.975, k + 1, n - k))
}
CLASSES <- c(comp = "compatible", mineur = "\u00e9cart mineur", nt = "non tranch\u00e9",
             lib = "distorsion mat\u00e9rielle lib\u00e9rale (sous-couverture)",
             cons = "distorsion mat\u00e9rielle conservatrice")
# Classe d'un taux k/n contre une reference rho (bande fermee [rho/2 ; 3 rho/2]).
classer <- function(k, n, rho) {
  if (n == 0) return(list(taux = NA_real_, ci = c(NA_real_, NA_real_), classe = "non \u00e9valuable (n = 0)",
                          code = NA_character_, bord = NA_character_))
  t <- k / n; ci <- ic_cp(k, n); bas <- rho / 2; haut <- 3 * rho / 2
  code <- if (ci[1] <= rho && rho <= ci[2]) "comp" else if (ci[1] > haut) "lib" else if (ci[2] < bas) "cons" else
    if (t >= bas && t <= haut) "mineur" else "nt"
  touche <- c(if (ci[1] <= bas && bas <= ci[2]) "\u03c1/2", if (ci[1] <= haut && haut <= ci[2]) "3\u03c1/2")
  list(taux = t, ci = ci, classe = CLASSES[[code]], code = code,
       bord = if (length(touche)) paste0("oui (", paste(touche, collapse = ", "), ")") else "non")
}
ACC <- D[D$statut == "ok", , drop = FALSE]
cellule <- function(j, code, niv, sous = NULL) {
  d <- ACC[ACC$jeu == j, , drop = FALSE]
  if (!is.null(sous)) d <- d[sous(d), , drop = FALSE]
  lo <- d[[paste0(code, "_", niv, "_bas")]]; hi <- d[[paste0(code, "_", niv, "_haut")]]
  k_ <- !is.na(lo) & !is.na(hi)
  s0 <- PLAN[[j]]$sigma0
  lo <- lo[k_]; hi <- hi[k_]; n <- length(lo)
  nb <- sum(s0 < lo); nh <- sum(s0 > hi)
  rho <- RHO_NIV[[niv]]
  list(n = n, nb = nb, nh = nh, cl = classer(nb + nh, n, rho),
       cb = classer(nb, n, rho / 2), ch = classer(nh, n, rho / 2),
       cov = if (n) 1 - (nb + nh) / n else NA_real_,
       cov_ci = if (n) 1 - rev(ic_cp(nb + nh, n)) else c(NA_real_, NA_real_),
       larg_med = if (n) stats::median((hi - lo) / s0) else NA_real_,
       larg_moy = if (n) mean((hi - lo) / s0) else NA_real_,
       neg = sum(lo <= 0))
}
CEL <- list()
for (j in names(JEUX)) for (code in CODES) for (niv in names(ALPHA_NIV))
  CEL[[paste(j, code, niv)]] <- cellule(j, code, niv)

# K-C3 (1) : fin du calcul (moteur et commit relus apres l'agregation).
MD5_MOTEUR_FIN <- md5_fichier(file.path(RACINE, "R", "engine.R"))
SHA_FIN <- sha_head()
local({
  ctx_tr <- unique(unname(vapply(FICHIERS_TR, function(f) readLines(f, n = 1L, warn = FALSE), "")))
  ok <- MD5_MOTEUR_DEBUT == MD5_MOTEUR_FIN && SHA_DEBUT == SHA_FIN && SHA_DEBUT != "inconnu" &&
    identical(J0$sha, SHA_DEBUT) && identical(J0$md5, MD5_MOTEUR_DEBUT) &&
    identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))
  controle("K-C3 (1)", ok, sprintf(paste("md5 R/engine.R d\u00e9but %s, fin %s, JOURNAL %s ; SHA d\u00e9but %s, fin %s, JOURNAL %s ;",
                                         "contexte (B, SHA, md5 du moteur et du script, plateforme) identique dans les %d tranche(s) : %s"),
                                   MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN, J0$md5, SHA_DEBUT, SHA_FIN, J0$sha, length(FICHIERS_TR),
                                   if (length(ctx_tr) == 1L && identical(ctx_tr, paste0("#CONTEXTE\t", txt_ctx(CTX)))) "oui" else "NON"))
})

# Refus et echecs par jeu (Psi0).
REFUS <- lapply(c(J1 = "J1", J2 = "J2"), function(j) table(factor(D$statut[D$jeu == j], levels = STATUTS)))
PART_REFUS <- vapply(REFUS, function(t) (sum(t) - t[["ok"]]) / R_RUN, 1)

# Profils (par. 2.6), evalues au niveau 90 % (K-C1), sans decision.
cl90 <- function(j, code) CEL[[paste(j, code, "90")]]$cl$code
okc <- function(cd) !is.na(cd) && cd %in% c("comp", "mineur")
lib_classe <- function(cd) if (is.na(cd)) "non \u00e9valuable (n = 0)" else CLASSES[[cd]]
profil <- local({
  kc3 <- !any(startsWith(INTEGRITE, "K-C3"))
  refus_hors <- names(PART_REFUS)[PART_REFUS > SEUIL_REFUS]
  i1 <- c(J1 = cl90("J1", "I1"), J2 = cl90("J2", "I1"))
  opp <- all(i1 %in% c("lib", "cons")) && i1[["J1"]] != i1[["J2"]]
  basic_ok <- c(I2 = okc(cl90("J1", "I2")) && okc(cl90("J2", "I2")), I4 = okc(cl90("J1", "I4")) && okc(cl90("J2", "I4")))
  suite <- if (opp) "\u03a84" else if (okc(i1[["J1"]]) && okc(i1[["J2"]])) "\u03a81" else if (any(basic_ok)) "\u03a82" else "\u03a83"
  p <- if (!kc3) "\u03a80" else if (length(refus_hors)) "\u03a80 (sous r\u00e9serve d'explication)" else suite
  list(profil = p, suite = suite, kc3 = kc3, refus_hors = refus_hors, i1 = i1, opp = opp, basic_ok = basic_ok)
})

###############################################################################
#  SORTIE MARKDOWN
###############################################################################
fit_txt <- function(j) {
  f <- PLAN[[j]]$fit0
  sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c30 = %.6g", f$delta, f$gamma, f$beta, f$sigma)
}
txt_cel_cov <- function(c_) if (!c_$n) "\u2014" else sprintf("%s %s", num(c_$cov), txt_ic(c_$cov_ci))
txt_cl <- function(cl) if (is.na(cl$taux)) "\u2014" else sprintf("%s %s", num(cl$taux), txt_ic(cl$ci))
duree_cumulee <- sum(D$duree_s, na.rm = TRUE)
S <- c(sprintf("## Mesure #305 (Fn, \u00e9tape 3) : couverture \u00e0 T = 8 de l'intervalle bootstrap de \u03c3, m\u00e9thode lognormale (J1, J2)%s",
               if (OPT_ESSAI) " -- ESSAI (--essai), non versionnable" else ""), "",
       "### T0 \u2014 provenance", "",
       entete_md(c("Grandeur", "Valeur")),
       ligne_md("Sp\u00e9cification", sprintf("%s, par. 2 (d\u00e9cisions Q-D1-Fn-4 \u00e0 6 du 27/10/2026) ; md5 %s", SPEC, md5_fichier(file.path(RACINE, SPEC)))),
       ligne_md("Mode", if (OPT_ESSAI) "essai (--essai) : non versionnable" else "mesure"),
       ligne_md("R par jeu ; B ; niveau", sprintf("%d ; %d ; %s", R_RUN, B_RUN, if (is.na(OPT_NIVEAU)) "non d\u00e9clar\u00e9" else OPT_NIVEAU)),
       ligne_md("Chemin", "usp_simuler(fit0) sous engine_sous_graine(G_ext(r)) ; engine_valider_donnees() (premium, brutes, segment 1, annexe II) ; usp_ajuster() ; usp_valider_ajustement(fit, \"premium\") ; usp_bootstrap(fit, B, seed = G_int(r)) (option (a))"),
       ligne_md("J1", sprintf("%s ; %s", JEUX[["J1"]], fit_txt("J1"))),
       ligne_md("J2", sprintf("%s ; %s", JEUX[["J2"]], fit_txt("J2"))),
       ligne_md("Graines", "J1 : G_ext(r) = 305 200 000 + r, G_int(r) = 305 300 000 + r ; J2 : G_ext(r) = 305 250 000 + r, G_int(r) = 305 350 000 + r ; flux compl\u00e9mentaire G_int(r) + 539 169 (usp_graine_flux_regime()) ; plages disjointes v\u00e9rifi\u00e9es au chargement"),
       ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
       ligne_md("Intervalles", "quantiles de type 7 de \u03c3* (perc_script()) ; I1 [q_\u03b1 ; q_(1\u2212\u03b1)] ; I2 [2\u03c3\u0302 \u2212 q_(1\u2212\u03b1) ; 2\u03c3\u0302 \u2212 q_\u03b1] ; I3 percentile de \u03c3*_r ; I4 [\u03c3\u0302\u00b2/q_(1\u2212\u03b1) ; \u03c3\u0302\u00b2/q_\u03b1] ; A1 corr \u00d7 I1, corr = \u221a((T+1)/(T\u22121)) ; intervalle form\u00e9 si plus de 20 valeurs bootstrap"),
       ligne_md("SHA, git rev-parse HEAD (d\u00e9but ; fin)", sprintf("%s ; %s", SHA_DEBUT, SHA_FIN)),
       ligne_md("Commit (commit_depot(), au d\u00e9but)", COMMIT_DEBUT),
       ligne_md("md5 R/engine.R (d\u00e9but ; fin)", sprintf("%s ; %s", MD5_MOTEUR_DEBUT, MD5_MOTEUR_FIN)),
       ligne_md("Empreinte sans commentaires de R/engine.R (#231)", empreinte_sans_commentaires()),
       ligne_md("Empreintes md5 du code ex\u00e9cut\u00e9", EMPREINTES),
       ligne_md("Plateforme de calcul", PLATEFORME),
       ligne_md("Tranches", sprintf("%d (taille %d) ; calcul\u00e9es par cette ex\u00e9cution : %d jeu(x) simul\u00e9(s) en %s s d'horloge \u00e0 %d processus ; reprises : %d",
                                    length(FICHIERS_TR), TAILLE_TRANCHE, N_CALC, num(T_CALC, 0), OPT_PROC,
                                    length(FICHIERS_TR) - N_TR_CALC)),
       ligne_md("Dur\u00e9e cumul\u00e9e par jeu simul\u00e9 (somme des processus)", sprintf("%s s (%s s par jeu)", num(duree_cumulee, 0), num(duree_cumulee / nrow(D), 2))),
       ligne_md("JOURNAL", sprintf("%s (lancement %s)", NOM_JNL, sub("^- Lancement : ", "", J0$lignes[grep("^- Lancement : ", J0$lignes)[1]]))),
       ligne_md("Valeurs brutes", sprintf("%s (une ligne par jeu simul\u00e9, %%.17g)", NOM_TSV)),
       ligne_md("Versionnable (--ecrire)", if (length(motifs_non_versionnable(COMMIT_DEBUT, EMPREINTES, "de la mesure")) || OPT_ESSAI) "non" else "oui"),
       ligne_md("Contr\u00f4les d'int\u00e9grit\u00e9", if (length(INTEGRITE)) paste("\u00c9CHEC :", paste(INTEGRITE, collapse = ", ")) else "OK"),
       "",
       "### Aide \u00e0 la lecture", "",
       paste("Statut : **constat de simulation sous les mod\u00e8les ajust\u00e9s aux jeux J1 et J2**, pas un r\u00e9sultat g\u00e9n\u00e9ral.",
             "Cible : \u03c30 = \u03c3(\u03b40, \u03b30) du mod\u00e8le simul\u00e9 (par. 2.1) ; couverture conditionnelle \u00e0 l'acceptation (statut ok).",
             "\u03c4 = part des jeux o\u00f9 \u03c30 est hors de l'intervalle ; IC de Clopper-Pearson \u00e0 95 % (qbeta), incertitude Monte-Carlo sur le taux (fonction de R).",
             "Classes et profils calcul\u00e9s m\u00e9caniquement, sur les valeurs non arrondies, **sans conclure** : la lecture revient \u00e0 actuary, la d\u00e9cision (D2-Fn) au mainteneur."), "",
       "**Crit\u00e8re de la sp\u00e9cification (par. 2.5), report\u00e9 sans modification :**", "",
       paste0("> ", TEXTE_CRITERE_305), "")
if (length(REMPLACES)) S <- inserer_t0(S, ligne_remplacement(REMPLACES, CIBLES[1]))

# T1 : K-C1.
S <- c(S, "### T1 \u2014 K-C1 (principal) : classe \u00e0 90 % de I1, I2 et I4", "",
       entete_md(c("Jeu", "Intervalle", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC CP 95 %]", "classe", "K-C4 : IC touche un bord")))
for (j in names(JEUX)) for (code in c("I1", "I2", "I4")) {
  c_ <- CEL[[paste(j, code, "90")]]
  S <- c(S, ligne_md(j, LIB_CODES[[code]], c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord))
}
# T2 : toutes les cellules.
S <- c(S, "", "### T2 \u2014 couverture par jeu, intervalle et niveau (K-C1, K-C2, K-C4)", "",
       paste("Queues s\u00e9par\u00e9es (K-C2) : part de \u03c30 sous la borne basse et au-dessus de la borne haute, classe contre \u03c1/2",
             "(m\u00eame r\u00e8gle, bande [\u03c1/4 ; 3\u03c1/4]). Largeurs divis\u00e9es par \u03c30."), "",
       entete_md(c("Jeu", "Intervalle", "Niveau", "n", "couverture [IC 95 %]", "\u03c4\u0302 [IC]", "classe (\u03c4, \u03c1)", "K-C4",
                   "sous la borne basse [IC] ; classe (\u03c1/2)", "au-dessus de la borne haute [IC] ; classe (\u03c1/2)",
                   "largeur m\u00e9diane / \u03c30", "largeur moyenne / \u03c30", "bornes basses \u2264 0")))
for (j in names(JEUX)) for (code in CODES) for (niv in names(ALPHA_NIV)) {
  c_ <- CEL[[paste(j, code, niv)]]
  S <- c(S, ligne_md(j, LIB_CODES[[code]], paste0(niv, " %"), c_$n, txt_cel_cov(c_), txt_cl(c_$cl), c_$cl$classe, c_$cl$bord,
                     sprintf("%s ; %s", txt_cl(c_$cb), c_$cb$classe), sprintf("%s ; %s", txt_cl(c_$ch), c_$ch$classe),
                     num(c_$larg_med), num(c_$larg_moy), c_$neg))
}
# T3 : par regime de delta chapeau.
S <- c(S, "", "### T3 \u2014 couverture par r\u00e9gime de \u03b4\u0302 du jeu simul\u00e9 (descriptif)", "",
       entete_md(c("Jeu", "Intervalle", "Niveau", "bord : n", "bord : couverture [IC]", "int\u00e9rieur : n", "int\u00e9rieur : couverture [IC]")))
for (j in names(JEUX)) for (code in CODES) for (niv in names(ALPHA_NIV)) {
  cb <- cellule(j, code, niv, function(d) d$regime %in% c("bord0", "bord1"))
  ci <- cellule(j, code, niv, function(d) d$regime %in% "interieur")
  S <- c(S, ligne_md(j, LIB_CODES[[code]], paste0(niv, " %"), cb$n, txt_cel_cov(cb), ci$n, txt_cel_cov(ci)))
}
# T4 : B1.
moy_ic <- function(v) {
  v <- v[is.finite(v)]; n <- length(v)
  if (n < 2L) return(if (n) num(v) else "\u2014")
  sprintf("%s \u00b1 %s", num(mean(v)), num(1.96 * stats::sd(v) / sqrt(n)))
}
S <- c(S, "", "### T4 \u2014 biais (B1, descriptif) : moyenne \u00b1 1,96 sd/\u221an sur les n jeux accept\u00e9s", "",
       entete_md(c("Jeu", "n", "E[\u03c3\u0302]/\u03c30", "E[corr\u00b7\u03c3\u0302]/\u03c30", "moyenne de \u03c3\u0302/moyenne(\u03c3*)",
                   "m\u00e9diane du rang de \u03c3\u0302 dans \u03c3* (#{\u03c3* < \u03c3\u0302}/B_eff)", "part de \u03b4\u0302 int\u00e9rieur [IC]")))
for (j in names(JEUX)) {
  d <- ACC[ACC$jeu == j, , drop = FALSE]; s0 <- PLAN[[j]]$sigma0
  ni <- sum(d$regime %in% "interieur")
  S <- c(S, ligne_md(j, nrow(d), moy_ic(d$sigma_hat / s0), moy_ic(d$corr * d$sigma_hat / s0),
                     moy_ic(d$sigma_hat / d$moy_sigma_star), num(if (nrow(d)) stats::median(d$rang) else NA),
                     sprintf("%s %s", num(if (nrow(d)) ni / nrow(d) else NA), txt_ic(ic_cp(ni, nrow(d))))))
}
# T5 : refus, echecs, variantes.
S <- c(S, "", "### T5 \u2014 refus, \u00e9checs et variantes des bootstraps", "",
       entete_md(c("Jeu", "R", paste("statut", STATUTS), "refus et \u00e9checs / R", "V1", "V3b", "tirages V3b (moyenne)",
                   "B_eff min", "B_eff restreint min", "\u00e9checs du restreint (somme)")))
for (j in names(JEUX)) {
  t_ <- REFUS[[j]]; d <- ACC[ACC$jeu == j, , drop = FALSE]
  S <- c(S, ligne_md(j, R_RUN, paste(as.integer(t_), collapse = " | "), num(PART_REFUS[[j]]),
                     sum(d$variante %in% "V1"), sum(d$variante %in% "V3b"),
                     num(if (any(d$variante %in% "V3b")) mean(d$tirages[d$variante %in% "V3b"]) else NA, 0),
                     if (nrow(d)) min(d$B_eff) else "\u2014", if (nrow(d)) min(d$B_eff_r) else "\u2014",
                     sum(d$n_echec_restreint, na.rm = TRUE)))
}
msgs <- unique(D$message[!is.na(D$message) & D$statut != "ok"])
if (length(msgs)) S <- c(S, "", paste0("Motifs rencontr\u00e9s : ", paste(utils::head(msgs, 10), collapse = " ; ")))
# Controles.
S <- c(S, "", "### Contr\u00f4les d'int\u00e9grit\u00e9 (K-C3 ; (5) sans objet, option (b) non utilis\u00e9e)", "",
       entete_md(c("Contr\u00f4le", "R\u00e9sultat", "D\u00e9tail")),
       vapply(CTRL, function(k) ligne_md(k$code, if (k$ok) "OK" else "\u00c9CHEC", k$detail), ""),
       ligne_md("K-C3 (4), \u00e9tendu (descriptif)", "\u2014",
                sprintf("\u00e9cart relatif maximal des bornes ind\u00e9pendantes sur les %d jeux accept\u00e9s : %.2e", nrow(ACC),
                        if (nrow(ACC)) max(ACC$ecart_ind) else NA_real_)))
# Profils.
S <- c(S, "", "### Profils de lecture pour D2-Fn (par. 2.6), \u00e9valu\u00e9s m\u00e9caniquement au niveau 90 % (K-C1), sans d\u00e9cision", "",
       paste0("> ", TEXTE_PROFILS_305), "",
       entete_md(c("\u00c9l\u00e9ment", "Valeur")),
       ligne_md("K-C3", if (profil$kc3) "rempli" else "en d\u00e9faut"),
       ligne_md("refus et \u00e9checs au-del\u00e0 de 2 % de R", if (length(profil$refus_hors))
         sprintf("oui (%s) : explication \u00e0 appr\u00e9cier, hors du script", paste(profil$refus_hors, collapse = ", ")) else
         sprintf("non (J1 %s ; J2 %s)", num(PART_REFUS[["J1"]]), num(PART_REFUS[["J2"]]))),
       ligne_md("classe de I1 \u00e0 90 %", sprintf("J1 %s ; J2 %s", lib_classe(profil$i1[["J1"]]), lib_classe(profil$i1[["J2"]]))),
       ligne_md("I1 en distorsion de c\u00f4t\u00e9s oppos\u00e9s (\u03a84)", if (profil$opp) "oui" else "non"),
       ligne_md("I2 compatible ou en \u00e9cart mineur sur J1 et J2", if (profil$basic_ok[["I2"]]) "oui" else "non"),
       ligne_md("I4 compatible ou en \u00e9cart mineur sur J1 et J2", if (profil$basic_ok[["I4"]]) "oui" else "non"),
       ligne_md("**Profil (lecture propos\u00e9e)**", if (startsWith(profil$profil, "\u03a80 (")) sprintf("**%s** ; si l'explication est admise : %s", profil$profil, profil$suite) else
         sprintf("**%s**", profil$profil)),
       "",
       "Le profil est une lecture propos\u00e9e : D2-Fn est toujours tenu, la d\u00e9cision revient au mainteneur.", "",
       sprintf("Bilan : %s", if (length(INTEGRITE)) sprintf("\u00c9CHEC (%s)", paste(INTEGRITE, collapse = ", ")) else "OK"), "")

###############################################################################
#  ECRITURE
###############################################################################
brut <- c(paste(COLONNES_BRUT, collapse = "\t"),
          vapply(seq_len(nrow(D)), function(i) format_ligne(as.list(D[i, , drop = FALSE]), COLONNES_BRUT), ""))
f_md <- file.path(TRAVAIL, NOM_MD); f_tsv <- file.path(TRAVAIL, NOM_TSV)
ecrire_fichier(f_md, S)
ecrire_fichier(f_tsv, brut)
ecrire_fichier(JOURNAL_T, c(sprintf("- Fin : %s ; dur\u00e9e de cette ex\u00e9cution %s s ; SHA \u00e0 la fin %s ; md5 R/engine.R \u00e0 la fin %s ; INTEGRITE %s",
                       horodatage(), num(secs(t_debut), 0), SHA_FIN, MD5_MOTEUR_FIN, if (length(INTEGRITE)) "ECHEC" else "OK"),
               sprintf("- Sortie %s : md5 %s", NOM_MD, md5_fichier(f_md)),
               sprintf("- Sortie %s : md5 %s", NOM_TSV, md5_fichier(f_tsv))), mode = "ab")
ecrire_console(S)
ecrire_console(c(sprintf("Sorties (dossier de travail, hors du d\u00e9p\u00f4t) : %s ; %s ; %s", f_md, f_tsv, JOURNAL_T)))
REFUS_ECRITURE <- FALSE
# Copie octet a octet vers docs/tableaux/, apres garde_ecrasement(). Atomique
# (#390) : ecriture dans un temporaire du meme dossier, controle du md5, puis
# file.rename() vers la cible ; le temporaire est supprime en cas d'echec, et
# la cible n'est jamais partielle (une cible existante reste intacte).
copier_fichier <- function(src, dst) {
  tmp <- tempfile(pattern = paste0(".", basename(dst), "."), tmpdir = dirname(dst))
  # Nettoyage a la sortie, interruption comprise (que tryCatch(error=) n'attrape pas).
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  ok <- tryCatch({
    oct <- readBin(src, "raw", n = file.size(src))
    # La connexion est fermee AVANT la comparaison des md5 : un on.exit() s'executerait
    # apres le return, tampon non vide, et le md5 du temporaire differerait (#305).
    con <- file(tmp, open = "wb")
    tryCatch(writeBin(oct, con), finally = close(con))
    identical(unname(tools::md5sum(tmp)), unname(tools::md5sum(src))) &&
      isTRUE(suppressWarnings(file.rename(tmp, dst)))
  }, error = function(e) FALSE)
  ok
}
if (OPT_ECRIRE) {
  if (length(INTEGRITE)) {
    REFUS_ECRITURE <- TRUE
    message("--ecrire refuse : INTEGRITE ECHEC (", paste(INTEGRITE, collapse = ", "), ") ; sorties laissees dans ", TRAVAIL)
  } else {
    nv <- motifs_non_versionnable(commit_depot(SCRIPT_DEPOT), empreintes_code(), "de la mesure")
    if (length(nv)) {
      message("--ecrire refuse au moment d'ecrire : ", paste(nv, collapse = " ; "))
      REFUS_ECRITURE <- TRUE
    } else {
      garde_ecrasement(CIBLES, remplacer = OPT_REMPLACER)
      if (!all(mapply(copier_fichier, c(f_md, f_tsv, JOURNAL_T), CIBLES))) {
        message("--ecrire : copie incomplete vers docs/tableaux")
        REFUS_ECRITURE <- TRUE
      } else ecrire_console(sprintf("\u00c9crit : %s", paste(CIBLES, collapse = " ; ")))
    }
  }
}
ecrire_console(paste("INTEGRITE", if (length(INTEGRITE)) "ECHEC" else "OK"))
quit(status = if (length(INTEGRITE) || REFUS_ECRITURE) 1L else 0L)
