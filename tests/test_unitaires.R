###############################################################################
#  tests/test_unitaires.R  --  LANCEUR DES TESTS UNITAIRES DU MOTEUR
#
#  Execute tous les fichiers tests/unitaires/test_*.R, chacun dans son propre
#  environnement, apres chargement de R/engine.R. Complement des tests de
#  non-regression (test_reproductibilite.R) : chaque fonction du moteur est
#  confrontee a une valeur de reference justifiee (texte reglementaire, valeur
#  publiee, enumeration exhaustive, implementation independante) ou a une
#  propriete theorique.
#
#  Les defauts connus du moteur sont documentes par des tests "echec attendu"
#  (xfail) : ils ne font pas echouer la batterie tant que le defaut subsiste ;
#  un "succes inattendu" (XPASS), signe que le defaut a ete corrige, la fait
#  echouer afin que le test soit transforme en test ordinaire.
#
#  R base + stats uniquement. Duree : 31 min 30 s en sequentiel et 8 min 39 s en
#  parallele a 4 processus (conteneur a 4 coeurs partage, 05/11/2026) ; 32 min 02 s
#  en sequentiel dans le job de la CI du 05/11/2026 (issue #444).
#  Code de sortie 0 si tout passe, 1 sinon (utilise par l'integration continue).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/test_unitaires.R
#  Detail de toutes les assertions :
#      Rscript -e "options(tu.verbeux = TRUE); source('tests/test_unitaires.R')"
#
#  Mode parallele (issue #444) : un processus Rscript par fichier, N a la fois,
#  la sortie de chaque fichier imprimee en bloc des qu'il a fini, avec sa
#  duree ; memes fichiers, meme bilan global, meme code de sortie.
#      Rscript tests/test_unitaires.R --parallele        (N = 4)
#      Rscript tests/test_unitaires.R --parallele=2      (N = 2)
#  ou, sans option, la variable d'environnement TU_PARALLELE=N (la valeur de
#  l'option l'emporte). Le mode sequentiel reste le defaut : il execute les
#  fichiers dans ce processus (seul mode qui accepte options(tu.verbeux)). Le
#  mode parallele repose sur parallel::mcparallel() (fork, systemes Unix) ;
#  sous Windows il se replie, avec un message, sur le mode sequentiel. Les
#  assertions de duree ("en moins d'une seconde") y subissent la charge de N
#  processus : ne pas depasser le nombre de coeurs.
###############################################################################

# Arguments : --parallele[=N] (ou TU_PARALLELE=N). Tout autre argument est
# refuse, pour qu'une faute de frappe ne lance pas le mode sequentiel en silence.
N_PARALLELE_DEFAUT <- 4L
.arguments <- commandArgs(trailingOnly = TRUE)
.option <- grep("^--parallele(=.*)?$", .arguments, value = TRUE)
if (length(setdiff(.arguments, .option))) {
  cat("Argument(s) inconnu(s) :", paste(setdiff(.arguments, .option), collapse = " "),
      "\nUsage : Rscript tests/test_unitaires.R [--parallele[=N]]\n")
  quit(status = 1)
}
.valeur <- if (length(.option)) sub("^--parallele=?", "", .option[1L]) else ""
if (!nzchar(.valeur)) .valeur <- Sys.getenv("TU_PARALLELE", unset = "")
N_PARALLELE <- 0L   # 0 : mode sequentiel
if (length(.option) || nzchar(.valeur)) {
  N_PARALLELE <- N_PARALLELE_DEFAUT
  if (nzchar(.valeur)) {
    N_PARALLELE <- suppressWarnings(as.integer(.valeur))
    if (is.na(N_PARALLELE) || N_PARALLELE < 1L || !identical(as.character(N_PARALLELE), .valeur)) {
      cat("Nombre de processus invalide :", .valeur, "(entier >= 1 attendu)\n")
      quit(status = 1)
    }
  }
}

.args <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
DOSSIER_UNITAIRES <- if (length(.args)) file.path(dirname(.args), "unitaires") else
                     if (dir.exists("tests/unitaires")) "tests/unitaires" else "unitaires"
if (!dir.exists(DOSSIER_UNITAIRES)) {
  cat("Dossier des tests unitaires introuvable :", DOSSIER_UNITAIRES, "\n")
  quit(status = 1)
}
FICHIERS_UNITAIRES <- sort(list.files(DOSSIER_UNITAIRES, pattern = "^test_.*[.]R$", full.names = TRUE))

# Garde (#284) : un fichier unitaire doit finir par fin_fichier(), seul appel
# qui rend un code de sortie non nul en lancement autonome
# (Rscript tests/unitaires/test_x.R) ; bilan_fichier() n'imprime que le
# decompte et laisse la sortie a 0 malgre des echecs. Renvoie le message
# d'echec, ou NULL si le fichier finit par fin_fichier().
garde_fin_fichier <- function(f) {
  l <- trimws(iconv(readLines(f, warn = FALSE), "UTF-8", "UTF-8", sub = "byte"))
  l <- l[nzchar(l)]
  if (length(l) && l[length(l)] == "fin_fichier()") return(NULL)
  paste0("derniere ligne non vide : ", if (length(l)) l[length(l)] else "(fichier vide)")
}

# Mode parallele (issue #444) : un Rscript par fichier, au plus `n` a la fois.
# Chaque fichier se lance seul, comme `Rscript tests/unitaires/test_x.R` :
# sa sortie est capturee (stdout et stderr) par un processus fils (fork) et
# imprimee en bloc, par le processus principal seul, quand il a fini ; elle
# ne s'entrelace donc jamais. Le bilan d'un fichier est lu sur la ligne TOTAL
# de terminer() (tests/unitaires/outils_unitaires.R), dont le format est
# repris ici (et celui de bilan_fichier(), repli) : un bilan absent est un echec. Renvoie les
# comptes cumules (data.frame d'une ligne par fichier) ; le code de sortie
# est decide par l'appelant, comme en mode sequentiel.
FORMAT_TOTAL <- paste0("^TOTAL : ([0-9]+) assertions, ([0-9]+) ok, ([0-9]+) echec[(]s[)], ",
                       "([0-9]+) echec[(]s[)] attendu[(]s[)] [(]defauts connus[)], ",
                       "([0-9]+) succes inattendu[(]s[)]$")

FORMAT_BILAN <- paste0("^ *([0-9]+) assertions : ([0-9]+) ok, ([0-9]+) echec[(]s[)], ",
                       "([0-9]+) echec[(]s[)] attendu[(]s[)], ([0-9]+) succes inattendu[(]s[)]  [(][0-9.]+ s[)]$")

# Derniere ligne de `sortie` au format `rx` (cinq entiers captures), ou NULL.
lire_total <- function(sortie, rx) {
  m <- Filter(length, regmatches(sortie, regexec(rx, sortie)))
  if (!length(m)) return(NULL)
  v <- as.integer(m[[length(m)]][-1L])
  setNames(v, c("n", "ok", "echec", "attendu", "inattendu"))
}

executer_fichier_externe <- function(f) {
  t0 <- Sys.time()
  sortie <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(f),
                                     stdout = TRUE, stderr = TRUE))
  statut <- attr(sortie, "status")
  list(sortie = as.character(sortie), statut = if (is.null(statut)) 0L else as.integer(statut),
       duree = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}

lancer_parallele <- function(fichiers, n) {
  n <- min(n, length(fichiers))
  # Les plus gros fichiers d'abord (taille en octets, indicateur grossier de
  # la duree) : un fichier long lance en dernier prolongerait la fin du lot.
  attente <- fichiers[order(-file.size(fichiers), fichiers)]
  en_cours <- list()
  comptes <- list()
  t0 <- Sys.time()
  on.exit(if (length(en_cours))
    try(parallel::mckill(vapply(en_cours, function(j) as.integer(j$pid), integer(1)), tools::SIGKILL), silent = TRUE),
    add = TRUE)
  cat(sprintf("Mode parallele : %d fichiers, %d processus a la fois.\n", length(fichiers), n))
  while (length(attente) || length(en_cours)) {
    while (length(attente) && length(en_cours) < n) {
      f <- attente[[1L]]; attente <- attente[-1L]
      en_cours[[basename(f)]] <- parallel::mcparallel(executer_fichier_externe(f), name = basename(f))
    }
    fini <- parallel::mccollect(en_cours, wait = FALSE, timeout = 1)
    for (nom in names(fini)) {
      en_cours[[nom]] <- NULL
      r <- fini[[nom]]
      f <- file.path(DOSSIER_UNITAIRES, nom)
      if (!is.list(r) || is.null(r$sortie))
        r <- list(sortie = paste("processus fils interrompu :", paste(format(r), collapse = " ")),
                  statut = NA_integer_, duree = NA_real_)
      un_echec <- c(n = 1L, ok = 0L, echec = 1L, attendu = 0L, inattendu = 0L)
      motif <- character(0)
      # Comptes : ligne TOTAL de terminer() ; a defaut, ligne de bilan_fichier()
      # (fichier sans fin_fichier() final, que la garde ci-dessous echoue) ;
      # a defaut, le fichier a plante sans rien compter : une ligne en echec
      # (en mode sequentiel, ses assertions deja comptees le seraient aussi).
      tot <- lire_total(r$sortie, FORMAT_TOTAL)
      sans_total <- is.null(tot)
      if (sans_total) tot <- lire_total(r$sortie, FORMAT_BILAN)
      if (is.null(tot)) {
        tot <- un_echec
        motif <- "aucun bilan (ni TOTAL ni bilan de fichier) dans la sortie : fichier interrompu"
      } else if (!sans_total && (is.na(r$statut) || r$statut != 0L) && tot[["echec"]] + tot[["inattendu"]] == 0L) {
        tot <- tot + un_echec
        motif <- sprintf("code de sortie %s sans echec compte", r$statut)
      }
      g <- garde_fin_fichier(f)
      if (!is.null(g)) {
        tot <- tot + un_echec
        motif <- c(motif, paste0(nom, " finit par fin_fichier() : ", g))
      } else if (sans_total && !length(motif)) {
        tot <- tot + un_echec
        motif <- "ligne TOTAL absente alors que le fichier finit par fin_fichier()"
      }
      comptes[[nom]] <- c(tot, duree = r$duree)
      ko <- tot[["echec"]] + tot[["inattendu"]] > 0L
      # En-tete, sortie du fichier sans sa ligne TOTAL ni son verdict final
      # (repris dans l'en-tete), puis les motifs propres au lanceur.
      sortie <- r$sortie
      retirer_fin <- function(x, rx) if (length(x) && grepl(rx, x[length(x)])) x[-length(x)] else x
      sortie <- retirer_fin(retirer_fin(retirer_fin(sortie, "^$"), "^(OK|ECHEC)$"), "^$")
      sortie <- retirer_fin(retirer_fin(sortie, FORMAT_TOTAL), "^$")
      cat(sprintf("\n##### [%d/%d] %s : %s, %d assertions, %.1f s\n", length(comptes), length(fichiers), nom,
                  if (ko) "ECHEC" else "OK", tot[["n"]], r$duree))
      cat(sortie, sep = "\n")
      if (length(sortie)) cat("\n")
      for (m in motif) cat(sprintf("  [ECHEC] %s\n", m))
    }
  }
  cat(sprintf("\nDuree totale : %.1f s (somme des durees par fichier : %.1f s, %d processus)\n",
              as.numeric(difftime(Sys.time(), t0, units = "secs")),
              sum(vapply(comptes, function(x) x[["duree"]], numeric(1)), na.rm = TRUE), n))
  d <- as.data.frame(do.call(rbind, comptes))
  d$fichier <- names(comptes)
  d
}

# Bilan global : meme format et meme code de sortie que terminer() de
# outils_unitaires.R (1 si au moins un echec ou un succes inattendu).
terminer_parallele <- function(d) {
  cat(sprintf("\nTOTAL : %d assertions, %d ok, %d echec(s), %d echec(s) attendu(s) (defauts connus), %d succes inattendu(s)\n",
              sum(d$n), sum(d$ok), sum(d$echec), sum(d$attendu), sum(d$inattendu)))
  ko <- d$fichier[d$echec + d$inattendu > 0L]
  if (length(ko)) {
    cat("\nFichiers en echec ou en succes inattendu :", paste(sort(ko), collapse = ", "), "\n")
    cat("\nECHEC\n")
    quit(status = 1)
  }
  cat("OK\n")
  invisible(TRUE)
}

if (N_PARALLELE > 0L && .Platform$OS.type != "unix") {
  cat("Mode parallele indisponible hors systemes Unix (fork) : repli sur le mode sequentiel.\n")
  N_PARALLELE <- 0L
}
if (N_PARALLELE > 0L) {
  terminer_parallele(lancer_parallele(FICHIERS_UNITAIRES, N_PARALLELE))
} else {
  # Mode sequentiel (defaut) : tous les fichiers dans ce processus.
  LANCEUR_UNITAIRES <- TRUE
  source(file.path(DOSSIER_UNITAIRES, "outils_unitaires.R"))

  t0 <- Sys.time()
  for (f in FICHIERS_UNITAIRES) {
    r <- tryCatch({ sys.source(f, envir = new.env(parent = globalenv())); NULL },
                  error = function(e) e)
    if (inherits(r, "error")) {
      .tu$fichier <- basename(f)
      .enregistrer("chargement du fichier", "ECHEC", conditionMessage(r))
    }
    g <- garde_fin_fichier(f)
    if (!is.null(g)) {
      .tu$fichier <- basename(f)
      .enregistrer(paste0(basename(f), " finit par fin_fichier()"), "ECHEC", g)
    }
  }
  cat(sprintf("\nDuree totale : %.1f s\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  terminer()
}
