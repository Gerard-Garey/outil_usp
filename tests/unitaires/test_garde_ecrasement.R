###############################################################################
#  tests/unitaires/test_garde_ecrasement.R  --  GARDE D'ECRASEMENT DES
#  TABLEAUX VERSIONNES (issue #173)
#
#  Teste garde_ecrasement(), ligne_remplacement() et inserer_t0() de
#  tests/outils_tests.R sur un depot git temporaire (git init dans
#  tempdir() : un fichier suivi, un non suivi, un absent), puis, sans calcul
#  long, les quatre scripts de mesure hors CI qui ont --ecrire :
#  (a) fichier suivi sans --remplacer : refus, rien d'ecrit (aucun des
#      fichiers de l'execution), message qui nomme le fichier ;
#  (b) fichier non suivi ou absent : aucun refus ;
#  (c) --remplacer : fichier suivi rendu avec son md5 d'avant, cite par la
#      ligne de T0 ;
#  (d) --remplacer sans --ecrire : refus d'usage des quatre scripts (avant
#      tout chargement du moteur) ;
#  git indisponible (commande introuvable) ou racine hors d'un depot, et
#  fichier existant : refus, meme avec --remplacer ; test statique : chacun
#  des quatre scripts appelle la garde avant toute ecriture ; puissance_t8.R
#  --ecrire (hors --combiner) dans un depot git temporaire ou le tableau du
#  jour est suivi : refus des l'analyse des options, avant tout calcul
#  (constat m2 d'audit de #173).
#  Les tests qui demandent git sont sautes, avec message, si git manque.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_garde_ecrasement.R")

# outils_tests.R est source dans un environnement dedie (comme
# test_comparateur.R) : le moteur qu'il charge n'atteint pas
# l'environnement global.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = outils_env)
garde <- outils_env$garde_ecrasement
ligne_r <- outils_env$ligne_remplacement
inserer <- outils_env$inserer_t0
RACINE_DEPOT <- outils_env$RACINE

# Refus de la garde (quitter = FALSE) : message du refus, NULL si aucun refus.
refus <- function(...) tryCatch({ garde(..., quitter = FALSE); NULL },
                                garde_ecrasement_refus = function(e) conditionMessage(e))

## --- Mise en forme (sans git) ------------------------------------------------
t0 <- c("## Titre", "", "Paramètres : x", "", "### T0 -- contexte", "",
        "| Grandeur | Valeur |", "| --- | --- |", "| Commit | abc |", "| Empreintes | def |", "",
        "### T1 -- autre", "", "| a | b |", "| --- | --- |", "| 1 | 2 |", "")
rp <- data.frame(cible = "/d/x.md", chemin = "docs/tableaux/x.md", md5_avant = "0123abcd", stringsAsFactors = FALSE)
verifier("ligne_remplacement() : ligne de T0 qui cite le chemin et le md5 d'avant",
         identical(ligne_r(rp, "/d/x.md"),
                   "| Fichier remplacé (--remplacer) | docs/tableaux/x.md, md5 d'avant 0123abcd |"))
verifier("ligne_remplacement() : aucune ligne pour une cible non remplacee, pour NULL et pour zero ligne",
         identical(ligne_r(rp, "/d/y.md"), character(0)) && identical(ligne_r(NULL, "/d/x.md"), character(0)) &&
           identical(ligne_r(rp[0, ], "/d/x.md"), character(0)))
verifier("inserer_t0() : ligne ajoutee a la fin du tableau de T0, avant la ligne vide, le reste inchange",
         { o <- inserer(t0, "| Fichier remplacé (--remplacer) | z |")
           identical(o[11], "| Fichier remplacé (--remplacer) | z |") && identical(o[-11], t0) })
verifier("inserer_t0() : aucun ajout, sortie identique",
         identical(inserer(t0, character(0)), t0))
verifier("inserer_t0() : erreur si la sortie n'a pas de titre ### T0",
         leve_erreur(inserer(t0[-5], "| a | b |")))

## --- Depot git temporaire ----------------------------------------------------
GIT_OK <- nzchar(Sys.which("git")) &&
  identical(suppressWarnings(system2("git", "--version", stdout = FALSE, stderr = FALSE)), 0L)
if (GIT_OK) {
  # racine qui contient un espace (constat M1 d'audit : arguments de
  # system2() non proteges)
  depot <- file.path(tempfile("garde_"), "depot avec espace")
  dir.create(file.path(depot, "docs", "tableaux"), recursive = TRUE)
  git <- function(...) suppressWarnings(system2("git", c("-C", shQuote(depot), ...), stdout = FALSE, stderr = FALSE))
  ecrire <- function(f, x) writeLines(x, file.path(depot, f))
  ecrire("docs/tableaux/suivi.md", "tableau publie")
  ecrire("docs/tableaux/suivi2.md", "second tableau publie")
  ecrire("docs/tableaux/supprime.md", "tableau publie puis supprime de l'arbre")
  ecrire("docs/tableaux/a b.md", "tableau publie, espace dans le nom")
  ecrire("docs/tableaux/x1.md", "tableau publie, cible d'un motif glob")
  init_ok <- identical(git("init", "-q"), 0L) &&
    identical(git("add", "docs/tableaux/suivi.md", "docs/tableaux/suivi2.md", "docs/tableaux/supprime.md",
                  shQuote("docs/tableaux/a b.md"), "docs/tableaux/x1.md"), 0L) &&
    identical(git("-c", "user.name=test", "-c", "user.email=test@example.invalid", "-c", "commit.gpgsign=false",
                  "commit", "-q", "-m", "init"), 0L)
  file.remove(file.path(depot, "docs/tableaux/supprime.md"))
  ecrire("docs/tableaux/non_suivi.md", "tableau local non versionne")
  f_suivi <- file.path(depot, "docs/tableaux/suivi.md")
  f_suivi2 <- file.path(depot, "docs/tableaux/suivi2.md")
  f_non <- file.path(depot, "docs/tableaux/non_suivi.md")
  f_abs <- file.path(depot, "docs/tableaux/absent.md")
  f_supp <- file.path(depot, "docs/tableaux/supprime.md")
  md5_suivi <- unname(tools::md5sum(f_suivi))
  verifier("Depot git temporaire (racine avec espace) : init, cinq fichiers suivis commites", init_ok)

  ## espaces et motifs glob (constat M1 d'audit)
  f_esp <- file.path(depot, "docs/tableaux/a b.md")
  verifier("(a) fichier suivi au nom avec espace, racine avec espace : refus sans --remplacer, qui le nomme",
           { m <- refus(f_esp, FALSE, depot); !is.null(m) && grepl("docs/tableaux/a b.md", m, fixed = TRUE) })
  verifier("(c) fichier suivi au nom avec espace, racine avec espace : remplace avec --remplacer, md5 d'avant",
           { r <- garde(f_esp, TRUE, depot, quitter = FALSE)
             nrow(r) == 1L && identical(r$chemin, "docs/tableaux/a b.md") &&
               identical(r$md5_avant, unname(tools::md5sum(f_esp))) })
  verifier("(b) chemin absent au nom de motif glob (x[0-9].md, x?.md) : non suivi, meme si un fichier suivi y repond",
           nrow(garde(file.path(depot, c("docs/tableaux/x[0-9].md", "docs/tableaux/x?.md")), FALSE, depot,
                      quitter = FALSE)) == 0L)

  ## (a) fichier suivi sans --remplacer
  verifier("(a) fichier suivi sans --remplacer : refus qui nomme le fichier",
           { m <- refus(f_suivi, FALSE, depot)
             !is.null(m) && grepl("docs/tableaux/suivi.md", m, fixed = TRUE) && grepl("--remplacer", m, fixed = TRUE) })
  verifier("(a) refus si UN des chemins de l'execution est suivi (absent et non suivi parmi eux), tous nommes",
           { m <- refus(c(f_abs, f_non, f_suivi, f_suivi2), FALSE, depot)
             !is.null(m) && grepl("suivi.md, docs/tableaux/suivi2.md", m, fixed = TRUE) &&
               !grepl("non_suivi.md", m, fixed = TRUE) })
  verifier("(a) fichier suivi supprime de l'arbre de travail : refus (il reste versionne)",
           !is.null(refus(f_supp, FALSE, depot)))
  verifier("(a) refus : fichier suivi inchange (la garde n'ecrit rien)",
           identical(unname(tools::md5sum(f_suivi)), md5_suivi))

  ## (b) fichier non suivi ou absent
  verifier("(b) fichier non suivi existant et fichier absent : aucun refus, aucun fichier remplace",
           { r <- garde(c(f_non, f_abs), FALSE, depot, quitter = FALSE)
             is.data.frame(r) && nrow(r) == 0L })
  verifier("(b) chemin relatif a une racine relative : meme statut",
           { ancien <- setwd(dirname(depot))
             tryCatch({
               m <- refus("depot avec espace/docs/tableaux/suivi.md", FALSE, "depot avec espace")
               r <- garde("depot avec espace/docs/tableaux/non_suivi.md", FALSE, "depot avec espace", quitter = FALSE)
               !is.null(m) && grepl("docs/tableaux/suivi.md", m, fixed = TRUE) && nrow(r) == 0L
             }, finally = setwd(ancien)) })
  verifier("(b) fichier existant hors de la racine : non suivi par ce depot, aucun refus",
           { ailleurs <- tempfile("hors_depot_", fileext = ".md"); writeLines("x", ailleurs)
             r <- garde(ailleurs, FALSE, depot, quitter = FALSE)
             nrow(r) == 0L })

  ## (c) --remplacer
  verifier("(c) --remplacer : fichier suivi rendu (chemin relatif, md5 d'avant), non suivi et absent non cites",
           { r <- garde(c(f_suivi, f_non, f_abs), TRUE, depot, quitter = FALSE)
             nrow(r) == 1L && identical(r$cible, f_suivi) && identical(r$chemin, "docs/tableaux/suivi.md") &&
               identical(r$md5_avant, md5_suivi) })
  verifier("(c) --remplacer : la ligne de T0 cite le fichier remplace et son md5 d'avant",
           { r <- garde(f_suivi, TRUE, depot, quitter = FALSE)
             identical(ligne_r(r, f_suivi),
                       sprintf("| Fichier remplacé (--remplacer) | docs/tableaux/suivi.md, md5 d'avant %s |", md5_suivi)) })
  verifier("(c) --remplacer : fichier suivi supprime de l'arbre cite comme absent",
           { r <- garde(f_supp, TRUE, depot, quitter = FALSE)
             nrow(r) == 1L && is.na(r$md5_avant) && grepl("absent de l'arbre", ligne_r(r, f_supp), fixed = TRUE) })

  ## git indisponible, racine hors d'un depot
  verifier("git indisponible et fichier existant : refus, meme avec --remplacer",
           { m1 <- refus(f_non, FALSE, depot, git = "git-introuvable-173")
             m2 <- refus(f_suivi, TRUE, depot, git = "git-introuvable-173")
             !is.null(m1) && !is.null(m2) && grepl("ne peut etre verifie", m2, fixed = TRUE) })
  verifier("git indisponible et fichier absent : aucun refus",
           nrow(garde(f_abs, FALSE, depot, quitter = FALSE, git = "git-introuvable-173")) == 0L)
  verifier("racine hors d'un depot git et fichier existant : refus (suivi indetermine)",
           { r2 <- tempfile("sans_git_"); dir.create(r2); f2 <- file.path(r2, "t.md"); writeLines("x", f2)
             !is.null(refus(f2, FALSE, r2)) && !is.null(refus(f2, TRUE, r2)) })

  ## quitter = TRUE (chemin des scripts) : code 1, message, rien d'ecrit
  verifier("quitter = TRUE : code de sortie 1 et message qui nomme le fichier suivi (processus separe)",
           { s <- tempfile("garde_", fileext = ".R")
             writeLines(c(sprintf("setwd(%s)", deparse(normalizePath(RACINE_DEPOT))),
                          "source('tests/outils_tests.R')",
                          sprintf("garde_ecrasement(c(%s, %s), FALSE, %s)", deparse(f_abs), deparse(f_suivi), deparse(depot)),
                          "writeLines('x', file.path(tempdir(), 'ne-doit-pas-arriver'))",
                          "cat('APRES LA GARDE\\n')"), s)
             o <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(s), stdout = TRUE, stderr = TRUE))
             identical(attr(o, "status"), 1L) && any(grepl("docs/tableaux/suivi.md", o, fixed = TRUE)) &&
               !any(grepl("APRES LA GARDE", o, fixed = TRUE)) && !file.exists(f_abs) &&
               identical(unname(tools::md5sum(f_suivi)), md5_suivi) })
} else {
  cat("  [saute] garde_ecrasement() sur depot git temporaire : git introuvable\n")
}

## --- Les quatre scripts ------------------------------------------------------
SCRIPTS_ECRIRE <- c("puissance_t8.R", "constats_puissance_t8.R", "calibration_mc_t8.R",
                    "taux_franchissement_reperes.R")
.tests <- file.path(.dossier, "..")
for (sc in SCRIPTS_ECRIRE) {
  L <- readLines(file.path(.tests, sc), encoding = "UTF-8")
  code <- sub("#.*$", "", L)
  i_garde <- grep("garde_ecrasement(", code, fixed = TRUE)
  i_ecrit <- grep("open = \"wb\"", code, fixed = TRUE)
  verifier(sprintf("%s : appelle garde_ecrasement(), avant toute ouverture de fichier en ecriture", sc),
           length(i_garde) >= 1L && length(i_ecrit) >= 1L && min(i_garde) < min(i_ecrit))
  # Boucle d'ecriture de plusieurs fichiers (constat m1 d'audit) : la garde
  # precede la boucle "for (" qui ouvre les fichiers en ecriture, et n'est
  # pas appelee dans cette boucle (tous les chemins controles avant d'en
  # ecrire un seul).
  if (sc %in% c("puissance_t8.R", "constats_puissance_t8.R"))
    verifier(sprintf("%s : garde appelee avant la boucle d'ecriture, jamais dans la boucle", sc),
             { i_for <- grep("^\\s*for \\(", code)
               all(vapply(i_ecrit, function(w) {
                 f <- max(c(0L, i_for[i_for < w]))
                 f > 0L && any(i_garde < f & i_garde > f - 15L) && !any(i_garde > f & i_garde < w)
               }, logical(1))) })
  verifier(sprintf("%s : --remplacer documente dans l'usage de l'en-tete", sc),
           any(grepl("^#.*--remplacer", L)))
  # (d) refus d'usage, avant tout chargement du moteur (aucun calcul)
  verifier(sprintf("(d) %s --remplacer sans --ecrire : refus d'usage (code 1, message)", sc),
           { o <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                           c(shQuote(file.path(.tests, sc)), "--remplacer"), stdout = TRUE, stderr = TRUE))
             identical(attr(o, "status"), 1L) && any(grepl("--remplacer : reserve a --ecrire", o, fixed = TRUE)) })
}

## --- puissance_t8.R : garde anticipee, avant tout calcul (constat m2) ----------
# Depot git temporaire (racine avec espace) qui porte le moteur, les outils,
# les donnees et le script ; les tableaux du jour (et du lendemain : passage
# de minuit pendant le test) y sont suivis. Le script est lance depuis cette
# racine (RACINE de outils_tests.R). Preuve qu'aucun calcul n'a commence :
# aucun titre "## Puissance" (imprime a la fin de chaque volet) dans la
# sortie, et duree mesuree.
if (GIT_OK) {
  dp <- file.path(tempfile("garde_m2_"), "depot avec espace")
  for (d in c("R", "tests/donnees", "docs/tableaux")) dir.create(file.path(dp, d), recursive = TRUE)
  copies <- c("R/engine.R", "tests/outils_tests.R", "tests/puissance_t8.R",
              "tests/donnees/donnees_ln.csv", "tests/donnees/triangle_mw.csv")
  file.copy(file.path(RACINE_DEPOT, copies), file.path(dp, copies))
  dates <- format(Sys.Date() + 0:1, "%Y%m%d")
  suivis <- c(sprintf("docs/tableaux/%s-issue116-exact-J1.md", dates),
              sprintf("docs/tableaux/%s-issue116-chaine-J2.md", dates))
  for (f in suivis) writeLines("tableau publie", file.path(dp, f))
  gp <- function(...) suppressWarnings(system2("git", c("-C", shQuote(dp), ...), stdout = FALSE, stderr = FALSE))
  init_p <- identical(gp("init", "-q"), 0L) && identical(gp("add", "-A"), 0L) &&
    identical(gp("-c", "user.name=test", "-c", "user.email=test@example.invalid", "-c", "commit.gpgsign=false",
                 "commit", "-q", "-m", "init"), 0L)
  verifier("puissance_t8.R, garde anticipee : depot git temporaire (racine avec espace), tableaux du jour suivis",
           init_p)
  md5_p <- tools::md5sum(file.path(dp, suivis))
  lancer_p <- function(args) {
    ancien <- setwd(dp)
    on.exit(setwd(ancien))
    t0 <- Sys.time()
    o <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), c(shQuote("tests/puissance_t8.R"), args),
                                  stdout = TRUE, stderr = TRUE))
    list(o = o, duree = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  }
  inchange <- function() identical(tools::md5sum(file.path(dp, suivis)), md5_p) &&
    setequal(list.files(file.path(dp, "docs/tableaux")), basename(suivis))
  for (cas in list(list(args = c("--ecrire", "--volet", "A", "--R", "20"), cible = "exact-J1", autre = "chaine-J"),
                   list(args = c("--ecrire", "--volet", "B", "--R-chaine", "1"), cible = "chaine-J2",
                        autre = "exact-J1"),
                   # --jeu J2 : chaine-J2 seul controle (chaine-J1 non suivi)
                   list(args = c("--ecrire", "--volet", "B", "--jeu", "J2", "--R-chaine", "1"), cible = "chaine-J2",
                        autre = "exact-J1"))) {
    r <- lancer_p(cas$args)
    cat(sprintf("  puissance_t8.R %s : code %s en %.1f s\n", paste(cas$args, collapse = " "),
                format(if (is.null(attr(r$o, "status"))) 0L else attr(r$o, "status")), r$duree))
    verifier(sprintf("puissance_t8.R %s, %s suivi : refus (code 1) qui le nomme, avant tout calcul (aucun titre de volet)",
                     paste(cas$args, collapse = " "), cas$cible),
             identical(attr(r$o, "status"), 1L) &&
               any(grepl(paste0("--ecrire refuse : fichier(s) suivi(s)"), r$o, fixed = TRUE)) &&
               any(grepl(paste0("-issue116-", cas$cible, ".md"), r$o, fixed = TRUE)) &&
               !any(grepl(paste0("-issue116-", cas$autre), r$o, fixed = TRUE)) &&
               !any(grepl("## Puissance", r$o, fixed = TRUE)))
    verifier(sprintf("puissance_t8.R %s : rien d'ecrit (tableaux suivis inchanges, aucun fichier cree)",
                     paste(cas$args, collapse = " ")), inchange())
  }
  # --jeu J1 : chaine-J2 (suivi) n'est pas une cible, aucun refus anticipe ;
  # l'execution va a son terme (B = B_MIN_USAGE = 99, R-chaine 1 : ~ 8 s)
  # et ecrit chaine-J1, non suivi. Un controle qui ignorerait --jeu
  # (chaine-J1 et chaine-J2 figes) refuserait ici avant tout calcul.
  r <- lancer_p(c("--ecrire", "--volet", "B", "--jeu", "J1", "--R-chaine", "1", "--B", "99"))
  cat(sprintf("  puissance_t8.R --ecrire --volet B --jeu J1 --R-chaine 1 --B 99 : code %s en %.1f s\n",
              format(if (is.null(attr(r$o, "status"))) 0L else attr(r$o, "status")), r$duree))
  nouveaux <- setdiff(list.files(file.path(dp, "docs/tableaux")), basename(suivis))
  verifier("puissance_t8.R --ecrire --volet B --jeu J1, chaine-J2 suivi : aucun refus (chaine-J2 hors cible), chaine-J1 ecrit",
           is.null(attr(r$o, "status")) && !any(grepl("--ecrire refuse", r$o, fixed = TRUE)) &&
             any(grepl("## Puissance", r$o, fixed = TRUE)) && length(nouveaux) == 1L &&
             grepl("-issue116-chaine-J1.md$", nouveaux) &&
             identical(tools::md5sum(file.path(dp, suivis)), md5_p))
} else {
  cat("  [saute] puissance_t8.R, garde anticipee : git introuvable\n")
}

fin_fichier()
