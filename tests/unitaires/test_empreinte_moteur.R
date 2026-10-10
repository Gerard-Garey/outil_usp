###############################################################################
#  tests/unitaires/test_empreinte_moteur.R  --  EMPREINTE DE R/engine.R SANS
#                         COMMENTAIRES (#231)
#
#  empreinte_sans_commentaires() (tests/outils_tests.R) : md5 d'un codage
#  canonique de l'arbre syntaxique de parse(keep.source = FALSE), lu par le
#  controle (i3) de tests/conservatisme_interieur_t8.R. Proprietes testees,
#  sur des copies temporaires de R/engine.R (le moteur du depot n'est jamais
#  modifie) et sur de petits sources ecrits ici :
#    - inchangee : commentaire modifie, ajoute ou retire, commentaire de fin
#      de ligne, ligne vide ajoutee, toutes les lignes de commentaire et
#      lignes vides retirees, indentation, fins de ligne CRLF ;
#    - changee : constante (entiere, decimale, au dernier bit d'un double,
#      1L contre 1), corps de fonction, nom d'une fonction, nom d'un
#      argument, argument par defaut, ordre de deux expressions, chaine ;
#    - chaines non ASCII : e accent aigu ecrit par echappement (\u00e9) ou
#      en octets UTF-8 (c3 a9) donne
#      la meme empreinte, sous la locale courante et sous LC_CTYPE = "C" ;
#    - erreur si le fichier ne s'analyse pas.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_empreinte_moteur.R")

.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = outils_env)
empreinte <- outils_env$empreinte_sans_commentaires
MOTEUR <- file.path(outils_env$RACINE, "R", "engine.R")

# Lignes du moteur (octets UTF-8 conserves) et copie temporaire modifiee.
LIGNES <- readLines(MOTEUR, warn = FALSE, encoding = "UTF-8")
copie <- function(lignes, crlf = FALSE) {
  f <- tempfile("engine_", fileext = ".R")
  txt <- paste0(paste(enc2utf8(lignes), collapse = if (crlf) "\r\n" else "\n"), if (crlf) "\r\n" else "\n")
  writeBin(charToRaw(txt), f)
  f
}
# Remplace un motif qui doit figurer sur une seule ligne du moteur (sinon
# erreur : une modification qui ne s'applique pas rendrait le test vide).
modifier <- function(motif, remplacement) {
  i <- grep(motif, LIGNES, fixed = TRUE)
  if (length(i) != 1L) stop(sprintf("motif %s : %d ligne(s) au lieu d'une", motif, length(i)))
  l <- LIGNES
  l[i] <- sub(motif, remplacement, l[i], fixed = TRUE)
  copie(l)
}
inserer <- function(apres_motif, ajout) {
  i <- grep(apres_motif, LIGNES, fixed = TRUE)
  if (length(i) != 1L) stop(sprintf("motif %s : %d ligne(s) au lieu d'une", apres_motif, length(i)))
  copie(append(LIGNES, ajout, after = i))
}
source_texte <- function(...) {
  f <- tempfile("src_", fileext = ".R")
  writeBin(charToRaw(enc2utf8(paste0(paste(c(...), collapse = "\n"), "\n"))), f)
  f
}

E0 <- empreinte(MOTEUR)

verifier("empreinte du moteur : 32 caracteres hexadecimaux, egale sur une copie a l'identique",
         grepl("^[0-9a-f]{32}$", E0) && identical(empreinte(copie(LIGNES)), E0))

# --- Inchangee : commentaires, lignes vides, mise en page ---------------------
verifier("commentaire modifie (ligne 4, accents retires) : empreinte inchangee (md5 du fichier change)", {
  f <- modifier("#  Param\u00e8tres propres \u00e0 l'entreprise (USP) - Solvabilit\u00e9 II",
                "#  Parametres propres a l'entreprise -- commentaire modifie")
  identical(empreinte(f), E0) && !identical(unname(tools::md5sum(f)), unname(tools::md5sum(MOTEUR)))
})
verifier("ligne de commentaire ajoutee, commentaire de fin de ligne ajoute : empreinte inchangee", {
  f1 <- inserer("B_MIN_USAGE <- 99", "# commentaire ajoute pour le test")
  f2 <- modifier("B_MIN_USAGE <- 99", "B_MIN_USAGE <- 99  # commentaire de fin de ligne")
  identical(empreinte(f1), E0) && identical(empreinte(f2), E0)
})
verifier("ligne vide ajoutee : empreinte inchangee", identical(empreinte(inserer("B_MIN_USAGE <- 99", "")), E0))
verifier("toutes les lignes de commentaire et lignes vides retirees : empreinte inchangee", {
  garde <- !grepl("^[[:space:]]*(#.*)?$", LIGNES)
  sum(!garde) > 1000 && identical(empreinte(copie(LIGNES[garde])), E0)
})
verifier("indentation modifiee (deux espaces en tete de chaque ligne non vide) et fins de ligne CRLF : empreinte inchangee", {
  l <- ifelse(nzchar(LIGNES), paste0("  ", LIGNES), LIGNES)
  # une ligne de suite d'une chaine multiligne changerait la chaine : aucune
  # dans le moteur, ou le test le signale par un echec
  identical(empreinte(copie(l)), E0) && identical(empreinte(copie(LIGNES, crlf = TRUE)), E0)
})

# --- Changee : code ------------------------------------------------------------
verifier("constante modifiee (B_MIN_USAGE 99 -> 100, TOL_DELTA_BORD 1e-6 -> 2e-6) : empreinte changee", {
  !identical(empreinte(modifier("B_MIN_USAGE <- 99", "B_MIN_USAGE <- 100")), E0) &&
    !identical(empreinte(modifier("TOL_DELTA_BORD <- 1e-6", "TOL_DELTA_BORD <- 2e-6")), E0)
})
verifier("corps de fonction modifie (engine_sous_graine()) : empreinte changee",
         !identical(empreinte(modifier("  genv <- globalenv()", "  genv <- globalenv(); genv <- genv")), E0))
verifier("argument par defaut modifie (usp_bootstrap(), B = 999 -> 998) : empreinte changee",
         !identical(empreinte(modifier("usp_bootstrap <- function(fit, B = 999,", "usp_bootstrap <- function(fit, B = 998,")), E0))
verifier("nom de fonction modifie (engine_sous_graine -> engine_sous_graine2) : empreinte changee",
         !identical(empreinte(modifier("engine_sous_graine <- function(seed, expr) {",
                                       "engine_sous_graine2 <- function(seed, expr) {")), E0))
verifier("nom d'argument modifie (engine_sous_graine(seed, expr) -> (graine, expr)) : empreinte changee",
         !identical(empreinte(modifier("engine_sous_graine <- function(seed, expr) {",
                                       "engine_sous_graine <- function(graine, expr) {")), E0))

# --- Petits sources : cas limites du codage -------------------------------------
verifier("double au dernier bit (1 contre 1 + 2^-52), 1L contre 1, TRUE contre T : empreintes distinctes", {
  e <- c(empreinte(source_texte("x <- 1")), empreinte(source_texte("x <- 1.0000000000000002")),
         empreinte(source_texte("x <- 1L")), empreinte(source_texte("y <- TRUE")), empreinte(source_texte("y <- T")))
  1.0000000000000002 != 1 && length(unique(e)) == 5L
})
verifier("ecritures equivalentes pour l'analyseur (1e-6 et 0.000001) : empreinte egale",
         identical(empreinte(source_texte("x <- 1e-6")), empreinte(source_texte("x <- 0.000001"))))
verifier("ordre de deux expressions inverse, x <- 1 contre x = 1 : empreintes changees", {
  a <- empreinte(source_texte("a <- 1", "b <- 2"))
  !identical(a, empreinte(source_texte("b <- 2", "a <- 1"))) &&
    !identical(empreinte(source_texte("x <- 1")), empreinte(source_texte("x = 1")))
})
verifier("saut de ligne qui separe deux expressions (x <- 1 / -2 contre x <- 1 -2) : empreintes distinctes",
         !identical(empreinte(source_texte("x <- 1", "-2")), empreinte(source_texte("x <- 1 -2"))))
verifier("argument vide (x[, 1] contre x[1]) et argument nomme (f(a = 1) contre f(1)) : empreintes distinctes", {
  !identical(empreinte(source_texte("y <- x[, 1]")), empreinte(source_texte("y <- x[1]"))) &&
    !identical(empreinte(source_texte("f(a = 1)")), empreinte(source_texte("f(1)")))
})
verifier("chaines : NA_character_ contre \"NA\", chaine vide, chaine longue (2000 caracteres) modifiee au dernier : distinctes", {
  long <- strrep("a", 2000)
  e <- c(empreinte(source_texte("s <- NA_character_")), empreinte(source_texte("s <- \"NA\"")),
         empreinte(source_texte("s <- \"\"")),
         empreinte(source_texte(sprintf("s <- \"%s\"", long))),
         empreinte(source_texte(sprintf("s <- \"%sb\"", substr(long, 1, 1999)))))
  length(unique(e)) == 5L
})

# Chaines non ASCII : echappement \u00e9 et caractere UTF-8 ecrit en octets
# (c3 a9). Les octets sont ecrits directement : sous LC_ALL=C, un litteral
# "\u00e9" de ce fichier n'est pas marque UTF-8 (Encoding() "unknown",
# octets c3 a9) et enc2utf8() de source_texte() le traduit en texte
# "<c3><a9>" (mesure sous R 4.3.3) : le source ecrit ne serait plus le bon.
ecrire_octets <- function(...) {
  f <- tempfile("src_", fileext = ".R")
  writeBin(unlist(lapply(list(...), function(p) if (is.raw(p)) p else charToRaw(p))), f)
  f
}
E_AIGU <- as.raw(c(0xc3, 0xa9))
SRC_ECHAP <- ecrire_octets("msg <- \"\\u00e9t\\u00e9 d\\u00e9clar\\u00e9\"  # commentaire\n")
SRC_UTF8  <- ecrire_octets("msg <- \"", E_AIGU, "t", E_AIGU, " d", E_AIGU, "clar", E_AIGU, "\"\n")
verifier("chaine non ASCII : echappement \\u00e9 et caractere UTF-8 donnent la meme empreinte ; e sans accent la change", {
  identical(empreinte(SRC_ECHAP), empreinte(SRC_UTF8)) &&
    !identical(empreinte(SRC_UTF8), empreinte(source_texte("msg <- \"ete declare\"")))
})
verifier("locale : empreintes du moteur et des chaines non ASCII egales sous LC_CTYPE = \"C\"", {
  avant <- Sys.getlocale("LC_CTYPE")
  ref <- c(E0, empreinte(SRC_ECHAP), empreinte(SRC_UTF8))
  pose <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C"))
  sous_c <- tryCatch(c(empreinte(MOTEUR), empreinte(SRC_ECHAP), empreinte(SRC_UTF8)),
                     finally = suppressWarnings(Sys.setlocale("LC_CTYPE", avant)))
  nzchar(pose) && identical(sous_c, ref) && identical(Sys.getlocale("LC_CTYPE"), avant)
})

verifier("source qui ne s'analyse pas : erreur",
         leve_erreur(empreinte(source_texte("f <- function(x {"))))

fin_fichier()
