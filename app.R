###############################################################################
#  app.R  --  APPLICATION SHINY (couche interface uniquement)
#
#  Paramètres propres à l'entreprise (USP) - Solvabilité II, annexe XVII.
#
#  ARCHITECTURE IMPERATIVE
#  Ce fichier ne contient AUCUN calcul statistique, actuariel, de test, de
#  bootstrap ou de calibration. Il se limite a :
#     1. collecter les entrees (xt, yt, parametres) ;
#     2. appeler run_engine() de R/engine.R sur clic ;
#     3. conserver l'objet retourne ;
#     4. afficher les elements de cet objet.
#  Toute la logique quantitative est dans R/engine.R, qui reste utilisable
#  hors Shiny (source("R/engine.R") puis run_engine(...)).
#
#  Lancement :  shiny::runApp(".")
###############################################################################

library(shiny)
if (requireNamespace("plotly", quietly = TRUE)) library(plotly)

source("R/engine.R", local = FALSE)
source("R/display_helpers.R", local = FALSE)

# Identite du code (version DESCRIPTION, md5 de R/engine.R), relevee au
# moment ou le moteur est charge ; reportee dans le rapport fige.
IDENTITE_CODE <- identite_code(".")

# Sortie graphique polymorphe : plotly si le paquet est disponible, graphique
# de base sinon. Choix de rendu uniquement, sans effet sur les donnees.
sortie_graphique <- function(id, hauteur = "330px") {
  if (requireNamespace("plotly", quietly = TRUE))
    plotly::plotlyOutput(id, height = hauteur)
  else plotOutput(id, height = hauteur)
}

# Les fonctions render*() de Shiny CAPTURENT leur argument sans l'evaluer.
# Il faut donc leur transmettre l'expression deja citee ET l'environnement
# d'evaluation, via les arguments `env` et `quoted` -- c'est l'idiome prevu
# par Shiny pour envelopper un render dans une fonction. Une version anterieure
# passait eval(expr, parent.frame()) directement : l'expression litterale
# etait alors stockee puis reevaluee dans la frame du render, ou les objets
# reactifs de la fonction server ne sont plus visibles.
rendu_graphique <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr); quoted <- TRUE }
  # force(env) est indispensable : `env` est une promesse valant
  # parent.frame(), qui serait sinon evaluee paresseusement DANS la frame de
  # renderPlotly() et designerait alors le mauvais environnement. On la fige
  # ici, tant que la frame appelante est encore celle de la fonction server.
  force(env)
  if (requireNamespace("plotly", quietly = TRUE))
    plotly::renderPlotly(expr, env = env, quoted = quoted)
  else shiny::renderPlot(expr, env = env, quoted = quoted)
}


# Fichiers d'echange, produits par les boutons d'export de l'onglet Donnees.
# Un fichier par methode : les deux formats sont incompatibles (deux vecteurs
# d'un cote, un triangle de l'autre), ce qui evite qu'un passage d'une methode
# a l'autre ecrase ou reinterprete a tort les donnees de la premiere.
FICHIER_LN <- "usp_donnees_LN.csv"     # methodes lognormales (prime, reserve 1)
FICHIER_MW <- "usp_donnees_MW.csv"     # methode Merz-Wuthrich (reserve 2)

# Libelles du bandeau de refus. Quatre natures, distinguees par l'endroit ou
# le calcul s'est arrete (issue #94, suites de #87 et #88) :
#  - avant tout appel au moteur (controles de validite) : TITRE_NON_LANCE ;
#  - run_engine() retourne ok = FALSE sans validation$erreur_r : refus des
#    donnees ou des parametres (profondeur T, reserve ou MSEP de Merz-
#    Wuthrich...) : TITRE_REFUSE ;
#  - run_engine() retourne ok = FALSE avec validation$erreur_r : defaut de
#    calcul intercepte par le moteur apres une validation reussie :
#    TITRE_DEFAUT ;
#  - run_engine() leve une erreur R (branche try-error) : erreur d'usage,
#    argument rejete par le moteur : TITRE_ERREUR.
# Le motif detaille vient toujours du moteur ; ces libelles ne font que le
# presenter. Une pile d'appels n'est jamais affichee : elle va au journal.
TITRE_NON_LANCE <- paste("Calcul non lance : les donnees saisies n'ont pas passe",
                         "les controles de validite du moteur.")
TITRE_REFUSE    <- paste("Calcul refuse par le moteur : les donnees ou les parametres",
                         "transmis ne sont pas recevables.")
TITRE_DEFAUT    <- paste("Defaut de calcul : le moteur a accepte les donnees, mais le",
                         "calcul s'est interrompu sur une erreur interne, interceptee",
                         "par le moteur ; aucun resultat n'est produit.")
TITRE_ERREUR    <- paste("Erreur d'usage : le moteur a rejete un parametre transmis ;",
                         "aucun resultat n'est produit.")

# Lignes ajoutees au motif du moteur, sans rien decider : elles disent ou
# trouver le diagnostic, ou quel champ de l'interface corriger.
AIDE_DEFAUT <- paste("Le diagnostic technique (message R, appel, pile) est consigne",
                     "dans le journal de la session R ; le transmettre avec les",
                     "donnees et les parametres utilises.")
AIDE_USAGE  <- "Verifier les parametres du panneau de droite."
AIDE_T_VIDE <- paste("Le champ \"Profondeur T retenue\" du panneau de droite est vide :",
                     "y saisir le nombre d'annees a retenir.")

# Journal de la session R (console, sortie d'erreur) : seul endroit ou un
# message R brut ou une pile d'appels est ecrit.
journaliser <- function(contexte, lignes)
  message(sprintf("[outil USP] %s\n  %s", contexte, paste(lignes, collapse = "\n  ")))

# Explication commune : elle dit pourquoi l'ecran est vide. Le resultat du
# calcul precedent est retire de l'affichage ET des exports, pour qu'aucun
# livrable ne puisse porter un sigma_USP ou des verdicts obtenus sur d'autres
# donnees que celles actuellement saisies.
EXPLICATION_REFUS <- paste(
  "Aucun resultat n'est affiche. Le resultat du calcul precedent a ete retire",
  "de l'ecran et des exports, pour qu'aucun livrable ne porte un sigma_USP ou",
  "des verdicts obtenus sur d'autres donnees que celles actuellement saisies.",
  "Corrigez les donnees ou les parametres, puis relancez les calculs.")

DONNEES_DEFAUT <- data.frame(
  t  = 1:8,
  xt = c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22),
  yt = c( 68.97,  76.76,  83.49,  95.38,  88.96,  70.22,  78.89, 117.37)
)

# Triangle par defaut : 8 annees d'accident, cumules croissants, servant de
# point de depart lorsqu'aucun fichier n'est disponible.
# seq_len(T)[-1] et non 2:T : pour T = 1, 2:1 vaut c(2, 1) et la colonne 2
# n'existe pas (issue #100) ; triangle identique pour T >= 2.
# Au-dela des dix facteurs de f (T >= 12), le dernier facteur est prolonge
# (issue #108) : f[j - 1] valait NA et le NA gagnait la partie observee du
# triangle, refusee au clic par mw_valider_triangle(). Triangle identique
# pour T <= 11. Donnees de demonstration synthetiques.
triangle_defaut <- function(T = 8) {
  f <- c(3.20, 1.65, 1.32, 1.14, 1.08, 1.05, 1.02, 1.01, 1.005, 1.003)
  base <- seq(300, 380, length.out = T)
  tri <- matrix(NA_real_, T, T)
  tri[, 1] <- base
  for (j in seq_len(T)[-1]) tri[, j] <- round(tri[, j - 1] * f[min(j - 1, length(f))] *
                                                (1 + 0.02 * sin(seq_len(T) + j)), 2)
  for (i in 1:T) if (T - i + 1 < T) tri[i, (T - i + 2):T] <- NA_real_
  tri
}

# Chargement des fichiers d'echange au demarrage. La lecture disque est faite
# ici ; l'interpretation et les controles reviennent au moteur
# (engine_lire_donnees_csv(), engine_valider_donnees(), engine_lire_triangle()).
# Aucun remplacement silencieux (issue #33, #4 piste 3) : un fichier present
# mais refuse laisse une grille VIDE et un statut affiche dans l'onglet
# Donnees ; le jeu par defaut n'est charge que si aucun fichier n'existe, ou
# sur clic de "Reinitialiser les donnees". Chaque fonction renvoie
# list(valeur, statut) ; statut vaut NULL si aucun fichier n'existe.
statut_fichier <- function(ok, src, texte)
  list(ok = ok, msg = sprintf("Fichier %s %s", src, texte))

REFUS_DEMARRAGE <- paste("Aucune donnee n'a ete chargee a sa place : corriger le",
                         "fichier puis l'importer, ou cliquer sur \"Reinitialiser les",
                         "donnees\" pour charger le jeu par defaut.")

grille_vide_ln <- function(T) data.frame(t = seq_len(T), xt = NA_real_, yt = NA_real_)
triangle_vide <- function(T) matrix(NA_real_, T, T)

# Lecture disque d'un fichier d'echange (demarrage) ou d'import (issue #94).
# Une erreur de lecture n'est jamais montree telle quelle a l'utilisateur :
# elle est remplacee par un message fixe selon le format, et le message R est
# consigne dans le journal. Les avertissements de lecture ne sont pas
# modifies. L'interpretation du tableau lu reste au moteur
# (engine_lire_donnees_csv(), engine_lire_triangle()). Retourne list(df,
# erreur) : erreur vaut NULL si la lecture a abouti, le message fixe sinon.
MESSAGE_ILLISIBLE <- c(
  xlsx = paste("illisible comme classeur Excel : verifier qu'il s'agit d'un fichier",
               ".xlsx valide et non corrompu, dont la premiere feuille porte les donnees."),
  csv  = paste("illisible comme tableau (fichier vide, binaire ou mal structure) :",
               "verifier l'encodage, le separateur (virgule attendue) et que chaque",
               "ligne a autant de valeurs que la ligne d'en-tete."))
lire_tableau <- function(chemin, xlsx, nom = basename(chemin), ...) {
  df <- tryCatch(if (xlsx) engine_lire_xlsx(chemin)
                 else utils::read.csv(chemin, stringsAsFactors = FALSE, ...),
                 error = function(e) e)
  if (!inherits(df, "error")) return(list(df = df, erreur = NULL))
  journaliser(sprintf("Lecture du fichier %s impossible", nom), conditionMessage(df))
  list(df = NULL, erreur = MESSAGE_ILLISIBLE[[if (xlsx) "xlsx" else "csv"]])
}

# Le nombre d'annees T est deduit du fichier lui-meme : il n'est pas impose
# par une valeur par defaut. Le classeur Excel est cherche en premier, puis le CSV.
charger_ln <- function() {
  x <- sub("\\.csv$", ".xlsx", FICHIER_LN)
  src <- if (file.exists(x)) x else FICHIER_LN
  if (!file.exists(src)) return(list(valeur = DONNEES_DEFAUT, statut = NULL))
  refus <- function(motifs) list(valeur = grille_vide_ln(nrow(DONNEES_DEFAUT)),
    statut = statut_fichier(FALSE, src, paste("present mais refuse au demarrage :",
                                              paste(motifs, collapse = " "), REFUS_DEMARRAGE)))
  lu <- lire_tableau(src, grepl("xlsx$", src))
  if (!is.null(lu$erreur)) return(refus(lu$erreur))
  r <- engine_lire_donnees_csv(lu$df)
  if (!r$ok) return(refus(r$erreurs))
  d <- data.frame(t = seq_along(r$xt), xt = r$xt, yt = r$yt)
  # Donnees lisibles mais hors des controles de validite : chargees pour
  # etre corrigees dans la grille, avec les motifs du moteur (le calcul reste
  # bloque par les memes controles au clic).
  v <- engine_valider_donnees(r$xt, r$yt)
  list(valeur = d, statut = if (v$ok)
    statut_fichier(TRUE, src, sprintf("charge au demarrage (%d annees).", r$n))
    else statut_fichier(FALSE, src, paste("charge au demarrage, mais les donnees ne passent",
                                          "pas les controles de validite du moteur :",
                                          paste(v$erreurs, collapse = " "))))
}

# Triangle : une colonne par annee de developpement, une ligne par annee
# d'accident, cellules non observees vides ; conversion et controle de
# recevabilite par engine_lire_triangle() (moteur).
charger_mw <- function() {
  x <- sub("\\.csv$", ".xlsx", FICHIER_MW)
  src <- if (file.exists(x)) x else FICHIER_MW
  if (!file.exists(src)) return(list(valeur = triangle_defaut(8), statut = NULL))
  refus <- function(motifs) list(valeur = triangle_vide(8),
    statut = statut_fichier(FALSE, src, paste("present mais refuse au demarrage :",
                                              paste(utils::head(motifs, 6), collapse = " "),
                                              REFUS_DEMARRAGE)))
  lu <- lire_tableau(src, grepl("xlsx$", src), row.names = NULL)
  if (!is.null(lu$erreur)) return(refus(lu$erreur))
  r <- engine_lire_triangle(lu$df)
  if (!r$ok) return(refus(r$erreurs))
  list(valeur = r$triangle,
       statut = statut_fichier(TRUE, src, sprintf("charge au demarrage (triangle %d x %d).",
                                                  nrow(r$triangle), ncol(r$triangle))))
}

CHARGE_LN <- charger_ln()
CHARGE_MW <- charger_mw()
DONNEES_INIT  <- CHARGE_LN$valeur
TRIANGLE_INIT <- CHARGE_MW$valeur
T_INIT        <- nrow(DONNEES_INIT)

# ---------------------------------------------------------------------------
# UI : zone principale a gauche, panneau de parametres a DROITE
# ---------------------------------------------------------------------------
ui <- fluidPage(
  title = "USP Solvabilite II - annexe XVII",
  tags$head(tags$style(HTML("
    body { background:#FDFEFE; }
    h4 { margin-top: 4px; }
    .bloc { background:#fff; border:1px solid #E5E8E8; border-radius:6px;
            padding:12px 14px; margin-bottom:12px; }
    .cle { font-size:26px; font-weight:700; color:#B03A2E; }
    .avert { background:#FEF9E7; border-left:4px solid #B9770E;
             padding:9px 12px; margin-bottom:10px; font-size:13px; }
    .err { background:#FDEDEC; border-left:4px solid #922B21;
           padding:9px 12px; margin-bottom:10px; font-size:13px; }
    table.data { font-size:12.5px; }
    /* Grille de saisie du triangle : cellules larges, en-tetes figes. */
    table.triangle { border-collapse:separate; border-spacing:3px 2px; }
    table.triangle th { font-weight:600; color:#00468C; font-size:12px;
                        text-align:center; padding:2px 4px; white-space:nowrap; }
    table.triangle tbody th { text-align:right; padding-right:8px; }
    table.triangle td { padding:0; vertical-align:middle; }
    table.triangle td.vide { color:#CCC; text-align:center; font-size:13px; }
    table.triangle .form-group { margin-bottom:0; }
    table.triangle input.form-control { padding:3px 6px; height:30px;
                                        font-size:12.5px; text-align:right; }
  "))),

  fluidRow(
    column(
      width = 9,
      h3("Parametres propres a l'entreprise — risque de prime et de reserve"),
      uiOutput("bandeau_refus"),
      div(class = "avert", uiOutput("bandeau_T")),
      tabsetPanel(
        id = "onglets", type = "tabs",

        # ----------------------------- DONNEES ----------------------------
        tabPanel(
          "Donnees",
          br(),
          div(class = "bloc",
              h4(textOutput("titre_donnees", inline = TRUE)),
              uiOutput("aide_donnees"),
              fluidRow(
                column(4, br(), actionButton("reinit", "Reinitialiser les donnees")),
                column(2, br(), downloadButton("dl_donnees", "Export CSV")),
                column(2, br(), downloadButton("dl_donnees_xlsx", "Export Excel")),
                column(4, fileInput("fichier_import", "Importer",
                                    accept = c(".csv", ".xlsx"), buttonLabel = "Parcourir",
                                    placeholder = "CSV ou Excel"))
              ),
              uiOutput("statut_demarrage"),
              uiOutput("import_statut"),
              conditionalPanel("input.methode == 'reserve2'",
                helpText(paste("Le nombre d'annees T se regle dans le panneau de",
                               "parametres, a droite. Le triangle de saisie s'y adapte",
                               "automatiquement."))),
              conditionalPanel("input.methode != 'reserve2'",
                helpText(paste("La grille porte toutes les annees fournies (t = 1 la plus",
                               "ancienne). La profondeur T du panneau de droite ne la",
                               "modifie pas : au clic, le moteur retient les T annees les",
                               "plus recentes, et une troncature est signalee dans les",
                               "resultats.")),
                fluidRow(
                  column(4, actionButton("ajouter_annee", "Ajouter une annee")),
                  column(4, actionButton("retirer_annee", "Retirer la derniere ligne"))),
                br()),
              uiOutput("grille_donnees")),
          div(class = "bloc",
              h4("Controles de validite"),
              helpText(paste("Ces controles ont une signification statistique et",
                             "actuarielle : ils sont implementes dans engine.R",
                             "et non dans l'interface. Apres le calcul, la table",
                             "comprend aussi les controles numeriques de",
                             "l'estimation (famille H : condition du premier",
                             "ordre, convergence multi-demarrages) ; un ECHEC y",
                             "est signale sans bloquer le calcul.")),
              uiOutput("validation_live"),
              tableOutput("tab_controles"))
        ),

        # ------------------------------ TESTS -----------------------------
        tabPanel(
          "Tests statistiques",
          br(),
          tabsetPanel(
            tabPanel(
              "Resultats", br(),
              div(class = "bloc",
                  helpText(HTML(paste(
                    "Nature de la p-value retenue :",
                    "<b style='color:#1E8449'>exacte</b> &gt;",
                    "<b style='color:#00468C'>Monte-Carlo</b> &gt;",
                    "<b style='color:#B9770E'>asymptotique</b>.",
                    "Les p-values <b style='color:#7D3C98'>sous le mod&egrave;le auxiliaire MCO</b>",
                    "(TOST, pente, Fisher) sont hors hi&eacute;rarchie : elles ne sont retenues",
                    "que faute de p exacte ou Monte-Carlo sous le mod&egrave;le r&eacute;glementaire,",
                    "et ne sont pas exactes au sens de l'outil.",
                    "La s&eacute;lection des tests affich&eacute;s se r&egrave;gle",
                    "dans le sous-onglet <i>Personnalisation</i>."))),
                  radioButtons("vue_tests", "Niveau de detail", inline = TRUE,
                               choices = c("Synthese" = "synth", "Detail" = "detail"),
                               selected = "synth")),
              uiOutput("tests_par_hypothese")
            ),
            tabPanel(
              "Personnalisation", br(),
              div(class = "bloc",
                  h4("Selection des tests"),
                  helpText(HTML(paste(
                    "Chaque test peut &ecirc;tre conserv&eacute; ou retir&eacute; de la",
                    "restitution. Pour les tests d'ind&eacute;pendance et de",
                    "stabilit&eacute; de la m&eacute;thode lognormale, la base de",
                    "r&eacute;sidus est &eacute;galement r&eacute;glable : sur les",
                    "<i>r&eacute;sidus normalis&eacute;s</i> les p-values exactes et",
                    "asymptotiques sont valides ; sur les <i>ratios bruts</i> le test",
                    "ne d&eacute;pend d'aucun ajustement mais seule la p-value de",
                    "Monte-Carlo y est valide.",
                    "<br><b>Par d&eacute;faut</b> : variantes secondaires retir&eacute;es,",
                    "r&eacute;sidus normalis&eacute;s."))),
                  fluidRow(
                    column(4, actionButton("sel_defaut", "Retablir la selection par defaut")),
                    column(4, actionButton("sel_tout", "Tout conserver")),
                    column(4, actionButton("sel_rien", "Tout retirer"))),
                  br(),
                  uiOutput("panneau_personnalisation"))
            )
          )
        ),

        # ---------------------------- GRAPHIQUES --------------------------
        tabPanel("Graphiques", br(), uiOutput("onglets_graphiques")),

        # --------------------------- CALIBRATION --------------------------
        tabPanel(
          "Calibration",
          br(),
          div(class = "bloc",
              h4("Parametre retenu"),
              uiOutput("bloc_final")),
          div(class = "bloc",
              h4(paste("Parametre standard remplace (art. 218, paragraphe 1) et bareme de",
                       "credibilite (annexe XVII, section G)")),
              uiOutput("derogations"),
              tableOutput("tab_param_std")),
          div(class = "bloc",
              h4("Chaine de calibration (annexe XVII, sections B/C et G)"),
              tableOutput("tab_calibration")),
          div(class = "bloc",
              h4("Valeurs candidates"),
              fluidRow(column(6, tableOutput("tab_candidats")),
                       column(6, sortie_graphique("g_calib", "280px")))),
          div(class = "bloc",
              h4("Robustesse du calibrage"),
              tableOutput("tab_robustesse"))
        ),

        # -------------------------- DESCRIPTIF ----------------------------
        tabPanel(
          "Descriptif et journal",
          br(),
          div(class = "bloc", h4("Statistiques descriptives"),
              tableOutput("tab_desc")),
          div(class = "bloc", h4("Journal d'execution (tracabilite)"),
              verbatimTextOutput("tab_meta")),
          div(class = "bloc", h4("Export"),
              uiOutput("bloc_export"))
        )
      )
    ),

    # ------------------------ PANNEAU DE PARAMETRES (DROITE) --------------
    column(
      width = 3,
      div(class = "bloc",
          h4("Parametres de calcul"),
          selectInput("methode", "Methode (annexe XVII)",
                      c("Risque de prime (section B)" = "premium",
                        "Risque de reserve 1 (section C)" = "reserve1",
                        "Risque de reserve 2 - Merz-Wuthrich (section D)" = "reserve2")),
          helpText(textOutput("aide_methode", inline = TRUE)),
          radioButtons("annexe", "Perimetre", inline = TRUE,
                       choices = c("Non-vie (annexe II)" = "II",
                                   "Sante non-SLT (annexe XIV)" = "XIV"),
                       selected = "II"),
          uiOutput("choix_segment"),
          # Nature des donnees (issue #55, decision M13) : declaration
          # obligatoire pour la methode du risque de primes, SANS
          # preselection (selected = character(0) : aucune case cochee,
          # input$nature_donnees vaut NULL). Le refus en l'absence de
          # declaration est celui du moteur (engine_valider_donnees()).
          conditionalPanel("input.methode == 'premium'",
                           radioButtons("nature_donnees",
                                        "Nature des donnees (declaration obligatoire)",
                                        choices = c("Brutes de reassurance (annexe XVII, B(2)(c))" = "brutes",
                                                    "Nettes de reassurance (annexe XVII, B(2)(d))" = "nettes"),
                                        selected = character(0)),
                           helpText("Brutes : sigma standard = sigma brut de l'annexe.",
                                    "Nettes : sigma standard = NP standard x sigma brut ;",
                                    "donnees ajustees de la reassurance et des vehicules",
                                    "de titrisation, conformement aux contrats en place",
                                    "pour les douze mois a venir (B(2)(d)).")),
          checkboxInput("sigma_manuel", "Saisir sigma standard manuellement", FALSE),
          conditionalPanel("input.sigma_manuel",
                           numericInput("sigma_std", "sigma standard",
                                        value = 0.10, min = 0.01, max = 1, step = 0.005),
                           helpText("Saisie libre : derogation au parametre reglementaire,",
                                    "signalee dans les resultats et le rapport fige.")),
          numericInput("profondeur", "Profondeur T retenue", value = T_INIT,
                       min = 5, max = 40, step = 1),
          conditionalPanel("input.methode == 'reserve2'",
            helpText("T pilote la taille du triangle de saisie de l'onglet Donnees.")),
          conditionalPanel("input.methode != 'reserve2'",
            helpText("Le moteur retient les T annees les plus recentes de la grille",
                     "de l'onglet Donnees ; les annees plus anciennes sont ecartees",
                     "et la troncature est signalee.")),
          numericInput("B", "Replications bootstrap B", value = 999, min = B_MIN_USAGE,
                       max = 9999, step = 100),
          helpText("L'erreur de Monte-Carlo decroit en 1/sqrt(B) ; elle est",
                   "independante de la qualite de l'approximation liee a T.",
                   "B + 1 > 4/alpha requis pour que l'ECHEC bilateral reste atteignable."),
          numericInput("alpha", "Seuil alpha des verdicts", value = 0.10,
                       min = 0.01, max = 0.20, step = 0.01),
          uiOutput("avert_b_alpha"),
          hr(),
          h5("Test d'equivalence de la constante"),
          checkboxInput("delta_apriori", "Marge Delta fixee a priori", FALSE),
          conditionalPanel("!input.delta_apriori",
                           numericInput("theta_equiv", "Marge theta, fraction de la perte moyenne (0,10 = 10 %)",
                                        value = 0.10, min = 0.01, max = 0.95, step = 0.01)),
          conditionalPanel("input.delta_apriori",
                           numericInput("delta_equiv", "Marge Delta (unite monetaire)",
                                        value = 8, min = 0, step = 0.5)),
          helpText("Marge fixee a priori : test exact. Marge en fraction de la moyenne :",
                   "exactitude seulement approchee (la marge depend des donnees)."),
          numericInput("seed", "Graine (reproductibilite)", value = 20260831, step = 1),
          hr(),
          actionButton("go", "Relancer les calculs", class = "btn-primary",
                       width = "100%", icon = icon("play")),
          br(), br(),
          helpText("Les modifications des donnees ou des parametres ne declenchent",
                   "aucun calcul : seul ce bouton appelle run_engine().")),
      div(class = "bloc",
          h4("Etat"),
          uiOutput("etat"))
    )
  )
)

# ---------------------------------------------------------------------------
# SERVEUR : collecte des entrees, appel du moteur, affichage
# ---------------------------------------------------------------------------
server <- function(input, output, session) {

  donnees   <- reactiveVal(DONNEES_INIT)     # methodes lognormales
  triangle  <- reactiveVal(TRIANGLE_INIT)    # methode Merz-Wuthrich
  resultat  <- reactiveVal(NULL)
  selection <- reactiveVal(NULL)             # personnalisation des tests
  # Motif du dernier calcul non abouti, remis a NULL des qu'un calcul aboutit.
  dernier_refus <- reactiveVal(NULL)
  est_mw <- reactive(identical(input$methode, "reserve2"))
  # Statut du chargement des fichiers d'echange au demarrage (charger_ln(),
  # charger_mw()), par methode ; efface par une reinitialisation ou un import
  # reussi de la methode concernee.
  statut_demarrage <- reactiveVal(list(LN = CHARGE_LN$statut, MW = CHARGE_MW$statut))
  effacer_statut_demarrage <- function() {
    st <- statut_demarrage(); st[if (est_mw()) "MW" else "LN"] <- list(NULL)
    statut_demarrage(st)
  }
  output$statut_demarrage <- renderUI({
    st <- statut_demarrage()[[if (est_mw()) "MW" else "LN"]]
    if (is.null(st)) return(NULL)
    div(class = if (st$ok) "avert" else "err",
        style = if (st$ok) "border-left-color:#1E8449;background:#EAFAF1" else NULL, st$msg)
  })
  # Marge du test d'equivalence telle que transmise au moteur (au clic comme
  # dans la validation en direct) ; le controle de son domaine est fait par
  # engine_valider_donnees().
  marge_theta <- function() if (isTRUE(input$delta_apriori)) 0.10 else input$theta_equiv
  marge_delta <- function() if (isTRUE(input$delta_apriori)) input$delta_equiv else NULL
  # Nature des donnees transmise au moteur : la declaration de l'utilisateur
  # pour la methode du risque de primes (NULL tant qu'aucun choix n'est
  # fait : le moteur refuse alors le calcul), rien pour les methodes de
  # reserve (issue #55).
  nature_saisie <- function() if (identical(input$methode, "premium")) input$nature_donnees else NULL

  # Retour anticipe de observeEvent(input$go) : on retire le resultat du
  # calcul precedent (il ne correspond plus aux donnees affichees, et il ne
  # doit plus pouvoir etre exporte) et on enregistre le motif, qui provient du
  # moteur. Aucune regle metier ici : l'interface ne fait que restituer.
  refuser <- function(titre, motifs) {
    resultat(NULL); selection(NULL)
    dernier_refus(list(titre = titre, motifs = as.character(motifs)))
  }

  # Issue d'un appel a run_engine() (issue #94, suites de #87 et #88).
  # Conserve le resultat et renvoie TRUE si le calcul a abouti ; sinon
  # restitue la situation et renvoie FALSE. La nature de l'echec est lue dans
  # ce que le moteur retourne, sans regle metier : erreur R (try-error),
  # ok = FALSE avec validation$erreur_r (defaut de calcul intercepte), ok =
  # FALSE sans (refus). Le message R et la pile ne vont qu'au journal.
  conserver <- function(res) {
    if (inherits(res, "try-error")) {
      cond <- attr(res, "condition")
      journaliser("Erreur d'usage : run_engine() a leve une erreur R",
                  c(paste("message :", conditionMessage(cond)),
                    paste("appel :", paste(deparse(conditionCall(cond), nlines = 1L), collapse = ""))))
      # Message de l'erreur d'usage : texte du moteur, qui nomme l'argument
      # rejete (.engine_verifier_usage(), issue #88).
      refuser(TITRE_ERREUR, c(conditionMessage(cond), AIDE_USAGE))
      showNotification(paste("Erreur d'usage :", conditionMessage(cond)),
                       type = "error", duration = 12)
      return(FALSE)
    }
    if (isTRUE(res$ok)) {
      resultat(res); selection(NULL); dernier_refus(NULL)
      return(TRUE)
    }
    motifs <- utils::head(res$validation$erreurs, 6)
    er <- res$validation$erreur_r
    if (!is.null(er)) {
      journaliser("Defaut de calcul intercepte par le moteur (validation$erreur_r)",
                  c(paste("message :", er$message), paste("appel :", er$appel),
                    paste("origine :", er$origine),
                    paste("pile :", paste(er$pile, collapse = " > "))))
      refuser(TITRE_DEFAUT, c(motifs, AIDE_DEFAUT))
      showNotification("Defaut de calcul : aucun resultat n'est produit (voir le bandeau).",
                       type = "error", duration = 15)
      return(FALSE)
    }
    # Champ T vide : input$profondeur vaut NA et le moteur refuse (issue
    # #87) ; l'interface dit seulement quel champ est en cause.
    if (!est_mw() && (is.null(input$profondeur) || is.na(input$profondeur)))
      motifs <- c(motifs, AIDE_T_VIDE)
    refuser(TITRE_REFUSE, motifs)
    showNotification(paste("Calcul refuse :",
                           paste(utils::head(res$validation$erreurs, 2), collapse = " ")),
                     type = "error", duration = 15)
    FALSE
  }

  output$aide_methode <- renderText({
    if (est_mw())
      "Entree : triangle de paiements cumules (T annees d'accident x T annees de developpement)."
    else paste("Entree : deux vecteurs x_t et y_t sur n annees ; le moteur retient",
               "les T annees les plus recentes.")
  })
  output$titre_donnees <- renderText({
    if (est_mw()) "Triangle de paiements cumules C(i,j)" else "Series x_t et y_t"
  })
  output$aide_donnees <- renderUI({
    if (est_mw())
      helpText(HTML(paste("Lignes : annees d'accident i = 0..I. Colonnes : annees de",
        "developpement j = 0..J. Seule la partie superieure gauche (i + j &le; I) est",
        "observee ; les cellules restantes sont laiss&eacute;es vides. Le fichier",
        "d'echange est <code>", FICHIER_MW, "</code>.")))
    else
      helpText(HTML(paste("Methode risque de prime : x_t = primes acquises, y_t = pertes",
        "agregees. Methode risque de reserve 1 : x_t = provision d'ouverture,",
        "y_t = paiements de l'exercice + meilleure estimation de cloture.",
        "Le fichier d'echange est <code>", FICHIER_LN, "</code>.")))
  })

  # Liste des segments de l'annexe choisie. Les libelles et les numeros
  # proviennent du catalogue SEGMENTS de engine.R : aucune valeur reglementaire
  # n'est saisie en dur dans l'interface.
  output$choix_segment <- renderUI({
    tab <- SEGMENTS[SEGMENTS$annexe == input$annexe, ]
    selectInput("segment",
                sprintf("Segment (annexe %s)", input$annexe),
                setNames(as.character(tab$segment),
                         paste0(tab$segment, " - ", substr(tab$libelle, 1, 40))))
  })

  # --- Grille de saisie (interface pure) -----------------------------------
  # Methodes lognormales (issue #134, piste 3 d'architect, decision du
  # mainteneur du 28/09/2026) : la grille des series n'est plus alignee sur
  # T. Elle porte les n annees fournies (import, jeu par defaut, lignes
  # ajoutees ou retirees par les boutons ci-dessous) ; T n'est qu'un
  # parametre du calcul : run_engine() retient les T annees les plus
  # recentes et restitue la troncature (ligne "profondeur" de
  # engine_derogations(), issue #104). Auparavant, reduire T gardait les
  # lignes 1..T, soit les annees les plus ANCIENNES, sans avertissement, et
  # n_fournies valait toujours T.
  # Triangle (reserve no 2, jamais tronque par le moteur) : sa dimension
  # reste pilotee par T. Les valeurs deja saisies sont conservees, les cases
  # ajoutees sont vides.
  observeEvent(input$profondeur, {
    T <- input$profondeur
    if (is.null(T) || !is.finite(T) || T < 1) return()
    tri <- triangle()
    if (nrow(tri) != T) {
      nt <- matrix(NA_real_, T, T)
      k <- min(nrow(tri), T)
      nt[seq_len(k), seq_len(k)] <- tri[seq_len(k), seq_len(k)]
      for (ii in seq_len(T)) if (T - ii + 1 < T) nt[ii, (T - ii + 2):T] <- NA_real_
      triangle(nt)
    }
  }, ignoreInit = FALSE)

  # Lignes de la grille des series (issue #134) : ajout d'une annee vide en
  # fin de grille (la plus recente), retrait de la derniere ligne. Les
  # valeurs saisies sont relues avant le redimensionnement, sans quoi le
  # nouveau rendu de la grille les remplacerait par celles de donnees().
  # Le retrait d'une ligne renseignee est notifie avec ses valeurs.
  saisie_courante <- function() {
    sa <- lire_saisie()
    data.frame(t = seq_along(sa$xt), xt = sa$xt, yt = sa$yt)
  }
  observeEvent(input$ajouter_annee, {
    d <- saisie_courante()
    donnees(rbind(d, data.frame(t = nrow(d) + 1L, xt = NA_real_, yt = NA_real_)))
  })
  observeEvent(input$retirer_annee, {
    d <- saisie_courante(); n <- nrow(d)
    if (n <= 1L) return()
    if (!is.na(d$xt[n]) || !is.na(d$yt[n]))
      showNotification(sprintf("Ligne t = %d retiree (x_t = %s, y_t = %s).", n,
                               format(d$xt[n]), format(d$yt[n])),
                       type = "warning", duration = 8)
    donnees(d[-n, , drop = FALSE])
  })

  output$grille_donnees <- renderUI({
    if (est_mw()) {
      tri <- triangle(); T <- nrow(tri)
      # Tableau HTML plutot que la grille Bootstrap : column(1, ...) alloue un
      # douzieme de la largeur, insuffisant pour afficher des cumules a sept
      # chiffres, et inutilisable au-dela de onze annees de developpement. Le
      # tableau fixe la largeur des cellules et defile horizontalement si
      # necessaire, quelle que soit la valeur de T.
      # Largeur adaptee au nombre de chiffres reellement presents. On evite
      # formatC(format = "d"), qui coerce en entier et deborde au-dela de
      # 2,1 milliards ; format(scientific = FALSE) n'a pas cette limite.
      vals <- tri[!is.na(tri)]
      nchif <- if (length(vals))
        max(nchar(format(round(vals), scientific = FALSE, trim = TRUE))) else 6
      largeur <- paste0(max(95, min(150, 55 + 7 * nchif)), "px")
      tags$div(
        style = "overflow-x:auto; padding-bottom:6px",
        tags$table(
          class = "triangle",
          tags$thead(tags$tr(
            tags$th("i \\ j"),
            lapply(0:(T - 1), function(j) tags$th(j)))),
          tags$tbody(lapply(seq_len(T), function(i)
            tags$tr(
              tags$th(i - 1),
              lapply(0:(T - 1), function(j) {
                id <- paste0("c_", i - 1, "_", j)
                if (i - 1 + j <= T - 1)
                  tags$td(numericInput(id, NULL, value = tri[i, j + 1],
                                       step = 1, width = largeur))
                else tags$td(class = "vide", "\u2014")
              })))))) 
    } else {
      d <- donnees()
      do.call(tagList, lapply(seq_len(nrow(d)), function(i) {
        fluidRow(
          column(2, div(style = "padding-top:26px;font-weight:600", paste0("t = ", d$t[i]))),
          column(5, numericInput(paste0("x_", i), if (i == 1) "x_t" else NULL,
                                 value = d$xt[i], step = 0.01)),
          column(5, numericInput(paste0("y_", i), if (i == 1) "y_t" else NULL,
                                 value = d$yt[i], step = 0.01)))
      }))
    }
  })


  # Lecture des champs de saisie : aucune transformation quantitative ici.
  lire_saisie <- function() {
    d <- donnees(); n <- nrow(d)
    xt <- vapply(seq_len(n), function(i) {
      v <- input[[paste0("x_", i)]]; if (is.null(v)) NA_real_ else as.numeric(v) }, numeric(1))
    yt <- vapply(seq_len(n), function(i) {
      v <- input[[paste0("y_", i)]]; if (is.null(v)) NA_real_ else as.numeric(v) }, numeric(1))
    list(xt = xt, yt = yt)
  }

  # Lecture du triangle saisi. Aucune transformation quantitative : seules les
  # cellules observees (i + j <= I) sont relues, les autres restent NA.
  lire_triangle <- function() {
    T <- nrow(triangle())
    m <- matrix(NA_real_, T, T)
    for (i in 0:(T - 1)) for (j in 0:(T - 1)) if (i + j <= T - 1) {
      v <- input[[paste0("c_", i, "_", j)]]
      m[i + 1, j + 1] <- if (is.null(v)) NA_real_ else as.numeric(v)
    }
    m
  }

  # Validation en direct : l'appel est fait au moteur, pas reimplemente ici.
  output$validation_live <- renderUI({
    v <- if (est_mw()) mw_valider_triangle(lire_triangle())
         else { sa <- lire_saisie()
                # Methode et nature declaree transmises comme au clic
                # (issue #55) : la nature manquante s'affiche des la saisie.
                engine_valider_donnees(sa$xt, sa$yt, theta_equiv = marge_theta(),
                                       delta_equiv = marge_delta(), methode = input$methode,
                                       nature_donnees = nature_saisie()) }
    tagList(
      if (length(v$erreurs))
        div(class = "err", tags$b("Donnees non exploitables :"),
            tags$ul(lapply(utils::head(v$erreurs, 6), tags$li))),
      if (length(v$avertissements))
        div(class = "avert", tags$b("Avertissements :"),
            tags$ul(lapply(v$avertissements, tags$li))),
      if (isTRUE(v$ok) && !length(v$avertissements))
        div(style = "color:#1E8449", "Donnees valides.")
    )
  })

  # Reinitialisation. Series (methodes lognormales) : les 8 annees du jeu
  # par defaut, quelle que soit T (issue #134 : la grille n'est plus alignee
  # sur T ; le moteur retient les T plus recentes, ou refuse T > 8).
  # Triangle : jeu par defaut dimensionne a la profondeur T saisie.
  # Si le champ T est vide ou non recevable (NA, non entier, < 1), le
  # triangle ne peut pas etre dimensionne sur lui (issue #100) : le jeu par
  # defaut est restaure a sa propre profondeur, que l'on reporte dans le
  # champ T, et le motif du moteur (engine_valider_profondeur(), meme borne
  # T_min = 1 que le redimensionnement du triangle) est affiche. Aucune
  # borne superieure (n = Inf) : au-dela de 8 annees, le triangle par
  # defaut est prolonge (triangle_defaut(), issue #108).
  observeEvent(input$reinit, {
    T <- input$profondeur
    err_T <- if (is.null(T) || is.na(T)) "Profondeur T : champ vide."
             else engine_valider_profondeur(T, n = Inf, T_min = 1)
    if (length(err_T)) {
      T <- nrow(DONNEES_DEFAUT)
      updateNumericInput(session, "profondeur", value = T)
      showNotification(paste(c(err_T, sprintf("Profondeur par defaut retablie : T = %d.", T)),
                             collapse = " "), type = "warning", duration = 10)
    }
    if (est_mw()) triangle(triangle_defaut(T)) else donnees(DONNEES_DEFAUT)
    statut_import(NULL); effacer_statut_demarrage()
    showNotification("Donnees reinitialisees.", type = "message")
  })

  # Import. La lecture disque est faite ici (couche interface) ; la validation
  # structurelle revient au moteur.
  statut_import <- reactiveVal(NULL)
  observeEvent(input$fichier_import, {
    fi <- input$fichier_import
    # Le format est deduit de l'extension du fichier depose. La lecture est du
    # ressort de l'interface ; l'interpretation structurelle revient au moteur.
    ext <- tolower(tools::file_ext(fi$name))
    # Fichier illisible : message fixe, message R au journal (issue #94).
    lu <- lire_tableau(fi$datapath, ext %in% c("xlsx", "xlsm"), nom = fi$name)
    if (!is.null(lu$erreur)) {
      statut_import(list(ok = FALSE,
        msg = sprintf("Fichier %s (%s) %s", fi$name, toupper(ext), lu$erreur)))
      showNotification("Import refuse : fichier illisible.", type = "error", duration = 8)
      return()
    }
    df <- lu$df
    if (est_mw()) {
      # Conversion fichier -> triangle et recevabilite : moteur.
      v <- engine_lire_triangle(df)
      if (!v$ok) {
        statut_import(list(ok = FALSE, msg = paste(utils::head(v$erreurs, 3), collapse = " ")))
        showNotification("Import refuse.", type = "error", duration = 8); return()
      }
      m <- v$triangle
      triangle(m); updateNumericInput(session, "profondeur", value = nrow(m))
      effacer_statut_demarrage()
      statut_import(list(ok = TRUE, msg = sprintf("Triangle %d x %d importe depuis %s (%s).",
                                                  nrow(m), ncol(m), fi$name, toupper(ext))))
    } else {
      r <- engine_lire_donnees_csv(df)
      if (!r$ok) {
        statut_import(list(ok = FALSE, msg = paste(r$erreurs, collapse = " ")))
        showNotification("Import refuse.", type = "error", duration = 8); return()
      }
      donnees(data.frame(t = seq_along(r$xt), xt = r$xt, yt = r$yt))
      # Valeur initiale de T apres import : toutes les annees importees. La
      # grille n'en depend plus (issue #134) : reduire ensuite T fait ecarter
      # par le moteur les annees les plus anciennes, troncature restituee.
      updateNumericInput(session, "profondeur", value = r$n)
      effacer_statut_demarrage()
      # Meme politique qu'au demarrage (charger_ln()) : des donnees lisibles
      # mais hors des controles de validite du moteur sont chargees pour etre
      # corrigees dans la grille, avec les motifs du moteur ; le calcul reste
      # bloque par les memes controles au clic. Marge courante transmise,
      # comme dans la validation en direct, avec la methode et la nature
      # declaree (issue #55).
      v <- engine_valider_donnees(r$xt, r$yt, theta_equiv = marge_theta(),
                                  delta_equiv = marge_delta(), methode = input$methode,
                                  nature_donnees = nature_saisie())
      if (!v$ok) {
        statut_import(list(ok = FALSE, msg = paste(
          sprintf("%d annees importees depuis %s (%s), mais les donnees ne passent pas",
                  r$n, fi$name, toupper(ext)),
          "les controles de validite du moteur :", paste(v$erreurs, collapse = " "))))
        showNotification("Donnees importees, mais non valides : voir le statut d'import.",
                         type = "warning", duration = 8); return()
      }
      statut_import(list(ok = TRUE, msg = sprintf("%d annees importees depuis %s (%s).",
                                                  r$n, fi$name, toupper(ext))))
    }
    showNotification("Donnees importees.", type = "message")
  })

  output$import_statut <- renderUI({
    st <- statut_import(); if (is.null(st)) return(NULL)
    div(class = if (st$ok) "avert" else "err",
        style = if (st$ok) "border-left-color:#1E8449;background:#EAFAF1" else NULL, st$msg)
  })

  # --- Declenchement explicite des calculs ---------------------------------
  observeEvent(input$go, {
    if (est_mw()) {
      m <- lire_triangle(); v <- mw_valider_triangle(m)
      if (!v$ok) {
        refuser(TITRE_NON_LANCE, utils::head(v$erreurs, 6))
        showNotification(paste("Calcul non lance :", paste(utils::head(v$erreurs, 2), collapse = " ")),
                         type = "error", duration = 10); return()
      }
      abouti <- withProgress(message = "Merz-Wuthrich : chain-ladder, MSEP et bootstrap", value = 0.4, {
        res <- try(run_engine(methode = "reserve2", triangle = m,
                              segment = as.integer(input$segment), annexe = input$annexe,
                              sigma_standard = if (isTRUE(input$sigma_manuel)) input$sigma_std else NULL,
                              B = input$B, alpha = input$alpha, seed = input$seed), silent = TRUE)
        # Le moteur peut refuser le calcul APRES l'ajustement (reserve
        # chain-ladder totale <= 0, MSEP non finie) : le motif vient de lui,
        # l'interface ne fait que le restituer (conserver()).
        conserver(res)
      })
    } else {
      sa <- lire_saisie()
      v <- engine_valider_donnees(sa$xt, sa$yt, theta_equiv = marge_theta(),
                                  delta_equiv = marge_delta(), methode = input$methode,
                                  nature_donnees = nature_saisie())
      if (!v$ok) {
        refuser(TITRE_NON_LANCE, utils::head(v$erreurs, 6))
        showNotification(paste("Calcul non lance :", paste(v$erreurs, collapse = " ")),
                         type = "error", duration = 10); return()
      }
      abouti <- withProgress(message = "Calculs en cours (bootstrap parametrique)", value = 0.4, {
        res <- try(run_engine(xt = sa$xt, yt = sa$yt, methode = input$methode,
                              segment = as.integer(input$segment), annexe = input$annexe,
                              sigma_standard = if (isTRUE(input$sigma_manuel)) input$sigma_std else NULL,
                              T = input$profondeur, B = input$B, alpha = input$alpha,
                              seed = input$seed,
                              theta_equiv = marge_theta(), delta_equiv = marge_delta(),
                              nature_donnees = nature_saisie()),
                   silent = TRUE)
        conserver(res)
      })
    }
    # withProgress() evalue son bloc par eval() : un return() dans ce bloc ne
    # sortait que du bloc, et "Calculs termines." s'affichait aussi apres un
    # refus. L'issue est donc rendue par le bloc lui-meme.
    if (abouti) showNotification("Calculs termines.", type = "message")
  })

  R <- reactive({ req(resultat()); resultat() })
  TB <- reactive({ engine_table_tests(R()) })

  # --- Bandeaux et etat -----------------------------------------------------
  # Bandeau de refus : il reste affiche tant qu'aucun calcul n'a abouti depuis
  # le dernier retour anticipe, la ou la notification disparait au bout de
  # quelques secondes. Il explique pourquoi les onglets de resultat sont vides.
  output$bandeau_refus <- renderUI({
    ref <- dernier_refus()
    if (is.null(ref)) return(NULL)
    div(class = "err",
        tags$b(ref$titre),
        if (length(ref$motifs))
          tags$ul(style = "margin:4px 0", lapply(ref$motifs, tags$li)),
        tags$div(EXPLICATION_REFUS))
  })

  # B minimal fonction d'alpha (#127) : avertissement avant le clic, texte
  # rendu par le moteur (engine_motif_b_alpha()), aucune regle ici. Le bouton
  # reste actif ; au clic, run_engine() leve la meme erreur d'usage.
  output$avert_b_alpha <- renderUI({
    msg <- engine_motif_b_alpha(input$B, input$alpha)
    if (is.null(msg)) return(NULL)
    div(class = "avert", msg)
  })

  output$bandeau_T <- renderUI({
    r <- resultat()
    if (is.null(r)) return(HTML("Renseignez les donnees puis cliquez sur <b>Relancer les calculs</b>."))
    msg <- avertissement_T(r$metadata$T)
    if (is.null(msg)) HTML("Profondeur suffisante pour une lecture standard des tests.") else HTML(msg)
  })

  output$etat <- renderUI({
    r <- resultat()
    if (is.null(r)) return(div(style = "color:#7F8C8D", "Aucun calcul lance."))
    m <- r$metadata
    tagList(
      div(HTML(sprintf("<b>T</b> = %d &nbsp; <b>B</b> = %d", m$T, m$B))),
      div(HTML(sprintf("<b>seed</b> = %s", format(m$seed, scientific = FALSE)))),
      div(HTML(sprintf("<b>sigma_USP</b> = <span class='cle' style='font-size:18px'>%.4f</span>",
                       r$parametre_final$sigma_usp))),
      div(style = "color:#7F8C8D;font-size:12px",
          sprintf("calcule en %.1f s", m$duree_sec))
    )
  })

  # --- Donnees --------------------------------------------------------------
  output$tab_controles <- renderTable({
    do.call(rbind, lapply(R()$controles, function(t)
      data.frame(Controle = t$test, Verdict = t$verdict, Detail = t$detail,
                 stringsAsFactors = FALSE)))
  }, striped = TRUE, width = "100%")

  # --- Tests ----------------------------------------------------------------
  # Rendu des tests groupes par hypothese. Aucun calcul : on filtre et on
  # met en forme la table produite par engine_table_tests().
  # La selection par defaut (selection_defaut) et la regle de "test retenu"
  # (filtrer_selection) sont dans R/display_helpers.R, partagees avec le
  # rapport fige.
  sel_courante <- reactive({
    tb <- TB(); s <- selection()
    if (is.null(s)) selection_defaut(tb) else s
  })

  observeEvent(input$sel_defaut, selection(NULL))
  observeEvent(input$sel_tout, { s <- sel_courante(); s$garde <- TRUE; selection(s) })
  observeEvent(input$sel_rien, { s <- sel_courante(); s$garde <- FALSE; selection(s) })

  # Le panneau lit les cases a cocher et les boutons radio, et met a jour
  # l'objet de selection. Aucun recalcul n'est declenche : le moteur a deja
  # produit toutes les lignes.
  observe({
    tb <- TB(); s <- sel_courante(); modif <- FALSE
    for (k in seq_len(nrow(tb))) {
      idg <- paste0("g_test_", k); idb <- paste0("b_test_", k)
      vg <- input[[idg]]
      if (!is.null(vg) && !identical(vg, s$garde[k])) { s$garde[k] <- vg; modif <- TRUE }
      vb <- input[[idb]]
      if (!is.null(vb) && tb$base[k] != "commun" && !identical(vb, s$base[k])) {
        s$base[k] <- vb; modif <- TRUE
      }
    }
    if (modif) selection(s)
  })

  output$panneau_personnalisation <- renderUI({
    tb <- TB(); s <- sel_courante()
    # Les tests declines en deux bases sont apparies par leur libelle de base.
    blocs <- lapply(cles_groupes(), function(k) {
      idx <- which(vapply(tb$famille, function(f) groupe_de(f)$cle, character(1)) == k)
      if (!length(idx)) return(NULL)
      g <- groupe_de(tb$famille[idx[1]])
      lignes <- lapply(idx, function(r) {
        etiq <- tb$test[r]
        sec <- if (tb$variante[r] == "secondaire")
          span(style = "color:#B9770E;font-size:11px", " [variante secondaire]") else NULL
        bas <- if (tb$base[r] != "commun")
          radioButtons(paste0("b_test_", r), NULL, inline = TRUE,
                       choices = c("z_t" = "z", "ratios" = "r"),
                       selected = s$base[r])
        else div(style = "color:#AAA;font-size:11px;padding-top:6px", "base unique")
        fluidRow(
          column(1, checkboxInput(paste0("g_test_", r), NULL, value = s$garde[r])),
          column(8, div(style = "padding-top:6px", etiq, sec)),
          column(3, bas))
      })
      div(class = "bloc",
          div(style = "border-left:4px solid #00468C;padding-left:10px;margin-bottom:6px",
              h4(style = "color:#00468C;margin:0", g$titre)),
          do.call(tagList, lignes))
    })
    do.call(tagList, Filter(Negate(is.null), blocs))
  })

  output$tests_par_hypothese <- renderUI({
    tb <- TB(); s <- sel_courante()
    # Filtrage d'AFFICHAGE seulement : le moteur a calcule toutes les lignes et
    # l'export CSV les conserve toutes.
    tb <- tb[filtrer_selection(tb, s), , drop = FALSE]
    if (!nrow(tb)) return(div(class = "avert", "Aucun test selectionne."))
    tb$cle <- vapply(tb$famille, function(f) groupe_de(f)$cle, character(1))
    # cles_groupes() couvre les deux methodes ; seules les familles presentes
    # dans le resultat courant sont affichees, dans l'ordre du catalogue.
    blocs <- lapply(cles_groupes(), function(k) {
      sub <- tb[tb$cle == k, , drop = FALSE]
      if (!nrow(sub)) return(NULL)
      g <- groupe_de(sub$famille[1])
      nb <- table(factor(sub$verdict, levels = c("OK", "ALERTE", "ECHEC", "INFO")))
      d <- if (identical(input$vue_tests, "detail")) table_detail_groupe(sub)
           else table_synthese_groupe(sub)
      div(class = "bloc",
          div(style = "border-left:4px solid #00468C;padding-left:10px;margin-bottom:8px",
              h4(style = "color:#00468C;margin:0", g$titre),
              div(style = "color:#555;font-size:12.5px", g$sous),
              div(style = "color:#7F8C8D;font-size:11.5px;font-style:italic", g$ref),
              div(style = "margin-top:5px", HTML(paste(
                badge_verdict("OK"), nb[["OK"]], "&nbsp;&nbsp;",
                badge_verdict("ALERTE"), nb[["ALERTE"]], "&nbsp;&nbsp;",
                badge_verdict("ECHEC"), nb[["ECHEC"]], "&nbsp;&nbsp;",
                "<span style='color:#5D6D7E;font-size:11px'>INFO</span>", nb[["INFO"]])))),
          HTML(html_table(d)))
    })
    do.call(tagList, Filter(Negate(is.null), blocs))
  })

  # Les onglets graphiques different selon la methode : la geometrie des
  # donnees n'est pas la meme (deux vecteurs contre un triangle).
  output$onglets_graphiques <- renderUI({
    req(resultat())
    if (identical(R()$metadata$methode, "reserve2")) {
      tabsetPanel(
        tabPanel("Ajustement", br(),
                 fluidRow(column(6, sortie_graphique("mw_fact")),
                          column(6, sortie_graphique("mw_res")))),
        tabPanel("M1 - regressions", br(),
                 div(class = "bloc", uiOutput("note_m1")),
                 sortie_graphique("mw_reg", "560px"),
                 fluidRow(column(6, sortie_graphique("mw_orig", "330px")),
                          column(6, sortie_graphique("mw_alpha", "330px")))),
        tabPanel("M2 - variance", br(),
                 fluidRow(column(6, sortie_graphique("mw_rC")),
                          column(6, sortie_graphique("mw_rdev")))),
        tabPanel("M3 - independance", br(),
                 fluidRow(column(6, sortie_graphique("mw_racc")),
                          column(6, sortie_graphique("mw_rcal")))),
        tabPanel("M5 - normalite (diagnostic)", br(),
                 fluidRow(column(6, sortie_graphique("mw_qq")),
                          column(6, sortie_graphique("mw_boot")))),
        tabPanel("Influence et leviers", br(),
                 div(class = "bloc", uiOutput("note_influence_mw")),
                 fluidRow(column(6, sortie_graphique("mw_lev", "380px")),
                          column(6, sortie_graphique("mw_contrib", "380px"))),
                 fluidRow(column(12, sortie_graphique("mw_dfb", "330px")))))
    } else {
      tabsetPanel(
        tabPanel("Donnees", br(),
                 fluidRow(column(6, sortie_graphique("g_ajust")),
                          column(6, sortie_graphique("g_ratio")))),
        tabPanel("H2 - variance", br(),
                 fluidRow(column(6, sortie_graphique("g_qq2")),
                          column(6, sortie_graphique("g_spread"))),
                 fluidRow(column(12, sortie_graphique("g_resid")))),
        tabPanel("H3 - normalite", br(),
                 fluidRow(column(12, sortie_graphique("g_qq", "420px")))),
        tabPanel("Surface objectif", br(),
                 div(class = "bloc", uiOutput("note_surface")),
                 fluidRow(column(7, sortie_graphique("g_surface", "520px")),
                          column(5, sortie_graphique("g_coupe", "250px"),
                                    sortie_graphique("g_profil", "250px")))),
        tabPanel("Influence et leviers", br(),
                 div(class = "bloc", uiOutput("note_influence")),
                 fluidRow(column(6, sortie_graphique("g_inf_lev", "380px")),
                          column(6, sortie_graphique("g_inf_cook", "380px"))),
                 fluidRow(column(12, sortie_graphique("g_inf_sigma", "330px")))),
        tabPanel("Incertitude d'estimation", br(),
                 sortie_graphique("g_boot", "420px")))
    }
  })

  output$mw_fact <- rendu_graphique(plot_mw_facteurs(R()$plots_data))
  output$mw_res  <- rendu_graphique(plot_mw_reserve(R()$plots_data))
  output$mw_rC   <- rendu_graphique(plot_mw_residus_C(R()$plots_data))
  output$mw_rdev <- rendu_graphique(plot_mw_residus_dev(R()$plots_data))
  output$mw_racc <- rendu_graphique(plot_mw_residus_acc(R()$plots_data))
  output$mw_rcal <- rendu_graphique(plot_mw_residus_cal(R()$plots_data))
  output$mw_qq   <- rendu_graphique(plot_mw_qq(R()$plots_data))
  output$mw_reg   <- rendu_graphique(plot_mw_regressions(R()$plots_data))
  output$mw_orig  <- rendu_graphique(plot_mw_origine(R()$plots_data, R()$metadata$alpha))
  output$mw_alpha <- rendu_graphique(plot_mw_alpha(R()$plots_data))

  # Note contextuelle du volet M1 : les valeurs proviennent du moteur.
  # Texte partage avec le rapport fige (note_m1, R/display_helpers.R).
  output$note_m1 <- renderUI({
    n <- note_m1(R()$plots_data, R()$metadata$alpha)
    if (is.null(n)) return(NULL)
    helpText(HTML(n))
  })
  output$mw_boot <- rendu_graphique(plot_boot_sigma(R()$plots_data))
  output$g_inf_lev   <- rendu_graphique(plot_influence_levier(R()$plots_data))
  output$g_inf_cook  <- rendu_graphique(plot_influence_cook(R()$plots_data))
  output$g_inf_sigma <- rendu_graphique(plot_influence_sigma(R()$plots_data))
  output$mw_lev      <- rendu_graphique(plot_mw_levier(R()$plots_data))
  output$mw_dfb      <- rendu_graphique(plot_mw_dfbeta(R()$plots_data))
  output$mw_contrib  <- rendu_graphique(plot_mw_contributions(R()$plots_data))

  # Notes contextuelles : les seuils et les comptages viennent du moteur ;
  # textes partages avec le rapport fige (R/display_helpers.R).
  output$note_influence_mw <- renderUI({
    n <- note_influence_mw(R()$plots_data)
    if (is.null(n)) return(NULL)
    helpText(HTML(n))
  })

  output$note_influence <- renderUI({
    n <- note_influence(R()$plots_data)
    if (is.null(n)) return(NULL)
    helpText(HTML(n))
  })

  # --- Graphiques : uniquement du trace de res$plots_data -------------------
  output$g_ajust   <- rendu_graphique(plot_ajustement(R()$plots_data))
  output$g_ratio   <- rendu_graphique(plot_ratio(R()$plots_data))
  output$g_qq      <- rendu_graphique(plot_qqnorm(R()$plots_data))
  output$g_qq2     <- rendu_graphique(plot_qq2ech(R()$plots_data))
  output$g_spread  <- rendu_graphique(plot_spread(R()$plots_data))
  output$g_resid   <- rendu_graphique(plot_residus(R()$plots_data))
  output$g_profil  <- rendu_graphique(plot_profil_delta(R()$plots_data))
  output$g_surface <- rendu_graphique(plot_surface_objectif(R()$plots_data))
  output$g_coupe   <- rendu_graphique(plot_coupe_delta(R()$plots_data))
  output$g_boot    <- rendu_graphique(plot_boot_sigma(R()$plots_data))
  output$g_calib   <- rendu_graphique(plot_calibration(R()$candidats))

  # Note contextuelle sur la surface : les quantites affichees viennent du moteur.
  output$note_surface <- renderUI({
    if (identical(R()$metadata$methode, "reserve2")) return(NULL)
    n <- note_surface(R()$plots_data)
    if (is.null(n)) return(NULL)
    if (n$alerte) div(class = "avert", HTML(n$html))
    else div(style = "color:#1E8449", HTML(n$html))
  })

  # --- Calibration ----------------------------------------------------------
  output$bloc_final <- renderUI({
    r <- R(); p <- r$parametre_final; ic <- r$ic_bootstrap
    tagList(
      div(HTML(sprintf("<span class='cle'>sigma_USP = %.4f</span>", p$sigma_usp))),
      div(HTML(sprintf("soit %+.1f %% par rapport au parametre standard de %.4f",
                       100 * p$variation_relative, p$sigma_standard))),
      if (!is.null(ic))
        div(style = "margin-top:6px", HTML(sprintf(
          "Intervalle bootstrap 90 %% : [%.4f ; %.4f] &nbsp;|&nbsp; 95 %% : [%.4f ; %.4f]",
          ic[2], ic[4], ic[1], ic[5]))),
      # Texte propre a chaque methode (texte_formule, R/display_helpers.R),
      # partage avec le rapport fige : le facteur sqrt((T+1)/(T-1)) ne
      # concerne que les methodes lognormales (#4, piste 4).
      div(style = "margin-top:6px;color:#7F8C8D;font-size:12.5px", texte_formule(r))
    )
  })

  # Parametre standard remplace (issue #55) : valeurs de
  # engine_parametre_standard(), mises en forme par display_helpers.R.
  output$tab_param_std <- renderTable(table_parametre_standard(R()),
                                      striped = TRUE, width = "100%")
  # Bandeaux des derogations (issue #93) : une ligne par derogation de
  # engine_derogations(), lue par libelle_derogation() : partie en gras
  # reprise du libelle du moteur, phrase explicative du sigma standard
  # inchangee.
  output$derogations <- renderUI({
    lib_sigma <- libelle_derogation(R(), "sigma_standard")
    lib_bareme <- libelle_derogation(R(), "bareme")
    # Troncature des annees fournies a la profondeur T (issue #104) : ligne
    # "profondeur" de engine_derogations(), rendue si n_fournies > T.
    lib_prof <- libelle_derogation(R(), "profondeur")
    tagList(
      if (!is.null(lib_sigma))
        div(class = "avert", tags$b(lib_sigma),
            " : le sigma standard du melange est une saisie libre, et non le parametre",
            "reglementaire de l'annexe (meme s'il en egale la valeur)."),
      if (!is.null(lib_bareme)) div(class = "avert", tags$b(lib_bareme)),
      if (!is.null(lib_prof)) div(class = "avert", tags$b(lib_prof)))
  })

  output$tab_calibration <- renderTable({
    d <- R()$calibration; d$valeur <- fmt_nb(d$valeur, 5)
    names(d) <- c("Etape", "Valeur"); d
  }, striped = TRUE, width = "100%")

  output$tab_candidats <- renderTable({
    d <- R()$candidats
    data.frame(Variante = d$variante, Valeur = fmt_nb(d$valeur, 5),
               Retenu = ifelse(d$retenu, "OUI", ""), stringsAsFactors = FALSE)
  }, striped = TRUE, width = "100%")

  # Tableau partage avec la section 4 du rapport fige (display_helpers.R) :
  # tous les diagnostics ROB / M6, independamment de la selection.
  output$tab_robustesse <- renderTable(table_robustesse(TB()),
                                       striped = TRUE, width = "100%")

  # --- Descriptif et journal ------------------------------------------------
  output$tab_desc <- renderTable({
    d <- R()$statistiques_descriptives
    data.frame(Grandeur = d$grandeur, Valeur = fmt_nb(d$valeur, 4), stringsAsFactors = FALSE)
  }, striped = TRUE, width = "100%")

  output$tab_meta <- renderPrint({
    m <- R()$metadata
    cat("Methode              :", m$methode, "\n")
    cat("Perimetre            : annexe", m$annexe, "\n")
    cat("Segment              :", m$segment, "-", m$libelle_segment, "\n")
    cat("sigma standard       :", m$sigma_standard,
        if (!is.null(libelle_derogation(R(), "sigma_standard")))
          "(saisi : derogation au parametre reglementaire)", "\n")
    cat("Nature des donnees   :", table_parametre_standard(R())$Valeur[1], "\n")
    lib_bareme <- libelle_derogation(R(), "bareme")
    cat("Bareme credibilite   :", m$bareme,
        if (!is.null(lib_bareme)) paste0("(", lib_bareme, ")"), "\n")
    # Annees fournies (issue #104) : libelle de la ligne "profondeur" de
    # engine_derogations(), repris tel quel comme pour le bareme (issue #136 :
    # le journal ne refait plus le choix "exercices" / "annees" du moteur).
    lib_prof <- libelle_derogation(R(), "profondeur")
    cat("Profondeur T         :", m$T,
        if (!is.null(lib_prof)) paste0("(", lib_prof, ")"), "\n")
    cat("Replications B       :", m$B, "\n")
    cat("Granularite p_mc     :", format(R()$bootstrap$granularite),
        "( = 1/(B+1), B nominal : p-value unilaterale ; bilaterale 2/(B_eff+1),",
        "par statistique : res$bootstrap$granularite_stat )\n")
    cat("Seuil alpha          :", m$alpha, "\n")
    cat("Graine (seed)        :", format(m$seed, scientific = FALSE), "\n")
    # Generateur et graines fixes consignes par le moteur (issue #37) ; un
    # champ absent de metadata ne produit pas de ligne.
    # Libelles ASCII, comme les autres lignes de ce bloc.
    gen <- valeurs_generateur(m)
    if (!is.na(gen["generateur"]))
      cat("Generateur aleatoire :", gen[["generateur"]], "\n")
    if (!is.na(gen["seed_loi_nulle_sw"]))
      cat("Graine loi nulle SW  :", gen[["seed_loi_nulle_sw"]],
          "(loi nulle de Shapiro-Wilk)\n")
    cat("Horodatage           :", format(m$horodatage, "%Y-%m-%d %H:%M:%S"), "\n")
    cat("Duree (s)            :", round(m$duree_sec, 2), "\n")
    cat("Version R            :", m$version_R, "\n")
  })

  # Les boutons d'export des resultats ne sont proposes que si un calcul a
  # abouti : apres un refus, il n'y a plus de resultat a exporter, et le
  # resultat precedent ne doit pas pouvoir etre depose a cote de donnees qui
  # ne l'ont pas produit.
  output$bloc_export <- renderUI({
    if (is.null(resultat()))
      return(div(style = "color:#7F8C8D",
                 "Aucun resultat a exporter : lancez d'abord un calcul."))
    # Le bloc est recree a chaque resultat : la case reprend le dernier choix
    # de l'utilisateur (isolate : ce choix ne doit pas redeclencher le rendu),
    # cochee par defaut a la premiere apparition.
    choix_interactif <- isolate(input$rapport_interactif)
    if (is.null(choix_interactif)) choix_interactif <- TRUE
    tagList(downloadButton("dl_tests", "Table complete des tests (CSV)"), " ",
            downloadButton("dl_calib", "Calibration (CSV)"),
            hr(),
            h5("Rapport fige (HTML autonome)"),
            helpText(paste("Un fichier unique, sans ressource externe, qui fige le resultat",
                           "affiche : donnees du calcul, controles, parametre, tests retenus",
                           "par la personnalisation, tests exclus en annexe, graphiques et",
                           "empreintes. Aucun calcul n'est relance.")),
            checkboxInput("rapport_interactif",
                          paste("Graphiques interactifs (fichier d'environ 4 Mo ;",
                                "sinon graphiques figes en PNG, environ 0,1 Mo)"),
                          value = choix_interactif),
            downloadButton("dl_rapport", "Rapport fige (HTML)"))
  })

  # Rapport fige : l'objet resultat() et la selection courante sont transmis
  # tels quels ; rapport_html() ne fait que les mettre en forme.
  output$dl_rapport <- downloadHandler(
    filename = function() sprintf("usp_rapport_%s_%s.html", R()$metadata$methode,
                                  format(R()$metadata$horodatage, "%Y%m%d_%H%M%S")),
    content = function(f)
      rapport_html(resultat(), sel_courante(), f,
                   interactif = isTRUE(input$rapport_interactif),
                   identite = IDENTITE_CODE))

  output$dl_tests <- downloadHandler(
    filename = function() sprintf("usp_tests_T%d_B%d.csv", R()$metadata$T, R()$metadata$B),
    content = function(f) utils::write.csv(TB(), f, row.names = FALSE, fileEncoding = "UTF-8"))

  output$dl_calib <- downloadHandler(
    filename = function() sprintf("usp_calibration_T%d.csv", R()$metadata$T),
    content = function(f) utils::write.csv(R()$calibration, f, row.names = FALSE,
                                           fileEncoding = "UTF-8"))

  # Construction du tableau exporte, commune aux deux formats : le contenu ne
  # depend pas de l'extension choisie.
  tableau_export <- function() {
    if (est_mw()) {
      m <- lire_triangle()
      df <- data.frame(i = 0:(nrow(m) - 1), m)
      names(df) <- c("i", paste0("j", 0:(ncol(m) - 1)))
      df
    } else {
      sa <- lire_saisie()
      data.frame(t = seq_along(sa$xt), xt = sa$xt, yt = sa$yt)
    }
  }

  output$dl_donnees_xlsx <- downloadHandler(
    filename = function()
      sub("\\.csv$", ".xlsx", if (est_mw()) FICHIER_MW else FICHIER_LN),
    content = function(f)
      engine_ecrire_xlsx(tableau_export(), f,
                         feuille = if (est_mw()) "Triangle" else "Donnees"))

  output$dl_donnees <- downloadHandler(
    filename = function() if (est_mw()) FICHIER_MW else FICHIER_LN,
    content = function(f)
      utils::write.csv(tableau_export(), f, row.names = FALSE, na = ""))
}

shinyApp(ui, server)
