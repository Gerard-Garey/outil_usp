###############################################################################
#  tests/unitaires/test_application.R  --  APPLICATION SHINY (correctif R5)
#
#  app.R : triangle par defaut (issue #108), grille des series non alignee
#  sur T (issue #134), journal de session (issue #136).
#  Proprietes verifiees :
#   - triangle_defaut(T) sans valeur manquante dans la partie observee pour
#     T = 1..40 (borne max du champ T) et accepte par mw_valider_triangle() ;
#     triangle inchange pour T <= 11 (valeurs de controle ci-dessous) ;
#   - avec shiny installe (pas en CI, comme plotly, issue #53) : la grille
#     des methodes lognormales garde ses n annees quand T change ; au clic,
#     run_engine() recoit les n annees, retient les T plus recentes et
#     restitue la ligne "profondeur" (metadata$n_fournies = n) dans le
#     bandeau de l'onglet Calibration et dans le journal de session, qui
#     reprend le libelle du moteur tel quel (primes et reserve no 1).
#  La partie Shiny tourne dans un processus R distinct : app.R attache shiny
#  et recharge le moteur dans l'environnement global, ce qui ne doit pas
#  toucher les fichiers de tests suivants.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_application.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else
           if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
.app <- file.path(.racine, "app.R")

## --- Triangle par defaut (issue #108) ----------------------------------------
# Seule la definition de triangle_defaut() est evaluee : charger app.R
# lancerait l'application.
.env <- new.env()
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      identical(.x[[2]], as.name("triangle_defaut"))) eval(.x, .env)
verifier("app.R definit triangle_defaut()", is.function(.env$triangle_defaut))

.na_observees <- vapply(1:40, function(T) {
  tri <- .env$triangle_defaut(T)
  sum(is.na(tri[outer(seq_len(T), seq_len(T), "+") <= T + 1]))
}, numeric(1))
verifier("triangle_defaut(T), T = 1..40 : aucune valeur manquante dans la partie observee (#108)",
         all(.na_observees == 0))
verifier("triangle_defaut(T), T = 12, 15, 40 : accepte par mw_valider_triangle() (#108)",
         all(vapply(c(12, 15, 40), function(T) mw_valider_triangle(.env$triangle_defaut(T))$ok,
                    logical(1))))
verifier("triangle_defaut(T), T = 12 : partie future vide (T(T-1)/2 = 66 cellules)",
         sum(is.na(.env$triangle_defaut(12))) == 66L)
# Valeurs de controle relevees sur triangle_defaut() de app.R avant #108
# (main 9bce774) : le prolongement du dernier facteur ne change pas le
# triangle pour T <= 11.
verifier("triangle_defaut(8), premiere ligne inchangee (valeurs avant #108)",
         isTRUE(all.equal(.env$triangle_defaut(8)[1, ],
                          c(300, 962.71, 1564.43, 2025.44, 2296.1, 2512.37, 2690.19, 2766.61),
                          tolerance = 1e-12)))
verifier("triangle_defaut(11), cellules (1, 11) et (2, 10) inchangees (valeurs avant #108)",
         isTRUE(all.equal(c(.env$triangle_defaut(11)[1, 11], .env$triangle_defaut(11)[2, 10]),
                          c(2701.01, 2756.95), tolerance = 1e-12)))

## --- Grille des series et journal (issues #134, #136) -------------------------
if (requireNamespace("shiny", quietly = TRUE)) {
  .script <- tempfile(fileext = ".R")
  writeLines(c(
    'suppressMessages(library(shiny))',
    'ea <- new.env(); app <- source("app.R", local = ea)$value',
    'a <- function(nom, ok) cat(sprintf("ASSERT\\t%s\\t%s\\n", nom, isTRUE(ok)))',
    'xt <- c(98.10, 101.30, 104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)',
    'yt <- c(71.05,  66.40,  68.97,  76.76,  83.49,  95.38,  88.96,  70.22,  78.89, 117.37)',
    'testServer(app, {',
    '  session$setInputs(annexe = "II", segment = "1", sigma_manuel = FALSE, B = 99,',
    '                    alpha = 0.10, seed = 20260831, delta_apriori = FALSE,',
    '                    theta_equiv = 0.10, methode = "premium", nature_donnees = "brutes",',
    '                    profondeur = 8, reinit = 1)',
    '  a("reinitialisation : 8 annees du jeu par defaut", identical(donnees(), ea$DONNEES_DEFAUT))',
    '  session$setInputs(profondeur = 6)',
    '  a("T = 6 : la grille garde ses 8 annees (#134)", identical(donnees(), ea$DONNEES_DEFAUT))',
    '  session$setInputs(profondeur = 8, ajouter_annee = 1)',
    '  session$setInputs(ajouter_annee = 2)',
    '  a("deux ajouts : 10 lignes, les 2 dernieres vides", nrow(donnees()) == 10L &&',
    '    all(is.na(donnees()$xt[9:10])) && identical(donnees()$t, 1:10))',
    '  do.call(session$setInputs, c(setNames(as.list(xt), paste0("x_", 1:10)),',
    '                               setNames(as.list(yt), paste0("y_", 1:10))))',
    '  session$setInputs(go = 1)',
    '  r <- resultat()',
    '  a("n = 10, T = 8 : metadata$n_fournies = 10, metadata$T = 8 (#134)",',
    '    isTRUE(r$ok) && identical(as.integer(r$metadata$n_fournies), 10L) &&',
    '      identical(as.integer(r$metadata$T), 8L))',
    '  a("n = 10, T = 8 : le moteur retient les 8 annees les plus recentes",',
    '    identical(r$donnees$xt, xt[3:10]) && identical(r$donnees$yt, yt[3:10]))',
    '  lib <- libelle_derogation(r, "profondeur")',
    '  a("ligne profondeur restituee, 2 annees ecartees", length(lib) == 1L &&',
    '    grepl("sur n = 10 annees fournies : les 2 annees les plus anciennes", lib, fixed = TRUE))',
    '  a("bandeau Calibration : libelle du moteur", grepl(lib, as.character(output$derogations$html), fixed = TRUE))',
    '  a("journal (primes) : libelle du moteur repris tel quel (#136)",',
    '    grepl(paste0("Profondeur T         : 8 (", lib, ")"), output$tab_meta, fixed = TRUE))',
    '  session$setInputs(methode = "reserve1", go = 2)',
    '  lib1 <- libelle_derogation(resultat(), "profondeur")',
    '  a("journal (reserve no 1) : libelle du moteur, exercices fournis (#136)",',
    '    grepl("exercices fournis", lib1, fixed = TRUE) &&',
    '      grepl(paste0("Profondeur T         : 8 (", lib1, ")"), output$tab_meta, fixed = TRUE))',
    '  session$setInputs(profondeur = 10, go = 3)',
    '  a("T = n = 10 : aucune ligne profondeur, journal sans mention",',
    '    is.null(libelle_derogation(resultat(), "profondeur")) &&',
    '      grepl("Profondeur T         : 10 \\n", output$tab_meta, fixed = TRUE))',
    '  session$setInputs(retirer_annee = 1)',
    '  a("retrait : 9 lignes, saisies conservees", identical(donnees()$xt, xt[1:9]))',
    '})'), .script)
  # Processus fils lance depuis la racine du depot : app.R y source
  # R/engine.R par chemin relatif.
  .ici <- setwd(.racine)
  .sortie <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                      c("--vanilla", shQuote(.script)),
                                      stdout = TRUE, stderr = TRUE))
  setwd(.ici)
  .lignes <- grep("^ASSERT\t", .sortie, value = TRUE)
  verifier("processus Shiny : 11 assertions rendues", length(.lignes) == 11L)
  if (length(.lignes) != 11L) cat(utils::tail(.sortie, 10), sep = "\n")
  for (.l in strsplit(.lignes, "\t", fixed = TRUE))
    verifier(paste("Application :", .l[2]), identical(.l[3], "TRUE"))
} else {
  cat("  note : shiny absent ; grille et journal non exerces (attendu en CI, comme plotly, issue #53).\n")
}

fin_fichier()
