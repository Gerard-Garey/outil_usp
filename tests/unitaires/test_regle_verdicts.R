###############################################################################
#  tests/unitaires/test_regle_verdicts.R  --  REGLE DES VERDICTS EN TEXTE
#                                             (engine_regle_verdicts(), #498)
#
#  engine_regle_verdicts(alpha) rend les quatre phrases de la regle des
#  verdicts (texte seul, hors run_engine()). add() d'engine_registre_tests()
#  reste la seule source de la regle : ce fichier confronte chaque zone
#  enoncee par le texte (seuils relus DANS les phrases) au verdict que produit
#  add(), dans les deux sens, sur une grille de p contenant les bornes ; il
#  controle les valeurs injectees (format decimal francais, aller-retour), la
#  lecture du seuil d'ECHEC dans SEUIL_ECHEC_SENS_REJETER, le domaine de alpha
#  (meme libelle que .engine_verifier_usage()) et les lignes INFO.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_regle_verdicts.R")

# Registre fictif (aucune simulation), comme test_nature_p_non_simulee.R.
reg498 <- function(alpha) {
  engine_registre_tests(list(p_mc = c(A = 0.5), err_mc = c(A = 0.01)),
                        list(A = .mc_entree(function(e) 1, "haut")), alpha, "Monte-Carlo")
}
# Verdict d'add() pour une p non simulee seule, selon le sens.
verdict498 <- function(alpha, p, sens) {
  r <- reg498(alpha)
  r$add("F", "t", "ref", fonction = "usp_tests", p_as = p, sens = sens)
  r$lignes()[[1]]$verdict
}
# Nombres d'une phrase, dans l'ordre (point decimal restitue). Les chiffres
# colles a une lettre (H0) ou a "/" (alpha/2) ne sont pas des nombres.
nombres498 <- function(phrase)
  as.numeric(sub(",", ".", regmatches(phrase, gregexpr(
    "(?<![A-Za-z/])[0-9]+(,[0-9]+)?(e-?[0-9]+)?", phrase, perl = TRUE))[[1]], fixed = TRUE))
# Zone enoncee par le texte (phrases 2 et 3), seuils lus dans les phrases.
zone498 <- function(txt, p, sens) {
  if (sens == "rejeter") {
    n <- nombres498(txt[2])             # alpha, alpha, seuil, seuil
    if (p < n[1]) "OK" else if (p >= n[2] && p < n[3]) "ALERTE" else if (p >= n[4]) "ECHEC" else NA
  } else {
    n <- nombres498(txt[3])             # alpha/2, alpha/2, alpha, alpha
    if (p < n[1]) "ECHEC" else if (p >= n[2] && p < n[3]) "ALERTE" else if (p >= n[4]) "OK" else NA
  }
}
# Grille : bornes exactes et leurs voisines, pour chaque seuil de la regle.
grille498 <- function(alpha) {
  b <- c(alpha / 2, alpha, SEUIL_ECHEC_SENS_REJETER)
  sort(unique(c(1e-12, 0, 0.5, 1, 0.30, b, b * (1 - 1e-9), b * (1 + 1e-9))))
}

## --- Structure et valeurs injectees ---------------------------------------------
t10 <- engine_regle_verdicts(0.10)
verifier("engine_regle_verdicts(0,10) : character(4), non vides, sans NA",
         is.character(t10) && length(t10) == 4L && !anyNA(t10) && all(nzchar(t10)))
verifier("alpha par defaut 0,10 : valeurs 0,1 ; 0,05 ; 0,3 dans les phrases 2 et 3",
         identical(nombres498(t10[2]), c(0.1, 0.1, 0.3, 0.3)) &&
           identical(nombres498(t10[3]), c(0.05, 0.05, 0.1, 0.1)) &&
           grepl("= 0,1,", t10[1], fixed = TRUE) && grepl("(", t10[3], fixed = TRUE))
verifier("format decimal francais : aucun point decimal dans les nombres cites",
         !any(grepl("[0-9]\\.[0-9]", t10)))
a_non_rond <- 0.0731
t_nr <- engine_regle_verdicts(a_non_rond)
verifier("alpha non rond 0,0731 : alpha et alpha/2 cites, restitues par l'aller-retour",
         identical(nombres498(t_nr[2])[1:2], c(a_non_rond, a_non_rond)) &&
           identical(nombres498(t_nr[3]), c(a_non_rond / 2, a_non_rond / 2, a_non_rond, a_non_rond)) &&
           grepl("0,0731", t_nr[1], fixed = TRUE) && grepl("0,03655", t_nr[3], fixed = TRUE))
a17 <- 0.1234567891234567                       # non restitue par 15 chiffres
t17 <- engine_regle_verdicts(a17)
verifier("alpha a 17 chiffres : alpha et alpha/2 restitues exactement par l'aller-retour",
         identical(as.numeric(sprintf("%.15g", a17)) == a17, FALSE) &&
           identical(nombres498(t17[2])[1], a17) &&
           identical(nombres498(t17[3]), c(a17 / 2, a17 / 2, a17, a17)))
verifier("alpha tres petit 1e-5 : citation en notation scientifique relue exactement",
         identical(nombres498(engine_regle_verdicts(1e-5)[3]), c(5e-6, 5e-6, 1e-5, 1e-5)))
verifier("phrase 4 (INFO) : independante de alpha, sans valeur injectee",
         identical(t10[4], t_nr[4]) && identical(t10[4], t17[4]) && grepl("INFO", t10[4], fixed = TRUE))

## --- Le texte = le verdict d'add(), dans les deux sens ----------------------------
for (a in c(0.10, 0.05, a_non_rond, a17, 0.29)) {
  txt <- engine_regle_verdicts(a); g <- grille498(a)
  for (sens in c("rejeter", "ne pas rejeter")) {
    ecarts <- g[vapply(g, function(p) !identical(zone498(txt, p, sens), verdict498(a, p, sens)),
                       logical(1))]
    verifier(sprintf("alpha = %s, sens '%s' : zone du texte = verdict d'add() sur %d valeurs de p",
                     format(a, digits = 17), sens, length(g)),
             if (length(ecarts)) paste("p en ecart :", paste(format(ecarts, digits = 17), collapse = ", "))
             else TRUE)
  }
}
verifier("bornes de la specification a alpha = 0,10 (add())",
         identical(verdict498(0.10, 0.10, "rejeter"), "ALERTE") &&
           identical(verdict498(0.10, 0.30, "rejeter"), "ECHEC") &&
           identical(verdict498(0.10, 0.05, "ne pas rejeter"), "ALERTE") &&
           identical(verdict498(0.10, 0.10, "ne pas rejeter"), "OK") &&
           identical(verdict498(0.10, 0.0999, "rejeter"), "OK") &&
           identical(verdict498(0.10, 0.0499, "ne pas rejeter"), "ECHEC"))

## --- Seuil d'ECHEC lu dans SEUIL_ECHEC_SENS_REJETER -----------------------------
verifier("seuil d'ECHEC du sens 'rejeter' lu dans SEUIL_ECHEC_SENS_REJETER (valeur substituee 0,25)",
         {
           env <- environment(engine_regle_verdicts)
           ancien <- get("SEUIL_ECHEC_SENS_REJETER", envir = env)
           verrou <- bindingIsLocked("SEUIL_ECHEC_SENS_REJETER", env)
           if (verrou) unlockBinding("SEUIL_ECHEC_SENS_REJETER", env)
           on.exit({ assign("SEUIL_ECHEC_SENS_REJETER", ancien, envir = env)
                     if (verrou) lockBinding("SEUIL_ECHEC_SENS_REJETER", env) })
           assign("SEUIL_ECHEC_SENS_REJETER", 0.25, envir = env)
           x <- engine_regle_verdicts(0.10)
           identical(nombres498(x[2]), c(0.1, 0.1, 0.25, 0.25)) &&
             identical(zone498(x, 0.25, "rejeter"), verdict498(0.10, 0.25, "rejeter")) &&
             identical(zone498(x, 0.2499, "rejeter"), verdict498(0.10, 0.2499, "rejeter"))
         })
verifier("seuil restitue apres substitution : 0,3 de nouveau cite",
         identical(nombres498(engine_regle_verdicts(0.10)[2]), c(0.1, 0.1, 0.3, 0.3)))

## --- Domaine de alpha : meme refus, meme libelle que .engine_verifier_usage() -----
hors_domaine <- list(0, -0.1, SEUIL_ECHEC_SENS_REJETER, 0.5, 1, NA_real_, NaN, Inf, -Inf,
                     c(0.05, 0.10), numeric(0), "0.1", TRUE, NULL,
                     structure(0.1, nom = "a"))
msg498 <- function(expr) tryCatch({ expr; NA_character_ }, error = function(e) conditionMessage(e))
for (i in seq_along(hors_domaine)) {
  a <- hors_domaine[[i]]
  verifier(sprintf("alpha hors domaine no %d refuse, libelle de .engine_verifier_usage()", i),
           {
             m <- msg498(engine_regle_verdicts(a))
             m_ref <- msg498(.engine_verifier_usage(99, 1, NULL, alpha = a))
             !is.na(m) && identical(m, m_ref) && grepl("^alpha = ", m)
           })
}
verifier("alpha hors domaine : erreur sans appel (call. = FALSE)",
         is.null(tryCatch(engine_regle_verdicts(0), error = function(e) conditionCall(e))))
verifier("alpha valide 0,10 : .engine_verifier_usage() ne leve aucune erreur sur alpha (contre-controle)",
         !grepl("^alpha = ", msg498(.engine_verifier_usage(99, 1, NULL, alpha = 0.10))))

## --- Lignes INFO (phrase 4) et verdict independant des mentions -------------------
verifier("INFO : ligne de diagnostic, ligne non applicable, test sans p retenue, test inoperant",
         {
           r <- reg498(0.10)
           r$add("F", "diag", "ref", type = "diagnostic", fonction = "usp_tests", p_as = 0.5)
           r$add("F", "na", "ref", type = "non applicable", fonction = "usp_tests")
           r$add("F", "sans_p", "ref", fonction = "usp_tests")
           r$add("F", "inop", "ref", fonction = "usp_tests", p_ex = 0.5, p_min = 0.10)
           l <- r$lignes()
           identical(vapply(l, function(z) z$verdict, ""), rep("INFO", 4L)) &&
             identical(vapply(l, function(z) isTRUE(z$inoperant), TRUE), c(FALSE, FALSE, FALSE, TRUE))
         })
verifier("mention 'ECHEC inatteignable' dans le detail : le verdict reste celui de p, alpha et du sens",
         {
           r <- reg498(0.10)
           r$add("F", "t", "ref", fonction = "usp_tests", p_ex = 0.02, p_min = 0.06)
           l <- r$lignes()[[1]]
           grepl("ECHEC inatteignable", l$detail, fixed = TRUE) &&
             identical(l$verdict, zone498(t10, 0.02, "ne pas rejeter"))
         })

fin_fichier()
