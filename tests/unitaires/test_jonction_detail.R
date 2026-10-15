###############################################################################
#  tests/unitaires/test_jonction_detail.R  --  JONCTION DES TEXTES DE DETAIL
#                                              (ISSUE #264)
#
#  Forme d'actuary (commentaire 6172078766 de #264) : une fonction unique,
#  .engine_joindre(a, b), remplace les sept copies de la regle de jonction
#  (cinq dans add(), une dans mw_tests(), .usp_joindre()) :
#    b vide -> a ; sinon a vide -> b ; sinon a, puis " " si a finit par un
#    point, " ; " sinon, puis b ; aucun trimws(), aucune majuscule.
#  Tests :
#    J1 : les trois branches et b vide ;
#    J2 : invariant "b suffixe verbatim du resultat" (lu par
#         .usp_poser_renvois() et R/display_helpers.R) ;
#    J3 : controle de source : la regle (grepl("\\.$", ...)) ne figure plus
#         que dans .engine_joindre() et .mw_avec_exclusion() (autre regle,
#         ". ", hors perimetre) ; add(), mw_tests(), usp_tests() et
#         .usp_poser_renvois() appellent la fonction ; .usp_joindre() retiree ;
#    J4 : mutation de la regle detectee sur le detail produit par add()
#         (registre fictif, sans simulation).
#  L'egalite des detail des six cas aux references (aucun texte change) est
#  portee par tests/test_reproductibilite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_jonction_detail.R")

.racine264 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

## --- J1 : branches -------------------------------------------------------------
verifier("J1 a vide -> b",
         identical(.engine_joindre("", "texte b"), "texte b"))
verifier("J1 a fini par un point -> jonction par une espace",
         identical(.engine_joindre("Texte a.", "texte b"), "Texte a. texte b"))
verifier("J1 a sans point final -> jonction par ' ; '",
         identical(.engine_joindre("Texte a", "texte b"), "Texte a ; texte b"))
verifier("J1 b vide -> a, sans separateur pendant (a sans point, a fini par un point, a vide)",
         identical(.engine_joindre("Texte a", ""), "Texte a") &&
           identical(.engine_joindre("Texte a.", ""), "Texte a.") &&
           identical(.engine_joindre("", ""), ""))
verifier("J1 aucun trimws() ni majuscule : espaces de a et b conserves, b non capitalise",
         identical(.engine_joindre("a ", " b"), "a  ;  b") &&
           identical(.engine_joindre("Fin.", "pi_t constant"), "Fin. pi_t constant"))
verifier("J1 point interieur sans effet : seul le dernier caractere de a compte",
         identical(.engine_joindre("p = 0.05 retenue", "x"), "p = 0.05 retenue ; x"))

## --- J2 : invariant de suffixe --------------------------------------------------
A264 <- c("", "Texte", "Texte.", "p = 0.1", "fin ;", "TEST INOPERANT (ADR 0001).", " ")
B264 <- c("b", "m = 4 paires", PHRASE_VERDICT_SENSIBLE_MC, USP_TXT_RENVOI_CST, ". b", " b ")
verifier("J2 b non vide est un suffixe verbatim du resultat (grille 7 x 6)",
         all(vapply(A264, function(a) all(vapply(B264, function(b)
           endsWith(.engine_joindre(a, b), b) &&
             identical(substr(.engine_joindre(a, b), 1L, nchar(a)), a), logical(1))),
           logical(1))))
verifier("J2 longueur du resultat = nchar(a) + separateur (0, 1 ou 3) + nchar(b)",
         all(vapply(A264, function(a) all(vapply(B264, function(b) {
           n <- nchar(.engine_joindre(a, b)) - nchar(a) - nchar(b)
           n == if (!nzchar(a)) 0L else if (grepl("[.]$", a)) 1L else 3L
         }, logical(1))), logical(1))))

## --- J3 : controle de source ----------------------------------------------------
# Corps des fonctions de premier niveau de R/engine.R, deparses sans
# commentaires (parse(keep.source = FALSE)) : la regle de jonction
# (grepl("\\.$", ...)) ne figure que dans .engine_joindre() et dans
# .mw_avec_exclusion() (regle ". ", hors perimetre de #264).
.src264 <- parse(file.path(.racine264, "R", "engine.R"), keep.source = FALSE)
.fn264 <- Filter(Negate(is.null), lapply(.src264, function(e) {
  if (is.call(e) && identical(e[[1]], as.name("<-")) && is.name(e[[2]]) &&
      is.call(e[[3]]) && identical(e[[3]][[1]], as.name("function")))
    list(nom = as.character(e[[2]]), texte = paste(deparse(e[[3]]), collapse = "\n"))
}))
.noms264 <- vapply(.fn264, `[[`, character(1), "nom")
.txt264 <- stats::setNames(vapply(.fn264, `[[`, character(1), "texte"), .noms264)
.regle264 <- 'grepl("\\\\.$"'
verifier("J3 la regle 'point final' n'apparait que dans .engine_joindre() et .mw_avec_exclusion()",
         identical(sort(names(.txt264)[grepl(.regle264, .txt264, fixed = TRUE)]),
                   sort(c(".engine_joindre", ".mw_avec_exclusion"))))
verifier("J3 le separateur ' ; ' conditionnel au point final n'apparait que dans .engine_joindre()",
         identical(names(.txt264)[grepl('else " ; "', .txt264, fixed = TRUE)], ".engine_joindre"))
verifier("J3 .usp_joindre() retiree du moteur",
         !".usp_joindre" %in% .noms264 && !exists(".usp_joindre"))
verifier("J3 appelants : engine_registre_tests() (add), mw_tests(), usp_tests(), .usp_poser_renvois()",
         all(vapply(c("engine_registre_tests", "mw_tests", "usp_tests", ".usp_poser_renvois"),
                    function(n) grepl(".engine_joindre", .txt264[[n]], fixed = TRUE), logical(1))) &&
           lengths(regmatches(.txt264[["engine_registre_tests"]],
                              gregexpr(".engine_joindre(detail, ", .txt264[["engine_registre_tests"]],
                                       fixed = TRUE))) == 5L)

## --- J4 : mutation de la regle detectee --------------------------------------------
# Registre fictif (meme construction que test_verdict_sensible_mc.R) : une
# statistique Monte-Carlo "S", p = 0,090 a 0,0091 pres d'alpha = 0,10, ce qui
# fait poser PHRASE_VERDICT_SENSIBLE_MC par add() a la jonction. Le registre
# est construit avec la fonction de jonction fournie : la vraie, ou une
# mutante dans un environnement qui la masque.
PH264 <- PHRASE_VERDICT_SENSIBLE_MC
detail264 <- function(detail, joindre = .engine_joindre) {
  env <- new.env(parent = environment(engine_registre_tests))
  env$.engine_joindre <- joindre
  reg_f <- engine_registre_tests
  environment(reg_f) <- env
  boot <- list(p_mc = c(S = 0.090), err_mc = c(S = 0.0091))
  r <- reg_f(boot, list(S = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
  r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", detail = detail)
  r$lignes()[[1]]$detail
}
attendus264 <- function(j) c(
  identical(detail264("Texte sans point", j), paste0("Texte sans point ; ", PH264)),
  identical(detail264("Texte fini par un point.", j), paste0("Texte fini par un point. ", PH264)),
  identical(detail264("", j), PH264))
verifier("J4 add() joint par .engine_joindre() : ' ; ' sans point, ' ' apres un point, rien si vide",
         all(attendus264(.engine_joindre)))
mutantes264 <- list(
  point_virgule_colle = function(a, b) {
    if (!nzchar(b)) return(a); if (!nzchar(a)) return(b)
    paste0(a, if (grepl("\\.$", a)) " " else "; ", b)
  },
  sans_regle_point = function(a, b) {
    if (!nzchar(b)) return(a); if (!nzchar(a)) return(b)
    paste0(a, " ; ", b)
  },
  separateur_si_a_vide = function(a, b) {
    if (!nzchar(b)) return(a)
    paste0(a, if (grepl("\\.$", a)) " " else " ; ", b)
  },
  majuscule = function(a, b) {
    if (!nzchar(b)) return(a); if (!nzchar(a)) return(b)
    if (grepl("\\.$", a)) paste0(a, " ", toupper(substr(b, 1, 1)), substring(b, 2))
    else paste0(a, " ; ", b)
  })
verifier("J4 chaque mutation de la regle (4 mutantes) est detectee sur le detail d'add()",
         all(vapply(mutantes264, function(m) !all(attendus264(m)), logical(1))))

fin_fichier()
