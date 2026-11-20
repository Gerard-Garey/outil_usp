# Etape P de S5 (PR #609) : rejeu sous Windows, reliquat 10b d'A1.
# Points (ii), (iii), (v) et, sur option, (vi) de la fiche S5
# (docs/feuille-de-route.md, par. 3). Les points (i) et (iv) se lancent a part
# (README.md de ce dossier). Lecture et constat seulement : aucun fichier du
# depot n'est modifie ; les fichiers et dossiers temporaires crees sont
# supprimes.
# Usage (PowerShell, a la racine du depot) :
#   Rscript docs/revues/20261119-s5-rejeu-windows/rejeu_windows.R . [--mesure-608]
args <- commandArgs(TRUE)
if (!length(args)) stop("usage : Rscript rejeu_windows.R <racine du depot> [--mesure-608]")
depot <- normalizePath(args[1], winslash = "/")
mesure608 <- "--mesure-608" %in% args
source(file.path(depot, "R/charger_moteur.R")); charger_moteur(file.path(depot, "R/engine.R"))

git <- function(...) tryCatch(system2("git", c("-C", depot, ...), stdout = TRUE, stderr = TRUE),
                              error = function(e) paste("git indisponible :", conditionMessage(e)))
titre <- function(x) cat("\n==== ", x, " ====\n", sep = "")
verdict <- function(ok, texte) cat(if (isTRUE(ok)) "[OK]    " else "[ECHEC] ", texte, "\n", sep = "")

titre("Contexte")
cat("HEAD :", git("rev-parse", "HEAD"), "\n")
diff_code <- git("diff", "--stat", "e4a8ae4", "HEAD", "--", "R", "tests", "app.R")
cat("R/, tests/ et app.R identiques a e4a8ae4 :", !length(diff_code), "\n")
etat <- git("status", "--porcelain")
cat("arbre propre :", !length(etat), "\n"); if (length(etat)) cat(etat, sep = "\n")
cat(R.version.string, "|", .Platform$OS.type, "| LC_CTYPE =", Sys.getlocale("LC_CTYPE"), "\n")
cat("openxlsx :", if (requireNamespace("openxlsx", quietly = TRUE))
  as.character(utils::packageVersion("openxlsx")) else "non installe", "\n")
cat("getwd() :", getwd(), "| tempdir() :", tempdir(), "\n")
if (.Platform$OS.type != "windows")
  cat("ATTENTION : ce script est fait pour Windows ; sous un autre systeme, ses verdicts ne mesurent pas l'etape P.\n")

## (ii) #602 : saut de ligne ecrit puis relu, aucun octet 0x0D dans l'archive
titre("(ii) #602 : \"a\\nb\" ecrit par engine_ecrire_xlsx() puis relu")
local({
  f <- tempfile(fileext = ".xlsx"); rep <- tempfile("parties_")
  on.exit(unlink(c(f, rep), recursive = TRUE), add = TRUE)
  d <- data.frame(texte = c("a\nb", "c\td", "e"), stringsAsFactors = FALSE)
  r <- tryCatch({ engine_ecrire_xlsx(d, f); engine_lire_xlsx(f) }, error = function(e) e)
  if (inherits(r, "error")) { verdict(FALSE, paste("erreur :", conditionMessage(r))); return(invisible()) }
  verdict(identical(r[[1]], d[[1]]), sprintf("cellules relues identical() ; lu : %s", deparse(r[[1]])))
  utils::unzip(f, exdir = rep)
  parties <- list.files(rep, recursive = TRUE, full.names = TRUE)
  cr <- vapply(parties, function(p) any(readBin(p, "raw", file.size(p)) == as.raw(13L)), logical(1))
  names(cr) <- sub(paste0("^", rep, "/"), "", names(cr), fixed = FALSE)
  verdict(!any(cr), sprintf("aucun octet 0x0D dans les %d parties de l'archive%s", length(cr),
                            if (any(cr)) paste(" ; parties fautives :", paste(names(cr)[cr], collapse = ", ")) else ""))
})

## (iii) #603 : forme X: sans barre refusee, aucun fichier cree
titre("(iii) #603 : engine_ecrire_xlsx(df, \"C:f.xlsx\")")
local({
  ancien <- getwd(); dossier <- file.path(tempdir(), "p603")
  dir.create(dossier, showWarnings = FALSE); setwd(dossier)
  on.exit({ setwd(ancien); unlink(dossier, recursive = TRUE) }, add = TRUE)
  lieux <- unique(c(file.path(dossier, "f.xlsx"), "C:/f.xlsx", file.path(depot, "f.xlsx"), file.path(ancien, "f.xlsx")))
  avant <- file.exists(lieux)
  d <- utils::read.csv(file.path(depot, "tests/donnees/donnees_ln.csv"))
  r <- tryCatch(engine_ecrire_xlsx(d, "C:f.xlsx"), error = function(e) e)
  apres <- file.exists(lieux)
  verdict(inherits(r, "usp_refus_ecriture"),
          paste("refus motive :", if (inherits(r, "error")) conditionMessage(r) else paste("aucun refus, rendu", deparse(r))))
  verdict(identical(avant, apres), sprintf("aucun f.xlsx cree (lieux controles : %s)", paste(lieux, collapse = " ; ")))
  if (any(avant)) cat("NOTE : f.xlsx existait deja avant l'appel en :", paste(lieux[avant], collapse = " ; "), "\n")
})

## (v) Emploi 1 du temoin sous la version installee d'openxlsx (releve)
titre("(v) temoin openxlsx, corpus naturel : ecarts a la source (releve, sans effet sur la branche)")
if (!requireNamespace("openxlsx", quietly = TRUE)) {
  cat("openxlsx non installe : releve sans objet\n")
} else local({
  # Memes aides que tests/unitaires/test_controles_entree.R (section du temoin, ADR 0020)
  temoin <- function(f) openxlsx::read.xlsx(f, sheet = 1, colNames = TRUE, skipEmptyRows = FALSE,
                                            skipEmptyCols = FALSE, na.strings = character(0), sep.names = " ")
  lire_source <- function(n) utils::read.csv(file.path(depot, "tests", "donnees", n), colClasses = "character",
                                             check.names = FALSE, na.strings = character(0))
  tri <- lire_source("triangle_mw.csv"); tri_note <- tri; tri_note$note <- paste0("note", tri$i)
  sources <- list(series = engine_lire_donnees_csv(lire_source("donnees_ln.csv")),
                  triangle = engine_lire_triangle(tri), triangle_note = engine_lire_triangle(tri_note))
  nature <- function(n) if (grepl("triangle_note", basename(n))) "triangle_note" else
    if (grepl("triangle", basename(n))) "triangle" else "series"
  aval <- function(n, d) if (identical(nature(n), "series")) engine_lire_donnees_csv(d) else engine_lire_triangle(d)
  dossier <- file.path(depot, "tests", "donnees", "classeurs")
  corpus <- sort(list.files(dossier, pattern = "\\.xlsx$", recursive = TRUE))
  ecarts <- character(0)
  for (n in corpus) {
    o <- tryCatch(temoin(file.path(dossier, n)), error = function(e) e)
    if (!is.data.frame(o) || !identical(aval(n, o), sources[[nature(n)]])) ecarts <- c(ecarts, n)
  }
  ref <- c("blancs/ligne_finale_note_blanche.xlsx", "entete/openpyxl_entete_lu_blanc.xlsx")
  cat("version :", as.character(utils::packageVersion("openxlsx")), "| classeurs :", length(corpus), "\n")
  cat("ecarts mesures :", if (length(ecarts)) paste(ecarts, collapse = ", ") else "aucun", "\n")
  cat("egaux a la liste datee 4.2.5.2 :", identical(ecarts, ref), "\n")
  # Le lecteur interne, lui, doit rendre la source sur tout le corpus
  lus <- vapply(corpus, function(n) {
    o <- tryCatch(engine_lire_xlsx(file.path(dossier, n)), error = function(e) e)
    is.data.frame(o) && identical(aval(n, o), sources[[nature(n)]])
  }, logical(1))
  verdict(all(lus), sprintf("lecteur interne : %d classeurs sur %d rendent la source%s", sum(lus), length(lus),
                            if (!all(lus)) paste(" ; ecarts :", paste(corpus[!lus], collapse = ", ")) else ""))
})

## (vi) #608 : barre initiale unique, mesure par lecteur virtuel subst (sur option)
titre("(vi) #608 : chemin a barre initiale unique (releve, sans effet sur la branche)")
if (!mesure608) {
  cat("non demande (option --mesure-608 absente)\n")
} else if (.Platform$OS.type != "windows") {
  cat("sans objet hors de Windows\n")
} else local({
  pris <- toupper(substr(system2("cmd", c("/c", "subst"), stdout = TRUE), 1, 1))
  libres <- setdiff(rev(LETTERS[16:26]), c(pris, toupper(substr(c(getwd(), tempdir()), 1, 1))))
  libres <- libres[!dir.exists(paste0(libres, ":/"))]
  if (!length(libres)) { cat("aucune lettre libre de P a Z : mesure impossible\n"); return(invisible()) }
  L <- libres[1]; racine_virt <- tempfile("p608_"); dir.create(racine_virt)
  nom <- "usp608_s5"; cible_c <- file.path(substr(tempdir(), 1, 2), nom)
  if (dir.exists(cible_c)) { cat("le dossier", cible_c, "existe deja : mesure abandonnee pour ne rien ecraser\n"); return(invisible()) }
  s <- system2("subst", c(paste0(L, ":"), shQuote(normalizePath(racine_virt, winslash = "\\"))), stdout = TRUE, stderr = TRUE)
  ancien <- getwd()
  on.exit({
    setwd(ancien)
    system2("subst", c(paste0(L, ":"), "/D"), stdout = TRUE, stderr = TRUE)
    unlink(c(racine_virt, cible_c), recursive = TRUE)
  }, add = TRUE)
  if (!dir.exists(paste0(L, ":/"))) { cat("subst a echoue :", s, "\n"); return(invisible()) }
  dir.create(file.path(paste0(L, ":/"), nom)); setwd(paste0(L, ":/"))
  cat("lecteur virtuel", paste0(L, ":"), "->", racine_virt, "| getwd() :", getwd(), "| lecteur de tempdir() :", substr(tempdir(), 1, 2), "\n")
  d <- utils::read.csv(file.path(depot, "tests/donnees/donnees_ln.csv"))
  essai <- function(chemin, etiquette) {
    attendu <- file.path(paste0(L, ":/"), nom, "f.xlsx"); ailleurs <- file.path(cible_c, "f.xlsx")
    unlink(c(attendu, ailleurs))
    r <- tryCatch(engine_ecrire_xlsx(d, chemin), error = function(e) e)
    cat(sprintf("  %s, chemin %s : %s | fichier en %s : %s | fichier en %s : %s\n", etiquette, deparse(chemin),
                if (inherits(r, "error")) paste("erreur :", conditionMessage(r)) else paste("rendu", deparse(r)),
                attendu, file.exists(attendu), ailleurs, file.exists(ailleurs)))
  }
  for (chemin in c(paste0("\\", nom, "\\f.xlsx"), paste0("/", nom, "/f.xlsx"))) {
    essai(chemin, sprintf("sans dossier %s", cible_c))
    dir.create(cible_c); essai(chemin, sprintf("avec dossier %s", cible_c)); unlink(cible_c, recursive = TRUE)
  }
  cat("Lecture : fichier attendu sur", paste0(L, ":"), "(lecteur de l'appelant) ; un fichier sur",
      substr(tempdir(), 1, 2), "ou une erreur confirme le constat de #608.\n")
})
cat("\nFin du rejeu.\n")
