# Creneau A2, etape W (issue #608) : mesure, sous Windows, du cas d'un chemin a
# barre initiale unique ("\d\f.xlsx", "/d/f.xlsx") dont le dossier est absent du
# lecteur de l'appelant mais present sur celui de tempdir().
# Specification : docs/revues/20261123-a2-creneau/audit-lecture-608.md, par. 3
# (cas de la ligne 4 du tableau du par. 2).
# Lecture et constat seulement : aucun fichier du depot n'est modifie. Les seules
# ecritures sont dans racine_virt (lecteur virtuel subst) et dans cible_t (dossier
# a la racine du lecteur de tempdir()) ; tout est supprime en sortie, et la
# suppression est verifiee et imprimee.
# Hors Windows : "sans objet", sortie 0.
# Usage (PowerShell, a la racine du depot) :
#   Rscript docs/revues/20261123-a2-creneau/mesure_608.R .
args <- commandArgs(TRUE)
if (!length(args)) stop("usage : Rscript mesure_608.R <racine du depot>")
racine <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
MAIN_A2 <- "8d7bf2f"   # main du creneau A2 : R/engine.R doit y etre identique
source(file.path(racine, "R/charger_moteur.R"))
charger_moteur(file.path(racine, "R/engine.R"))   # copie les liaisons (.xlsx_chemin_sortie compris) ici

## ---------------------------------------------------------------- aides
git <- function(...) tryCatch(system2("git", c("-C", racine, ...), stdout = TRUE, stderr = TRUE),
                              error = function(e) paste("git indisponible :", conditionMessage(e)))
titre <- function(x) cat("\n==== ", x, " ====\n", sep = "")
asc <- function(x) iconv(as.character(x), "", "ASCII", sub = "?")   # sorties en ASCII
decrire <- function(r) {
  if (inherits(r, "error"))
    sprintf("erreur [classe %s] : %s", paste(class(r), collapse = "/"), asc(conditionMessage(r)))
  else paste("rendu", asc(paste(deparse(r), collapse = " ")))
}
# Lettre de lecteur en tete d'une cible ? (NA si la sonde a echoue)
a_lecteur <- function(cible) if (is.na(cible)) NA else grepl("^[A-Za-z]:", cible)

## Regle de lecture (Q-73-2 (a)), par. 3 du rapport d'audit. Entrees, vecteurs
## logiques (NA = mesure non faite ou en echec : jamais lue comme FALSE) :
##   a_sans_lecteur : (a) la cible n'a pas de lettre de lecteur (4 sondes : 2 chemins x cible_t absent/cree)
##   a_attendu      : (a) la cible est L:/<nom>/f.xlsx (memes 4 sondes)
##   b_refus        : (b) l'appel rend un refus usp_refus_ecriture (2 chemins)
##   b_apparu       : (b) un fichier f.xlsx est apparu dans cible_t (2 chemins)
##   c_altere       : (c) le temoin de cible_t est efface ou son md5 a change (2 chemins)
## Une erreur n'est PAS un constat : un refus est le comportement non reproduit
## (ne pas reprendre la lecture de S5, "une erreur confirme le constat").
lire_608 <- function(a_sans_lecteur, a_attendu, b_refus, b_apparu, c_altere) {
  vrai <- function(x) any(x %in% TRUE)
  tout_faux <- function(x) length(x) > 0L && all(x %in% FALSE)
  tout_vrai <- function(x) length(x) > 0L && all(x %in% TRUE)
  motifs <- character(0)
  if (vrai(a_sans_lecteur)) motifs <- c(motifs, "(a) une cible sans lettre de lecteur")
  if (vrai(b_apparu)) motifs <- c(motifs, "(b) un fichier est apparu dans cible_t")
  if (vrai(c_altere)) motifs <- c(motifs, "(c) le temoin de cible_t est efface ou modifie")
  if (length(motifs))
    return(list(verdict = "REPRODUIT", detail = motifs))
  manques <- character(0)
  if (!tout_vrai(a_attendu)) manques <- c(manques, "(a) pas L:/<nom>/f.xlsx pour les deux chemins (ou sonde non faite)")
  if (!tout_vrai(b_refus)) manques <- c(manques, "(b) pas un refus usp_refus_ecriture pour les deux chemins (ou mesure non faite)")
  if (!tout_faux(b_apparu)) manques <- c(manques, "(b) presence d'un fichier dans cible_t non constatee comme absente")
  if (!tout_faux(c_altere)) manques <- c(manques, "(c) integrite du temoin non constatee")
  if (!length(manques))
    return(list(verdict = "NON REPRODUIT",
                detail = "(a) L:/<nom>/f.xlsx deux fois, (b) refus deux fois sans fichier, (c) temoin intact"))
  list(verdict = "INDETERMINE", detail = manques)
}

## Sonde (a), sans ecriture : ce que le moteur calcule pour un chemin donne
sonde <- function(chemin, nom, L) {
  np_dossier <- tryCatch(normalizePath(dirname(chemin), winslash = "/", mustWork = FALSE),
                         error = function(e) NA_character_)
  np_nom <- tryCatch(normalizePath(paste0("/", nom), winslash = "/", mustWork = FALSE),
                     error = function(e) NA_character_)
  cible <- tryCatch(.xlsx_chemin_sortie(chemin, getwd()), error = function(e) NA_character_)
  attendu <- paste0(L, ":/", nom, "/f.xlsx")
  cat(sprintf("  chemin %s\n    normalizePath(dirname(chemin)) : %s\n    normalizePath(\"/%s\")      : %s\n    .xlsx_chemin_sortie(chemin, getwd()) : %s\n    lettre de lecteur : %s | egale a %s : %s\n",
              deparse(chemin), asc(np_dossier), nom, asc(np_nom), asc(cible), a_lecteur(cible), attendu,
              if (is.na(cible)) NA else identical(tolower(cible), tolower(attendu))))
  list(sans_lecteur = if (is.na(cible)) NA else !grepl("^[A-Za-z]:", cible),
       attendu = if (is.na(cible)) NA else identical(tolower(cible), tolower(attendu)))
}

## ------------------------------------------------------- mesure proprement dite
## ctx : L (lettre), racine_l ("L:/"), cible_t, nom, chemins (2), donnees (data.frame)
## etat : environnement qui porte le drapeau cree_cible_t (lu par le on.exit de l'appelant)
mesurer <- function(ctx, etat) {
  L <- ctx$L; nom <- ctx$nom; cible_t <- ctx$cible_t; chemins <- ctx$chemins; d <- ctx$donnees
  f_t <- file.path(cible_t, "f.xlsx")
  f_l <- file.path(ctx$racine_l, nom, "f.xlsx")
  poser_cible <- function() {
    ok <- suppressWarnings(dir.create(cible_t))
    if (isTRUE(ok) && dir.exists(cible_t)) { etat$cree_cible_t <- TRUE; TRUE } else FALSE
  }
  retirer_cible <- function() {
    unlink(cible_t, recursive = TRUE)
    if (!dir.exists(cible_t)) etat$cree_cible_t <- FALSE
    !dir.exists(cible_t)
  }
  appel <- function(chemin) tryCatch(engine_ecrire_xlsx(d, chemin), error = function(e) e)
  nc <- length(chemins)
  m <- list(a_sans_lecteur = rep(NA, 2L * nc), a_attendu = rep(NA, 2L * nc),
            b_refus = rep(NA, nc), b_apparu = rep(NA, nc), c_altere = rep(NA, nc), d_conforme = rep(NA, nc))

  setwd(ctx$racine_l)
  cat("getwd() apres setwd :", getwd(), "| L:/<nom> n'est PAS cree :", !dir.exists(file.path(ctx$racine_l, nom)), "\n")

  titre("(a) sonde pure, sans ecriture")
  k <- 0L
  for (etape in c("absent", "cree")) {
    if (etape == "cree") {
      if (!poser_cible()) { cat("creation de", cible_t, "impossible : sonde 'cree' et mesures (b), (c) non faites\n"); break }
    }
    cat(sprintf("- cible_t %s (%s)\n", etape, cible_t))
    for (i in seq_len(nc)) {
      s <- sonde(chemins[i], nom, L)
      k <- (if (etape == "absent") 0L else nc) + i
      m$a_sans_lecteur[k] <- s$sans_lecteur; m$a_attendu[k] <- s$attendu
    }
  }

  if (isTRUE(etat$cree_cible_t)) {
    titre("(b) ecriture, cible_t cree et vide")
    for (i in seq_len(nc)) {
      unlink(f_t)
      r <- appel(chemins[i])
      m$b_refus[i] <- inherits(r, "usp_refus_ecriture")
      m$b_apparu[i] <- file.exists(f_t)
      cat(sprintf("  chemin %s : %s\n    fichier en %s : %s | fichier en %s : %s\n", deparse(chemins[i]), decrire(r),
                  f_l, file.exists(f_l), f_t, m$b_apparu[i]))
      unlink(f_t)
    }

    titre("(c) temoin d'effacement : f.xlsx de contenu connu dans cible_t avant l'appel")
    contenu <- charToRaw("TEMOIN usp608 : contenu connu, ne doit pas etre touche\n")
    for (i in seq_len(nc)) {
      writeBin(contenu, f_t)
      md5_avant <- unname(tools::md5sum(f_t))
      r <- appel(chemins[i])
      existe <- file.exists(f_t)
      md5_apres <- if (existe) unname(tools::md5sum(f_t)) else NA_character_
      m$c_altere[i] <- !existe || !identical(md5_apres, md5_avant)
      cat(sprintf("  chemin %s : %s\n    temoin existe encore : %s | md5 avant %s | md5 apres %s | md5 change : %s\n",
                  deparse(chemins[i]), decrire(r), existe, md5_avant, md5_apres,
                  if (existe) !identical(md5_apres, md5_avant) else NA))
      unlink(f_t)
    }
    if (!retirer_cible()) cat("ATTENTION : cible_t n'a pas pu etre retire entre (c) et (d)\n")
  }

  titre("(d) temoin negatif : cible_t absent, refus attendu")
  if (dir.exists(cible_t)) {
    cat("cible_t existe : temoin negatif non fait\n")
  } else {
    for (i in seq_len(nc)) {
      r <- appel(chemins[i])
      m$d_conforme[i] <- inherits(r, "usp_refus_ecriture") && !file.exists(f_t) && !dir.exists(cible_t)
      cat(sprintf("  chemin %s : %s | fichier en %s : %s | cible_t cree par l'appel : %s\n", deparse(chemins[i]),
                  decrire(r), f_t, file.exists(f_t), dir.exists(cible_t)))
    }
  }
  m
}

## ------------------------------------------------------------------ contexte
titre("Contexte")
cat("HEAD :", git("rev-parse", "HEAD"), "\n")
diff_moteur <- git("diff", "--stat", MAIN_A2, "HEAD", "--", "R/engine.R")
cat(sprintf("git diff --stat %s HEAD -- R/engine.R vide : %s\n", MAIN_A2, !length(diff_moteur)))
if (length(diff_moteur)) cat(asc(diff_moteur), sep = "\n")
cat("md5 de R/engine.R :", unname(tools::md5sum(file.path(racine, "R/engine.R"))), "\n")
cat(R.version.string, "|", .Platform$OS.type, "| LC_CTYPE =", Sys.getlocale("LC_CTYPE"), "\n")
cat("getwd() :", getwd(), "| tempdir() :", tempdir(), "\n")
paquet_zip <- requireNamespace("zip", quietly = TRUE)
commande_zip <- Sys.which(Sys.getenv("R_ZIPCMD", "zip"))
cat("paquet zip :", if (paquet_zip) as.character(utils::packageVersion("zip")) else "non installe",
    "| commande zip :", if (nzchar(commande_zip)) commande_zip else "absente", "\n")
cat("voie prise par engine_ecrire_xlsx() :",
    if (paquet_zip) "zip::zipr, puis repli utils::zip si echec" else
      if (nzchar(commande_zip)) "utils::zip (commande zip)" else "aucune (refus avant toute ecriture)", "\n")

if (.Platform$OS.type != "windows") {
  cat("\nsans objet hors de Windows : cette mesure porte sur le repli de normalizePath() et les lecteurs Windows.\n")
  cat("Fin de la mesure (aucune ecriture).\n")
} else {
  etat <- new.env()
  etat$L <- NA_character_; etat$cible_t <- NA_character_; etat$racine_virt <- NA_character_
  etat$subst_pose <- FALSE; etat$cree_cible_t <- FALSE; etat$preexistant <- FALSE
  etat$motif <- NA_character_; etat$m <- NULL

  mesure_windows <- function() {
    ancien <- getwd()
    nom <- basename(tempfile("usp608_a2_"))
    if (!grepl("^[A-Za-z]:", tempdir())) { etat$motif <- "tempdir() n'a pas de lettre de lecteur"; return(invisible()) }
    cible_t <- file.path(substr(tempdir(), 1, 2), nom)
    etat$cible_t <- cible_t
    if (dir.exists(cible_t) || file.exists(cible_t)) {
      etat$preexistant <- TRUE
      etat$motif <- sprintf("%s existe deja : mesure abandonnee pour ne rien ecraser", cible_t)
      return(invisible())
    }
    pris <- toupper(substr(system2("cmd", c("/c", "subst"), stdout = TRUE), 1, 1))
    libres <- setdiff(rev(LETTERS[16:26]), c(pris, toupper(substr(c(getwd(), tempdir()), 1, 1))))
    libres <- libres[!dir.exists(paste0(libres, ":/"))]
    if (!length(libres)) { etat$motif <- "aucune lettre libre de P a Z"; return(invisible()) }
    L <- libres[1]; racine_virt <- tempfile("p608_")
    etat$L <- L; etat$racine_virt <- racine_virt
    # Nettoyage enregistre AVANT le subst, dans cet ordre ; drapeaux poses apres succes seulement
    on.exit({
      try(setwd(ancien), silent = TRUE)
      if (isTRUE(etat$subst_pose)) try(system2("subst", c(paste0(L, ":"), "/D"), stdout = TRUE, stderr = TRUE), silent = TRUE)
      unlink(racine_virt, recursive = TRUE)
      if (isTRUE(etat$cree_cible_t)) unlink(cible_t, recursive = TRUE)
    }, add = TRUE)
    dir.create(racine_virt)
    if (!dir.exists(racine_virt)) { etat$motif <- "creation de racine_virt impossible"; return(invisible()) }
    s <- system2("subst", c(paste0(L, ":"), shQuote(normalizePath(racine_virt, winslash = "\\"))),
                 stdout = TRUE, stderr = TRUE)
    if (is.null(attr(s, "status")) || identical(attr(s, "status"), 0L)) etat$subst_pose <- TRUE
    if (!dir.exists(paste0(L, ":/"))) { etat$motif <- paste("subst a echoue :", asc(paste(s, collapse = " "))); return(invisible()) }
    cat("\nlecteur virtuel", paste0(L, ":"), "->", racine_virt, "| lecteur de tempdir() :", substr(tempdir(), 1, 2),
        "| cible_t :", cible_t, "\n")
    donnees <- file.path(racine, "tests/donnees/donnees_ln.csv")
    if (!file.exists(donnees)) { etat$motif <- paste("introuvable :", donnees); return(invisible()) }
    d <- utils::read.csv(donnees)
    ctx <- list(L = L, racine_l = paste0(L, ":/"), cible_t = cible_t, nom = nom, donnees = d,
                chemins = c(paste0("\\", nom, "\\f.xlsx"), paste0("/", nom, "/f.xlsx")))
    etat$m <- mesurer(ctx, etat)
    invisible()
  }
  res <- tryCatch({ mesure_windows(); NULL }, error = function(e) e)
  if (inherits(res, "error")) etat$motif <- paste("erreur pendant la mesure :", asc(conditionMessage(res)))

  titre("Lecture (regle Q-73-2 (a))")
  if (is.null(etat$m)) {
    cat("INDETERMINE (mesure non faite :", etat$motif, ")\n")
  } else {
    m <- etat$m
    lect <- lire_608(m$a_sans_lecteur, m$a_attendu, m$b_refus, m$b_apparu, m$c_altere)
    cat(lect$verdict, "\n")
    cat(paste0("  - ", lect$detail), sep = "\n")
    if (!is.na(etat$motif)) cat("  note :", etat$motif, "\n")
    if (!all(m$d_conforme %in% TRUE))
      cat("ATTENTION : temoin negatif (d) non conforme ou non fait (d_conforme :", deparse(unname(m$d_conforme)),
          ") : lecture a confirmer\n")
    cat("Rappel : un refus usp_refus_ecriture ou une erreur n'est PAS le constat de #608 ;\n",
        "         le constat est un fichier ecrit ou un temoin touche sur le lecteur de tempdir().\n", sep = "")
  }

  titre("Verification finale du nettoyage")
  if (!is.na(etat$L)) cat(if (!dir.exists(paste0(etat$L, ":/"))) "[OK]    " else "[ECHEC] ",
                          sprintf("le lecteur %s: n'existe plus\n", etat$L), sep = "")
  else cat("aucun lecteur virtuel pose\n")
  if (etat$preexistant) cat("cible_t preexistant, non touche :", etat$cible_t, "\n")
  else if (!is.na(etat$cible_t)) cat(if (!dir.exists(etat$cible_t) && !file.exists(etat$cible_t)) "[OK]    " else "[ECHEC] ",
                                     sprintf("%s n'existe plus\n", etat$cible_t), sep = "")
  if (!is.na(etat$racine_virt)) cat(if (!dir.exists(etat$racine_virt)) "[OK]    " else "[ECHEC] ",
                                    sprintf("%s n'existe plus\n", etat$racine_virt), sep = "")
  cat("\nFin de la mesure.\n")
}
