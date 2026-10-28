###############################################################################
#  tests/unitaires/test_chargement_moteur.R  --  CHARGEMENT DU MOTEUR DANS UN
#                         ENVIRONNEMENT DEDIE (#200, ADR 0016)
#
#  charger_moteur() (R/charger_moteur.R) charge R/engine.R dans un
#  environnement "usp_moteur" dont la chaine de resolution est
#  usp_moteur -> imports:usp_moteur (exports de stats) -> base. Proprietes
#  testees (criteres d'acceptation 1 a 5 de l'ADR 0016) :
#    - forme de la chaine, enclos baseenv() du chargeur, exposition par copie
#      (noms a point compris), dans = NULL, refus des arguments invalides ;
#    - sigma_USP de reserve1 (tests/donnees/donnees_ln.csv, segment 1,
#      B = B_MIN_USAGE) inchange avec la fonction c de #200 dans
#      l'environnement global ;
#    - intersect(), setdiff() et pi de l'environnement global sans effet ;
#    - paquet factice attache AVANT le chargement, qui exporte intersect() et
#      setdiff() : sans effet ;
#    - add() refuse un argument fonction qui ne designe qu'une fonction de
#      l'environnement global (limite C1 de l'ADR 0003 levee).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_chargement_moteur.R")

.dossier200 <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
.racine200 <- file.path(.dossier200, "..", "..")
.moteur200 <- file.path(.racine200, "R", "engine.R")
.chg200 <- new.env()
sys.source(file.path(.racine200, "R", "charger_moteur.R"), envir = .chg200)
.ln200 <- utils::read.csv(file.path(.racine200, "tests", "donnees", "donnees_ln.csv"))
# Valeur de l'ADR 0016 (tableau des mesures, reserve1, B = B_MIN_USAGE).
SIGMA_REF200 <- 0.1073524114

# sigma_USP de reserve1 calcule par le moteur charge (fonction run_engine
# passee en argument), les objets `objets` (liste nommee) poses dans
# l'environnement global le temps du calcul seulement, puis retires. Aucun
# nom pose ne doit preexister dans l'environnement global.
sigma_sous_globaux200 <- function(run, objets = list()) {
  genv <- globalenv()
  noms <- names(objets)
  stopifnot(!any(vapply(noms, exists, logical(1), envir = genv, inherits = FALSE)))
  on.exit(rm(list = noms[vapply(noms, exists, logical(1), envir = genv, inherits = FALSE)],
             envir = genv), add = TRUE)
  for (n in noms) assign(n, objets[[n]], envir = genv)
  r <- run(xt = .ln200$xt, yt = .ln200$yt, methode = "reserve1", segment = 1,
           annexe = "II", B = B_MIN_USAGE)
  if (!isTRUE(r$ok)) return(NA_real_)
  r$parametre_final$sigma_usp
}

# --- Forme de l'environnement (critere 4) -----------------------------------
verifier("charger_moteur() : environment(run_engine) nomme usp_moteur, parent imports:usp_moteur (exports de stats), puis baseenv() ; enclos du chargeur baseenv() (#200, ADR 0016)",
         {
           e <- environment(run_engine)
           p <- parent.env(e)
           identical(attr(e, "name"), "usp_moteur") &&
             identical(attr(p, "name"), "imports:usp_moteur") &&
             identical(parent.env(p), baseenv()) &&
             setequal(ls(p, all.names = TRUE), getNamespaceExports("stats")) &&
             identical(environment(.chg200$charger_moteur), baseenv()) &&
             identical(environment(engine_registre_tests), e)
         })
verifier("charger_moteur() : exposition par copie de toutes les liaisons (noms a point compris), enclos des copies = environnement du moteur ; dans = NULL n'expose rien ; rend l'environnement du moteur",
         {
           d <- new.env(parent = emptyenv())
           m <- .chg200$charger_moteur(.moteur200, dans = d)
           d0 <- new.env(parent = emptyenv())
           m0 <- .chg200$charger_moteur(.moteur200, dans = NULL)
           noms <- ls(m, all.names = TRUE)
           identical(sort(ls(d, all.names = TRUE)), sort(noms)) &&
             ".shapiro_sur" %in% noms &&
             identical(environment(d$run_engine), m) &&
             identical(attr(m0, "name"), "usp_moteur") && !identical(m0, m) &&
             !length(ls(d0, all.names = TRUE))
         })
verifier("charger_moteur() : fichier absent, fichier non chaine, dans ni NULL ni environnement -> erreur",
         leve_erreur(.chg200$charger_moteur(tempfile("absent_"), dans = NULL)) &&
           leve_erreur(.chg200$charger_moteur(1, dans = NULL)) &&
           leve_erreur(.chg200$charger_moteur(c(.moteur200, .moteur200), dans = NULL)) &&
           leve_erreur(.chg200$charger_moteur(.moteur200, dans = list())))

# --- Homonymes de l'environnement global (criteres 1 et 2) ------------------
.sigma0_200 <- sigma_sous_globaux200(run_engine)
verifier("reserve1, segment 1, B = B_MIN_USAGE, sans homonyme : sigma_USP = 0,1073524114 (ADR 0016)",
         proche(.sigma0_200, SIGMA_REF200, rel = 1e-6))
verifier("#200 : fonction c de l'issue (doubles multiplies par 1 + 1e-3) dans l'environnement global -> sigma_USP de reserve1 identique au calcul sans elle",
         identical(sigma_sous_globaux200(run_engine, list(
           c = function(...) { x <- base::c(...); if (is.double(x)) x * (1 + 1e-3) else x })),
           .sigma0_200))
verifier("#200 : intersect(), setdiff() (masques de dplyr) et pi <- 3 dans l'environnement global -> sigma_USP de reserve1 identique au calcul sans eux",
         identical(sigma_sous_globaux200(run_engine, list(
           intersect = function(x, y) x, setdiff = function(x, y) x, pi = 3)),
           .sigma0_200))
verifier("#200 : usp_parametre() redefinie dans l'environnement global apres le chargement -> sans effet sur run_engine()",
         {
           # usp_parametre est expose dans l'environnement global : la copie
           # y est ecrasee le temps du calcul, puis restauree.
           genv <- globalenv(); orig <- get("usp_parametre", envir = genv)
           on.exit(assign("usp_parametre", orig, envir = genv), add = TRUE)
           assign("usp_parametre", function(...) stop("detourne"), envir = genv)
           s <- sigma_sous_globaux200(run_engine)
           identical(s, .sigma0_200)
         })

# --- Paquet attache avant le chargement (critere 5) -------------------------
verifier("#200 : paquet factice attache AVANT le chargement, exportant intersect() et setdiff() -> moteur charge ensuite non detourne (sigma_USP identique)",
         {
           nom_pq <- "factice200"
           attach(list(intersect = function(x, y) x, setdiff = function(x, y) x),
                  name = nom_pq, warn.conflicts = FALSE)
           on.exit(if (nom_pq %in% search()) detach(nom_pq, character.only = TRUE), add = TRUE)
           m <- .chg200$charger_moteur(.moteur200, dans = NULL)
           identical(sigma_sous_globaux200(m$run_engine), .sigma0_200)
         })

# --- add() et l'argument fonction (critere 3 ; limite C1 levee) -------------
verifier("add() (#111, #200) : fonction qui ne designe qu'une fonction de l'environnement global -> refusee (fonction inconnue du moteur) ; fonction du moteur admise",
         {
           genv <- globalenv(); nom_g <- "fonction_globale_200"
           stopifnot(!exists(nom_g, envir = genv, inherits = FALSE))
           on.exit(if (exists(nom_g, envir = genv, inherits = FALSE)) rm(list = nom_g, envir = genv),
                   add = TRUE)
           assign(nom_g, function() NULL, envir = genv)
           boot <- list(stats_obs = list(), p_mc = numeric(0), err_mc = numeric(0))
           reg <- engine_registre_tests(boot, USP_CATALOGUE_MC, 0.10, "Monte-Carlo")
           m_g <- tryCatch({ reg$add("F", "t", "r", type = "diagnostic", fonction = nom_g); "" },
                           error = function(e) conditionMessage(e))
           m_ok <- tryCatch({ reg$add("F", "t", "r", type = "diagnostic", fonction = ".shapiro_sur"); "" },
                            error = function(e) conditionMessage(e))
           grepl(paste0("fonction inconnue du moteur : ", nom_g), m_g, fixed = TRUE) &&
             identical(m_ok, "") && length(reg$lignes()) == 1L
         })

rm(.dossier200, .racine200, .moteur200, .chg200, .ln200, SIGMA_REF200,
   sigma_sous_globaux200, .sigma0_200)

fin_fichier()
