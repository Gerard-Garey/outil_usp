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
#     reprend le libelle du moteur tel quel (primes et reserve no 1) ;
#   - apercu de validation (issue #183) : segment_recevable() sans
#     avertissement R, titre des refus, garde de la profondeur apres import
#     (profondeur_coherente(), profondeur_attendue_import(), n = 4 et 41
#     hors des bornes du champ T) et, avec shiny, sequence reactive de
#     l'apercu apres import (n different de T, n = T, n hors [5 ; 40]) ;
#   - vue Detail de l'onglet Tests (issue #178) : table_detail_groupe()
#     appelee avec replier = TRUE, regle CSS du repli presente et, avec
#     shiny, commentaire long replie et colonne Fonction dans le rendu de la
#     vue Detail, absents de la vue Synthese ;
#   - dimension du triangle et reinitialisation (issue #155, decision
#     Q-R7-2 (A)) : profondeur_reinitialisation(), jeu_reinitialise(),
#     message_reinitialisation() hors Shiny ; aucun observateur du champ T
#     n'ecrit le triangle, "Reinitialiser" incremente version_grille,
#     l'import d'un triangle ne touche plus le champ T (lecture du code) ;
#     avec shiny : un triangle lu au demarrage (10 x 10, T = 8) garde sa
#     dimension, de meme apres l'import d'une serie et au changement de T ;
#     seule "Reinitialiser" la change ; grille redessinee par une seconde
#     reinitialisation sur des donnees deja par defaut (series et triangle)
#     et par un second import du meme fichier ;
#   - objet non fonction rbind de l'environnement global (issue #199) : avec
#     shiny, table des controles (output$tab_controles) identique a celle
#     rendue sans lui ; rapport_html() : voir test_rapport_html.R.
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

## --- Apercu de validation (issue #183) ----------------------------------------
# Fonctions de premier niveau d'app.R, evaluees seules comme triangle_defaut().
.noms_183 <- c("segment_recevable", "TITRE_APERCU_REFUS", "profondeur_coherente",
               "PROFONDEUR_MIN", "PROFONDEUR_MAX", "profondeur_attendue_import")
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% .noms_183) eval(.x, .env)
verifier("app.R definit segment_recevable(), TITRE_APERCU_REFUS, profondeur_coherente(), profondeur_attendue_import() et les bornes du champ T",
         is.function(.env$segment_recevable) && is.character(.env$TITRE_APERCU_REFUS) &&
           is.function(.env$profondeur_coherente) && is.function(.env$profondeur_attendue_import) &&
           identical(c(.env$PROFONDEUR_MIN, .env$PROFONDEUR_MAX), c(5L, 40L)))

# Constat 1 : aucun avertissement R, quelle que soit la valeur de
# input$segment (et de input$annexe).
.sans_avert <- function(expr) {
  w <- FALSE
  v <- withCallingHandlers(expr, warning = function(c) { w <<- TRUE; invokeRestart("muffleWarning") })
  list(valeur = v, avertissement = w)
}
.entrees <- list("abc", "1a", " 1", "", "99999999999", "1e3", "-1", "1.5", NA, NA_character_,
                 NA_integer_, NULL, character(0), c("1", "2"), list("1"), TRUE, 1.5, Inf, "Inf")
.r <- lapply(.entrees, function(s) .sans_avert(.env$segment_recevable(s, "II")))
verifier("segment_recevable() : aucun avertissement R sur 19 valeurs inattendues de input$segment (#183)",
         !any(vapply(.r, `[[`, logical(1), "avertissement")))
verifier("segment_recevable() : valeurs inattendues -> NULL (aucun segment transmis)",
         all(vapply(.r, function(x) is.null(x$valeur), logical(1))))
.r_annexe <- lapply(list(NA, NULL, "XX", c("II", "XIV"), list("II")),
                    function(a) .sans_avert(.env$segment_recevable("1", a)))
verifier("segment_recevable() : annexe inattendue -> NULL, sans avertissement",
         all(vapply(.r_annexe, function(x) is.null(x$valeur) && !x$avertissement, logical(1))))
# Valeurs atteignables par l'interface : choix de selectInput("segment"),
# as.character(SEGMENTS$segment) de l'annexe courante.
.ok_catalogue <- all(vapply(seq_len(nrow(SEGMENTS)), function(i)
  identical(.env$segment_recevable(as.character(SEGMENTS$segment[i]), SEGMENTS$annexe[i]),
            as.integer(SEGMENTS$segment[i])), logical(1)))
verifier("segment_recevable() : chaque segment du catalogue rendu en entier dans son annexe",
         .ok_catalogue)
verifier("segment_recevable() : segment absent de l'annexe courante -> NULL (\"12\" en annexe XIV)",
         !12 %in% SEGMENTS$segment[SEGMENTS$annexe == "XIV"] &&
           is.null(.env$segment_recevable("12", "XIV")))
verifier("segment_recevable() : numerique 1 accepte comme \"1\" (annexe II)",
         identical(.env$segment_recevable(1, "II"), 1L))

# Constat 2 : T refuse par le moteur, titre qui ne parle pas des donnees ;
# le texte de l'erreur reste celui du moteur.
.v_T <- engine_valider_serie_retenue(c(98.1, 101.3, 104.2, 102.25, 109.34, 114.64),
                                     c(71.05, 66.4, 68.97, 76.76, 83.49, 95.38), T = 8,
                                     methode = "premium", nature_donnees = "brutes")$validation
verifier("apercu, T = 8 sur 6 annees : refus du moteur sur la profondeur",
         !.v_T$ok && identical(.v_T$erreurs[1],
                               "Profondeur T = 8 superieure au nombre d'annees fournies (6)."))
verifier("apercu : titre des erreurs sans le mot \"donnees\" (#183)",
         !grepl("donn", .env$TITRE_APERCU_REFUS, ignore.case = TRUE))
.src_app <- readLines(.app, warn = FALSE)
verifier("app.R : l'apercu affiche TITRE_APERCU_REFUS, plus \"Donnees non exploitables\"",
         any(grepl("tags$b(TITRE_APERCU_REFUS)", .src_app, fixed = TRUE)) &&
           !any(grepl("Donnees non exploitables", .src_app, fixed = TRUE)))

# Constat 3 : apres un import de n annees, l'apercu n'est pas evalue avec un
# T incoherent avec la grille.
verifier("profondeur_coherente() : sans import en attente, toujours TRUE",
         isTRUE(.env$profondeur_coherente(8, NULL)) && isTRUE(.env$profondeur_coherente(NA, NULL)) &&
           isTRUE(.env$profondeur_coherente(NULL, NULL)))
verifier("profondeur_coherente() : import de 6 annees, ancien T = 8 -> FALSE ; T = 6 -> TRUE",
         identical(.env$profondeur_coherente(8, 6L), FALSE) &&
           identical(.env$profondeur_coherente(6, 6L), TRUE))
verifier("profondeur_coherente() : champ T vide ou NULL pendant l'import -> FALSE",
         identical(.env$profondeur_coherente(NA_real_, 10L), FALSE) &&
           identical(.env$profondeur_coherente(NULL, 10L), FALSE))
# Reprise (revue app-review) : la garde n'est posee que pour un n que le
# champ T peut prendre, sans quoi l'apercu pourrait rester fige.
verifier("app.R : le champ T lit ses bornes dans PROFONDEUR_MIN et PROFONDEUR_MAX",
         any(grepl("min = PROFONDEUR_MIN, max = PROFONDEUR_MAX", .src_app, fixed = TRUE)))
verifier("profondeur_attendue_import() : n = 5, 10, 40 (bornes comprises) -> n",
         identical(.env$profondeur_attendue_import(5L), 5L) &&
           identical(.env$profondeur_attendue_import(10L), 10L) &&
           identical(.env$profondeur_attendue_import(40), 40L))
verifier("profondeur_attendue_import() : n = 4 et n = 41 (hors bornes du champ T) -> NULL, garde non posee",
         is.null(.env$profondeur_attendue_import(4L)) && is.null(.env$profondeur_attendue_import(41L)))
verifier("profondeur_attendue_import() : n non entier, NA, NULL -> NULL",
         is.null(.env$profondeur_attendue_import(6.5)) &&
           is.null(.env$profondeur_attendue_import(NA_integer_)) &&
           is.null(.env$profondeur_attendue_import(NULL)))
verifier("profondeur_coherente() : n = 4 ou 41 sans garde -> l'apercu s'evalue (TRUE)",
         isTRUE(.env$profondeur_coherente(8, .env$profondeur_attendue_import(4L))) &&
           isTRUE(.env$profondeur_coherente(8, .env$profondeur_attendue_import(41L))))

## --- Vue Detail de l'onglet Tests (issue #178) -------------------------------
# Lecture de l'arbre syntaxique d'app.R, sans le charger : tout appel a
# table_detail_groupe() demande le repli du commentaire (le rapport fige, qui
# l'appelle sans repli, est dans R/display_helpers.R).
.appels <- function(e, nom) {
  if (is.call(e)) {
    ici <- if (identical(e[[1]], as.name(nom))) list(e) else list()
    c(ici, unlist(lapply(as.list(e)[-1], .appels, nom), recursive = FALSE))
  } else if (is.expression(e) || is.list(e)) unlist(lapply(e, .appels, nom), recursive = FALSE)
  else list()
}
.tdg <- .appels(parse(.app, keep.source = FALSE), "table_detail_groupe")
verifier("app.R : vue Detail, un appel a table_detail_groupe() avec replier = TRUE (#178)",
         length(.tdg) == 1L && isTRUE(.tdg[[1]]$replier))
.src_app <- readLines(.app, encoding = "UTF-8")
verifier("app.R : regles CSS du commentaire replie (details.com) (#178)",
         any(grepl("details.com > summary", .src_app, fixed = TRUE)) &&
           any(grepl("details.com:not([open]) > summary::after", .src_app, fixed = TRUE)))

## --- Dimension du triangle et reinitialisation (issue #155) --------------------
# Fonctions de premier niveau d'app.R, evaluees seules comme triangle_defaut().
.noms_155 <- c("DONNEES_DEFAUT", "profondeur_reinitialisation", "jeu_reinitialise",
               "message_reinitialisation")
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% .noms_155) eval(.x, .env)
verifier("app.R definit profondeur_reinitialisation(), jeu_reinitialise(), message_reinitialisation() (#155)",
         is.function(.env$profondeur_reinitialisation) && is.function(.env$jeu_reinitialise) &&
           is.function(.env$message_reinitialisation) && is.data.frame(.env$DONNEES_DEFAUT))
# Assertion modifiee par #194, qui revient sur #108 (decision du mainteneur
# Q-R10-1 (A), 06/10/2026) : #108 ne posait aucune borne superieure et
# retenait T = 41 tel quel ; la reinitialisation plafonne desormais T a
# PROFONDEUR_MAX (40), borne du champ T, pour ne pas figer l'application
# sur le rendu d'une grille de 100 x 100 ou plus (12,6 s a T = 100, 91,5 s
# a T = 200, mesures de l'issue). T = 41 sort donc de cette assertion et
# passe dans celle du plafonnement, juste apres.
.pr <- lapply(list(5, 10, 12, 40), .env$profondeur_reinitialisation)
verifier("profondeur_reinitialisation() : T = 5, 10, 12, 40 retenus tels quels, sans motif ni plafonnement (#108, #194)",
         identical(vapply(.pr, function(r) as.numeric(r$T), numeric(1)), c(5, 10, 12, 40)) &&
           all(lengths(lapply(.pr, `[[`, "erreurs")) == 0L) &&
           all(lengths(lapply(.pr, `[[`, "plafonnement")) == 0L))
.pr <- lapply(list(41, 200, 1e6), .env$profondeur_reinitialisation)
verifier("profondeur_reinitialisation() : T = 41, 200, 1e6 plafonnes a PROFONDEUR_MAX = 40, sans motif d'erreur (#194, Q-R10-1 (A))",
         all(vapply(.pr, function(r) identical(r$T, 40L) && length(r$erreurs) == 0L &&
                      length(r$plafonnement) == 1L, logical(1))))
verifier("profondeur_reinitialisation() : le message de plafonnement nomme la valeur saisie et la valeur retenue (#194)",
         identical(.env$profondeur_reinitialisation(200)$plafonnement,
                   "Profondeur T = 200 au-dela du maximum de 40 : T = 40 retenu.") &&
           identical(.env$profondeur_reinitialisation(41)$plafonnement,
                     "Profondeur T = 41 au-dela du maximum de 40 : T = 40 retenu."))
verifier("profondeur_reinitialisation() : saisies irrecevables (#100) sans plafonnement",
         all(vapply(list(NULL, NA_real_, 12.5, 0, -3, Inf), function(t)
           length(.env$profondeur_reinitialisation(t)$plafonnement) == 0L, logical(1))))
verifier("message_reinitialisation() : triangle plafonne nomme 40 x 40 (#194)",
         identical(.env$message_reinitialisation(TRUE, .env$profondeur_reinitialisation(200)$T),
                   "Donnees reinitialisees : triangle par defaut 40 x 40."))
.pr <- lapply(list(NULL, NA_real_, 12.5, 0, -3, Inf), .env$profondeur_reinitialisation)
verifier("profondeur_reinitialisation() : champ vide, NA, 12.5, 0, -3, Inf -> T = 8 du jeu par defaut, avec motif (#100)",
         all(vapply(.pr, function(r) identical(r$T, 8L) && length(r$erreurs) == 1L &&
                      nzchar(r$erreurs), logical(1))))
verifier("profondeur_reinitialisation() : motif du champ vide, motif du moteur pour T = 0",
         identical(.env$profondeur_reinitialisation(NULL)$erreurs, "Profondeur T : champ vide.") &&
           identical(.env$profondeur_reinitialisation(0)$erreurs,
                     engine_valider_profondeur(0, n = Inf, T_min = 1)))
verifier("jeu_reinitialise() : triangle par defaut de T annees (reserve no 2), series par defaut sinon, quelle que soit T",
         identical(.env$jeu_reinitialise(TRUE, 10), .env$triangle_defaut(10)) &&
           identical(.env$jeu_reinitialise(TRUE, 5), .env$triangle_defaut(5)) &&
           identical(.env$jeu_reinitialise(FALSE, 5), .env$DONNEES_DEFAUT) &&
           identical(.env$jeu_reinitialise(FALSE, 12), .env$DONNEES_DEFAUT))
verifier("message_reinitialisation() : dimension du triangle nommee (reserve no 2) (#155)",
         identical(.env$message_reinitialisation(TRUE, 10),
                   "Donnees reinitialisees : triangle par defaut 10 x 10.") &&
           identical(.env$message_reinitialisation(FALSE, 10), "Donnees reinitialisees."))
# Lecture du code : aucun observateur du champ T n'ecrit le triangle (appel
# triangle(x), avec argument) ; l'observateur de "Reinitialiser" incremente
# le compteur version_grille ; celui de l'import n'appelle plus
# updateNumericInput() qu'une fois (branche des series).
.obs <- .appels(parse(.app, keep.source = FALSE), "observeEvent")
.sur <- function(o, champ) identical(o[[2]], call("$", as.name("input"), as.name(champ)))
.ecrit <- function(o, nom) any(vapply(.appels(o, nom), function(e) length(e) > 1L, logical(1)))
.obs_T <- Filter(function(o) .sur(o, "profondeur"), .obs)
verifier("app.R : aucun observateur de input$profondeur n'ecrit le triangle (#155 a, b)",
         length(.obs_T) >= 1L && !any(vapply(.obs_T, .ecrit, logical(1), "triangle")))
.obs_R <- Filter(function(o) .sur(o, "reinit"), .obs)
verifier("app.R : \"Reinitialiser\" incremente version_grille (#155 c)",
         length(.obs_R) == 1L && .ecrit(.obs_R[[1]], "version_grille"))
.obs_I <- Filter(function(o) .sur(o, "fichier_import"), .obs)
verifier("app.R : l'import d'un triangle ne modifie plus le champ T (#155)",
         length(.obs_I) == 1L && length(.appels(.obs_I[[1]], "updateNumericInput")) == 1L)

## --- Grille des series et journal (issues #134, #136) -------------------------
if (requireNamespace("shiny", quietly = TRUE)) {
  # Scenarios de l'issue #155 (dimension du triangle, reinitialisation),
  # ajoutes au script du processus fils ; chaine brute, sans echappement.
  .bloc_155 <- r"---(
## Dimension du triangle et reinitialisation (issue #155, Q-R7-2 (A))
grille_html <- function(output) as.character(output$grille_donnees$html)
a_id <- function(h, id) grepl(sprintf('id="%s"', id), h, fixed = TRUE)
a_val <- function(h, id, v) grepl(sprintf('id="%s" type="number" class="shiny-input-number form-control" value="%s"',
                                         id, v), h, fixed = TRUE)
# Fichier de triangle n x n au format de l'import (colonnes i, j0, j1...).
fichier_tri <- function(tri) {
  f <- tempfile(fileext = ".csv"); n <- nrow(tri)
  utils::write.csv(data.frame(i = seq_len(n) - 1L,
                              setNames(as.data.frame(tri), paste0("j", seq_len(n) - 1L))),
                   f, row.names = FALSE, na = "")
  data.frame(name = basename(f), size = file.size(f), type = "text/csv", datapath = f,
             stringsAsFactors = FALSE)
}
tri10 <- round(ea$triangle_defaut(10) * 1.1, 2)
meme_tri <- function(x, y) identical(dim(x), dim(y)) && isTRUE(all.equal(x, y, tolerance = 0))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  g1 <- grille_html(output)
  session$setInputs(x_1 = 999)
  session$setInputs(reinit = 2)
  g2 <- grille_html(output)
  a("series deja par defaut, seconde reinitialisation : grille redessinee, valeur par defaut (#155 c)",
    identical(donnees(), ea$DONNEES_DEFAUT) && identical(version_grille(), 2L) &&
      !identical(g1, g2) && grepl('data-version="2"', g2, fixed = TRUE) && a_val(g2, "x_1", "104.2"))
  t0 <- triangle()
  session$setInputs(fichier_import = fichier(6)); session$setInputs(profondeur = 6)
  a("import d'une serie de 6 annees, puis T = 6 : triangle 8 x 8 garde (#155 a)",
    nrow(donnees()) == 6L && nrow(t0) == 8L && identical(triangle(), t0))
  g3 <- grille_html(output)
  session$setInputs(fichier_import = fichier(6))
  a("second import du meme fichier de series : grille redessinee (#155 c)",
    !identical(g3, grille_html(output)))
  session$setInputs(methode = "reserve2")
  a("passage en reserve no 2 apres l'import : triangle 8 x 8 garde (#155 a)",
    identical(triangle(), t0) && a_id(grille_html(output), "c_7_0") &&
      !a_id(grille_html(output), "c_8_0"))
  session$setInputs(profondeur = 5)
  a("reserve no 2, T = 5 : triangle 8 x 8 inchange, aucune troncature (#155 b)",
    identical(triangle(), t0))
  session$setInputs(profondeur = 12)
  a("reserve no 2, T = 12 : triangle 8 x 8 inchange, aucun prolongement (#155 b)",
    identical(triangle(), t0))
  session$setInputs(reinit = 3)
  a("Reinitialiser avec T = 12 : triangle par defaut 12 x 12, seul changement de dimension (#155)",
    identical(triangle(), ea$triangle_defaut(12)) && a_id(grille_html(output), "c_11_0"))
  g4 <- grille_html(output)
  session$setInputs(c_0_0 = 1)
  session$setInputs(reinit = 4)
  a("triangle deja par defaut, seconde reinitialisation : grille redessinee, valeur par defaut (#155 c)",
    identical(triangle(), ea$triangle_defaut(12)) && !identical(g4, grille_html(output)) &&
      a_val(grille_html(output), "c_0_0", "300"))
  session$setInputs(fichier_import = fichier_tri(tri10))
  a("import d'un triangle 10 x 10 avec T = 12 : dimension 10 gardee (#155)",
    meme_tri(triangle(), tri10) && a_id(grille_html(output), "c_9_0") &&
      !a_id(grille_html(output), "c_10_0"))
  session$setInputs(profondeur = 8)
  a("triangle importe 10 x 10, puis T = 8 : dimension gardee (#155 b)", meme_tri(triangle(), tri10))
})
# Demarrage sur un fichier de triangle 10 x 10, sans fichier de series
# (T_INIT = 8, jeu par defaut) : app.R est relu dans un dossier temporaire
# qui porte usp_donnees_MW.csv ; le depot n'est pas touche.
tmp <- tempfile("app155_"); dir.create(file.path(tmp, "R"), recursive = TRUE)
invisible(file.copy(c("app.R", "DESCRIPTION"), tmp))
invisible(file.copy(file.path("R", c("engine.R", "display_helpers.R")), file.path(tmp, "R")))
invisible(file.copy(fichier_tri(tri10)$datapath, file.path(tmp, "usp_donnees_MW.csv")))
ici <- setwd(tmp); eb <- new.env(); app_b <- source("app.R", local = eb)$value; setwd(ici)
testServer(app_b, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2", profondeur = eb$T_INIT)))
  a("demarrage : triangle 10 x 10 lu, T = 8 (series par defaut) : dimension gardee (#155 a)",
    identical(eb$T_INIT, 8L) && isTRUE(eb$CHARGE_MW$statut$ok) && meme_tri(triangle(), tri10) &&
      a_id(grille_html(output), "c_9_0"))
})
)---"
  # Objet rbind non fonction de l'environnement global (issue #199) : la
  # table des controles (output$tab_controles) est rendue dans deux sessions,
  # sans puis avec rbind <- 5 pose avant le calcul, sur la grille du jeu par
  # defaut renseignee (sans elle, R() reste vide et la table n'est pas rendue).
  # Mordant : avec do.call(rbind, ...), la seconde session leve "'what' must
  # be a function or character string" (mesure du 06/10/2026, shiny 1.8.0).
  .bloc_199 <- r"---(
## Objet rbind de l'environnement global (issue #199)
r199 <- new.env()
d199 <- ea$DONNEES_DEFAUT
saisie199 <- c(setNames(as.list(d199$xt), paste0("x_", seq_len(nrow(d199)))),
               setNames(as.list(d199$yt), paste0("y_", seq_len(nrow(d199)))))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r199$sans <- tryCatch(output$tab_controles, error = function(e) e)
})
assign("rbind", 5, envir = globalenv())
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r199$avec <- tryCatch(output$tab_controles, error = function(e) e)
})
rm(list = "rbind", envir = globalenv())
a("objet non fonction rbind global : table des controles identical a celle rendue sans lui (#199)",
  is.character(r199$sans) && grepl("<table", r199$sans, fixed = TRUE) &&
    identical(r199$avec, r199$sans))
)---"
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
    '  session$setInputs(vue_tests = "detail")',
    '  dt <- as.character(output$tests_par_hypothese$html)',
    '  a("vue Detail : commentaire long replie et colonne Fonction (#178)",',
    '    grepl("<details class=\'com\'><summary>", dt, fixed = TRUE) &&',
    '      grepl("<th>Fonction</th>", dt, fixed = TRUE) && grepl("<code>test_intercept</code>", dt, fixed = TRUE))',
    '  session$setInputs(vue_tests = "synth")',
    '  sy <- as.character(output$tests_par_hypothese$html)',
    '  a("vue Synthese : ni repli ni colonne Fonction (#178)",',
    '    !grepl("<details", sy, fixed = TRUE) && !grepl("<th>Fonction</th>", sy, fixed = TRUE))',
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
    '})',
    '## Apercu de validation apres un import de series (issue #183, constat 3)',
    '# Fichier CSV de n annees, au format de l\'import (colonnes t, xt, yt).',
    'fichier <- function(n) {',
    '  f <- tempfile(fileext = ".csv")',
    '  utils::write.csv(data.frame(t = seq_len(n), xt = round(100 * 1.03^seq_len(n), 2),',
    '                              yt = round(70 * 1.03^seq_len(n) + 5 * (-1)^seq_len(n), 2)),',
    '                   f, row.names = FALSE)',
    '  data.frame(name = basename(f), size = file.size(f), type = "text/csv", datapath = f,',
    '             stringsAsFactors = FALSE)',
    '}',
    '# Le navigateur rend la grille de n lignes apres l\'import : ses champs',
    '# x_i, y_i sont relus, sans evenement du champ T.',
    'grille <- function(session, n) { d <- read.csv(fichier(n)$datapath)',
    '  do.call(session$setInputs, c(setNames(as.list(d$xt), paste0("x_", seq_len(n))),',
    '                               setNames(as.list(d$yt), paste0("y_", seq_len(n))))) }',
    '# Rendu de l\'apercu ; condition si le rendu est annule (req(cancelOutput)).',
    'apercu <- function(output) tryCatch(as.character(output$validation_live$html),',
    '                                    error = function(e) e)',
    'garde <- function(avant, apres) inherits(apres, "shiny.output.cancel") || identical(apres, avant)',
    'base <- list(annexe = "II", segment = "1", sigma_manuel = FALSE, B = 99, alpha = 0.10,',
    '             seed = 20260831, delta_apriori = FALSE, theta_equiv = 0.10,',
    '             methode = "premium", nature_donnees = "brutes", profondeur = 8)',
    'testServer(app, {',
    '  do.call(session$setInputs, base)',
    '  av <- apercu(output)',
    '  session$setInputs(fichier_import = fichier(6)); grille(session, 6)',
    '  ap <- apercu(output)',
    '  a("import n = 6, T = 8 : garde posee a 6 (#183)", identical(profondeur_import(), 6L))',
    '  a("import n = 6, T = 8 : apercu non reevalue, rendu precedent garde (#183)",',
    '    garde(av, ap) && !grepl("superieure", paste(ap, collapse = ""), fixed = TRUE))',
    '  session$setInputs(profondeur = 6)',
    '  ap <- apercu(output)',
    '  a("import n = 6, puis T = 6 : garde levee, apercu reevalue sur 6 annees (#183)",',
    '    is.null(profondeur_import()) && is.character(ap) && grepl("T = 6 :", ap, fixed = TRUE) &&',
    '      !grepl("class=\\"err\\"", ap, fixed = TRUE))',
    '})',
    'testServer(app, {',
    '  do.call(session$setInputs, base)',
    '  av <- apercu(output)',
    '  session$setInputs(fichier_import = fichier(8)); grille(session, 8)',
    '  ap <- apercu(output)',
    '  a("import n = T = 8 : apercu reevalue sans evenement du champ T (#183)",',
    '    identical(profondeur_import(), 8L) && is.character(ap) && !identical(ap, av) &&',
    '      grepl("T = 8 :", ap, fixed = TRUE) && !grepl("class=\\"err\\"", ap, fixed = TRUE))',
    '})',
    'testServer(app, {',
    '  do.call(session$setInputs, base)',
    '  session$setInputs(fichier_import = fichier(4)); grille(session, 4)',
    '  ap <- apercu(output)',
    '  a("import n = 4 (hors [5 ; 40]) : garde non posee, apercu evalue avec T = 8 (#183)",',
    '    is.null(profondeur_import()) && is.character(ap) &&',
    '      grepl("Profondeur T = 8 superieure au nombre d\'annees fournies (4).", ap, fixed = TRUE))',
    '  session$setInputs(fichier_import = fichier(41)); grille(session, 41)',
    '  ap <- apercu(output)',
    '  a("import n = 41 (hors [5 ; 40]) : garde non posee, apercu evalue avec T = 8 (#183)",',
    '    is.null(profondeur_import()) && is.character(ap) &&',
    '      !grepl("superieure", ap, fixed = TRUE))',
    '})', .bloc_155, .bloc_199), .script)
  # Processus fils lance depuis la racine du depot : app.R y source
  # R/engine.R par chemin relatif. --vanilla ignore .Renviron et .Rprofile :
  # les bibliotheques de ce processus (.libPaths()) lui sont transmises par
  # R_LIBS, sans quoi un shiny installe dans une bibliotheque declaree par
  # .Renviron n'y est pas trouve (poste du mainteneur, R 4.3.3, PR #208).
  .ici <- setwd(.racine)
  .r_libs <- Sys.getenv("R_LIBS", unset = NA)
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
  .sortie <- tryCatch(suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                               c("--vanilla", shQuote(.script)),
                                               stdout = TRUE, stderr = TRUE)),
                      finally = {
                        if (is.na(.r_libs)) Sys.unsetenv("R_LIBS") else Sys.setenv(R_LIBS = .r_libs)
                        setwd(.ici)
                      })
  .lignes <- grep("^ASSERT\t", .sortie, value = TRUE)
  verifier("processus Shiny : 31 assertions rendues", length(.lignes) == 31L)
  if (length(.lignes) != 31L) cat(utils::tail(.sortie, 10), sep = "\n")
  for (.l in strsplit(.lignes, "\t", fixed = TRUE))
    verifier(paste("Application :", .l[2]), identical(.l[3], "TRUE"))
} else {
  cat("  note : shiny absent ; grille, journal, apercu, vue Detail, dimension du triangle et table des controles (#199) non exerces (attendu en CI, comme plotly, issue #53).\n")
}

fin_fichier()
