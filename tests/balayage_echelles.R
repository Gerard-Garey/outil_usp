###############################################################################
#  tests/balayage_echelles.R  --  INVARIANCE DE run_engine() PAR CHANGEMENT
#  D'ECHELLE COMMUN DE x ET y, SUR TOUTES LES PUISSANCES DE 10 DU DOMAINE
#  NUMERIQUE (issue #153)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Il n'ecrit aucun fichier : sortie en markdown sur la console (UTF-8).
#  R base + stats ; le comparateur est comparer_objets() de
#  tests/outils_tests.R (TOLERANCE = 1e-6), celui des references.
#
#  Objet : la batterie unitaire (tests/unitaires/test_controles_entree.R,
#  critere amende du 02/10/2026 de #153) ne lance run_engine() que sur un
#  echantillon de huit echelles dans le domaine, le calcul complet prenant
#  quelques secondes par echelle. Ce script parcourt TOUTES les echelles
#  10^e, e entier, pour lesquelles chaque valeur de x 10^e et de y 10^e est
#  dans [DOMAINE_NUMERIQUE_MIN ; DOMAINE_NUMERIQUE_MAX] (refus de #145
#  sinon), et compare a l'echelle 1 :
#    - ok = TRUE ;
#    - sigma_USP (parametre_final$sigma_usp) et la colonne p_retenue de
#      engine_table_tests(), par comparer_objets() (chaque valeur isolement,
#      a TOLERANCE pres, relative si |reference| > 1e-6, absolue sinon ;
#      NA a la meme place) ;
#    - la colonne verdict de engine_table_tests(), a l'identique.
#  Le script verifie aussi que les echelles 10^(e_min - 1) et 10^(e_max + 1)
#  sont refusees (ok = FALSE), pour attester que le balayage couvre tout le
#  domaine.
#
#  Jeux (T = 8) :
#    J153 : jeu de l'issue #153, x = 100, 150, 200, 300, 400, 500, 600, 700,
#           y = x * (0,71 ; 0,64 ; 0,80 ; 0,69 ; 0,75 ; 0,62 ; 0,90 ; 0,66) ;
#    JLN  : tests/donnees/donnees_ln.csv (donnees de test lognormales).
#  Configuration : methode prime, segment 1 de l'annexe II, donnees brutes,
#  B = B_MIN_USAGE (99) par defaut, graine par defaut de run_engine().
#
#  Statut des valeurs : CONSTAT NUMERIQUE sur ces deux jeux, sur la machine
#  d'execution ; pas une preuve d'invariance pour toute serie.
#
#  Usage (depuis la racine du depot) :
#      LC_ALL=C.UTF-8 Rscript tests/balayage_echelles.R [--B 99]
#  Code de sortie : 0 si toutes les echelles sont conformes, 1 sinon.
#  Duree mesuree : 524 s (conteneur de developpement Linux, R 4.3.3,
#  02/10/2026, B = 99 ; 99 echelles par jeu, e de -51 a 47, plus 2 x 2
#  bornes refusees).
###############################################################################

ARGS <- commandArgs(trailingOnly = TRUE)
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop(nom, " : valeur manquante")
  ARGS[i + 1L]
}
inconnues <- setdiff(ARGS[startsWith(ARGS, "--")], "--B")
if (length(inconnues)) stop("option inconnue : ", paste(inconnues, collapse = ", "))

.racine <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f)) normalizePath(file.path(dirname(f), "..")) else "."
})
source(file.path(.racine, "R", "engine.R"))
outils <- new.env(parent = globalenv())
sys.source(file.path(.racine, "tests", "outils_tests.R"), envir = outils)

B <- as.integer(lire_option("--B", B_MIN_USAGE))
if (is.na(B) || B < B_MIN_USAGE) stop("--B : entier >= ", B_MIN_USAGE, " attendu")

x153 <- c(100, 150, 200, 300, 400, 500, 600, 700)
d_ln <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln.csv"))
JEUX <- list(
  J153 = list(x = x153, y = x153 * c(0.71, 0.64, 0.80, 0.69, 0.75, 0.62, 0.90, 0.66)),
  JLN  = list(x = d_ln$xt, y = d_ln$yt))

calcul <- function(j, e) suppressWarnings(
  run_engine(xt = j$x * 10^e, yt = j$y * 10^e, methode = "premium", segment = 1,
             B = B, nature_donnees = "brutes"))
cle <- function(r) list(sigma = r$parametre_final$sigma_usp,
                        p = engine_table_tests(r)$p_retenue)
dans_domaine <- function(v) all(v >= DOMAINE_NUMERIQUE_MIN & v <= DOMAINE_NUMERIQUE_MAX)

# Contexte d'execution (#171, sur le modele de
# tests/taux_franchissement_reperes.R) : commit du depot (commit_depot() de
# tests/outils_tests.R, definition unique, #205) et plateforme de calcul (R,
# systeme, machine, BLAS, LAPACK).
plateforme_calcul <- function() {
  txt <- function(v) if (is.null(v) || !length(v) || is.na(v[1]) || !nzchar(v[1])) "non renseigné" else unname(v[1])
  si <- Sys.info()
  sprintf("%s ; %s ; %s, %s ; BLAS : %s ; LAPACK : %s (version %s)",
          R.version.string, txt(utils::sessionInfo()$running), txt(si[["sysname"]]), txt(si[["machine"]]),
          txt(extSoftVersion()["BLAS"]), txt(La_library()), txt(La_version()))
}

debut <- proc.time()[["elapsed"]]
cat("# Balayage des echelles du domaine numerique (#153)\n\n")
cat(sprintf("- Commit : %s\n- Plateforme : %s\n", outils$commit_depot(racine = .racine), plateforme_calcul()))
cat(sprintf("- B = %d ; domaine [%g ; %g] ; TOLERANCE = %g\n\n",
            B, DOMAINE_NUMERIQUE_MIN, DOMAINE_NUMERIQUE_MAX, outils$TOLERANCE))
cat("| Jeu | e min | e max | echelles | conformes | ecart relatif max sigma_USP |",
    "ecart max p retenue | verdicts differents | bornes refusees |\n", sep = " ")
cat("|---|---|---|---|---|---|---|---|---|\n")
tout_ok <- TRUE
for (nom in names(JEUX)) {
  j <- JEUX[[nom]]
  e_tous <- -400:400
  e_dom <- e_tous[vapply(e_tous, function(e) dans_domaine(c(j$x, j$y) * 10^e), logical(1))]
  stopifnot(length(e_dom) > 0L, all(diff(e_dom) == 1L))
  r1 <- calcul(j, 0); a <- cle(r1); v1 <- engine_table_tests(r1)$verdict
  stopifnot(isTRUE(r1$ok))
  n_conf <- 0L; d_sig <- 0; d_p <- 0; n_verd <- 0L; echecs <- character(0)
  for (e in e_dom) {
    r <- tryCatch(calcul(j, e), error = function(err) err)
    if (inherits(r, "error") || !isTRUE(r$ok)) {
      echecs <- c(echecs, sprintf("e = %d : %s", e,
                                  if (inherits(r, "error")) conditionMessage(r)
                                  else paste(r$validation$erreurs, collapse = " ; ")))
      next
    }
    b <- cle(r); vb <- engine_table_tests(r)$verdict
    d_sig <- max(d_sig, abs(b$sigma / a$sigma - 1))
    if (length(b$p) == length(a$p)) {
      fin <- is.finite(a$p) & is.finite(b$p)
      if (any(fin)) d_p <- max(d_p, abs(b$p[fin] - a$p[fin]))
    }
    nv <- if (length(vb) == length(v1)) sum(vb != v1) else NA_integer_
    n_verd <- n_verd + if (is.na(nv)) 1L else as.integer(nv > 0)
    conf <- isTRUE(outils$comparer_objets(a, b)$conforme) && identical(vb, v1)
    if (conf) n_conf <- n_conf + 1L
    else echecs <- c(echecs, sprintf("e = %d : ecart a l'echelle 1 hors TOLERANCE ou verdict different", e))
  }
  bornes <- vapply(c(min(e_dom) - 1L, max(e_dom) + 1L), function(e)
    identical(tryCatch(calcul(j, e)$ok, error = function(err) NA), FALSE), logical(1))
  ok_jeu <- n_conf == length(e_dom) && all(bornes)
  tout_ok <- tout_ok && ok_jeu
  cat(sprintf("| %s | %d | %d | %d | %d | %.2e | %.2e | %d | %s |\n", nom, min(e_dom),
              max(e_dom), length(e_dom), n_conf, d_sig, d_p, n_verd,
              if (all(bornes)) "oui" else "non"))
  if (length(echecs)) cat(paste0("\n  - ", nom, ", ", echecs), "\n", sep = "")
}
cat(sprintf("\nDuree : %.0f s. Bilan : %s\n", proc.time()[["elapsed"]] - debut,
            if (tout_ok) "toutes les echelles conformes" else "ECARTS (voir ci-dessus)"))
if (!tout_ok) quit(status = 1L)
