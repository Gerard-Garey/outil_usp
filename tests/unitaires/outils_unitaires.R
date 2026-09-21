###############################################################################
#  tests/unitaires/outils_unitaires.R  --  MINI-CADRE DE TESTS UNITAIRES
#
#  R base uniquement (le moteur et la CI n'ont aucune dependance). Fournit :
#    verifier(nom, expr)                  : assertion ; expr doit valoir TRUE
#    echec_attendu(nom, constat, expr)    : defaut CONNU du moteur. expr decrit
#                                           le comportement CORRECT ; elle doit
#                                           echouer tant que le defaut existe.
#                                           Si elle passe, le test est compte en
#                                           echec ("succes inattendu") afin que
#                                           le test soit revu avec la correction.
#    proche(a, b, rel, abs)               : egalite numerique a tolerance pres
#    leve_erreur(expr)                    : TRUE si expr leve une erreur
#    debut_fichier(nom) / bilan_fichier() : regroupement et decompte par fichier
#
#  Charge aussi le moteur R/engine.R, par chemin relatif a la racine du depot
#  (les scripts se lancent depuis la racine ou depuis tests/).
###############################################################################

if (!exists("ENGINE_CHARGE", inherits = TRUE)) {
  RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
            if (file.exists("../../R/engine.R")) "../.." else
            stop("R/engine.R introuvable : lancer depuis la racine du depot.")
  source(file.path(RACINE, "R", "engine.R"))
  ENGINE_CHARGE <- TRUE
}

.tu <- new.env(parent = emptyenv())
.tu$lignes <- data.frame(fichier = character(0), nom = character(0),
                         statut = character(0), message = character(0),
                         stringsAsFactors = FALSE)
.tu$fichier <- "?"

debut_fichier <- function(nom) {
  .tu$fichier <- nom
  .tu$t0 <- Sys.time()
  cat(sprintf("\n== %s\n", nom))
}

.enregistrer <- function(nom, statut, message = "") {
  .tu$lignes[nrow(.tu$lignes) + 1, ] <- list(.tu$fichier, nom, statut, message)
  marque <- switch(statut, OK = "ok  ", ECHEC = "ECHEC", ATTENDU = "xfail",
                   INATTENDU = "XPASS")
  if (statut != "OK" || isTRUE(getOption("tu.verbeux")))
    cat(sprintf("  [%s] %s%s\n", marque, nom,
                if (nzchar(message)) paste0("\n          -> ", message) else ""))
}

# Evalue expr dans l'environnement appelant ; renvoie list(ok, message).
# Les avertissements sont neutralises sans reevaluation : seuls comptent la
# valeur renvoyee et les erreurs.
.evaluer <- function(expr_sub, env) {
  r <- tryCatch(withCallingHandlers(eval(expr_sub, env),
                                    warning = function(w) invokeRestart("muffleWarning")),
                error = function(e) e)
  if (inherits(r, "error")) return(list(ok = FALSE, message = paste("erreur :", conditionMessage(r))))
  if (isTRUE(r)) return(list(ok = TRUE, message = ""))
  list(ok = FALSE, message = if (is.character(r)) paste(r, collapse = " ; ")
                             else paste("valeur obtenue :", paste(format(r), collapse = " ")))
}

verifier <- function(nom, expr) {
  r <- .evaluer(substitute(expr), parent.frame())
  .enregistrer(nom, if (r$ok) "OK" else "ECHEC", r$message)
  invisible(r$ok)
}

echec_attendu <- function(nom, constat, expr) {
  r <- .evaluer(substitute(expr), parent.frame())
  if (r$ok) .enregistrer(nom, "INATTENDU",
                         paste("le defaut semble corrige (", constat,
                               ") : transformer ce test en test ordinaire"))
  else .enregistrer(paste0(nom, "  {", constat, "}"), "ATTENDU", "")
  invisible(!r$ok)
}

# Egalite numerique elementwise : |a - b| <= abs + rel * |b|. Renvoie TRUE ou
# un message decrivant le plus grand ecart (affiche en cas d'echec).
proche <- function(a, b, rel = 1e-10, abs = 0) {
  a <- unname(as.numeric(a)); b <- unname(as.numeric(b))
  if (length(a) != length(b)) return(sprintf("longueurs %d et %d", length(a), length(b)))
  if (any(is.na(a) != is.na(b))) return("NA a des positions differentes")
  k <- !is.na(a)
  e <- abs(a[k] - b[k]); lim <- abs + rel * abs(b[k])
  if (all(e <= lim)) return(TRUE)
  i <- which.max(e - lim)
  sprintf("ecart max %.3g (obtenu %.12g, attendu %.12g, tolerance %.3g)",
          e[i], a[k][i], b[k][i], lim[i])
}

leve_erreur <- function(expr) inherits(tryCatch(expr, error = function(e) e), "error")

bilan_fichier <- function() {
  d <- .tu$lignes[.tu$lignes$fichier == .tu$fichier, ]
  cat(sprintf("   %d assertions : %d ok, %d echec(s), %d echec(s) attendu(s), %d succes inattendu(s)  (%.1f s)\n",
              nrow(d), sum(d$statut == "OK"), sum(d$statut == "ECHEC"),
              sum(d$statut == "ATTENDU"), sum(d$statut == "INATTENDU"),
              as.numeric(difftime(Sys.time(), .tu$t0, units = "secs"))))
}

# Code de sortie : 1 si au moins un echec ou un succes inattendu.
terminer <- function() {
  d <- .tu$lignes
  n_ko <- sum(d$statut %in% c("ECHEC", "INATTENDU"))
  cat(sprintf("\nTOTAL : %d assertions, %d ok, %d echec(s), %d echec(s) attendu(s) (defauts connus), %d succes inattendu(s)\n",
              nrow(d), sum(d$statut == "OK"), sum(d$statut == "ECHEC"),
              sum(d$statut == "ATTENDU"), sum(d$statut == "INATTENDU")))
  if (n_ko) {
    cat("\nECHEC\n")
    quit(status = 1)
  }
  cat("OK\n")
  invisible(TRUE)
}

# Lancement autonome d'un fichier de test : Rscript tests/unitaires/test_x.R
# (le lanceur tests/test_unitaires.R definit LANCEUR_UNITAIRES et appelle
# terminer() lui-meme).
fin_fichier <- function() {
  bilan_fichier()
  if (!exists("LANCEUR_UNITAIRES", inherits = TRUE)) terminer()
}
