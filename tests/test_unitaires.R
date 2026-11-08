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
#
#  Selection d'un lot de fichiers (issue #512) : --lot=k/n ne lance que le lot
#  k sur n (1 <= k <= n), seul ou avec --parallele, pour repartir la batterie
#  sur plusieurs jobs de la CI (matrice de ci.yml).
#      Rscript tests/test_unitaires.R --parallele --lot=2/3
#  Repartition deterministe, calculee sur les fichiers presents sur le disque :
#  chaque fichier est dans un lot et un seul, la reunion des n lots est la
#  batterie complete. Algorithme LPT (plus longs d'abord, chacun dans le lot le
#  moins charge) sur la table des durees tests/durees_unitaires.tsv (une ligne
#  par fichier : nom, tabulation, duree en secondes ; lignes # ignorees). Un
#  fichier absent de la table prend DUREE_DEFAUT_S ; une ligne de la table sans
#  fichier sur le disque est ignoree. Les fichiers qui exigent shiny ou plotly
#  (requireNamespace("shiny"|"plotly") ou shiny:: / plotly:: dans leur texte)
#  forment un groupe indivisible place dans le lot 1, pour l'ordonnancement ;
#  la CI installe shiny et plotly dans chaque lot. La meme table ordonne
#  --parallele (plus longs d'abord), avec ou sans --lot.
###############################################################################

# Arguments : --parallele[=N] (ou TU_PARALLELE=N) et --lot=k/n. Tout autre
# argument est refuse, pour qu'une faute de frappe ne lance pas le mode
# sequentiel ou la batterie entiere en silence.
N_PARALLELE_DEFAUT <- 4L
.arguments <- commandArgs(trailingOnly = TRUE)
.option <- grep("^--parallele(=.*)?$", .arguments, value = TRUE)
.option_lot <- grep("^--lot=", .arguments, value = TRUE)
if (length(setdiff(.arguments, c(.option, .option_lot))) || length(.option_lot) > 1L) {
  cat("Argument(s) inconnu(s) ou repete(s) :",
      paste(c(setdiff(.arguments, c(.option, .option_lot)), if (length(.option_lot) > 1L) .option_lot), collapse = " "),
      "\nUsage : Rscript tests/test_unitaires.R [--parallele[=N]] [--lot=k/n]\n")
  quit(status = 1)
}
LOT <- NULL   # NULL : batterie complete ; sinon c(k = , n = )
if (length(.option_lot)) {
  .m <- regmatches(.option_lot, regexec("^--lot=([0-9]+)/([0-9]+)$", .option_lot))[[1L]]
  .k <- suppressWarnings(as.integer(.m[2L])); .n <- suppressWarnings(as.integer(.m[3L]))
  if (length(.m) != 3L || is.na(.k) || is.na(.n) || .k < 1L || .k > .n) {
    cat("Lot invalide :", .option_lot, "(--lot=k/n avec 1 <= k <= n, entiers)\n")
    quit(status = 1)
  }
  LOT <- c(k = .k, n = .n)
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

# Table des durees (issue #512) : tests/durees_unitaires.tsv, une ligne par
# fichier (nom avec .R, tabulation, duree en secondes, mesurees en CI sous 4
# processus) ; lignes vides et lignes # ignorees. Une table illisible est une
# erreur (jamais un repli silencieux sur la duree par defaut).
FICHIER_DUREES <- file.path(dirname(DOSSIER_UNITAIRES), "durees_unitaires.tsv")
DUREE_DEFAUT_S <- 60   # fichier absent de la table : duree moyenne d'un fichier (~58 s en CI)

lire_durees <- function(chemin = FICHIER_DUREES) {
  vide <- setNames(numeric(0), character(0))
  if (!file.exists(chemin)) return(vide)
  l <- readLines(chemin, warn = FALSE)
  l <- l[nzchar(trimws(l)) & !grepl("^#", l)]
  if (!length(l)) return(vide)
  champs <- strsplit(l, "\t", fixed = TRUE)
  d <- suppressWarnings(vapply(champs, function(x) if (length(x) == 2L) as.numeric(x[2L]) else NA_real_, numeric(1)))
  nom <- vapply(champs, function(x) x[1L], character(1))
  if (anyNA(d) || any(d <= 0) || anyDuplicated(nom)) {
    cat("Table des durees illisible :", chemin, "\n",
        "  attendu : nom<TAB>duree > 0, un nom par ligne ; ligne fautive : ",
        if (anyNA(d) || any(d <= 0)) l[which(is.na(d) | d <= 0)[1L]] else nom[anyDuplicated(nom)], "\n")
    quit(status = 1)
  }
  setNames(d, nom)
}
DUREES_UNITAIRES <- lire_durees()

duree_estimee <- function(fichiers, durees = DUREES_UNITAIRES) {
  d <- unname(durees[basename(fichiers)])
  d[is.na(d)] <- DUREE_DEFAUT_S
  d
}

# Fichiers qui exigent shiny ou plotly : sans ces paquets, leurs blocs sautent
# en silence et le nombre d'assertions baisse. Regroupes dans le lot 1 pour
# l'ordonnancement seulement (la CI installe ces paquets dans chaque lot).
# Lecture en octets : les fichiers sont en UTF-8 et la locale du lanceur peut
# etre POSIX.
MOTIF_APPLICATION <- "requireNamespace[(][\"](shiny|plotly)[\"]|(shiny|plotly)::"
exige_application <- function(f)
  any(grepl(MOTIF_APPLICATION, readLines(f, warn = FALSE), useBytes = TRUE))

# Repartition en n lots (liste : lot = entier par fichier, charge = duree
# estimee par lot, application = fichiers du groupe shiny / plotly). Groupe
# application indivisible dans le lot 1, puis LPT sur les autres fichiers ;
# egalites departagees par le nom, donc repartition deterministe.
repartir_lots <- function(fichiers, n, durees = DUREES_UNITAIRES) {
  d <- duree_estimee(fichiers, durees)
  app <- vapply(fichiers, exige_application, logical(1), USE.NAMES = FALSE)
  lot <- integer(length(fichiers)); lot[app] <- 1L
  charge <- numeric(n); charge[1L] <- sum(d[app])
  reste <- which(!app)
  for (i in reste[order(-d[reste], basename(fichiers[reste]), method = "radix")]) {
    k <- which.min(charge); lot[i] <- k; charge[k] <- charge[k] + d[i]
  }
  list(lot = lot, charge = charge, application = fichiers[app])
}

if (!is.null(LOT)) {
  .rep <- repartir_lots(FICHIERS_UNITAIRES, LOT[["n"]])
  .choisis <- FICHIERS_UNITAIRES[.rep$lot == LOT[["k"]]]
  cat(sprintf("Lot %d/%d : %d fichiers sur %d, duree estimee %.0f s (lots : %s s ; %d fichier(s) hors de %s, a %d s).\n",
              LOT[["k"]], LOT[["n"]], length(.choisis), length(FICHIERS_UNITAIRES), .rep$charge[LOT[["k"]]],
              paste(round(.rep$charge), collapse = " / "),
              sum(is.na(DUREES_UNITAIRES[basename(FICHIERS_UNITAIRES)])), basename(FICHIER_DUREES), DUREE_DEFAUT_S))
  cat(sprintf("Fichiers exigeant shiny ou plotly (groupe du lot 1) : %s\n",
              paste(basename(.rep$application), collapse = ", ")))
  if (!length(.choisis)) {
    cat("Lot vide : moins de fichiers que de lots.\n")
    quit(status = 1)
  }
  FICHIERS_UNITAIRES <- .choisis
}

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
  # Les plus longs d'abord (table des durees mesurees, DUREE_DEFAUT_S hors
  # table ; issue #512, A5) : un fichier long lance en dernier prolongerait la
  # fin du lot.
  attente <- fichiers[order(-duree_estimee(fichiers), fichiers, method = "radix")]
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
  if (!is.null(LOT)) cat(sprintf("\nBilan du lot %d/%d (%d fichiers) :", LOT[["k"]], LOT[["n"]], nrow(d)))
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
  if (!is.null(LOT)) cat(sprintf("\nBilan du lot %d/%d (%d fichiers) :", LOT[["k"]], LOT[["n"]], length(FICHIERS_UNITAIRES)))
  terminer()
}
