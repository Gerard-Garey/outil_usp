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
#   - regle des verdicts (issue #498) : avec shiny, les quatre phrases
#     d'engine_regle_verdicts() au alpha du resultat ouvrent le tableau des
#     tests (Synthese et Detail), absentes du tableau des controles ; colonne
#     Sens ; bloc Etat : alpha du resultat et signal d'un alpha du panneau
#     different, sans recalcul ;
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
#   - portee de PROFONDEUR_MAX, regle "T = donnees chargees" (issue #212,
#     decision du mainteneur du 14/10/2026) : refus_dimension_triangle() et
#     profondeur_apres_reinitialisation() hors Shiny ; avec shiny, import
#     d'un triangle 41 x 41 refuse avec motif (triangle courant garde),
#     charger_mw() refusant au demarrage un fichier de 41 annees,
#     triangle 40 x 40 accepte, reinitialisation des series ramenant le
#     champ T a 8 (T saisi 12 et 200), saisie T = 200 en reserve no 2
#     toujours plafonnee a 40 (non-regression de #194) ;
#   - objet non fonction rbind de l'environnement global (issue #199) : avec
#     shiny, table des controles (output$tab_controles) identique a celle
#     rendue sans lui ; rapport_html() : voir test_rapport_html.R ;
#   - notifications de refus (issue #226) : avec shiny, "Calcul refuse"
#     (scenario de l'issue, motif de plus de 700 caracteres) et "Calcul non
#     lance" (reserve no 2) notifient un texte fixe, le motif complet du
#     moteur etant dans le bandeau ;
#   - virgule decimale des nombres affiches (issue #236) : avec shiny, bloc
#     Etat, bloc du parametre retenu, journal, table de calibration, note
#     d'influence et notification du retrait d'une ligne ;
#   - granularite effective par ligne (issue #285) : la vue Detail passe
#     l'objet bootstrap a table_detail_groupe() ; avec shiny, colonne
#     "granularite MC" dans la vue Detail, absente de la vue Synthese ;
#   - limite de 40 annees des series (issue #286, option (a)) :
#     refus_dimension_series() et charger_ln() au demarrage (fichiers de 41
#     et 60 annees refuses, 40 charge) hors Shiny ; avec shiny, import de 60
#     annees refuse (series courantes et champ T gardes), import de 41 annees
#     refuse sans garde de l'apercu (#183 adapte), 40 annees acceptees ;
#   - plafond de six motifs leve (issue #287, option (a)) : aucun head() dans
#     le bandeau, l'apercu et le clic (lecture du code) ; avec shiny, sept
#     motifs dans le bandeau et l'apercu, notification "Calcul non lance"
#     des methodes lognormales au texte fixe ;
#   - option usp.graphiques_base (issue #295) : sortie_graphique() et
#     rendu_graphique() lisent .plotly_dispo() (lecture du code) ;
#     sortie_graphique() en base R sous l'option, plotly simule installe ;
#     avec shiny, rendu_graphique() en base R sous l'option ;
#   - personnalisation de l'onglet Tests et nouveau calcul (issue #380,
#     personnalisation gardee ligne par ligne) : cle_ligne_test(),
#     id_entree_test() et selection_reportee() hors Shiny ; avec shiny,
#     scenarios S0 (aucune case touchee), S1 (Pitman decochee en premium puis
#     reserve no 2, retour en premium) et S2 (relance de meme methode), les
#     trois boutons de selection (Tout retirer, Tout conserver, Retablir la
#     selection par defaut) et la personnalisation gardee a travers un calcul
#     refuse ;
#   - bandeau des avertissements de validation d'apres calcul (issue #412,
#     Q-46-4 (a)) : avec shiny, vide avant calcul ; sur tri_deg (reserve no 2),
#     entierement replie (<details class='com'> sans open), resume "4
#     avertissements de validation du calcul", textes du moteur tels quels ;
#     resume au singulier pour un seul avertissement ;
#   - lecture CSV en texte (issue #483, partie application, et #490 sur ce
#     chemin) : lire_tableau() rend des cellules non converties, lignes
#     vides et en-tetes vides gardes, "NA" en chaine ; ligne vide intercalee,
#     "0x10" et cellule "NA" d'un triangle refuses par le moteur avec le meme
#     motif qu'en xlsx ; fichiers d'exemple de tests/donnees lus a
#     l'identique ; demarrage refuse sur une ligne vide intercalee ; avec
#     shiny, memes refus a l'import (CSV et xlsx), series courantes gardees,
#     import valide inchange.
#   - lecture sans nom de ligne, avertissements du moteur restitues (issue
#     #518) : CSV dont une ligne compte plus de champs que l'en-tete refuse par
#     lire_tableau() (MESSAGE_ILLISIBLE$csv), colonne en surnombre nommee
#     ignoree par nom, aucune lecture de app.R sans row.names = NULL ;
#     avertissement des cellules sous la diagonale (#491) restitue au
#     demarrage (statut) et a l'import d'un triangle (statut, rendu,
#     notification warning), seul : champ avertissements_lecture du moteur,
#     jamais les avertissements calcules sans segment (credibilite, repere
#     I + 1 < 10), absents du statut ;
#   - exports des donnees relus au bit (issue #488) : export CSV par
#     engine_ecrire_csv() relu par lire_tableau() (grille, triangle a 17
#     chiffres) ; avec shiny, output$dl_donnees et output$dl_donnees_xlsx
#     (series et triangle) relus identical() a la saisie ;
#   - restitution unique des refus d'import et echec d'un export (issue
#     #556) : texte_refus_import(), NOTIFICATION_REFUS_IMPORT et
#     texte_echec_export() hors Shiny ; avec shiny, statut et notification
#     des refus illisible, de recevabilite (series, triangle), de dimension et
#     du lecteur, donnees courantes gardees ; echec d'un export (erreur
#     usp_refus_ecriture, erreur R ordinaire, erreur silencieuse de shiny) :
#     notification, journal, erreur relevee.
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
# Bloc Etat et journal d'execution (issue #240, Q-A4-12 (B)) : la ligne
# "P-values Monte-Carlo" est mise en forme par texte_p_mc_regime()
# (display_helpers.R), appelee deux fois dans app.R : une fois dans le rendu
# de output$etat, une fois dans celui de output$tab_meta.
.rendu <- function(nom) Filter(function(e) identical(e[[2]], call("$", as.name("output"), as.name(nom))),
                               .appels(parse(.app, keep.source = FALSE), "<-"))
.etat <- .rendu("etat"); .meta <- .rendu("tab_meta")
verifier("app.R : texte_p_mc_regime() appelee deux fois, une dans output$etat, une dans output$tab_meta (#240)",
         length(.appels(parse(.app, keep.source = FALSE), "texte_p_mc_regime")) == 2L &&
           length(.etat) == 1L && length(.appels(.etat[[1]], "texte_p_mc_regime")) == 1L &&
           length(.meta) == 1L && length(.appels(.meta[[1]], "texte_p_mc_regime")) == 1L)
.src_app <- readLines(.app, encoding = "UTF-8")
verifier("app.R : regles CSS du commentaire replie (details.com) (#178)",
         any(grepl("details.com > summary", .src_app, fixed = TRUE)) &&
           any(grepl("details.com:not([open]) > summary::after", .src_app, fixed = TRUE)))
verifier("app.R : bandeau des avertissements, titre en gras et sans repere [...] de troncature (#412)",
         any(grepl(".avert details.com > summary { font-weight:700; }", .src_app, fixed = TRUE)) &&
           any(grepl(".avert details.com:not([open]) > summary::after { content:none; }", .src_app, fixed = TRUE)))

verifier("app.R : impression des graphiques plotly (script beforeprint / afterprint, data-impression, regles @media print) et titre de carte jamais isole (#566)",
         any(grepl("addEventListener('beforeprint'", .src_app, fixed = TRUE)) &&
           any(grepl("addEventListener('afterprint'", .src_app, fixed = TRUE)) &&
           any(grepl("setAttribute('data-impression'", .src_app, fixed = TRUE)) &&
           any(grepl(".js-plotly-plot[data-impression] .svg-container", .src_app, fixed = TRUE)) &&
           any(grepl(".js-plotly-plot[data-impression] svg.main-svg", .src_app, fixed = TRUE)) &&
           any(grepl(".bloc > h4 { break-after:avoid; }", .src_app, fixed = TRUE)) &&
           any(grepl(".bloc > h4 + .row { break-inside:avoid; }", .src_app, fixed = TRUE)) &&
           any(grepl("/px$/.test(c.style.width)", .src_app, fixed = TRUE)))

## --- Dimension du triangle et reinitialisation (issue #155) --------------------
# Fonctions de premier niveau d'app.R, evaluees seules comme triangle_defaut().
.noms_155 <- c("DONNEES_DEFAUT", "profondeur_reinitialisation", "jeu_reinitialise",
               "message_reinitialisation", "refus_dimension_triangle", "refus_dimension",
               "profondeur_apres_reinitialisation")
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
# Assertion modifiee par #212 (regle "T = donnees chargees") : le message
# des series nommait seulement la reinitialisation ; il nomme desormais les
# 8 annees chargees et T = 8, valeur reportee dans le champ T.
verifier("message_reinitialisation() : dimension du triangle (reserve no 2) (#155), annees des series et T (#212)",
         identical(.env$message_reinitialisation(TRUE, 10),
                   "Donnees reinitialisees : triangle par defaut 10 x 10.") &&
           identical(.env$message_reinitialisation(FALSE, 8),
                     "Donnees reinitialisees : series par defaut de 8 annees, T = 8."))

## --- Portee de PROFONDEUR_MAX : regle "T = donnees chargees" (issue #212) ----
verifier("refus_dimension_triangle() : triangle de 5, 8, 40 annees dans la borne, sans motif (#212)",
         all(vapply(list(5L, 8L, 40L), function(n)
           identical(.env$refus_dimension_triangle(n), character(0)), logical(1))))
verifier("refus_dimension_triangle() : 41 et 100 annees refusees, motif qui nomme la dimension et la limite de l'application (#212)",
         identical(.env$refus_dimension_triangle(41L),
                   "Triangle 41 x 41 : au-dela de la limite de l'application (40 annees d'accident, rendu de la grille).") &&
           identical(.env$refus_dimension_triangle(100L),
                     "Triangle 100 x 100 : au-dela de la limite de l'application (40 annees d'accident, rendu de la grille)."))
# Demarrage sur un fichier de triangle de 41 annees (issue #212, M2 de la
# revue) : charger_mw() est evaluee avec ses dependances d'app.R, FICHIER_MW
# pointant vers un fichier ecrit dans un repertoire temporaire (le depot
# n'est pas touche). Les fonctions du moteur sont lues dans l'environnement
# global.
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% c("statut_fichier", "REFUS_DEMARRAGE", "triangle_vide",
                                   "MESSAGE_ILLISIBLE", "lire_tableau", "journaliser",
                                   "charger_mw")) eval(.x, .env)
.dir212 <- tempfile("demarrage212_"); dir.create(.dir212)
.tri41 <- .env$triangle_defaut(41)
utils::write.csv(data.frame(i = 0:40, setNames(as.data.frame(.tri41), paste0("j", 0:40))),
                 file.path(.dir212, "usp_donnees_MW.csv"), row.names = FALSE, na = "")
.env$FICHIER_MW <- file.path(.dir212, "usp_donnees_MW.csv")
.cm <- .env$charger_mw()
verifier("charger_mw(), fichier de 41 annees au demarrage : refuse avec le motif de refus_dimension_triangle(), grille vide 8 x 8 (#212)",
         identical(.cm$statut$ok, FALSE) &&
           grepl(.env$refus_dimension_triangle(41L), .cm$statut$msg, fixed = TRUE) &&
           grepl("present mais refuse au demarrage", .cm$statut$msg, fixed = TRUE) &&
           identical(.cm$valeur, .env$triangle_vide(8)))
utils::write.csv(data.frame(i = 0:39, setNames(as.data.frame(.env$triangle_defaut(40)), paste0("j", 0:39))),
                 file.path(.dir212, "usp_donnees_MW.csv"), row.names = FALSE, na = "")
.cm <- .env$charger_mw()
verifier("charger_mw(), fichier de 40 annees au demarrage : charge (#212)",
         isTRUE(.cm$statut$ok) && identical(dim(.cm$valeur), c(40L, 40L)))
unlink(.dir212, recursive = TRUE); rm("FICHIER_MW", envir = .env)

## --- Limite de 40 annees des series (issue #286, option (a)) ---------------
# Meme regle que le triangle (#212) : refus motive au-dela de PROFONDEUR_MAX,
# a l'import (bloc Shiny ci-dessous) comme au demarrage (charger_ln()).
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% c("refus_dimension_series", "refus_dimension", "grille_vide_ln", "charger_ln"))
    eval(.x, .env)
verifier("refus_dimension() : aide commune des deux refus, motif compose de l'objet et de la limite, character(0) dans la borne (revue finale de R16)",
         identical(.env$refus_dimension(40L, 40L, "X", "y"), character(0)) &&
           identical(.env$refus_dimension(41, 40L, "X", "annees y"),
                     "X : au-dela de la limite de l'application (40 annees y)."))
verifier("profondeur_apres_reinitialisation() : series, T retenu = 8 pour T saisi 4, 41, 100 et NA (appelant de profondeur_attendue_import(), garde n > T_max defensive)",
         all(vapply(list(4, 41, 100, NA), function(t)
           identical(as.numeric(.env$profondeur_apres_reinitialisation(FALSE, t)$T), 8), logical(1))))
verifier("refus_dimension_series() : series de 5, 8, 40 annees dans la borne, sans motif (#286)",
         all(vapply(list(5L, 8L, 40L), function(n)
           identical(.env$refus_dimension_series(n), character(0)), logical(1))))
verifier("refus_dimension_series() : 41 et 60 annees refusees, motif qui nomme la dimension et la limite (#286)",
         identical(.env$refus_dimension_series(41L),
                   "Series de 41 annees : au-dela de la limite de l'application (40 annees, borne du champ Profondeur T).") &&
           identical(.env$refus_dimension_series(60L),
                     "Series de 60 annees : au-dela de la limite de l'application (40 annees, borne du champ Profondeur T)."))
# Demarrage sur un fichier de series de n annees, comme pour le triangle :
# FICHIER_LN pointe vers un fichier ecrit dans un repertoire temporaire.
.dir286 <- tempfile("demarrage286_"); dir.create(.dir286)
.ecrire_ln <- function(n) utils::write.csv(
  data.frame(t = seq_len(n), xt = round(100 * 1.03^seq_len(n), 2),
             yt = round(70 * 1.03^seq_len(n) + 5 * (-1)^seq_len(n), 2)),
  file.path(.dir286, "usp_donnees_LN.csv"), row.names = FALSE)
.env$FICHIER_LN <- file.path(.dir286, "usp_donnees_LN.csv")
.cl <- lapply(c(41L, 60L), function(n) { .ecrire_ln(n); .env$charger_ln() })
verifier("charger_ln(), fichiers de 41 et 60 annees au demarrage : refuses avec le motif de refus_dimension_series(), grille vide de 8 annees (#286)",
         all(vapply(seq_along(.cl), function(k) {
           cl <- .cl[[k]]; n <- c(41L, 60L)[k]
           identical(cl$statut$ok, FALSE) &&
             grepl(.env$refus_dimension_series(n), cl$statut$msg, fixed = TRUE) &&
             grepl("present mais refuse au demarrage", cl$statut$msg, fixed = TRUE) &&
             identical(cl$valeur, .env$grille_vide_ln(8L))
         }, logical(1))))
.ecrire_ln(40L); .cl <- .env$charger_ln()
verifier("charger_ln(), fichier de 40 annees au demarrage : charge (#286)",
         isTRUE(.cl$statut$ok) && nrow(.cl$valeur) == 40L)
unlink(.dir286, recursive = TRUE); rm("FICHIER_LN", envir = .env)

## --- Lecture CSV en texte, interpretation par le moteur (issue #483, #490) ---
# lire_tableau() lit le CSV en texte (colClasses = "character",
# blank.lines.skip = FALSE, check.names = FALSE, na.strings = character(0)) ;
# nombres, lignes et colonnes vides sont juges par engine_lire_donnees_csv()
# et engine_lire_triangle() seuls, avec le meme motif qu'en xlsx. Avant
# #483 (mesure du 08/11/2026, branche K1, e3b18e7) : ligne vide intercalee
# retiree par read.csv (ok TRUE, 8 annees sur 9), "0x10" lu 16 par
# type.convert() (ok TRUE), cellule "NA" d'un triangle lue comme vide.
.csv483 <- function(lignes) { f <- tempfile(fileext = ".csv"); writeLines(lignes, f); f }
.lire483 <- function(lignes) {
  f <- .csv483(lignes); on.exit(unlink(f))
  .env$lire_tableau(f, FALSE)$df
}
# Meme tableau en xlsx (ecrivain du moteur), lu par lire_tableau() :
# NULL si aucun ecrivain xlsx n'est disponible (ni paquet zip ni commande
# zip ; openxlsx n'ecrit plus depuis #488).
.xlsx483 <- function(d) {
  if (!requireNamespace("zip", quietly = TRUE) && !nzchar(Sys.which("zip"))) return(NULL)
  f <- tempfile(fileext = ".xlsx"); on.exit(unlink(f))
  engine_ecrire_xlsx(d, f)
  .env$lire_tableau(f, TRUE)$df
}
.ser483 <- c("xt,yt", paste(100:102, 60:62, sep = ","), "", paste(103:107, 63:67, sep = ","))
.d483 <- .lire483(c("xt,yt,", "100,60,", "NA,0x10,", ",,"))
verifier("lire_tableau() : CSV lu en texte, cellules non converties, ligne vide gardee, en-tete vide \"\", cellule \"NA\" gardee en chaine (#483)",
         identical(names(.d483), c("xt", "yt", "")) &&
           all(vapply(.d483, is.character, logical(1))) && nrow(.d483) == 3L &&
           identical(.d483$xt, c("100", "NA", "")) && identical(.d483$yt, c("60", "0x10", "")))
.r483 <- engine_lire_donnees_csv(.lire483(.ser483))
.x483 <- .xlsx483(data.frame(xt = c(100:102, NA, 103:107), yt = c(60:62, NA, 63:67)))
verifier("Import CSV de series sans t a ligne vide intercalee : refuse par le moteur (ligne de donnees 4), meme motif que le xlsx (#483)",
         !.r483$ok && identical(.r483$erreurs, engine_lire_donnees_csv(
           data.frame(xt = c(100:102, NA, 103:107), yt = c(60:62, NA, 63:67)))$erreurs) &&
           grepl("Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees 4)", .r483$erreurs, fixed = TRUE) &&
           (is.null(.x483) || identical(engine_lire_donnees_csv(.x483)$erreurs, .r483$erreurs)))
.r490 <- engine_lire_donnees_csv(.lire483(c("xt,yt", "100,60", "0x10,61", paste(102:104, 62:64, sep = ","))))
.x490 <- .xlsx483(data.frame(xt = c("100", "0x10", "102", "103", "104"), yt = 60:64,
                             stringsAsFactors = FALSE))
verifier("Import CSV : \"0x10\" refuse comme valeur non numerique avec sa position, meme motif que le xlsx (#490)",
         !.r490$ok && identical(.r490$erreurs,
                                "Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).") &&
           (is.null(.x490) || identical(engine_lire_donnees_csv(.x490)$erreurs, .r490$erreurs)))
.tri483 <- c("i,j0,j1,j2,j3,j4", "0,300,960,1560,2020,2290", "1,310,980,1590,NA,",
             "2,320,1000,1600,,", "3,330,1010,,,", "4,340,,,,")
.rt483 <- engine_lire_triangle(.lire483(.tri483))
verifier("Import CSV : cellule \"NA\" d'un triangle refusee avec sa position, comme en xlsx (na.strings = character(0)) (#483)",
         !.rt483$ok && length(.rt483$erreurs) == 1L &&
           identical(.rt483$erreurs, paste("Cellule(s) non numerique(s) en (i = 1, j = 3) (i : annee d'accident, j : annee de developpement).",
                                           "Une cellule \"NA\" est lue comme du texte : renseigner la valeur,",
                                           "ou laisser vide une cellule non observee.")))
# CSV dont la ligne 1 ne porte que des separateurs (#522, extension aux CSV
# du 12/11/2026) : lu par lire_tableau() sans erreur (en-tetes ""), refuse
# par le moteur au texte du classeur, series et triangle ; une ligne 1
# physiquement vide reste refusee avant lecture (MESSAGE_ILLISIBLE$csv).
.l1_522 <- .lire483(c(",,", "t,xt,yt", paste(1:5, 10:14, 2:6, sep = ",")))
.l1t_522 <- .lire483(c(",,,,,", .tri483))
.f1v_522 <- .csv483(c("", "t,xt,yt", "1,2,3")); .l1v_522 <- suppressMessages(.env$lire_tableau(.f1v_522, FALSE)); unlink(.f1v_522)
verifier("Import CSV : ligne 1 \",,,\" au-dessus de l'en-tete refusee par le moteur au texte du classeur (series et triangle) ; ligne 1 vide : MESSAGE_ILLISIBLE$csv avant lecture (#522)",
         identical(names(.l1_522), c("", "", "")) &&
           identical(engine_lire_donnees_csv(.l1_522)$erreurs, MOTIF_LIGNE1_VIDE) &&
           identical(engine_lire_triangle(.l1t_522)$erreurs, MOTIF_LIGNE1_VIDE) &&
           is.null(.l1v_522$df) && identical(.l1v_522$erreur, .env$MESSAGE_ILLISIBLE[["csv"]]))
# Lecture des fichiers d'exemple avant #483 : read.csv par defaut, comme
# lire_tableau() (row.names = NULL a toute lecture depuis #518).
.ex483 <- file.path(.racine, "tests", "donnees", c("donnees_ln.csv", "donnees_ln_interieur.csv", "triangle_mw.csv"))
verifier("Fichiers d'exemple (tests/donnees) : series et triangle lus par lire_tableau() identiques a la lecture d'avant #483",
         identical(engine_lire_donnees_csv(.env$lire_tableau(.ex483[1], FALSE)$df),
                   engine_lire_donnees_csv(utils::read.csv(.ex483[1], stringsAsFactors = FALSE))) &&
           identical(engine_lire_donnees_csv(.env$lire_tableau(.ex483[2], FALSE)$df),
                     engine_lire_donnees_csv(utils::read.csv(.ex483[2], stringsAsFactors = FALSE))) &&
           identical(engine_lire_triangle(.env$lire_tableau(.ex483[3], FALSE)$df),
                     engine_lire_triangle(utils::read.csv(.ex483[3], stringsAsFactors = FALSE,
                                                          row.names = NULL))) &&
           isTRUE(engine_lire_triangle(.env$lire_tableau(.ex483[3], FALSE)$df)$ok))
verifier("Import CSV : colonne de fin sans en-tete (virgule finale) retiree, series et triangle identiques (#483)",
         identical(engine_lire_donnees_csv(.lire483(paste0(.ser483[-5], ","))),
                   engine_lire_donnees_csv(.lire483(.ser483[-5]))) &&
           identical(engine_lire_triangle(.lire483(paste0(sub("NA", "2050", .tri483), ","))),
                     engine_lire_triangle(.lire483(sub("NA", "2050", .tri483)))) &&
           isTRUE(engine_lire_triangle(.lire483(sub("NA", "2050", .tri483)))$ok))
# Demarrage : charger_ln() et charger_mw() lisent par lire_tableau() ; un
# fichier a ligne vide intercalee est refuse avec le motif du moteur.
.dir483 <- tempfile("demarrage483_"); dir.create(.dir483)
.env$FICHIER_LN <- file.path(.dir483, "usp_donnees_LN.csv"); writeLines(.ser483, .env$FICHIER_LN)
.env$FICHIER_MW <- file.path(.dir483, "usp_donnees_MW.csv")
writeLines(append(sub("NA", "2050", .tri483), "", after = 3), .env$FICHIER_MW)
.cl483 <- .env$charger_ln(); .cm483 <- .env$charger_mw()
verifier("Demarrage : fichiers CSV de series et de triangle a ligne vide intercalee refuses avec le motif du moteur, grilles vides (#483)",
         identical(.cl483$statut$ok, FALSE) && grepl(.r483$erreurs, .cl483$statut$msg, fixed = TRUE) &&
           identical(.cl483$valeur, .env$grille_vide_ln(8L)) &&
           identical(.cm483$statut$ok, FALSE) &&
           grepl("Ligne(s) vide(s) intercalee(s) dans le triangle (ligne(s) de donnees 3)", .cm483$statut$msg,
                 fixed = TRUE) && identical(.cm483$valeur, .env$triangle_vide(8)))
unlink(.dir483, recursive = TRUE); rm("FICHIER_LN", "FICHIER_MW", envir = .env)

## --- Lecture sans nom de ligne, avertissements restitues (issue #518) ---------
# Mesure avant correction (09/11/2026, branche K5, 3286ab6) : "xt,yt" avec
# lignes "annee,xt,yt" lu sans row.names = NULL, colonne d'annees prise pour
# des noms de lignes et ignoree sans message ; en-tete "j0,j1,j2" de trois
# champs sur des lignes de quatre dont la premiere colonne se repete :
# erreur "duplicate 'row.names' are not allowed".
.lire518 <- function(lignes) {
  f <- .csv483(lignes); on.exit(unlink(f))
  .env$lire_tableau(f, FALSE)
}
.ser518 <- c("xt,yt", paste(2015:2022, 100:107, 60:67, sep = ","))
.dup518 <- c("j0,j1,j2", "1,300,960,1560", "1,310,980,", "1,320,,")
.l518 <- suppressMessages(.lire518(.ser518)); .d518 <- suppressMessages(.lire518(.dup518))
.jr518 <- tryCatch(.lire518(.ser518), message = function(m) conditionMessage(m))
.nomme518 <- .lire518(c("xt,yt,annee", paste(100:107, 60:67, 2015:2022, sep = ",")))
.ref518 <- .lire518(c("xt,yt", paste(100:107, 60:67, sep = ",")))
.court518 <- .lire518(c("t,xt,yt", "1,100,60", "2,101"))
verifier("lire_tableau() : CSV dont les lignes comptent plus de champs que l'en-tete refuse (series et triangle), message fixe MESSAGE_ILLISIBLE$csv, motif precis au journal, aucun tableau (#518)",
         is.null(.l518$df) && identical(.l518$erreur, .env$MESSAGE_ILLISIBLE[["csv"]]) &&
           is.null(.d518$df) && identical(.d518$erreur, .env$MESSAGE_ILLISIBLE[["csv"]]) &&
           grepl("en-tete de 2 champ(s), ligne 2 du fichier de 3 champs", .jr518, fixed = TRUE))
verifier("lire_tableau() : colonne en surnombre NOMMEE (en-tete aussi long que les lignes) lue puis ignoree par nom par le moteur, series identiques a celles du fichier sans elle ; ligne plus courte que l'en-tete acceptee (#518)",
         is.null(.nomme518$erreur) && identical(names(.nomme518$df), c("xt", "yt", "annee")) &&
           isTRUE(engine_lire_donnees_csv(.nomme518$df)$ok) &&
           identical(engine_lire_donnees_csv(.nomme518$df), engine_lire_donnees_csv(.ref518$df)) &&
           is.null(.court518$erreur) && nrow(.court518$df) == 2L)
.lectures_app <- function(e) {
  if (is.call(e)) {
    f <- paste(deparse(e[[1]]), collapse = "")
    ici <- if (grepl("(^|::)(read\\.csv2?|read\\.table|read\\.delim2?)$", f)) list(e) else list()
    c(ici, unlist(lapply(as.list(e)[-1], .lectures_app), recursive = FALSE))
  } else if (is.expression(e) || is.list(e)) unlist(lapply(e, .lectures_app), recursive = FALSE)
  else list()
}
.lectures518 <- .lectures_app(parse(.app, keep.source = FALSE))
verifier("app.R : toute lecture de tableau (read.csv...) passe row.names = NULL, une seule lecture (lire_tableau) (#518)",
         length(.lectures518) == 1L && all(vapply(.lectures518, function(e) "row.names" %in% names(e) &&
                                                    is.null(e[["row.names"]]), logical(1))))
# Demarrage : triangle 8 x 8 a cellules renseignees sous la diagonale (#491).
# Le statut ne porte que engine_lire_triangle()$avertissements_lecture : les
# avertissements calcules sans segment (credibilite au bareme court par
# convention, repere I + 1 < 10) n'y figurent pas (N1 et N2 d'app-review :
# avant correction, "c = 81 %" au statut pour le segment II-1, quand l'apercu
# et le calcul donnent 59 %).
.dir518 <- tempfile("demarrage518_"); dir.create(.dir518)
.env$FICHIER_MW <- file.path(.dir518, "usp_donnees_MW.csv")
.t518 <- .env$triangle_defaut(8); .t518[row(.t518) + col(.t518) - 2L > 7L] <- 1000
utils::write.csv(data.frame(i = 0:7, setNames(as.data.frame(.t518), paste0("j", 0:7))),
                 .env$FICHIER_MW, row.names = FALSE, na = "")
.cm518 <- .env$charger_mw()
.lu518 <- engine_lire_triangle(.env$lire_tableau(.env$FICHIER_MW, FALSE)$df)
verifier("Demarrage : triangle 8 x 8 a cellules sous la diagonale charge, statut au seul avertissement de #491 (avertissements_lecture du moteur), tel quel, sans credibilite ni pourcentage (#518)",
         isTRUE(.cm518$statut$ok) && length(.cm518$statut$avertissements) == 1L &&
           identical(.cm518$statut$avertissements, .lu518$avertissements_lecture) &&
           grepl("sous la diagonale", .cm518$statut$avertissements, fixed = TRUE) &&
           length(.lu518$avertissements) > 1L &&
           !any(grepl("%|credibilite|bruites", c(.cm518$statut$msg, .cm518$statut$avertissements))))
invisible(file.copy(file.path(.racine, "tests", "donnees", "triangle_mw.csv"), .env$FICHIER_MW, overwrite = TRUE))
.cm518b <- .env$charger_mw()
.lu518b <- engine_lire_triangle(.env$lire_tableau(.env$FICHIER_MW, FALSE)$df)
verifier("Demarrage : tests/donnees/triangle_mw.csv (8 x 8, sans cellule sous la diagonale) charge, statut sans avertissement ni pourcentage de credibilite, quand le moteur en rend deux sans segment (#518)",
         isTRUE(.cm518b$statut$ok) && identical(.cm518b$statut$avertissements, character(0)) &&
           length(.lu518b$avertissements) == 2L &&
           !any(grepl("%|credibilite", .cm518b$statut$msg)))
unlink(.dir518, recursive = TRUE); rm("FICHIER_MW", envir = .env)
## --- Refus motive du lecteur xlsx restitue (issue #522) ---------------------
# Un refus de classe "usp_refus_lecture" (engine_lire_xlsx() : ligne 1 sans
# aucune valeur...) est rendu tel quel par lire_tableau(), journalise ; toute
# autre erreur garde MESSAGE_ILLISIBLE. Classeur ecrit par l'ecrivain du
# moteur, lignes descendues d'une ligne dans le XML, recompresse par le
# paquet zip s'il est installe, sinon par la commande zip (l'un ou l'autre
# requis, comme pour l'ecrivain depuis #488).
.zip522 <- requireNamespace("zip", quietly = TRUE)
if (.zip522 || nzchar(Sys.which("zip"))) {
  .ligne1_522 <- "Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete."
  .xlsx522 <- function(f) {
    engine_ecrire_xlsx(data.frame(xt = 100:107, yt = 60:67), f)
    x <- tempfile("x522_"); on.exit(unlink(x, recursive = TRUE), add = TRUE)
    utils::unzip(f, exdir = x)
    fs <- file.path(x, "xl", "worksheets", "sheet1.xml")
    s <- paste(readLines(fs, warn = FALSE), collapse = "")
    m <- gregexpr('<(row|c) r="[A-Z]*[0-9]+"', s)
    regmatches(s, m) <- lapply(regmatches(s, m), function(tk) vapply(tk, function(t)
      sub('[0-9]+"$', paste0(as.integer(sub('.*[^0-9]([0-9]+)"$', "\\1", t)) + 1L, '"'), t), "", USE.NAMES = FALSE))
    writeLines(s, fs, useBytes = TRUE)
    unlink(f); od <- setwd(x); on.exit(setwd(od), add = TRUE, after = FALSE)
    if (.zip522) zip::zipr(f, list.files(".", all.files = TRUE, no.. = TRUE), include_directories = FALSE)
    else utils::zip(f, list.files(".", all.files = TRUE, no.. = TRUE), flags = "-r9Xq")
    f
  }
  .f522 <- .xlsx522(tempfile(fileext = ".xlsx"))
  .jr522 <- character(0)
  .l522 <- withCallingHandlers(.env$lire_tableau(.f522, TRUE),
                               message = function(m) { .jr522 <<- c(.jr522, conditionMessage(m)); invokeRestart("muffleMessage") })
  .faux522 <- tempfile(fileext = ".xlsx"); writeLines("pas un classeur", .faux522)
  .g522 <- suppressMessages(.env$lire_tableau(.faux522, TRUE))
  verifier("lire_tableau() : refus motive du moteur (ligne 1 sans aucune valeur, classe usp_refus_lecture) rendu tel quel, refus_moteur TRUE, journalise ; autre erreur : MESSAGE_ILLISIBLE$xlsx, refus_moteur FALSE (#522)",
           is.null(.l522$df) && identical(.l522$erreur, .ligne1_522) && isTRUE(.l522$refus_moteur) &&
             any(grepl(.ligne1_522, .jr522, fixed = TRUE)) &&
             is.null(.g522$df) && identical(.g522$erreur, .env$MESSAGE_ILLISIBLE[["xlsx"]]) &&
             identical(.g522$refus_moteur, FALSE))
  # Demarrage : usp_donnees_LN.xlsx (prioritaire sur le CSV) a ligne 1 vide
  .dir522 <- tempfile("demarrage522_"); dir.create(.dir522)
  .env$FICHIER_LN <- file.path(.dir522, "usp_donnees_LN.csv")
  invisible(file.copy(.f522, file.path(.dir522, "usp_donnees_LN.xlsx")))
  .cl522 <- suppressMessages(.env$charger_ln())
  verifier("Demarrage : classeur de series a ligne 1 vide refuse, statut \"present mais refuse au demarrage : <texte du moteur> <REFUS_DEMARRAGE>\" (#522)",
           identical(.cl522$statut$ok, FALSE) &&
             grepl(paste("present mais refuse au demarrage :", .ligne1_522, .env$REFUS_DEMARRAGE),
                   .cl522$statut$msg, fixed = TRUE) &&
             identical(.cl522$valeur, .env$grille_vide_ln(8L)))
  unlink(c(.f522, .faux522)); unlink(.dir522, recursive = TRUE); rm("FICHIER_LN", envir = .env)
} else cat("  [saute] refus motive du lecteur xlsx (#522) : ni paquet zip ni commande zip\n")
## --- Restitution unique des refus d'import, echec d'export (issue #556) -----
# Textes et mises en forme evalues hors Shiny (definitions de app.R seules) ;
# le comportement des observateurs et des exports est dans le processus Shiny
# (bloc de #556).
.env556 <- new.env()
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% c("texte_refus_import", "NOTIFICATION_REFUS_IMPORT",
                                   "texte_echec_export", "MESSAGE_ILLISIBLE")) eval(.x, .env556)
verifier("texte_refus_import() : \"Import du fichier <nom> (<EXT>) refuse ; donnees courantes conservees. Motif : <motifs>\", motifs joints par une espace, extension en majuscules (#556)",
         identical(.env556$texte_refus_import("a.xlsx", "xlsx", c("m1.", "m2.")),
                   "Import du fichier a.xlsx (XLSX) refuse ; donnees courantes conservees. Motif : m1. m2.") &&
           identical(.env556$texte_refus_import("b.csv", "csv", .env556$MESSAGE_ILLISIBLE[["csv"]]),
                     paste("Import du fichier b.csv (CSV) refuse ; donnees courantes conservees. Motif :",
                           .env556$MESSAGE_ILLISIBLE[["csv"]])) &&
           startsWith(.env556$MESSAGE_ILLISIBLE[["xlsx"]], "illisible comme "))
verifier("NOTIFICATION_REFUS_IMPORT : texte unique, voir le statut d'import (#556)",
         identical(.env556$NOTIFICATION_REFUS_IMPORT,
                   "Import refuse ; donnees courantes conservees : voir le statut d'import."))
.refus_ecr556 <- structure(class = c("usp_refus_ecriture", "error", "condition"),
                           list(message = "Ecriture du fichier .xlsx impossible : cause de test.", call = NULL))
.brute556 <- simpleError("impossible d'ouvrir le fichier '/tmp/x/usp_tests.csv' : Permission denied")
verifier("texte_echec_export() : usp_refus_ecriture -> \"Export impossible : <texte du moteur>\" ; toute autre erreur -> texte fixe sans la cause R (#556)",
         identical(.env556$texte_echec_export(.refus_ecr556),
                   "Export impossible : Ecriture du fichier .xlsx impossible : cause de test.") &&
           identical(.env556$texte_echec_export(.brute556),
                     "Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).") &&
           !grepl("Permission|usp_tests", .env556$texte_echec_export(.brute556)))
# Lecture du code : aucun ancien texte de refus, un seul showNotification de
# refus d'import (refuser_import()), cinq exports passes par proteger_export().
verifier("app.R : anciens textes de refus d'import retires, une seule notification de refus, les cinq downloadHandler passent par proteger_export() (#556)",
         {
           src <- paste(readLines(.app, warn = FALSE), collapse = "\n")
           n <- function(motif) lengths(regmatches(src, gregexpr(motif, src, fixed = TRUE)))
           n('"Import refuse.') == 0L && n("fichier illisible.") == 0L &&
             n("Import refuse, ") == 0L && n("showNotification(NOTIFICATION_REFUS_IMPORT") == 1L &&
             n("downloadHandler(") == 5L && n("content = proteger_export(") == 5L
         })
.pa <- lapply(list(NULL, NA_real_, 0, 5, 12, 40, 200), function(t)
  .env$profondeur_apres_reinitialisation(FALSE, t))
verifier("profondeur_apres_reinitialisation() (series) : T = 8 des series par defaut, quel que soit le T saisi, sans motif ni plafonnement (#212)",
         all(vapply(.pa, function(r) identical(r$T, 8L) && length(r$erreurs) == 0L &&
                      length(r$plafonnement) == 0L, logical(1))))
verifier("profondeur_apres_reinitialisation() (reserve no 2) : identique a profondeur_reinitialisation() (#194, #212)",
         all(vapply(list(NULL, NA_real_, 0, 5, 12, 40, 200), function(t)
           identical(.env$profondeur_apres_reinitialisation(TRUE, t),
                     .env$profondeur_reinitialisation(t)), logical(1))))
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
# Revue finale de #212 : un seul appel de updateNumericInput() dans
# l'observateur de "Reinitialiser" (trois auparavant, pour la meme valeur T),
# et la garde de l'apercu y est posee comme a l'import.
verifier("app.R : \"Reinitialiser\" n'appelle updateNumericInput() qu'une fois et pose la garde profondeur_import() (#212, #183)",
         length(.appels(.obs_R[[1]], "updateNumericInput")) == 1L &&
           .ecrit(.obs_R[[1]], "profondeur_import"))

## --- Plafond de six motifs leve, notification au texte fixe (issue #287) ----
# Lecture du code : aucun appel a head() dans conserver() (bandeau du refus
# du moteur), dans le rendu de l'apercu (output$validation_live) ni dans
# l'observateur du clic ; aucune notification du clic ne recopie les motifs.
.fn_conserver <- Filter(function(e) identical(e[[2]], as.name("conserver")),
                        .appels(parse(.app, keep.source = FALSE), "<-"))
.obs_go <- Filter(function(o) .sur(o, "go"), .obs)
.apercu <- .rendu("validation_live")
# head() ou utils::head() : recherche dans le texte deparse (le nom
# qualifie utils::head est en tete d'appel, hors des arguments que parcourt
# .appels()).
.heads <- function(e) grepl("\\bhead\\(", paste(deparse(e), collapse = " "))
verifier("app.R : aucun head() dans conserver(), l'apercu et le clic (plafond de six motifs leve, #287)",
         length(.fn_conserver) == 1L && length(.obs_go) == 1L && length(.apercu) == 1L &&
           !.heads(.fn_conserver[[1]]) && !.heads(.obs_go[[1]]) && !.heads(.apercu[[1]]) &&
           .heads(quote(utils::head(v$erreurs, 6))))
# Suite de #287 (revue finale de R16) : plafonds leves aussi au demarrage du
# triangle (charger_mw(), six motifs) et a l'import d'un triangle (trois
# motifs) ; aucun head() ni utils::head() dans app.R hors tags$head.
.src_heads <- grep("(^|[^$[:alnum:]_.])head\\(", readLines(.app, encoding = "UTF-8"), value = TRUE)
.fn_charger_mw <- Filter(function(e) identical(e[[2]], as.name("charger_mw")),
                         .appels(parse(.app, keep.source = FALSE), "<-"))
verifier("app.R : aucun head() dans charger_mw() ni ailleurs dans app.R (plafonds du demarrage et de l'import du triangle leves, #287)",
         length(.fn_charger_mw) == 1L && !.heads(.fn_charger_mw[[1]]) && length(.src_heads) == 0L)
.notifs_go <- .appels(.obs_go[[1]], "showNotification")
verifier("app.R : notifications du clic \"Calcul non lance\" au texte fixe, aucune ne recopie les motifs (#287, #226)",
         sum(vapply(.notifs_go, function(n) identical(n[[2]],
           "Calcul non lance : aucun resultat n'est produit (voir le bandeau)."), logical(1))) == 2L &&
           !any(vapply(.notifs_go, function(n) is.call(n[[2]]), logical(1))))

## --- Granularite effective par ligne (issue #285) ----------------------------
verifier("app.R : la vue Detail passe l'objet bootstrap du resultat a table_detail_groupe() (#285)",
         length(.tdg) == 1L && identical(.tdg[[1]]$boot,
                                         call("$", call("R"), as.name("bootstrap"))))

## --- Option usp.graphiques_base (issue #295) ---------------------------------
# Lecture du code : sortie_graphique() et rendu_graphique() choisissent le
# moteur graphique par .plotly_dispo() (display_helpers.R), comme les plot_*(),
# et plus par requireNamespace("plotly").
.fn_graph <- Filter(function(e) as.character(e[[2]]) %in% c("sortie_graphique", "rendu_graphique"),
                    Filter(function(x) is.call(x) && identical(x[[1]], as.name("<-")),
                           as.list(parse(.app, keep.source = FALSE))))
verifier("app.R : sortie_graphique() et rendu_graphique() lisent .plotly_dispo(), sans requireNamespace() (#295)",
         length(.fn_graph) == 2L &&
           all(vapply(.fn_graph, function(e) length(.appels(e, ".plotly_dispo")) == 1L &&
                        !length(.appels(e, "requireNamespace")), logical(1))))
# Comportement, sans shiny ni plotly : display_helpers.R est charge dans un
# environnement ou requireNamespace() repond TRUE (plotly simule installe)
# et plotOutput() est remplace par un releve ; sous l'option, la sortie est
# celle de base R. Avant #295, la branche plotly etait prise
# (plotly::plotlyOutput()).
.env295 <- new.env()
sys.source(file.path(.racine, "R", "display_helpers.R"), envir = .env295)
for (.x in .fn_graph) if (identical(as.character(.x[[2]]), "sortie_graphique")) eval(.x, .env295)
.env295$requireNamespace <- function(package, ...) TRUE
.env295$plotOutput <- function(id, height) c(base = id)
.op295 <- options(usp.graphiques_base = TRUE)
.so295 <- tryCatch(.env295$sortie_graphique("p"), error = function(e) e)
options(.op295)
verifier("sortie_graphique() : option usp.graphiques_base posee, plotly simule installe -> plotOutput (#295)",
         identical(.so295, c(base = "p")))

## --- Cle de ligne et report de la selection (issue #380) ------------------------
.dh380 <- new.env()
sys.source(file.path(.racine, "R", "display_helpers.R"), envir = .dh380)
# Table minimale au format de engine_table_tests() (famille, test, base,
# variante) : trois lignes, dont un test decline en deux bases.
.tb380 <- data.frame(famille = c("M1. a", "M1. a", "M2. b"),
                     test = c("T1", "T2", "T1"), base = c("commun", "z", "r"),
                     variante = c("principale", "principale", "secondaire"),
                     stringsAsFactors = FALSE)
verifier("cle_ligne_test() : famille, test et base concatenes, une cle par ligne (#380)",
         identical(.dh380$cle_ligne_test(.tb380),
                   c("M1. a | T1 | commun", "M1. a | T2 | z", "M2. b | T1 | r")))
.id380 <- .dh380$id_entree_test("g_test", .dh380$cle_ligne_test(.tb380), 3L)
verifier("id_entree_test() : prefixe et numero du calcul, reste [0-9a-z_], injectif, accents compris (#380)",
         all(grepl("^g_test_3_[0-9a-f]+$", .id380)) && !anyDuplicated(.id380) &&
           !identical(.dh380$id_entree_test("g_test", "a", 3L), .dh380$id_entree_test("g_test", "a", 4L)) &&
           grepl("^b_test_1_[0-9a-f]+$", .dh380$id_entree_test("b_test", "\u00e9t\u00e9 | x", 1L)))
# Largeur fixe : avec "%x", "\u03b45" et ";\u0435" donnaient tous deux 3b435 (mesure
# du 28/10/2026) ; avec "%06x", six chiffres par caractere.
.col380 <- .dh380$id_entree_test("g_test", c("\u03b45", ";\u0435"), 1L)
verifier("id_entree_test() : codes de largeurs differentes accoles sans collision ('\u03b45' et ';\u0435'), six chiffres hexadecimaux par caractere (#380)",
         !anyDuplicated(.col380) &&
           identical(.col380, c("g_test_1_0003b4000035", "g_test_1_00003b000435")))
.s380 <- .dh380$selection_defaut(.tb380); .s380$garde[1] <- FALSE; .s380$base[2] <- "r"
.tb380b <- rbind(.tb380[c(2, 3), ], data.frame(famille = "M9. n", test = "T9", base = "commun",
                                                variante = "principale", stringsAsFactors = FALSE))
.r380 <- .dh380$selection_reportee(.s380, .tb380b)
verifier("selection_reportee() : ligne qui subsiste gardee, ligne nouvelle au defaut, ligne disparue ignoree (#380)",
         identical(.r380$cle, .dh380$cle_ligne_test(.tb380b)) && identical(.r380$garde, c(TRUE, FALSE, TRUE)) &&
           identical(.r380$base, c("r", "z", "commun")) && is.null(.dh380$selection_reportee(NULL, .tb380b)))
verifier("selection_defaut() : cle = cle_ligne_test(), alignement lu par rapport_html() (#380)",
         identical(.dh380$selection_defaut(.tb380)$cle, .dh380$cle_ligne_test(.tb380)))

## --- Export CSV des donnees relu par lire_tableau() (issue #488) --------------
# L'export CSV des donnees (output$dl_donnees) passe par engine_ecrire_csv() ;
# relu par lire_tableau() d'app.R (journaliser() neutralise), puis par
# engine_lire_donnees_csv() / engine_lire_triangle() comme a l'import.
.env488 <- new.env(); .env488$journaliser <- function(...) invisible(NULL)
for (.x in parse(.app, keep.source = FALSE))
  if (is.call(.x) && identical(.x[[1]], as.name("<-")) &&
      as.character(.x[[2]]) %in% c("lire_tableau", "MESSAGE_ILLISIBLE")) eval(.x, .env488)
.csv488 <- function(d) { f <- tempfile(fileext = ".csv"); engine_ecrire_csv(d, f); .env488$lire_tableau(f, FALSE) }
.g488 <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1 + 0.2, 5e-324, NA)
.l488 <- .csv488(data.frame(t = 1:8, xt = .g488, yt = rev(.g488)))
.r488 <- engine_lire_donnees_csv(.l488$df)
verifier("Export CSV des donnees (#488) : grille relue par lire_tableau() puis engine_lire_donnees_csv(), identical()",
         is.null(.l488$erreur) && identical(.r488$xt, .g488) && identical(.r488$yt, rev(.g488)))
.t488 <- .env$triangle_defaut(8) * pi / 3
.d488 <- data.frame(i = 0:7, .t488); names(.d488) <- c("i", paste0("j", 0:7))
.rt488 <- engine_lire_triangle(.csv488(.d488)$df)
verifier("Export CSV des donnees (#488) : triangle a decimales sur 17 chiffres relu par lire_tableau() puis engine_lire_triangle(), identical()",
         isTRUE(.rt488$ok) && identical(.rt488$triangle, unname(.t488)))
# Lecture du code : corps du downloadHandler de dl_donnees (de son ouverture a
# la prochaine affectation d'une sortie ou a la fin du serveur).
verifier("app.R : le downloadHandler de dl_donnees appelle engine_ecrire_csv() et non write.csv (#488)",
         {
           src <- readLines(.app, warn = FALSE)
           i <- grep("output$dl_donnees <- downloadHandler(", src, fixed = TRUE)
           corps <- if (length(i) == 1L) {
             fin <- grep("^\\s*output\\$|^}", src)
             fin <- fin[fin > i]
             paste(src[i:(if (length(fin)) fin[1] - 1L else length(src))], collapse = "\n")
           } else ""
           grepl("engine_ecrire_csv(", corps, fixed = TRUE) && !grepl("write.csv", corps, fixed = TRUE)
         })

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
invisible(file.copy(file.path("R", c("engine.R", "charger_moteur.R", "display_helpers.R")), file.path(tmp, "R")))
invisible(file.copy(fichier_tri(tri10)$datapath, file.path(tmp, "usp_donnees_MW.csv")))
ici <- setwd(tmp); eb <- new.env(); app_b <- source("app.R", local = eb)$value; setwd(ici)
testServer(app_b, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2", profondeur = eb$T_INIT)))
  a("demarrage : triangle 10 x 10 lu, T = 8 (series par defaut) : dimension gardee (#155 a)",
    identical(eb$T_INIT, 8L) && isTRUE(eb$CHARGE_MW$statut$ok) && meme_tri(triangle(), tri10) &&
      a_id(grille_html(output), "c_9_0"))
})
)---"
  # Portee de PROFONDEUR_MAX (issue #212, regle "T = donnees chargees" du
  # mainteneur du 14/10/2026). updateNumericInput() et showNotification()
  # sont remplaces, dans l'environnement d'app.R, par un releve : la session
  # simulee de shiny ne renvoie pas au serveur la valeur poussee dans le
  # champ T. Mesure avant correction (14/10/2026, testServer) : triangle
  # 41 x 41 importe en 1,65 s, 100 x 100 en 12,0 s (rendu de la grille,
  # HTML de 1,86 Mo) ; series reinitialisees avec T saisi = 12 ou 40 : champ
  # T inchange, avec T = 200 : champ T a 40, pour 8 annees chargees.
  .bloc_212 <- r"---(
## Portee de PROFONDEUR_MAX : regle "T = donnees chargees" (issue #212)
maj212 <- list(); notifs212 <- character(0)
assign("updateNumericInput", function(session, inputId, value = NULL, ...) {
  maj212[[length(maj212) + 1L]] <<- list(id = inputId, value = value); invisible(NULL)
}, envir = ea)
assign("showNotification", function(ui, ...) {
  notifs212 <<- c(notifs212, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
champ_T <- function() vapply(Filter(function(m) identical(m$id, "profondeur"), maj212),
                             function(m) as.numeric(m$value), numeric(1))
testServer(app, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2", reinit = 1)))
  t0 <- triangle(); v0 <- version_grille()
  f41 <- fichier_tri(ea$triangle_defaut(41))
  maj212 <<- list(); notifs212 <<- character(0)
  duree <- system.time(session$setInputs(fichier_import = f41))[["elapsed"]]
  a("import d'un triangle 41 x 41 : refuse, triangle courant 8 x 8 et grille gardes (#212)",
    identical(triangle(), t0) && identical(version_grille(), v0) &&
      a_id(grille_html(output), "c_7_0") && !a_id(grille_html(output), "c_8_0"))
  a("import d'un triangle 41 x 41 : statut d'import au texte unique (fichier, donnees courantes conservees, motif), notification unique, champ T non touche (#212, #556)",
    identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg,
                sprintf("Import du fichier %s (CSV) refuse ; donnees courantes conservees. Motif : %s",
                        f41$name, ea$refus_dimension_triangle(41L))) &&
      identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import.") &&
      !length(champ_T()))
  a("import d'un triangle 41 x 41 : refus en moins de 1 s (1,65 s avant #212)", duree < 1)
  session$setInputs(fichier_import = fichier_tri(ea$triangle_defaut(40)))
  a("import d'un triangle 40 x 40 : accepte, dimension gardee (#212)",
    identical(dim(triangle()), c(40L, 40L)) &&
      isTRUE(all.equal(triangle(), ea$triangle_defaut(40))) && isTRUE(statut_import()$ok) &&
      a_id(grille_html(output), "c_39_0"))
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(profondeur = 200, reinit = 2)
  a("saisie T = 200, reserve no 2 : triangle par defaut 40 x 40, champ T a 40, message de plafonnement (#194)",
    identical(triangle(), ea$triangle_defaut(40)) && identical(champ_T(), 40) &&
      identical(notifs212, c("Profondeur T = 200 au-dela du maximum de 40 : T = 40 retenu.",
                             "Donnees reinitialisees : triangle par defaut 40 x 40.")))
})
for (T212 in c(12, 200)) testServer(app, {
  do.call(session$setInputs, modifyList(base, list(profondeur = T212)))
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(reinit = 1)
  a(sprintf("series, T saisi = %d : reinitialisation, 8 annees chargees, champ T ramene a 8 (#212)", T212),
    identical(donnees(), ea$DONNEES_DEFAUT) && identical(champ_T(), 8) &&
      identical(notifs212, "Donnees reinitialisees : series par defaut de 8 annees, T = 8."))
})
testServer(app, {
  do.call(session$setInputs, base)
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(reinit = 1)
  a("series, T saisi = 8 : reinitialisation sans mise a jour du champ T (#212)",
    identical(donnees(), ea$DONNEES_DEFAUT) && !length(champ_T()) &&
      identical(notifs212, "Donnees reinitialisees : series par defaut de 8 annees, T = 8."))
})
# Series de plus de 40 annees (issue #286, option (a)) : meme refus motive que
# le triangle. Mesure avant correction (issue #286, testServer) : 60 annees
# importees, champ T pousse a 60 au-dela de sa borne PROFONDEUR_MAX.
testServer(app, {
  do.call(session$setInputs, base)
  d0 <- donnees(); v0 <- version_grille()
  maj212 <<- list(); notifs212 <<- character(0)
  f60 <- fichier(60)
  session$setInputs(fichier_import = f60)
  a("import de series de 60 annees : refuse, series courantes et grille gardees, champ T non touche (#286)",
    identical(donnees(), d0) && identical(version_grille(), v0) &&
      identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg,
                sprintf("Import du fichier %s (CSV) refuse ; donnees courantes conservees. Motif : %s",
                        f60$name, ea$refus_dimension_series(60L))) &&
      identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import.") &&
      !length(champ_T()))
  maj212 <<- list()
  session$setInputs(fichier_import = fichier(40))
  a("import de series de 40 annees : accepte, champ T pousse a 40 (#286)",
    nrow(donnees()) == 40L && identical(champ_T(), 40))
  # Refus motive du lecteur xlsx (#522) : classeur dont la ligne 1 est vide
  # (lignes descendues d'une ligne dans le XML ; paquet zip ou commande zip
  # requis). Sans l'un ni l'autre : assertion sautee, signalee dans le
  # libelle (meme nombre d'assertions, comme le bloc de #488).
  nom522 <- "import d'un classeur a ligne 1 vide : statut \"Import du fichier ligne1.xlsx (XLSX) refuse ; donnees courantes conservees. Motif : <texte du moteur>\", notification unique, series gardees (#522, #556)"
  zip522 <- requireNamespace("zip", quietly = TRUE)
  if (zip522 || nzchar(Sys.which("zip"))) {
    f522 <- tempfile(fileext = ".xlsx")
    get("engine_ecrire_xlsx", envir = ea)(data.frame(xt = 100:107, yt = 60:67), f522)
    x522 <- tempfile("x522_"); utils::unzip(f522, exdir = x522)
    fs <- file.path(x522, "xl", "worksheets", "sheet1.xml")
    s <- paste(readLines(fs, warn = FALSE), collapse = "")
    m <- gregexpr('<(row|c) r="[A-Z]*[0-9]+"', s)
    regmatches(s, m) <- lapply(regmatches(s, m), function(tk) vapply(tk, function(t)
      sub('[0-9]+"$', paste0(as.integer(sub('.*[^0-9]([0-9]+)"$', "\\1", t)) + 1L, '"'), t), "", USE.NAMES = FALSE))
    writeLines(s, fs, useBytes = TRUE)
    unlink(f522); od <- setwd(x522)
    if (zip522) zip::zipr(f522, list.files(".", all.files = TRUE, no.. = TRUE), include_directories = FALSE)
    else utils::zip(f522, list.files(".", all.files = TRUE, no.. = TRUE), flags = "-r9Xq")
    setwd(od)
    d40 <- donnees(); notifs212 <<- character(0)
    suppressMessages(session$setInputs(fichier_import = list(name = "ligne1.xlsx", datapath = f522)))
    a(nom522,
      identical(statut_import()$ok, FALSE) && identical(donnees(), d40) &&
        identical(statut_import()$msg, paste("Import du fichier ligne1.xlsx (XLSX) refuse ; donnees courantes conservees. Motif :",
          "Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete.")) &&
        identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import."))
    unlink(c(f522, x522), recursive = TRUE)
  } else a(paste0(nom522, " ; saute (ni paquet ni commande zip)"), TRUE)
})
rm("updateNumericInput", "showNotification", envir = ea)
)---"
  # Garde de l'apercu a la reinitialisation des series (revue finale de #212,
  # sur le modele de l'import, #183). La session simulee ne renvoie pas la
  # valeur poussee dans le champ T : elle reproduit l'aller-retour du
  # navigateur, pendant lequel le champ vaut encore l'ancien T. Mesure avant
  # correction (14/10/2026) : 12 annees importees, T = 12, puis Reinitialiser
  # : garde NULL, apercu "Profondeur T = 12 superieure au nombre d'annees
  # fournies (8)."
  .bloc_212_garde <- r"---(
## Garde de l'apercu a la reinitialisation des series (issue #212)
d0 <- ea$DONNEES_DEFAUT
testServer(app, {
  do.call(session$setInputs, base)
  session$setInputs(fichier_import = fichier(12)); grille(session, 12)
  session$setInputs(profondeur = 12)
  av <- apercu(output)
  session$setInputs(reinit = 1)
  do.call(session$setInputs, c(setNames(as.list(d0$xt), paste0("x_", 1:8)),
                               setNames(as.list(d0$yt), paste0("y_", 1:8))))
  ap <- apercu(output)
  a("series, T = 12, Reinitialiser : garde posee a 8, apercu non reevalue avec T = 12 sur 8 annees (#212)",
    is.character(av) && !grepl("class=\"err\"", av, fixed = TRUE) &&
      identical(profondeur_import(), 8L) && garde(av, ap) &&
      !grepl("superieure", paste(ap, collapse = ""), fixed = TRUE))
  session$setInputs(profondeur = 8)
  ap <- apercu(output)
  a("series, puis T = 8 : garde levee, apercu reevalue sur 8 annees sans refus (#212)",
    is.null(profondeur_import()) && is.character(ap) && grepl("T = 8 :", ap, fixed = TRUE) &&
      !grepl("class=\"err\"", ap, fixed = TRUE))
})
testServer(app, {
  do.call(session$setInputs, base)
  session$setInputs(reinit = 1)
  a("series, T saisi = 8, Reinitialiser : garde non posee (champ deja aligne) (#212)",
    is.null(profondeur_import()))
  session$setInputs(methode = "reserve2", profondeur = 200)
  session$setInputs(reinit = 2)
  a("reserve no 2, T = 200, Reinitialiser : garde des series non posee (#212)",
    is.null(profondeur_import()) && identical(dim(triangle()), c(40L, 40L)))
})
)---"
  # Virgule decimale des traces base R de l'application (revue finale de
  # #236) : rendu_graphique() sans plotly (ou avec l'option
  # usp.graphiques_base, voir le compte rendu) passe par renderPlot(), qui
  # trace avec OutDec = "," et le restaure. Mesure avant correction
  # (14/10/2026, plotly absent) : OutDec "." pendant le trace, format(0.5)
  # "0.5". Sous plotly, rendu_graphique() rend un graphique plotly : la
  # verification ne porte alors que sur la restauration d'OutDec.
  .bloc_236_base <- r"---(
## Virgule decimale des traces base R de l'application (issue #236)
vu236 <- NULL
app236 <- shinyApp(fluidPage(), function(input, output, session) {
  output$p <- ea$rendu_graphique({
    if (requireNamespace("plotly", quietly = TRUE)) plotly::plot_ly()
    else { plot(c(0.5, 1.5))
           vu236 <<- list(OutDec = getOption("OutDec"),
                          graduations = format(graphics::axTicks(2)))
           invisible() }
  })
})
od236 <- getOption("OutDec")
testServer(app236, { x236 <<- tryCatch(output$p, error = function(e) e) })
plotly236 <- requireNamespace("plotly", quietly = TRUE)
a("rendu_graphique() (base R) : OutDec = \",\" pendant le trace, graduations en virgule, OutDec restaure (#236)",
  identical(getOption("OutDec"), od236) &&
    (plotly236 || (identical(vu236$OutDec, ",") && is.character(x236$src) &&
                     all(grepl("^[0-9]+(,[0-9]+)?$", vu236$graduations)) &&
                     any(grepl(",", vu236$graduations, fixed = TRUE)))))
# Option usp.graphiques_base (issue #295) : rendu_graphique() rend alors la
# fonction de avec_virgule_decimale() (branche renderPlot) et
# sortie_graphique() un plotOutput, que plotly soit installe ou non.
op295 <- options(usp.graphiques_base = TRUE)
rg295 <- ea$rendu_graphique(plot(1)); so295 <- ea$sortie_graphique("p295")
options(op295)
a("option usp.graphiques_base : rendu_graphique() et sortie_graphique() en base R (#295)",
  identical(body(rg295), body(ea$avec_virgule_decimale(function(...) NULL))) &&
    grepl("shiny-plot-output", as.character(so295), fixed = TRUE))
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
  # Ligne "P-values Monte-Carlo" du bloc Etat et du journal, graine du flux
  # dans le journal (issue #240, Q-A4-12 (B)) : textes de texte_p_mc_regime()
  # et de valeurs_generateur(), lus dans le resultat, presents en primes (jeu
  # par defaut) et absents en reserve no 2 (triangle par defaut) ; graine de
  # la loi nulle SW : l'inverse (reserve no 2 seulement, #351).
  .bloc_240 <- r"---(
## Ligne "P-values Monte-Carlo" du bloc Etat (issue #240)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  et <- as.character(output$etat$html)
  lig <- texte_p_mc_regime(resultat())
  a("bloc Etat (primes) : ligne P-values Monte-Carlo, texte de texte_p_mc_regime() (#240)",
    is.character(lig) && grepl("<b>P-values Monte-Carlo</b>", et, fixed = TRUE) &&
      grepl(htmltools::htmlEscape(lig), et, fixed = TRUE))
  jo <- output$tab_meta
  a("journal (primes) : ligne P-values Monte-Carlo entre la granularite et alpha, graine du flux 20800000 (#240)",
    grepl(paste0("P-values Monte-Carlo : ", lig, " \n"), jo, fixed = TRUE) &&
      regexpr("Granularite p_mc", jo, fixed = TRUE) < regexpr("P-values Monte-Carlo", jo, fixed = TRUE) &&
      regexpr("P-values Monte-Carlo", jo, fixed = TRUE) < regexpr("Seuil alpha", jo, fixed = TRUE) &&
      grepl("Graine flux regime   : 20800000 ", jo, fixed = TRUE))
  a("journal (primes) : pas de ligne 'Graine loi nulle SW' (consignee en reserve no 2 seulement, #351)",
    !grepl("Graine loi nulle SW", jo, fixed = TRUE) &&
      is.null(resultat()$metadata$seed_loi_nulle_sw))
  session$setInputs(methode = "reserve2", reinit = 2)
  # Le navigateur rend la grille du triangle : ses cellules observees c_i_j
  # sont relues, sans quoi le moteur refuse un triangle vide.
  tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
  session$setInputs(go = 2)
  et <- as.character(output$etat$html)
  a("bloc Etat (reserve no 2) : aucune ligne P-values Monte-Carlo (#240)",
    isTRUE(resultat()$ok) && identical(resultat()$metadata$methode, "reserve2") &&
      grepl("sigma_USP", et, fixed = TRUE) && !grepl("P-values Monte-Carlo", et, fixed = TRUE))
  jo <- output$tab_meta
  a("journal (reserve no 2) : ni ligne P-values Monte-Carlo ni graine du flux (#240)",
    grepl("Seuil alpha", jo, fixed = TRUE) && !grepl("P-values Monte-Carlo", jo, fixed = TRUE) &&
      !grepl("Graine flux regime", jo, fixed = TRUE))
  a("journal (reserve no 2) : ligne 'Graine loi nulle SW' presente, graine du moteur (#351)",
    grepl(paste0("Graine loi nulle SW  : ",
                 format(resultat()$metadata$seed_loi_nulle_sw, scientific = FALSE), " "),
          jo, fixed = TRUE) && identical(resultat()$metadata$seed_loi_nulle_sw, 20260901))
})
)---"
  # Regle des verdicts, alpha du resultat et du panneau (issue #498) : la regle
  # (quatre phrases d'engine_regle_verdicts(), alpha du RESULTAT) ouvre le
  # tableau des tests, jamais celui des controles ; la colonne Sens figure en
  # Synthese et en Detail ; le bloc Etat donne l'alpha du resultat et signale,
  # sans recalcul, un alpha du panneau different (texte_alpha_divergent()).
  .bloc_498 <- r"---(
## Regle des verdicts, alpha du resultat et du panneau (issue #498)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  avant <- tryCatch(as.character(output$tests_par_hypothese$html), error = function(e) e)
  a("avant tout calcul : onglet Tests sans regle, ni erreur autre que l'annulation du rendu (#498)",
    inherits(avant, "shiny.silent.error"))
  session$setInputs(go = 1)
  ph <- engine_regle_verdicts(resultat()$metadata$alpha)
  h <- as.character(output$tests_par_hypothese$html)
  et <- as.character(output$etat$html)
  a("calcul abouti au jeu par defaut, alpha 0,1 du resultat (#498)",
    isTRUE(resultat()$ok) && identical(resultat()$metadata$alpha, 0.1))
  pos <- vapply(ph, function(x) regexpr(.echap_html(x), h, fixed = TRUE)[1], numeric(1))
  a("onglet Tests : les quatre phrases d'engine_regle_verdicts(alpha du resultat), dans l'ordre, avant le premier groupe (#498)",
    all(pos > 0) && all(diff(pos) > 0) && pos[1] < regexpr("<h4", h, fixed = TRUE)[1])
  a("onglet Tests : la regle ouvre le tableau, aucun autre element avant elle (#498)",
    startsWith(h, "<div class='bloc regle-verdicts'>"))
  # Repere de profondeur (#499) : champ du moteur, non replie, sous la regle.
  rp499 <- resultat()$validation$repere_profondeur
  bloc499 <- paste0("<div class='avert repere-profondeur'>", .echap_html(rp499), "</div>")
  a("onglet Tests : repere de profondeur du moteur (T = 8) non replie, juste sous la regle, avant le premier groupe (#499)",
    length(rp499) == 1L && startsWith(rp499, "T = 8 :") &&
      lengths(regmatches(h, gregexpr(bloc499, h, fixed = TRUE))) == 1L &&
      regexpr(paste0("</ul></div>\n", bloc499), h, fixed = TRUE)[1] == regexpr("</ul></div>", h, fixed = TRUE)[1] &&
      regexpr(bloc499, h, fixed = TRUE)[1] < regexpr("<h4", h, fixed = TRUE)[1])
  ctr <- as.character(output$tab_controles)
  a("tableau des controles : aucune phrase de la regle (#498)",
    is.character(ctr) && grepl("<table", ctr, fixed = TRUE) && !grepl("regle-verdicts", ctr, fixed = TRUE) &&
      !any(vapply(ph, function(x) grepl(.echap_html(x), ctr, fixed = TRUE), logical(1))))
  lig_pit <- grep("Test de Pitman", regmatches(h, gregexpr("<tr>.*?</tr>", h, perl = TRUE))[[1]],
                  fixed = TRUE, value = TRUE)
  a("vue Synthese : colonne Sens, ligne Pitman en ALERTE (p = 0,1107) avec le sens rejeter (#498)",
    grepl("<th>Sens</th>", h, fixed = TRUE) && length(lig_pit) == 1L &&
      grepl("ALERTE", lig_pit, fixed = TRUE) && grepl("<td>0,1107</td>", lig_pit, fixed = TRUE) &&
      endsWith(lig_pit, "<td><span style='white-space:nowrap'>rejeter</span></td></tr>"))
  session$setInputs(vue_tests = "detail")
  hd <- as.character(output$tests_par_hypothese$html)
  a("vue Detail : la regle en tete et la colonne Sens (#498)",
    startsWith(hd, "<div class='bloc regle-verdicts'>") && grepl("<th>Sens</th>", hd, fixed = TRUE) &&
      all(vapply(ph, function(x) grepl(.echap_html(x), hd, fixed = TRUE), logical(1))))
  a("bloc Etat : alpha du resultat (0,1), aucun signal tant que le panneau est a 0,1 (#498)",
    grepl("<b>&alpha;</b> = 0,1</div>", et, fixed = TRUE) && !grepl("du panneau", et, fixed = TRUE))
  session$setInputs(alpha = 0.2)
  et2 <- as.character(output$etat$html)
  h2 <- as.character(output$tests_par_hypothese$html)
  a("alpha du panneau a 0,2 : signal dans l'Etat, alpha du resultat toujours 0,1, aucun recalcul (#498)",
    grepl("α du panneau différent de celui du dernier calcul : relancer les calculs", et2, fixed = TRUE) &&
      grepl("<b>&alpha;</b> = 0,1</div>", et2, fixed = TRUE) && !grepl("<b>&alpha;</b> = 0,2", et2, fixed = TRUE) &&
      identical(resultat()$metadata$alpha, 0.1))
  a("alpha du panneau a 0,2 : la regle de l'onglet Tests reste celle du resultat (alpha 0,1), inchangee (#498)",
    identical(h2, hd) && grepl(.echap_html(ph[1]), h2, fixed = TRUE) && !grepl("α = 0,2", h2, fixed = TRUE))
  session$setInputs(alpha = NA_real_)
  et3 <- as.character(output$etat$html)
  a("champ alpha vide (NA) : ni signal ni erreur, alpha du resultat affiche (#498)",
    grepl("<b>&alpha;</b> = 0,1</div>", et3, fixed = TRUE) && !grepl("du panneau", et3, fixed = TRUE))
  session$setInputs(alpha = 0.10)
  a("alpha du panneau revenu a 0,1 : le signal disparait (#498)",
    !grepl("du panneau", as.character(output$etat$html), fixed = TRUE))
})
)---"
  # Notifications de refus (issue #226) : texte fixe d'interface, motif
  # complet dans le bandeau. showNotification() est remplace, dans
  # l'environnement d'app.R, par un releve du texte notifie : la session
  # simulee de shiny n'envoie aucune notification (sendNotification() y est
  # sans effet, shiny 1.8.0). Scenario de l'issue (refus "maximum de
  # vraisemblance non atteint", motif unique de plus de 700 caracteres) et
  # triangle a cellule observee manquante (Calcul non lance, reserve no 2).
  .bloc_226 <- r"---(
## Notifications de refus : texte fixe, motif complet dans le bandeau (issue #226)
notifs226 <- character(0)
assign("showNotification", function(ui, ...) {
  notifs226 <<- c(notifs226, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
xs226 <- c(98.10, 101.30, 104.20, 102.25, 109.34, 114.64, 118.41, 121.28)
r226 <- run_engine(xs226, 0.7 * xs226, methode = "premium", sigma_standard = 0.1,
                   nature_donnees = "brutes", T = 8, B = 99, alpha = 0.10, seed = 20260831,
                   segment = 1L, annexe = "II", theta_equiv = 0.10)
motif226 <- r226$validation$erreurs
testServer(app, {
  do.call(session$setInputs, modifyList(base, list(reinit = 1, sigma_manuel = TRUE, sigma_std = 0.1)))
  do.call(session$setInputs, c(setNames(as.list(xs226), paste0("x_", 1:8)),
                               setNames(as.list(0.7 * xs226), paste0("y_", 1:8))))
  notifs226 <<- character(0)
  session$setInputs(go = 1)
  bd <- as.character(output$bandeau_refus$html)
  a("scenario de #226 : refus du moteur, un motif de plus de 700 caracteres, sans erreur_r",
    identical(r226$ok, FALSE) && is.null(r226$validation$erreur_r) &&
      length(motif226) == 1L && nchar(motif226) > 700L)
  a("Calcul refuse : notification au texte fixe, seule notification du clic (#226)",
    identical(notifs226, "Calcul refuse : aucun resultat n'est produit (voir le bandeau)."))
  a("Calcul refuse : motif complet du moteur dans le bandeau (#226)",
    is.null(resultat()) && grepl(ea$TITRE_REFUSE, bd, fixed = TRUE) &&
      grepl(htmltools::htmlEscape(motif226), bd, fixed = TRUE))
  session$setInputs(methode = "reserve2", reinit = 2)
  tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
  session$setInputs(c_1_1 = NA)
  mv <- mw_valider_triangle(lire_triangle(), segment = 1L, annexe = "II")$erreurs
  notifs226 <<- character(0)
  session$setInputs(go = 2)
  bd <- as.character(output$bandeau_refus$html)
  a("Calcul non lance (reserve no 2) : notification au texte fixe (#226)",
    identical(notifs226, "Calcul non lance : aucun resultat n'est produit (voir le bandeau)."))
  a("Calcul non lance (reserve no 2) : motif du moteur dans le bandeau (#226)",
    identical(mv, "Cellule observee manquante : annee d'accident i = 1, annee de developpement j = 1.") &&
      grepl(ea$TITRE_NON_LANCE, bd, fixed = TRUE) && grepl(htmltools::htmlEscape(mv), bd, fixed = TRUE))
})
# Plafond de six motifs leve, notification lognormale au texte fixe (issue
# #287, option (a)) : valeurs hors domaine (1e60, -1), une valeur manquante,
# nature non declaree et marge theta vide donnent sept motifs (mesure du
# 17/10/2026, engine_valider_serie_retenue() : 7 motifs, 1 204 caracteres).
x287 <- c(1e60, -1, 104.20, 102.25, NA, 114.64, 118.41, 121.28)
y287 <- c(68.67, 70.91, -1, 1e60, 76.54, 80.25, 82.89, 84.90)
m287 <- engine_valider_serie_retenue(x287, y287, T = 8, theta_equiv = NA, delta_equiv = NULL,
                                     methode = "premium", nature_donnees = NULL,
                                     segment = 1L, annexe = "II")$validation$erreurs
testServer(app, {
  do.call(session$setInputs, modifyList(base[names(base) != "nature_donnees"],
                                        list(reinit = 1, theta_equiv = NA)))
  do.call(session$setInputs, c(setNames(as.list(x287), paste0("x_", 1:8)),
                               setNames(as.list(y287), paste0("y_", 1:8))))
  ap <- as.character(output$validation_live$html)
  notifs226 <<- character(0)
  session$setInputs(go = 1)
  bd <- as.character(output$bandeau_refus$html)
  tous <- function(h) all(vapply(m287, function(m) grepl(htmltools::htmlEscape(m), h, fixed = TRUE),
                                 logical(1)))
  a("scenario de #287 : sept motifs du moteur avant le calcul",
    length(m287) == 7L && is.null(input$nature_donnees))
  a("Calcul non lance (methodes lognormales) : notification au texte fixe (#287)",
    identical(notifs226, "Calcul non lance : aucun resultat n'est produit (voir le bandeau)."))
  a("Calcul non lance (methodes lognormales) : les sept motifs dans le bandeau et dans l'apercu (#287)",
    is.null(resultat()) && grepl(ea$TITRE_NON_LANCE, bd, fixed = TRUE) && tous(bd) && tous(ap))
})
rm("showNotification", envir = ea)
)---"
  # Virgule decimale des nombres affiches (issue #236) : bloc Etat, bloc du
  # parametre retenu (intervalle bootstrap "[a ; b]"), journal, table de
  # calibration, note d'influence et notification du retrait d'une ligne
  # (valeurs separees par " ; "), sur le jeu par defaut (B = 99, alpha = 0,10).
  .bloc_236 <- r"---(
## Virgule decimale des nombres affiches (issue #236)
notifs236 <- character(0)
assign("showNotification", function(ui, ...) {
  notifs236 <<- c(notifs236, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r <- resultat(); p <- r$parametre_final; ic <- r$ic_bootstrap
  sig <- sub(".", ",", sprintf("%.4f", p$sigma_usp), fixed = TRUE)
  et <- as.character(output$etat$html)
  a("bloc Etat : sigma_USP en virgule decimale, 4 decimales (#236)",
    isTRUE(r$ok) && grepl("^0,[0-9]{4}$", sig) &&
      grepl(paste0("font-size:18px'>", sig, "</span>"), et, fixed = TRUE))
  # Point decimal recherche hors des attributs style (font-size:12.5px).
  bf <- as.character(output$bloc_final$html)
  a("bloc du parametre : sigma_USP, variation et intervalle bootstrap \"[a ; b]\" en virgule decimale, aucun point decimal hors style (#236)",
    grepl(paste0("sigma_USP = ", sig, "</span>"), bf, fixed = TRUE) &&
      grepl("par rapport au parametre standard de 0,1000", bf, fixed = TRUE) &&
      grepl("90 % : \\[[0-9]+,[0-9]{4} ; [0-9]+,[0-9]{4}\\]", bf) &&
      grepl(gsub("(\\d)\\.(\\d)", "\\1,\\2", sprintf("95 %% : [%.4f ; %.4f]", ic[1], ic[5])), bf, fixed = TRUE) &&
      !grepl("[0-9]\\.[0-9]", gsub("style=\"[^\"]*\"", "", bf)))
  # Libelles des intervalles bootstrap (issue #305, Q-D2-Fn-3 (A)) : ligne
  # de percentile "niveau nominal", ligne "basic" sur l'echelle
  # logarithmique dessous, note grise ; ancien libelle absent.
  i_pc <- regexpr("Intervalle bootstrap de percentile, niveau nominal 90 % : [", bf, fixed = TRUE)
  i_bl <- regexpr("Intervalle bootstrap « basic » sur l'échelle logarithmique, niveau nominal 90 % : [",
                  bf, fixed = TRUE)
  a("bloc du parametre : intervalle de percentile 'niveau nominal', intervalle basic sur l'echelle logarithmique dessous, note grise des niveaux nominaux (#305)",
    i_pc > 0 && i_bl > i_pc && grepl("Niveaux nominaux. À T = 8, sous les modèles", bf, fixed = TRUE) &&
      !grepl("Intervalle bootstrap 90 %", bf, fixed = TRUE))
  jo <- output$tab_meta
  a("journal : sigma standard, granularite et alpha en virgule decimale (#236)",
    grepl("sigma standard       : 0,1 ", jo, fixed = TRUE) &&
      grepl("Granularite p_mc     : 0,01 ", jo, fixed = TRUE) &&
      grepl("Seuil alpha          : 0,1 \n", jo, fixed = TRUE))
  tc <- output$tab_calibration
  a("table de calibration : valeurs a 5 decimales en virgule decimale (#236)",
    grepl("<td> [0-9]+,[0-9]{5} </td>", tc) && !grepl("[0-9]\\.[0-9]", tc))
  ni <- as.character(output$note_influence$html)
  a("note d'influence (application) : reperes et ecart en virgule decimale, aucun point decimal (#236)",
    grepl("(4/T = 0,500)", ni, fixed = TRUE) && grepl("<b>[+-][0-9]+,[0-9] %</b>", ni) &&
      !grepl("[0-9]\\.[0-9]", ni))
  notifs236 <<- character(0)
  session$setInputs(retirer_annee = 1)
  a("retrait d'une ligne renseignee : valeurs en virgule decimale, separees par \" ; \" (#236)",
    identical(notifs236, "Ligne t = 8 retiree (x_t = 131,22 ; y_t = 117,37)."))
})
rm("showNotification", envir = ea)
)---"
  # Personnalisation de l'onglet Tests et nouveau calcul (issue #380, decision
  # du mainteneur du 27/10/2026 : personnalisation gardee ligne par ligne,
  # cle (famille, test, base)). Le navigateur est simule : le panneau rendu
  # (output$panneau_personnalisation) est relu et ses cases et radios sont
  # renvoyees au serveur ; les entrees du rendu precedent restent dans
  # input, comme dans le navigateur. Mesure avant correction (27/10/2026,
  # testServer, shiny 1.8.0) : S0 et S1 echouent (entrees g_test_k lues par
  # indice sur la nouvelle table).
  .bloc_380 <- r"---(
## Personnalisation de l'onglet Tests et nouveau calcul (issue #380)
panneau <- function(output) {
  h <- as.character(output$panneau_personnalisation$html)
  ch <- strsplit(h, '<div class="row">', fixed = TRUE)[[1]][-1]
  boite <- sub('(?s).*?(<input id="g_test_[^>]*>).*', "\\1", ch, perl = TRUE)
  data.frame(id = sub('^<input id="([^"]*)".*', "\\1", boite),
             garde = grepl('checked="checked"', boite, fixed = TRUE),
             texte = sub('(?s).*?padding-top:6px">([^<]*).*', "\\1", ch, perl = TRUE),
             stringsAsFactors = FALSE)
}
radios <- function(output) {
  h <- as.character(output$panneau_personnalisation$html)
  r <- regmatches(h, gregexpr('<input type="radio" name="b_test_[^"]*" value="[zr]" checked="checked"', h))[[1]]
  setNames(as.list(sub('.*value="([zr])".*', "\\1", r)), sub('.*name="([^"]*)".*', "\\1", r))
}
envoyer <- function(session, output) {
  p <- panneau(output)
  do.call(session$setInputs, c(setNames(as.list(p$garde), p$id), radios(output)))
  p
}
tri380 <- function(session, tr) {
  k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
}
# Bascule en reserve no 2, comme la session cloud et le navigateur : grille du
# triangle relue avant le calcul.
vers_reserve2 <- function(session, triangle, go) {
  session$setInputs(methode = "reserve2", reinit = go)
  tri380(session, triangle())
  session$setInputs(go = go)
}
d380 <- ea$DONNEES_DEFAUT
saisie380 <- c(setNames(as.list(d380$xt), paste0("x_", seq_len(nrow(d380)))),
               setNames(as.list(d380$yt), paste0("y_", seq_len(nrow(d380)))))
# S0 : aucune action de l'utilisateur, panneau affiche une fois.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  n1 <- nrow(TB()); tb1 <- TB()
  vers_reserve2(session, triangle, 2)
  p2 <- envoyer(session, output)
  def <- selection_defaut(TB())
  a("S0 : premium (53 lignes) puis reserve no 2 (25 lignes), aucune case touchee : selection par defaut de reserve no 2 (#380)",
    n1 == 53L && nrow(TB()) == 25L && identical(sel_courante(), def) &&
      sum(p2$garde) == sum(def$garde) && nrow(p2) == 25L)
  a("S0 : cle de ligne (famille, test, base) unique sur premium et sur reserve no 2 (#380)",
    !anyDuplicated(paste(TB()$famille, TB()$test, TB()$base)) &&
      !anyDuplicated(paste(tb1$famille, tb1$test, tb1$base)))
})
# S1 : case Pitman decochee en premium, puis reserve no 2.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  i <- grep("Pitman", p1$texte)
  tb1 <- TB()
  l1 <- which(grepl("Pitman", tb1$test))
  do.call(session$setInputs, setNames(list(FALSE), p1$id[i]))
  a("S1 : la case Pitman decochee en premium est prise en compte (#380)",
    length(i) == 1L && length(l1) == 1L && !sel_courante()$garde[l1] &&
      sum(!sel_courante()$garde) == sum(!selection_defaut(tb1)$garde) + 1L)
  vers_reserve2(session, triangle, 2)
  p2 <- envoyer(session, output)
  def <- selection_defaut(TB())
  m1 <- which(grepl("p de famille", TB()$test) & grepl("^M1", TB()$famille))
  a("S1 : reserve no 2 apres Pitman decochee en premium : aucune ligne decochee a tort, selection par defaut (#380)",
    identical(sel_courante(), def) && sum(p2$garde) == sum(def$garde))
  a("S1 : p de famille de M1 (lecture conjointe) reste cochee (#380)",
    length(m1) == 1L && sel_courante()$garde[m1])
  # La ligne Pitman n'existait pas au calcul intermediaire : retour en premium
  # a son defaut, sans reprendre la valeur perimee du rendu d'origine.
  session$setInputs(methode = "premium", reinit = 3)
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 3)
  p3 <- envoyer(session, output)
  a("S1 : retour en premium, la ligne Pitman absente du calcul intermediaire reprend son defaut (#380)",
    identical(sel_courante(), selection_defaut(TB())) && sum(p3$garde) == sum(selection_defaut(TB())$garde))
})
# S2 : relance de la meme methode, personnalisation gardee ligne par ligne.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  i <- grep("Pitman", p1$texte); l <- which(grepl("Pitman", TB()$test))
  do.call(session$setInputs, setNames(list(FALSE), p1$id[i]))
  session$setInputs(go = 2)
  p2 <- envoyer(session, output)
  def <- selection_defaut(TB()); s <- sel_courante()
  a("S2 : relance de meme methode, la ligne decochee reste decochee (#380)",
    length(l) == 1L && !s$garde[l] && !p2$garde[grep("Pitman", p2$texte)])
  a("S2 : relance de meme methode, les autres lignes restent a leur defaut (#380)",
    identical(s$garde[-l], def$garde[-l]) && identical(s$base, def$base) &&
      sum(p2$garde) == sum(def$garde) - 1L)
})
# C1 : les trois boutons de l'onglet Personnalisation. Clic, puis relecture du
# panneau rendu (le navigateur renvoie ses cases). Avant correction, les cases
# du rendu precedent etaient relues dans le meme flush et defaisaient le clic.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  def <- selection_defaut(TB())
  envoyer(session, output)
  session$setInputs(sel_rien = 1)
  pr <- envoyer(session, output)
  a("bouton Tout retirer : aucune ligne conservee, panneau et selection (#380)",
    !any(sel_courante()$garde) && !any(pr$garde) && nrow(pr) == 53L)
  session$setInputs(sel_tout = 1)
  pt <- envoyer(session, output)
  a("bouton Tout conserver : toutes les lignes conservees, panneau et selection (#380)",
    all(sel_courante()$garde) && all(pt$garde) && nrow(pt) == 53L)
  do.call(session$setInputs, setNames(list(FALSE), pt$id[grep("Pitman", pt$texte)]))
  session$setInputs(sel_defaut = 1)
  pd <- envoyer(session, output)
  a("bouton Retablir la selection par defaut : selection par defaut, panneau et selection (#380)",
    identical(sel_courante(), def) && sum(pd$garde) == sum(def$garde) && is.null(selection()))
})
# C2 : un calcul refuse entre deux calculs valides ne remet pas la
# personnalisation a zero (marge theta vide : refus du moteur avant le calcul).
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  l <- which(grepl("Pitman", TB()$test))
  do.call(session$setInputs, setNames(list(FALSE), p1$id[grep("Pitman", p1$texte)]))
  session$setInputs(theta_equiv = NA, go = 2)
  refuse <- is.null(resultat())
  session$setInputs(theta_equiv = 0.10, go = 3)
  p3 <- envoyer(session, output)
  def <- selection_defaut(TB()); s <- sel_courante()
  a("calcul refuse entre deux calculs valides : la ligne decochee reste decochee, les autres au defaut (#380)",
    refuse && isTRUE(resultat()$ok) && length(l) == 1L && !s$garde[l] &&
      identical(s$garde[-l], def$garde[-l]) && sum(p3$garde) == sum(def$garde) - 1L)
})
# C3 : "Tout conserver" et "Tout retirer" apres un calcul refuse (resultat()
# NULL, TB() indisponible) : avant correction, req(resultat()) perdait le clic,
# alors que "Retablir" s'appliquait.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  l <- which(grepl("Pitman", TB()$test))
  do.call(session$setInputs, setNames(list(FALSE), p1$id[grep("Pitman", p1$texte)]))
  session$setInputs(theta_equiv = NA, go = 2)
  refuse <- is.null(resultat())
  txt <- as.character(output$panneau_personnalisation$html)
  session$setInputs(sel_tout = 1)
  garde_tout <- all(selection()$garde)
  session$setInputs(theta_equiv = 0.10, go = 3)
  p3 <- envoyer(session, output)
  a("Tout conserver apres un calcul refuse : la ligne Pitman decochee est cochee au calcul suivant, panneau et selection (#380)",
    refuse && garde_tout && isTRUE(resultat()$ok) && all(sel_courante()$garde) && all(p3$garde) &&
      nrow(p3) == 53L)
  a("panneau de personnalisation apres un calcul refuse : texte explicatif, aucune case (#380)",
    grepl("Aucun resultat de calcul", txt, fixed = TRUE) && !grepl("g_test_", txt, fixed = TRUE))
  session$setInputs(theta_equiv = NA, go = 4)
  refuse2 <- is.null(resultat())
  session$setInputs(sel_rien = 1)
  garde_rien <- !any(selection()$garde)
  session$setInputs(theta_equiv = 0.10, go = 5)
  p5 <- envoyer(session, output)
  a("Tout retirer apres un calcul refuse : aucune ligne conservee au calcul suivant (#380)",
    refuse2 && garde_rien && isTRUE(resultat()$ok) && !any(sel_courante()$garde) && !any(p5$garde))
})
# C3 bis : sans personnalisation avant le refus (selection NULL), le clic part du
# defaut de la table du dernier calcul abouti ; sans calcul abouti, rien ne change.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie380)
  session$setInputs(sel_rien = 1)
  vide <- is.null(selection())
  session$setInputs(go = 1)
  p1 <- envoyer(session, output)
  def <- selection_defaut(TB())
  session$setInputs(theta_equiv = NA, go = 2)
  session$setInputs(sel_rien = 2)
  garde_rien <- !is.null(selection()) && !any(selection()$garde)
  session$setInputs(theta_equiv = 0.10, go = 3)
  p3 <- envoyer(session, output)
  a("Tout retirer sans calcul abouti : sans effet ; apres un refus sans personnalisation : part du defaut du dernier calcul (#380)",
    vide && garde_rien && isTRUE(resultat()$ok) && !any(sel_courante()$garde) && !any(p3$garde) &&
      sum(p1$garde) == sum(def$garde))
})
)---"
  # Bandeau des avertissements de validation d'apres calcul, entierement replie
  # (issue #412, decision Q-46-4 (a) ; test reporte de R30, Q-45-4) : triangle
  # tri_deg (test_merz_wuthrich.R) importe puis cellules c_i_j relues, comme le
  # navigateur ; reserve no 2, segment II-1, B = 99. Un cas a un seul
  # avertissement (primes, 12 annees, segment II-1, mesure du 03/11/2026) pour
  # le singulier du resume.
  .bloc_412 <- r"---(
## Bandeau d'apres calcul replie (issue #412)
tri_deg <- matrix(NA_real_, 6, 6)
tri_deg[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri_deg[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri_deg[3, 1:4] <- c(900, 1395, 1580, 1580)
tri_deg[4, 1:3] <- c(1200, 1980, 2210)
tri_deg[5, 1:2] <- c(1050, 1638)
tri_deg[6, 1]   <- 980
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  a("bandeau d'avertissements : vide avant tout calcul (#412)",
    is.null(output$bandeau_avertissements))
  session$setInputs(fichier_import = fichier_tri(tri_deg))
  tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
  session$setInputs(go = 1)
  av <- resultat()$validation$avertissements
  h <- as.character(output$bandeau_avertissements$html)
  balises <- regmatches(h, gregexpr("<details[^>]*>", h))[[1]]
  a("tri_deg : calcul abouti, quatre avertissements du moteur (#412)",
    isTRUE(resultat()$ok) && length(av) == 4L)
  a("tri_deg : bandeau replie, une seule balise <details> sans attribut open, classe com (#412)",
    length(balises) == 1L && !grepl("open", balises, fixed = TRUE) &&
      identical(balises, "<details class=\"com\">") && grepl("<summary>", h, fixed = TRUE))
  a("tri_deg : resume '4 avertissements de validation du calcul' (#412)",
    grepl("<summary>4 avertissements de validation du calcul</summary>", h, fixed = TRUE))
  a("tri_deg : les quatre textes du moteur, tels quels et dans l'ordre, dans le corps replie (#412)",
    all(vapply(av, function(x) grepl(paste0("<li>", htmltools::htmlEscape(x), "</li>"), h, fixed = TRUE),
               logical(1))) &&
      all(diff(vapply(av, function(x) regexpr(htmltools::htmlEscape(x), h, fixed = TRUE)[1], numeric(1))) > 0) &&
      regexpr("</summary>", h, fixed = TRUE) < regexpr(htmltools::htmlEscape(av[1]), h, fixed = TRUE))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(fichier_import = fichier(12)); grille(session, 12)
  session$setInputs(profondeur = 12, go = 1)
  av <- resultat()$validation$avertissements
  h <- as.character(output$bandeau_avertissements$html)
  a("primes, 12 annees : un seul avertissement, resume au singulier, replie (#412)",
    isTRUE(resultat()$ok) && length(av) == 1L &&
      grepl("<summary>1 avertissement de validation du calcul</summary>", h, fixed = TRUE) &&
      !grepl("avertissements de validation", h, fixed = TRUE) &&
      !grepl("<details[^>]* open", h) &&
      grepl(paste0("<li>", htmltools::htmlEscape(av), "</li>"), h, fixed = TRUE))
})
# Rendu tagList de output$note_surface (#405) : la note de la surface puis, dans
# un bloc distinct de style neutre, l'aide du profil en delta (champ aide de
# note_surface()) quand le profil est trace ; texte lu dans note_surface()
# (R/display_helpers.R), aucune regle ici.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(fichier_import = fichier(12)); grille(session, 12)
  session$setInputs(profondeur = 12, go = 1)
  pd <- resultat()$plots_data
  ns <- note_surface(pd)
  h <- as.character(output$note_surface$html)
  a("note_surface : profil trace, champ aide non vide (#405)",
    isTRUE(resultat()$ok) && !is.null(pd$profil_delta) && !all(is.na(pd$profil_delta$objectif)) &&
      !is.null(ns$aide) && nzchar(ns$aide))
  a("output$note_surface : contient la note de la surface puis l'aide du profil en delta, bloc neutre (#405)",
    grepl(ns$html, h, fixed = TRUE) && grepl(ns$aide, h, fixed = TRUE) &&
      grepl("Profil de vraisemblance en delta : la ligne pointill[^ ]* horizontale \\(rep", h) &&
      grepl("<div style=\"margin-top:6px;color:#7F8C8D;font-size:12.5px\">", h, fixed = TRUE) &&
      regexpr(ns$html, h, fixed = TRUE) < regexpr(ns$aide, h, fixed = TRUE))
})
)---"
  # Import d'un CSV lu en texte (issue #483, #490) : meme motif dans
  # l'application pour le CSV et le xlsx ; donnees courantes gardees.
  .bloc_483 <- r"---(
## Import CSV lu en texte, interpretation par le moteur (issue #483, #490)
depot <- function(lignes = NULL, d = NULL) {
  f <- tempfile(fileext = if (is.null(d)) ".csv" else ".xlsx")
  if (is.null(d)) writeLines(lignes, f) else engine_ecrire_xlsx(d, f)
  data.frame(name = basename(f), size = file.size(f), type = "", datapath = f,
             stringsAsFactors = FALSE)
}
xlsx_dispo <- requireNamespace("zip", quietly = TRUE) || nzchar(Sys.which("zip"))
ser_vide <- c("xt,yt", paste(100:102, 60:62, sep = ","), "", paste(103:107, 63:67, sep = ","))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees()
  session$setInputs(fichier_import = depot(ser_vide))
  m_csv <- statut_import()
  a("import CSV de series a ligne vide intercalee : refuse, motif du moteur, series courantes gardees (#483)",
    identical(m_csv$ok, FALSE) && identical(donnees(), d0) &&
      grepl("Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees 4)", m_csv$msg, fixed = TRUE))
  if (xlsx_dispo) {
    session$setInputs(fichier_import = depot(d = data.frame(xt = c(100:102, NA, 103:107),
                                                            yt = c(60:62, NA, 63:67))))
    # Le statut porte le nom du fichier (#556) : meme motif, nom et extension propres.
    motif483 <- function(st) sub("^.* Motif : ", "", st$msg)
    a("import xlsx du meme tableau : meme motif que le CSV (#483, #556)",
      identical(statut_import()$ok, m_csv$ok) && nzchar(motif483(m_csv)) &&
        identical(motif483(statut_import()), motif483(m_csv)) && identical(donnees(), d0))
  } else a("import xlsx du meme tableau : saute (aucun ecrivain xlsx)", TRUE)
  session$setInputs(fichier_import = depot(c("xt,yt", "100,60", "0x10,61", paste(102:104, 62:64, sep = ","))))
  a("import CSV avec \"0x10\" : refuse comme valeur non numerique (xt : ligne de donnees 2), series courantes gardees (#490)",
    identical(statut_import()$ok, FALSE) && identical(donnees(), d0) &&
      grepl("Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).", statut_import()$msg,
            fixed = TRUE))
  session$setInputs(fichier_import = depot(c("t,xt,yt,", paste0(1:6, ",", 100:105, ",", 60:65, ","))))
  a("import CSV de series valide (colonne de fin sans en-tete) : 6 annees importees, valeurs lues par le moteur (#483)",
    isTRUE(statut_import()$ok) && identical(donnees(), data.frame(t = 1:6, xt = as.numeric(100:105),
                                                                  yt = as.numeric(60:65))))
})
)---"
  # Avertissements de lecture du moteur restitues a l'import d'un triangle
  # (issue #518, R1 d'app-review) : cellules renseignees sous la diagonale
  # (#491), que la grille (i + j <= I) ne montre pas ; CSV dont une ligne
  # compte plus de champs que l'en-tete refuse (C4).
  .bloc_518 <- r"---(
## Avertissements de lecture restitues a l'import, lecture sans nom de ligne (issue #518)
notifs518 <- list()
assign("showNotification", function(ui, ..., type = "default") {
  notifs518[[length(notifs518) + 1L]] <<- list(texte = paste(as.character(ui), collapse = ""), type = type)
  invisible("id")
}, envir = ea)
types518 <- function() vapply(notifs518, `[[`, "", "type")
tri_sous <- ea$triangle_defaut(8); tri_sous[row(tri_sous) + col(tri_sous) - 2L > 7L] <- 1000
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  notifs518 <<- list()
  session$setInputs(fichier_import = fichier_tri(tri_sous))
  lu <- engine_lire_triangle(tri_sous)
  h <- as.character(output$import_statut$html)
  a("import d'un triangle 8 x 8 a cellules sous la diagonale : importe, statut au seul avertissement de #491 (avertissements_lecture du moteur), tel quel (#518)",
    isTRUE(statut_import()$ok) && length(statut_import()$avertissements) == 1L &&
      identical(statut_import()$avertissements, lu$avertissements_lecture) &&
      grepl("sous la diagonale", statut_import()$avertissements, fixed = TRUE) &&
      length(lu$avertissements) > 1L && identical(dim(triangle()), c(8L, 8L)))
  a("import du triangle sous la diagonale : avertissement visible a l'ecran sous le titre Avertissements, sans le vert du succes, sans credibilite ni pourcentage ; notification warning unique (#518)",
    grepl("Avertissements :", h, fixed = TRUE) &&
      grepl(paste0("<li>", htmltools::htmlEscape(lu$avertissements_lecture), "</li>"), h, fixed = TRUE) &&
      !grepl("1E8449", h, fixed = TRUE) && !grepl("%|credibilite|bruites", h) &&
      identical(types518(), "warning") &&
      identical(notifs518[[1]]$texte, "Triangle importe, avec des avertissements : voir le statut d'import."))
  notifs518 <<- list()
  session$setInputs(fichier_import = fichier_tri(ea$triangle_defaut(8)))
  h2 <- as.character(output$import_statut$html)
  a("import d'un triangle 8 x 8 sans cellule sous la diagonale : statut sans avertissement, en vert, sans pourcentage de credibilite, aucune notification warning (N2) (#518)",
    isTRUE(statut_import()$ok) && identical(statut_import()$avertissements, character(0)) &&
      length(engine_lire_triangle(ea$triangle_defaut(8))$avertissements) == 2L &&
      !grepl("Avertissements", h2, fixed = TRUE) && grepl("1E8449", h2, fixed = TRUE) &&
      !grepl("%|credibilite", h2) && !("warning" %in% types518()))
  a("statut_ui() : succes sans avertissement en vert, sans titre Avertissements ; avec avertissement, titre et liste, sans vert (#518)",
    {
      v0 <- as.character(ea$statut_ui(list(ok = TRUE, msg = "ok")))
      v1 <- as.character(ea$statut_ui(list(ok = TRUE, msg = "ok", avertissements = "a < b")))
      grepl("1E8449", v0, fixed = TRUE) && !grepl("Avertissements", v0, fixed = TRUE) &&
        !grepl("1E8449", v1, fixed = TRUE) && grepl("<li>a &lt; b</li>", v1, fixed = TRUE)
    })
  t1 <- triangle()
  session$setInputs(fichier_import = depot(c("j0,j1,j2", "1,300,960,1560", "1,310,980,", "1,320,,")))
  a("import d'un triangle dont les lignes ont plus de champs que l'en-tete : refuse, message fixe du CSV (plus de 'duplicate row.names'), triangle courant garde (#518)",
    identical(statut_import()$ok, FALSE) && identical(triangle(), t1) &&
      grepl(ea$MESSAGE_ILLISIBLE[["csv"]], statut_import()$msg, fixed = TRUE) &&
      !grepl("duplicate", statut_import()$msg, fixed = TRUE))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees()
  session$setInputs(fichier_import = depot(c("xt,yt", paste(2015:2022, 100:107, 60:67, sep = ","))))
  a("import de series 'xt,yt' dont les lignes portent une colonne d'annees de plus : refuse, message fixe du CSV, series courantes gardees, aucune colonne ignoree en silence (#518)",
    identical(statut_import()$ok, FALSE) && identical(donnees(), d0) &&
      grepl(ea$MESSAGE_ILLISIBLE[["csv"]], statut_import()$msg, fixed = TRUE))
  session$setInputs(fichier_import = depot(c("xt,yt,annee", paste(100:107, 60:67, 2015:2022, sep = ","))))
  a("import de series avec une colonne en surnombre NOMMEE : importee, colonne ignoree par nom (convention du moteur), 8 annees (#518)",
    isTRUE(statut_import()$ok) && identical(donnees(), data.frame(t = 1:8, xt = as.numeric(100:107),
                                                                  yt = as.numeric(60:67))))
})
rm("showNotification", envir = ea)
)---"
  # Restitution unique des refus d'import et echec d'export (issue #556) :
  # showNotification() est remplace, dans l'environnement d'app.R, par un
  # releve (texte, type, duree) ; engine_ecrire_xlsx() et engine_ecrire_csv()
  # sont remplaces par une erreur, retiree en sortie. Refus de dimension et du
  # lecteur : voir les blocs de #212 et #522.
  .bloc_556 <- r"---(
## Restitution unique des refus d'import ; echec d'un export (issue #556)
notifs556 <- list()
assign("showNotification", function(ui, ..., type = "default", duration = 5) {
  notifs556[[length(notifs556) + 1L]] <<- list(texte = paste(as.character(ui), collapse = ""),
                                               type = type, duration = duration)
  invisible("id")
}, envir = ea)
dep556 <- function(lignes, ext = ".csv") {
  f <- tempfile(fileext = ext); writeLines(lignes, f)
  data.frame(name = basename(f), size = file.size(f), type = "", datapath = f, stringsAsFactors = FALSE)
}
NOTIF556 <- "Import refuse ; donnees courantes conservees : voir le statut d'import."
ent556 <- function(d, ext) sprintf("Import du fichier %s (%s) refuse ; donnees courantes conservees. Motif : ", d$name, ext)
une_notif556 <- function() length(notifs556) == 1L && identical(notifs556[[1]]$texte, NOTIF556) &&
  identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 8)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees(); t0 <- triangle()
  notifs556 <<- list()
  dr <- dep556(c("xt,yt", "100,60,1", "101,61"))
  suppressMessages(session$setInputs(fichier_import = dr))
  a("import illisible (CSV a ligne plus longue que l'en-tete) : statut \"Import du fichier ... refuse ; donnees courantes conservees. Motif : <MESSAGE_ILLISIBLE>\", notification unique error de 8 s, series gardees (#556)",
    identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg, paste0(ent556(dr, "CSV"), ea$MESSAGE_ILLISIBLE[["csv"]])) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  dx <- dep556("pas un classeur", ".xlsx")
  suppressMessages(session$setInputs(fichier_import = dx))
  a("import illisible (xlsx faux) : meme forme, motif MESSAGE_ILLISIBLE$xlsx, notification unique, series gardees (#556)",
    identical(statut_import()$msg, paste0(ent556(dx, "XLSX"), ea$MESSAGE_ILLISIBLE[["xlsx"]])) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  dv <- dep556(c("xt,zz", "100,60"))
  session$setInputs(fichier_import = dv)
  a("import refuse par la recevabilite du moteur (colonne yt manquante) : nom du fichier, donnees conservees, motif du moteur apres \"Motif : \", notification unique, series gardees (#556)",
    identical(statut_import()$msg, paste0(ent556(dv, "CSV"), engine_lire_donnees_csv(
      data.frame(xt = "100", zz = "60"))$erreurs)) &&
      grepl("Motif : Colonne(s) manquante(s) : yt.", statut_import()$msg, fixed = TRUE) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  session$setInputs(methode = "reserve2", reinit = 2)
  t0 <- triangle(); notifs556 <<- list()
  dt <- dep556(c("i,j0,j1,j2", "0,1,2,3", "1,4,5,", "2,6,,", "3,7,,"))
  session$setInputs(fichier_import = dt)
  lu556 <- engine_lire_triangle(utils::read.csv(dt$datapath, colClasses = "character", check.names = FALSE,
                                                na.strings = character(0), row.names = NULL))
  a("import de triangle refuse par la recevabilite du moteur (triangle non carre) : meme forme, notification unique, triangle gardee (#556)",
    !lu556$ok && identical(statut_import()$msg, paste0(ent556(dt, "CSV"), paste(lu556$erreurs, collapse = " "))) &&
      une_notif556() && identical(triangle(), t0) && identical(donnees(), d0))
})
# Echec d'un export : journal, notification (texte, type, duree), erreur relevee.
journal556 <- character(0)
tente556 <- function(expr) withCallingHandlers(tryCatch(expr, error = function(e) e),
  message = function(m) { journal556 <<- c(journal556, conditionMessage(m)); invokeRestart("muffleMessage") })
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  notifs556 <<- list(); journal556 <<- character(0)
  assign("engine_ecrire_xlsx", function(...) stop(structure(class = c("usp_refus_ecriture", "error", "condition"),
    list(message = "Ecriture du fichier .xlsx impossible : cause de test.", call = NULL))), envir = ea)
  e <- tente556(output$dl_donnees_xlsx)
  rm("engine_ecrire_xlsx", envir = ea)
  a("export xlsx en echec par usp_refus_ecriture : notification error de 10 s \"Export impossible : <texte du moteur>\", cause au journal, erreur relevee au texte utilisateur (#556)",
    length(notifs556) == 1L &&
      identical(notifs556[[1]]$texte, "Export impossible : Ecriture du fichier .xlsx impossible : cause de test.") &&
      identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 10) &&
      any(grepl("cause de test", journal556, fixed = TRUE)) &&
      inherits(e, "error") && identical(conditionMessage(e), notifs556[[1]]$texte))
  notifs556 <<- list(); journal556 <<- character(0)
  assign("engine_ecrire_csv", function(...) stop("impossible d'ouvrir le fichier 'cause R brute' : Permission denied"), envir = ea)
  e <- tente556(output$dl_donnees)
  rm("engine_ecrire_csv", envir = ea)
  a("export CSV en echec par une erreur R ordinaire : texte fixe sans la cause R, cause au journal, erreur relevee (#556)",
    length(notifs556) == 1L &&
      identical(notifs556[[1]]$texte, "Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).") &&
      identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 10) &&
      !grepl("cause R brute", notifs556[[1]]$texte, fixed = TRUE) &&
      any(grepl("cause R brute", journal556, fixed = TRUE)) &&
      inherits(e, "error"))
  a("export CSV en echec : message de l'erreur relevee = texte destine a l'utilisateur, sans la cause R brute ni le chemin (corps de la page d'erreur HTTP 500 de shiny) (#556)",
    identical(conditionMessage(e), "Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).") &&
      !grepl("cause R brute|Permission", conditionMessage(e)))
  notifs556 <<- list(); journal556 <<- character(0)
  f <- tente556(output$dl_donnees)
  a("export CSV reussi : fichier ecrit, aucune notification, aucune ligne de journal (#556)",
    is.character(f) && file.exists(f) && !length(notifs556) && !length(journal556))
  # Export sans resultat (req(resultat()) : erreur silencieuse de shiny) : pas
  # un echec d'ecriture, aucune notification ; l'erreur reste relevee.
  e <- tente556(output$dl_tests)
  a("export des tests sans resultat : erreur silencieuse de shiny relevee, ni notification ni journal (#556)",
    inherits(e, "shiny.silent.error") && !length(notifs556) && !length(journal556))
})
rm("showNotification", envir = ea)
)---"
  # Repere de profondeur (issue #499) : texte et seuil poses par le moteur
  # seul (T < 10, I + 1 < 10), restitues apres calcul une fois dans la liste
  # repliee de bandeau_avertissements et une fois, non replie, en tete de
  # l'onglet Tests (champ validation$repere_profondeur, decision du
  # mainteneur du 10/11/2026) ; l'ancien bandeau_T (seuil T >= 15 propre a
  # l'affichage, phrase "Profondeur suffisante...") est retire.
  .bloc_499 <- r"---(
## Repere de profondeur du moteur : bandeau replie et onglet Tests (issue #499)
non_rejet <- "Une p-value elevee ne demontre pas la validite de l'hypothese : elle ne permet pas de la rejeter."
repere <- function(av) av[grepl("lois asymptotiques peu fiables|estimateurs de variance tres bruites", av)]
sans_bandeau_T <- function(output) inherits(tryCatch(output$bandeau_T, error = function(e) e), "error")
verif_499 <- function(lib, attendu, output, r) {
  av <- r$validation$avertissements; rp <- repere(av)
  h <- if (length(av)) as.character(output$bandeau_avertissements$html) else ""
  occ <- lengths(regmatches(h, gregexpr("lois asymptotiques peu fiables|estimateurs de variance tres bruites", h)))
  a(sprintf("%s : repere du moteur %s, une seule fois au plus dans le bandeau replie, texte du moteur tel quel, sans bandeau_T (#499)",
            lib, if (attendu) "present (phrase de non-rejet)" else "absent"),
    isTRUE(r$ok) && length(rp) == as.integer(attendu) && occ == as.integer(attendu) &&
      (!attendu || (endsWith(rp, non_rejet) &&
                      grepl(paste0("<li>", htmltools::htmlEscape(rp), "</li>"), h, fixed = TRUE))) &&
      sans_bandeau_T(output) && !grepl("Profondeur suffisante", h, fixed = TRUE))
  # Onglet Tests : le champ du moteur, egal au repere des avertissements,
  # une fois et non replie (aucun <details>), ou rien s'il est vide.
  ht <- as.character(output$tests_par_hypothese$html)
  occ_t <- lengths(regmatches(ht, gregexpr("repere-profondeur", ht, fixed = TRUE)))
  a(sprintf("%s : onglet Tests, champ repere_profondeur %s (#499)",
            lib, if (attendu) "affiche une fois, non replie, egal au repere des avertissements" else "vide, aucun bandeau"),
    identical(r$validation$repere_profondeur, rp) && occ_t == as.integer(attendu) &&
      (!attendu || grepl(paste0("<div class='avert repere-profondeur'>", htmltools::htmlEscape(rp), "</div>"),
                         ht, fixed = TRUE)) &&
      !grepl("<details[^>]*>[^<]*<summary[^>]*>[^<]*</summary>[^<]*<div class='avert repere-profondeur'>", ht))
}
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  for (n in c(8L, 12L, 15L)) {
    session$setInputs(fichier_import = fichier(n)); grille(session, n)
    session$setInputs(profondeur = n, go = n)
    verif_499(sprintf("primes, T = %d", n), n < 10L, output, resultat())
  }
})
tri6 <- matrix(NA_real_, 6, 6)
tri6[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri6[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri6[3, 1:4] <- c(900, 1395, 1580, 1580)
tri6[4, 1:3] <- c(1200, 1980, 2210)
tri6[5, 1:2] <- c(1050, 1638)
tri6[6, 1]   <- 980
for (cas in list(list(tri = tri6, attendu = TRUE), list(tri = tri10, attendu = FALSE))) {
  testServer(app, {
    do.call(session$setInputs, c(base, list(reinit = 1)))
    session$setInputs(methode = "reserve2", reinit = 2)
    session$setInputs(fichier_import = fichier_tri(cas$tri))
    tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
    do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
    session$setInputs(go = 1)
    verif_499(sprintf("reserve no 2, I + 1 = %d", nrow(cas$tri)), cas$attendu, output, resultat())
  })
}
)---"
  # Conservation de la saisie de la grille au changement de methode (issue
  # #497). Mesure avant correction (testServer, 10/11/2026) : x_1 = 999 puis
  # "reserve2" puis "premium" : x_1 = 104,2 ; c_0_0 = 12345 puis "reserve1"
  # puis "reserve2" : c_0_0 = 300. Le navigateur rend la grille apres un
  # import ou une reinitialisation et renvoie ses champs : grille() et
  # tri_champs() le reproduisent.
  .bloc_497 <- r"---(
## Saisie de la grille conservee au changement de methode (issue #497)
d497 <- ea$DONNEES_DEFAUT; t497 <- ea$triangle_defaut(8)
tri_champs <- function(tr) { k <- which(!is.na(tr), arr.ind = TRUE)
  setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)) }
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(x_1 = 999, y_2 = 555)
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("series : x_1 = 999 et y_2 = 555 conserves apres premium, reserve2, premium (#497)",
    identical(donnees()$xt[1], 999) && identical(donnees()$yt[2], 555) &&
      identical(donnees()$xt[-1], d497$xt[-1]) && identical(donnees()$yt[-2], d497$yt[-2]) &&
      a_val(grille_html(output), "x_1", "999") && a_val(grille_html(output), "y_2", "555"))
  session$setInputs(methode = "reserve1")
  a("series : x_1 = 999 conserve de premium a reserve1, sans changement de famille (#497)",
    identical(donnees()$xt[1], 999) && a_val(grille_html(output), "x_1", "999"))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(c_0_0 = 12345)
  session$setInputs(methode = "reserve1")
  session$setInputs(methode = "reserve2")
  tr <- triangle(); att <- t497; att[1, 1] <- 12345
  a("triangle : c_0_0 = 12345 conserve apres reserve2, reserve1, reserve2, autres cellules intactes (#497)",
    identical(tr, att) && a_val(grille_html(output), "c_0_0", "12345"))
})
# Champ non rendu (entree absente) : le triangle, jamais affiche dans cette
# session, n'est pas vide au retour des series.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  t0 <- triangle()
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("triangle sans champ rendu : valeurs stockees gardees au retour aux series (#497)",
    identical(triangle(), t0) && identical(donnees(), d497))
})
# Import et reinitialisation remplacent toujours la saisie : la recopie ne
# s'execute qu'au changement de methode et relit les champs rendus apres eux.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(x_1 = 999)
  session$setInputs(fichier_import = fichier(6)); grille(session, 6)
  imp <- read.csv(fichier(6)$datapath)
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("series : import apres la saisie, la serie importee remplace x_1 = 999 et survit a l'aller-retour (#497)",
    nrow(donnees()) == 6L && identical(donnees()$xt, imp$xt) && identical(donnees()$yt, imp$yt) &&
      !a_val(grille_html(output), "x_1", "999"))
  session$setInputs(x_1 = 888)
  session$setInputs(reinit = 2)
  do.call(session$setInputs, c(setNames(as.list(d497$xt), paste0("x_", 1:8)),
                               setNames(as.list(d497$yt), paste0("y_", 1:8))))
  session$setInputs(methode = "reserve1")
  session$setInputs(methode = "premium")
  a("series : Reinitialiser apres la saisie, le jeu par defaut remplace x_1 = 888 et survit a l'aller-retour (#497)",
    identical(donnees(), d497) && a_val(grille_html(output), "x_1", "104.2"))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(c_0_0 = 12345)
  session$setInputs(fichier_import = fichier_tri(tri10))
  do.call(session$setInputs, tri_champs(tri10))
  session$setInputs(methode = "premium")
  session$setInputs(methode = "reserve2")
  a("triangle : import apres la saisie, le triangle importe remplace c_0_0 = 12345 et survit a l'aller-retour (#497)",
    meme_tri(triangle(), tri10) && !a_val(grille_html(output), "c_0_0", "12345"))
  session$setInputs(c_0_0 = 777)
  session$setInputs(reinit = 3)   # T saisi = 8 : triangle par defaut 8 x 8
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(methode = "premium")
  session$setInputs(methode = "reserve2")
  a("triangle : Reinitialiser apres la saisie, le triangle par defaut remplace c_0_0 = 777 et survit a l'aller-retour (#497)",
    meme_tri(triangle(), t497) && a_val(grille_html(output), "c_0_0", "300"))
})
)---"
  # Exports des donnees (issue #488) : output$dl_donnees (CSV) et
  # output$dl_donnees_xlsx telecharges en testServer (chemin du fichier
  # ecrit), relus comme a l'import ; valeurs identical() a la saisie.
  .bloc_488 <- r"---(
## Exports des donnees relus au bit (issue #488)
g488 <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1 + 0.2, 5e-324, 7)
relire488 <- function(f, xlsx) ea$lire_tableau(f, xlsx)$df
# Export xlsx saute, et signale dans le libelle, sans paquet ni commande zip
# (meme nombre d'assertions dans les deux cas).
xlsx488 <- requireNamespace("zip", quietly = TRUE) || nzchar(Sys.which("zip"))
saut488 <- if (xlsx488) "" else " ; xlsx saute (ni paquet ni commande zip)"
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, c(setNames(as.list(g488), paste0("x_", 1:8)),
                               setNames(as.list(rev(g488)), paste0("y_", 1:8))))
  sa <- lire_saisie()
  rc <- engine_lire_donnees_csv(relire488(output$dl_donnees, FALSE))
  ok_x <- !xlsx488 || {
    rx <- engine_lire_donnees_csv(relire488(output$dl_donnees_xlsx, TRUE))
    identical(rx$xt, sa$xt) && identical(rx$yt, sa$yt)
  }
  a(paste0("export des series (CSV et xlsx) : saisie a 17 chiffres (1/3, 0.1+0.2, 1e-300, 1.7976931348623157e308, 5e-324) relue identical() (#488)", saut488),
    identical(sa$xt, g488) && identical(sa$yt, rev(g488)) &&
      identical(rc$xt, sa$xt) && identical(rc$yt, sa$yt) && ok_x)
  session$setInputs(methode = "reserve2")
  session$setInputs(reinit = 2)
  t488 <- ea$triangle_defaut(8) * pi / 3
  cel <- list()
  for (i in 0:7) for (j in 0:(7 - i)) cel[[paste0("c_", i, "_", j)]] <- t488[i + 1, j + 1]
  do.call(session$setInputs, cel)
  m <- lire_triangle()
  tc <- engine_lire_triangle(relire488(output$dl_donnees, FALSE))
  ok_x <- !xlsx488 || {
    tx <- engine_lire_triangle(relire488(output$dl_donnees_xlsx, TRUE))
    isTRUE(tx$ok) && identical(tx$triangle, m)
  }
  a(paste0("export du triangle (CSV et xlsx) : cellules a 17 chiffres relues identical() par engine_lire_triangle() (#488)", saut488),
    identical(m, unname(t488)) && isTRUE(tc$ok) && identical(tc$triangle, m) && ok_x)
})
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
    '  # Regle de repli de #517 : le rendu replie si et seulement si',
    '  # .commentaire_replie() replie un texte de la vue, et chaque cellule',
    '  # (Motif / commentaire, H0, H1) est rendue telle que la regle la produit :',
    '  # un repli absent ou mal place change la cellule et fait echouer le test.',
    '  # Lignes affichees : selection courante de l\'onglet (filtrer_selection).',
    '  tb_aff <- TB(); tb_aff <- tb_aff[filtrer_selection(tb_aff, sel_courante()), , drop = FALSE]',
    '  cel_att <- unlist(table_detail_groupe(tb_aff, replier = TRUE)[c("Motif / commentaire", "H0", "H1")])',
    '  attendu_repli <- any(startsWith(cel_att, "<details class=\'com\'>"))',
    '  a("vue Detail : repli present si et seulement si la regle de repli replie un texte de la vue (#178, #517)",',
    '    identical(grepl("<details class=\'com\'><summary>", dt, fixed = TRUE), attendu_repli))',
    '  a("vue Detail : chaque cellule de commentaire, H0 et H1 des lignes affichees rendue comme la regle de repli la produit (#517)",',
    '    length(cel_att) > 0L && all(vapply(unname(cel_att), grepl, NA, x = dt, fixed = TRUE)))',
    '  a("vue Detail : tableau dans le cadre defilant defil-detail (hauteur bornee, defilement dans les deux sens, en-tete colle, #525), largeur minimale de la colonne Motif / commentaire, colonne Fonction (#517, #178)",',
    '    grepl("<div class=\\"defil-detail\\"><table class=\'table table-condensed data\'>", dt, fixed = TRUE) &&',
    '    grepl(paste0("<th style=\'min-width:", LARGEURS_DETAIL[["Motif / commentaire"]], "px\'>Motif / commentaire</th>"), dt, fixed = TRUE) &&',
    '      grepl("<th>Fonction</th>", dt, fixed = TRUE) && grepl("<code>test_intercept</code>", dt, fixed = TRUE))',
    '  a("vue Detail : colonne granularite MC lue dans le bootstrap, au moins une valeur (#285)",',
    '    grepl("<th>granularit\u00e9 MC</th>", dt, fixed = TRUE) &&',
    '      any(is.finite(granularite_lignes(engine_table_tests(r), r$bootstrap))))',
    '  session$setInputs(vue_tests = "synth")',
    '  sy <- as.character(output$tests_par_hypothese$html)',
    '  a("vue Synthese : ni repli ni colonne Fonction ni granularite MC (#178, #285)",',
    '    !grepl("<details", sy, fixed = TRUE) && !grepl("<th>Fonction</th>", sy, fixed = TRUE) &&',
    '      !grepl("min-width", sy, fixed = TRUE) && !grepl("defil-detail", sy, fixed = TRUE) &&',
    '      grepl("<div style=\\"overflow-x:auto\\"><table class=\'table table-condensed data\'>", sy, fixed = TRUE) &&',
    '      !grepl("granularit\u00e9 MC", sy, fixed = TRUE))',
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
    '  session$setInputs(fichier_import = fichier(41))',
    '  ap <- apercu(output)',
    '  # Assertion modifiee par #286 (option (a)) : 41 annees sont refusees ; la',
    '  # serie de 4 annees reste chargee et l\'apercu s\'evalue avec T = 8.',
    '  a("import n = 41 (au-dela de 40) : refuse, 4 annees gardees, garde non posee, apercu evalue avec T = 8 (#183, #286)",',
    '    nrow(donnees()) == 4L && identical(statut_import()$ok, FALSE) &&',
    '      is.null(profondeur_import()) && is.character(ap) &&',
    '      grepl("Profondeur T = 8 superieure au nombre d\'annees fournies (4).", ap, fixed = TRUE))',
    '})', .bloc_155, .bloc_212, .bloc_212_garde, .bloc_236_base, .bloc_199, .bloc_240, .bloc_498, .bloc_226, .bloc_236, .bloc_380, .bloc_412, .bloc_483, .bloc_499, .bloc_497, .bloc_518, .bloc_488, .bloc_556), .script)
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
  verifier("processus Shiny : 149 assertions rendues", length(.lignes) == 149L)
  if (length(.lignes) != 149L) cat(utils::tail(.sortie, 10), sep = "\n")
  for (.l in strsplit(.lignes, "\t", fixed = TRUE))
    verifier(paste("Application :", .l[2]), identical(.l[3], "TRUE"))
} else {
  cat("  note : shiny absent ; grille, journal, apercu, vue Detail, dimension du triangle et table des controles (#199) non exerces (attendu en CI, comme plotly, issue #53).\n")
}

fin_fichier()
