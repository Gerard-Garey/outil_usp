###############################################################################
#  tests/concordance_doc_moteur.R  --  CONCORDANCE DOCUMENTATION <-> MOTEUR
#  (issue #65)
#
#  Confronte docs/latex/doc_tests_usp.tex au code, sans relecture manuelle :
#    1. chaque \code{nom()} du document designe une fonction qui existe :
#       moteur ou affichage (apres source de R/engine.R et
#       R/display_helpers.R), R de base ou paquet charge par defaut, paquet
#       cite nommement (pkg::f) ou declare dans DESCRIPTION, fonction definie
#       dans app.R, outil de test (defini dans tests/*.R), ou fonction locale
#       (definie a l'interieur d'une autre) ; app.R et tests/*.R sont lus
#       sans etre executes ; un nom a joker (test_*()) doit designer au
#       moins une fonction. Un nom introuvable peut etre exempte nommement
#       (liste EXEMPTES_CODE : nom, motif de contexte, motif ecrit ; decision
#       Q-O3 du 24/09/2026) : c'est le cas des primitives Shiny citees dans
#       la colonne "Interdit" du tableau d'architecture. Un nom exempte est
#       juge sans consulter les paquets (verdict independant des paquets
#       installes, issue #86). Une exemption qui n'exempte plus rien est un
#       ecart (exemption perimee) ;
#    2. les decomptes de lignes de tests annonces par le document :
#       a) VERIFIES automatiquement pour les phrases du registre DECOMPTES
#          (plus bas), chacune ancree sur sa formulation exacte et rattachee a
#          une methode ; une phrase du registre introuvable (reformulee) est
#          un ecart, pour que le registre ne perime pas en silence ;
#       b) INVENTORIES (ligne, extrait) pour toutes les autres formulations
#          "N lignes" / "N entrees" (chiffres ou nombres en lettres) : leur
#          objet (table entiere, famille, sous-ensemble) ne se lit pas de facon
#          fiable par une expression reguliere, elles sont listees pour
#          relecture humaine et ne comptent pas comme ecarts ;
#
#       LIMITE (faux negatif par construction, audit R1 point 7) : seules
#       les phrases du registre DECOMPTES sont verifiees. Un decompte faux
#       ecrit ailleurs -- par ex. "51 lignes de tests pour la prime" --
#       n'apparait que dans l'inventaire b), n'est PAS un ecart et ne fait
#       pas echouer --strict. La sortie le rappelle ("inventaire non
#       verifie : N formulations"). Un BILAN a 0 ecart ne garantit donc pas
#       que tous les decomptes du document sont justes.
#
#       Suite (issue #75, non implementee ici) : toute formulation de
#       l'inventaire devra etre soit couverte par une phrase du registre
#       DECOMPTES, soit exemptee nommement avec son motif ; --strict
#       echouera alors sur toute formulation ni verifiee ni exemptee, et
#       l'inventaire s'etendra aux formulations "N tests" ;
#    3. chaque prefixe de famille produit par le moteur dans res$tests (deux
#       premiers caracteres du champ famille, cle de GROUPES) est declare
#       dans GROUPES de R/display_helpers.R ; les familles rencontrees
#       ailleurs dans le resultat (res$controles : "A. Qualite des donnees")
#       ne passent pas par GROUPES et sont signalees pour information ;
#    4. chaque cle de la colonne "Cle MC" de l'index des fonctions appartient
#       au catalogue Monte-Carlo de la methode de sa section (intertitres
#       H1 a H4, stabilite, robustesse -> USP_CATALOGUE_MC ; intertitres
#       "Methode Merz--Wuthrich" -> MW_CATALOGUE_MC) : une cle du mauvais
#       catalogue ou d'aucun est un ecart (issue #91). Les cles d'un
#       catalogue non citees sont signalees pour information.
#
#  Le moteur est execute sur les jeux de tests/donnees/ avec B petit
#  (defaut 99) : seule la STRUCTURE de la table des tests sert ici (nombre de
#  lignes, familles, types, nature de la p-value retenue). Cette structure
#  DEPEND de B sous un seuil : run_engine() (branche lognormale, R/engine.R)
#  calcule l'IC bootstrap par
#      ic <- if (length(usp_b) > 20) stats::quantile(usp_b, ...) else NULL
#  ou usp_b a la longueur de boot$sigma_boot (replications bootstrap FINIES
#  seulement, usp_bootstrap()), puis fit$largeur_ic <- NULL si ic est NULL,
#  et usp_tests() n'ajoute la ligne "Largeur relative de l'IC bootstrap 90%"
#  (famille G.) que si fit$largeur_ic n'est pas NULL. Mesure sur
#  tests/donnees/ : 47 lignes pour premium et reserve1 a B = 19 et 20, 48 a
#  B = 21 et 22 ; reserve2 : 19 lignes a B = 19, 20, 21, 22. Le script
#  refuse donc tout --B < B_MIN = 21 (erreur, code de sortie 1), et verifie
#  apres execution que chaque resultat lognormal a bien plus de 20
#  replications finies (B >= 21 est necessaire, pas suffisant si des
#  replications echouent).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/concordance_doc_moteur.R              # mode rapport
#      Rscript tests/concordance_doc_moteur.R --strict     # code 1 si ecart
#      Rscript tests/concordance_doc_moteur.R --B 999
#      Rscript tests/concordance_doc_moteur.R --strict --tex autre.tex
#
#  Mode rapport (defaut) : code de sortie 0 meme en cas d'ecart. --strict
#  (branche O, issue #65, --strict minimal de la decision Q-O3) : code de
#  sortie 1 des qu'il y a un ecart VERIFIE -- nom introuvable non exempte,
#  exemption perimee, phrase du registre DECOMPTES absente ou fausse,
#  prefixe de famille non declare dans GROUPES, cle MC hors du catalogue de
#  sa methode ou tableau de l'index introuvable. L'inventaire b) reste une
#  information sans effet sur le code de sortie (issue #75). --tex remplace
#  le document lu (tests du mode strict sur une copie modifiee).
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions d'extraction, testees sur des chaines LaTeX en memoire par
#  tests/unitaires/test_concordance_doc_moteur.R.
#  R base + stats + utils uniquement.
###############################################################################

# ---------------------------------------------------------------------------
#  Lecture du LaTeX
# ---------------------------------------------------------------------------

# Retire les commentaires LaTeX (% non precede d'une barre oblique inverse),
# ligne par ligne : les numeros de ligne restent ceux du fichier.
retirer_commentaires <- function(lignes) sub("(?<!\\\\)%.*$", "", lignes, perl = TRUE)

# Desechappement d'un contenu de \code{} vers le texte R qu'il represente.
desechapper <- function(x) {
  x <- gsub("\\textasciicircum", "^", x, fixed = TRUE)
  x <- gsub("\\textbackslash", "\\", x, fixed = TRUE)
  x <- gsub("\\\\([_$#&%{}])", "\\1", x)
  x <- gsub("\\\\(allowbreak|linebreak|newline|-)", "", x)
  x <- gsub("\\\\\\\\", " ", x)
  trimws(gsub("\\s+", " ", x))
}

# Tous les \code{...} du texte (vecteur de lignes), accolades imbriquees
# comprises, avec la ligne de debut. Un nom coupe en deux \code{} pour la
# mise en page (\code{test\_shapiro\_}\\ \code{francia()}) est recolle : le
# premier se termine par \_ et n'est separe du second que par des blancs ou
# une commande de coupure (\\, \allowbreak, \-, \linebreak, \newline).
extraire_codes <- function(lignes) {
  lignes <- retirer_commentaires(lignes)
  texte <- paste(lignes, collapse = "\n")
  debuts_lignes <- cumsum(c(1L, nchar(lignes) + 1L))[seq_along(lignes)]
  pos <- gregexpr("\\code{", texte, fixed = TRUE)[[1]]
  if (pos[1] == -1L) return(data.frame(ligne = integer(0), brut = character(0), stringsAsFactors = FALSE))
  car <- strsplit(texte, "")[[1]]
  res <- list(); fin_prec <- -1L
  for (p in pos) {
    i <- p + 6L; prof <- 1L; j <- i
    while (j <= length(car) && prof > 0L) {
      if (car[j] == "\\") { j <- j + 2L; next }
      if (car[j] == "{") prof <- prof + 1L else if (car[j] == "}") prof <- prof - 1L
      j <- j + 1L
    }
    contenu <- paste(car[i:(j - 2L)], collapse = "")
    entre <- if (fin_prec > 0L && p > fin_prec) paste(car[fin_prec:(p - 1L)], collapse = "") else NA_character_
    n <- length(res)
    if (n && grepl("\\\\_$", res[[n]]$brut) && !is.na(entre) &&
        grepl("^(\\s|\\\\\\\\|\\\\allowbreak|\\\\-|\\\\linebreak|\\\\newline)*$", entre)) {
      res[[n]]$brut <- paste0(res[[n]]$brut, contenu)
    } else {
      res[[n + 1L]] <- list(ligne = findInterval(p, debuts_lignes), brut = contenu)
    }
    fin_prec <- j
  }
  data.frame(ligne = vapply(res, function(r) as.integer(r$ligne), integer(1)),
             brut = vapply(res, function(r) r$brut, character(1)), stringsAsFactors = FALSE)
}

# Citations de fonction : contenus de \code{} de la forme nom(...), le nom
# pouvant etre qualifie (pkg::nom), commencer par un point (fonction
# interne) et contenir un joker * (famille de fonctions). Les \code{} sans
# parenthese (champs, fichiers, valeurs) ne sont pas des citations de
# fonction.
citations_fonctions <- function(codes) {
  txt <- desechapper(codes$brut)
  m <- regmatches(txt, regexec("^((?:[A-Za-z][A-Za-z0-9.]*::)?[A-Za-z.][A-Za-z0-9._*]*)\\(", txt, perl = TRUE))
  ok <- lengths(m) == 2L
  data.frame(ligne = codes$ligne[ok], citation = txt[ok],
             nom = vapply(m[ok], `[`, character(1), 2L), stringsAsFactors = FALSE)
}

# Fonctions definies dans des sources R, par lecture du texte (sans les
# executer) : definitions de premier niveau et definitions locales
# (indentees, a l'interieur d'une autre fonction).
definitions_fonctions <- function(fichiers) {
  res <- data.frame(nom = character(0), fichier = character(0), locale = logical(0),
                    stringsAsFactors = FALSE)
  for (f in fichiers) {
    l <- readLines(f, warn = FALSE, encoding = "UTF-8")
    m <- regmatches(l, regexec("^(\\s*)([.A-Za-z][A-Za-z0-9._]*)\\s*(<-|=)\\s*function\\b", l, perl = TRUE))
    m <- m[lengths(m) == 4L]
    if (length(m))
      res <- rbind(res, data.frame(nom = vapply(m, `[`, character(1), 3L), fichier = basename(f),
                                   locale = vapply(m, function(x) nzchar(x[2L]), logical(1)),
                                   stringsAsFactors = FALSE))
  }
  res
}

# Statut d'un nom de fonction cite. env : moteur et affichage charges ;
# paquets : noms des paquets a consulter en plus de ceux du chemin de
# recherche ; defs : sortie de definitions_fonctions().
statut_fonction <- function(nom, env, paquets = character(0), defs = NULL) {
  dans_paquet <- function(p, f) requireNamespace(p, quietly = TRUE) &&
    exists(f, envir = asNamespace(p), mode = "function", inherits = FALSE)
  if (grepl("::", nom, fixed = TRUE)) {
    p <- sub("::.*$", "", nom); f <- sub("^.*::", "", nom)
    if (!requireNamespace(p, quietly = TRUE)) return(sprintf("non verifiable (paquet %s absent)", p))
    return(if (dans_paquet(p, f)) sprintf("paquet %s", p) else "INTROUVABLE")
  }
  if (grepl("*", nom, fixed = TRUE)) {
    rx <- utils::glob2rx(nom)
    cand <- c(ls(env, all.names = TRUE), unlist(lapply(paquets, function(p)
      if (requireNamespace(p, quietly = TRUE)) ls(asNamespace(p), all.names = TRUE))))
    n <- length(unique(grep(rx, cand, value = TRUE)))
    return(if (n) sprintf("joker (%d fonction(s))", n) else "INTROUVABLE")
  }
  if (exists(nom, envir = env, mode = "function", inherits = FALSE)) return("moteur ou affichage")
  if (exists(nom, envir = env, mode = "function")) return("R (chemin de recherche)")
  if (!is.null(defs)) {
    d <- defs[defs$nom == nom, , drop = FALSE]
    if (any(d$fichier == "app.R" & !d$locale)) return("app.R")
    if (any(!d$locale & !d$fichier %in% c("engine.R", "display_helpers.R")))
      return(sprintf("outil de test (%s)", paste(unique(d$fichier[!d$locale]), collapse = ", ")))
    if (any(d$locale)) return(sprintf("fonction locale (%s)", paste(unique(d$fichier[d$locale]), collapse = ", ")))
  }
  for (p in paquets) if (dans_paquet(p, nom)) return(sprintf("paquet %s", p))
  "INTROUVABLE"
}

# ---------------------------------------------------------------------------
#  Exemptions nominatives des citations de fonction (decision Q-O3 du
#  mainteneur du 24/09/2026, issue #65)
# ---------------------------------------------------------------------------

# Citations \code{nom()} qui designent a juste titre une fonction absente du
# code et que le script ne doit pas compter comme ecarts. Chaque exemption
# porte : nom (tel qu'extrait par citations_fonctions(), joker compris),
# contexte (expression reguliere, perl, cherchee dans le texte normalise de
# la ligne de la citation et des `fenetre` lignes qui la precedent : un
# motif de contexte plutot qu'un numero de ligne, pour survivre au
# deplacement des lignes), motif (raison ecrite de l'exemption). Seule une
# citation INTROUVABLE dont le contexte correspond est exemptee ; une
# exemption qui n'exempte plus aucune citation est PERIMEE et comptee comme
# ecart, pour que la liste ne perime pas en silence.
MOTIF_INTERDIT_SHINY <- paste0("primitive Shiny citée dans la colonne « Interdit » du tableau ",
                               "d'architecture, pour être exclue")
EXEMPTES_CODE <- list(
  list(nom = "reactive", contexte = "Toute primitive Shiny", fenetre = 2L, motif = MOTIF_INTERDIT_SHINY),
  list(nom = "render*", contexte = "Toute primitive Shiny", fenetre = 2L, motif = MOTIF_INTERDIT_SHINY)
)

# Applique les exemptions aux citations. cit : sortie de
# citations_fonctions() ; statuts : vecteur nomme (par nom) de
# statut_fonction() ; lignes : texte LaTeX. Renvoie une liste :
#   ecarts    data.frame (nom, lignes) des noms introuvables non exemptes ;
#   exemptees data.frame (nom, ligne, motif) des citations exemptees ;
#   perimees  data.frame (nom, contexte) des exemptions sans effet.
appliquer_exemptions <- function(cit, statuts, lignes, exemptions = EXEMPTES_CODE) {
  norm <- normaliser_ligne(lignes)
  introuv <- cit[unname(statuts[cit$nom]) %in% "INTROUVABLE", , drop = FALSE]
  exemptee <- logical(nrow(introuv)); motif <- rep(NA_character_, nrow(introuv))
  utilisee <- logical(length(exemptions))
  for (k in seq_along(exemptions)) {
    e <- exemptions[[k]]
    for (i in which(introuv$nom == e$nom & !exemptee)) {
      fen <- norm[max(1L, introuv$ligne[i] - e$fenetre):introuv$ligne[i]]
      if (grepl(e$contexte, paste(fen, collapse = " "), perl = TRUE)) {
        exemptee[i] <- TRUE; motif[i] <- e$motif; utilisee[k] <- TRUE
      }
    }
  }
  rest <- introuv[!exemptee, , drop = FALSE]
  noms <- unique(rest$nom)
  list(ecarts = data.frame(nom = noms,
                           lignes = vapply(noms, function(n) paste(unique(rest$ligne[rest$nom == n]), collapse = ", "),
                                           character(1), USE.NAMES = FALSE),
                           stringsAsFactors = FALSE),
       exemptees = data.frame(nom = introuv$nom[exemptee], ligne = introuv$ligne[exemptee],
                              motif = motif[exemptee], stringsAsFactors = FALSE),
       perimees = data.frame(nom = vapply(exemptions[!utilisee], `[[`, character(1), "nom"),
                             contexte = vapply(exemptions[!utilisee], `[[`, character(1), "contexte"),
                             stringsAsFactors = FALSE))
}

# Statuts des noms cites (vecteur nomme, par nom). Un nom vise par une
# exemption est juge contre le code du depot seul (moteur, affichage, app.R,
# tests, chemin de recherche de base), sans consulter les paquets : une
# exemption couvre un nom absent du code, et son application comme sa
# peremption ne doivent pas dependre des paquets installes (issue #86 :
# reactive() et render*() trouves dans shiny quand il est installe,
# introuvables sinon).
statuts_citations <- function(noms, env, paquets = character(0), defs = NULL, exemptions = EXEMPTES_CODE) {
  exemptes <- vapply(exemptions, `[[`, character(1), "nom")
  vapply(noms, function(n)
    statut_fonction(n, env, paquets = if (n %in% exemptes) character(0) else paquets, defs = defs),
    character(1))
}

# ---------------------------------------------------------------------------
#  Decomptes
# ---------------------------------------------------------------------------

# Ligne LaTeX ramenee a du texte pour la recherche des decomptes : \_ -> _,
# commandes de mise en forme et accolades retirees, espaces insecables
# (~, \,) -> espace.
normaliser_ligne <- function(l) {
  l <- retirer_commentaires(l)
  l <- gsub("\\_", "_", l, fixed = TRUE)
  l <- gsub("\\\\(textbf|emph|textit|code|texttt)\\{", "", l)
  l <- gsub("[{}]", "", l)
  l <- gsub("~|\\\\,", " ", l)
  l
}

NOMBRES_FR <- c(un = 1, une = 1, deux = 2, trois = 3, quatre = 4, cinq = 5, six = 6, sept = 7,
                huit = 8, neuf = 9, dix = 10, onze = 11, douze = 12, treize = 13, quatorze = 14,
                quinze = 15, seize = 16, vingt = 20, trente = 30, quarante = 40, cinquante = 50,
                soixante = 60)

# Nombre ecrit en chiffres ou en lettres (jusqu'a 69 : dix-neuf,
# vingt-et-un, trente-deux...) ; NA si illisible.
nombre_fr <- function(x) {
  x <- tolower(trimws(x))
  if (grepl("^[0-9]+$", x)) return(as.numeric(x))
  parties <- strsplit(gsub("-et-| et ", "-", x), "-")[[1]]
  v <- NOMBRES_FR[parties]
  if (anyNA(v)) return(NA_real_)
  sum(v)
}

MOT_NOMBRE <- paste0("(?:[0-9]+|(?:", paste(names(NOMBRES_FR), collapse = "|"), ")(?:-(?:et-)?(?:",
                     paste(names(NOMBRES_FR), collapse = "|"), "))*)")

# Registre des phrases de decompte verifiees. motif : expression reguliere
# (perl, insensible a la casse) sur le texte normalise ; une espace du motif
# vaut n'importe quel blanc, retour a la ligne compris. verifier : fonction
# (captures, grandeurs) -> vecteur nomme "annonce = mesure" des comparaisons,
# grandeurs etant la sortie de grandeurs_moteur() pour la methode.
DECOMPTES <- list(
  list(id = "prime : nature des p-values retenues (calibration des p-values MC)",
       methode = "premium",
       motif = paste0("m\u00e9thode prime.{0,40}?(\\d+) des (\\d+) lignes de la table auditable retiennent ",
                      "une p-value de Monte-Carlo, contre (\\d+) une p-value exacte, (\\d+) une p-value ",
                      "quasi-exacte et (\\d+) une p-value asymptotique, les (\\d+) derni\u00e8res n'ayant aucune ",
                      "p-value retenue \\((\\d+) diagnostics, (\\d+) proc\u00e9dure de d\u00e9cision et (\\d+) ",
                      "ligne non applicable\\)"),
       champs = c("nature Monte-Carlo", "lignes (total)", "nature exacte", "nature quasi-exacte",
                  "nature asymptotique", "sans p-value retenue", "type diagnostic",
                  "type procedure de decision", "type non applicable")),
  list(id = "prime : p-values exactes disposant d'une p_mc",
       methode = "premium",
       motif = paste0("m\u00e9thode prime.{0,40}?des (\\d+) lignes de la table auditable, (\\d+) retiennent une ",
                      "p-value exacte, et (\\d+) d'entre elles disposent pourtant d'une p_mc"),
       champs = c("lignes (total)", "nature exacte", "exacte avec p_mc")),
  list(id = "Merz-Wuthrich : entrees par type",
       methode = "reserve2",
       motif = paste0("(", MOT_NOMBRE, ") entr\u00e9es, dont (", MOT_NOMBRE, ") tests d'hypoth\u00e8se, (",
                      MOT_NOMBRE, ") proc\u00e9dure de d\u00e9cision et (", MOT_NOMBRE, ") diagnostics"),
       champs = c("lignes (total)", "type test", "type procedure de decision", "type diagnostic")),
  list(id = "Merz-Wuthrich : famille M1 (schema)", methode = "reserve2",
       motif = "M1 \\((\\d+) entr\u00e9es\\)", champs = "famille M1"),
  list(id = "Merz-Wuthrich : famille M2 (schema)", methode = "reserve2",
       motif = "M2 \\((\\d+) entr\u00e9es\\)", champs = "famille M2")
)

# Grandeurs structurelles de la table des tests d'un resultat du moteur.
grandeurs_moteur <- function(tests) {
  champ <- function(n) vapply(tests, function(t) { v <- t[[n]]; if (is.null(v) || !length(v)) NA_character_ else as.character(v)[1] },
                              character(1))
  nat <- champ("nature_p"); typ <- champ("type"); fam <- substr(champ("famille"), 1L, 2L)
  pmc <- vapply(tests, function(t) !is.null(t$p_mc) && length(t$p_mc) && !is.na(t$p_mc), logical(1))
  g <- c("lignes (total)" = length(tests),
         "nature exacte" = sum(grepl("^exacte", nat)),
         "nature quasi-exacte" = sum(grepl("^quasi-exacte", nat)),
         "nature Monte-Carlo" = sum(grepl("^Monte-Carlo", nat)),
         "nature asymptotique" = sum(grepl("^asymptotique", nat)),
         "sans p-value retenue" = sum(is.na(nat)),
         "exacte avec p_mc" = sum(grepl("^exacte", nat) & pmc),
         "type test" = sum(typ %in% "test"),
         "type diagnostic" = sum(typ %in% "diagnostic"),
         "type procedure de decision" = sum(typ %in% "procedure de decision"),
         "type non applicable" = sum(typ %in% "non applicable"))
  for (f in unique(fam)) g[paste("famille", f)] <- sum(fam == f)
  g
}

# Applique le registre au texte (vecteur de lignes LaTeX). grandeurs : liste
# nommee par methode de sorties de grandeurs_moteur(). Renvoie un
# data.frame (assertion, ligne, grandeur, annonce, mesure, statut) ; une
# assertion introuvable donne une ligne de statut "INTROUVABLE".
verifier_decomptes <- function(lignes, grandeurs, registre = DECOMPTES) {
  norm <- normaliser_ligne(lignes)
  texte <- paste(norm, collapse = "\n")
  debuts <- cumsum(c(1L, nchar(norm) + 1L))[seq_along(norm)]
  out <- list()
  for (a in registre) {
    rx <- gsub(" ", "\\s+", a$motif, fixed = TRUE)
    m <- regexec(rx, texte, perl = TRUE, ignore.case = TRUE)
    cap <- regmatches(texte, m)[[1]]
    if (!length(cap)) {
      out[[length(out) + 1L]] <- data.frame(assertion = a$id, ligne = NA_integer_, ligne_fin = NA_integer_,
                                            grandeur = "(phrase)",
                                            annonce = NA_real_, mesure = NA_real_, statut = "INTROUVABLE",
                                            stringsAsFactors = FALSE)
      next
    }
    ligne <- findInterval(m[[1]][1], debuts)
    ligne_fin <- findInterval(m[[1]][1] + attr(m[[1]], "match.length")[1] - 1L, debuts)
    ann <- vapply(cap[-1L], nombre_fr, numeric(1))
    g <- grandeurs[[a$methode]]
    mes <- unname(ifelse(a$champs %in% names(g), g[a$champs], 0))
    out[[length(out) + 1L]] <- data.frame(assertion = a$id, ligne = ligne, ligne_fin = ligne_fin,
                                          grandeur = a$champs,
                                          annonce = unname(ann), mesure = mes,
                                          statut = ifelse(!is.na(ann) & ann == mes, "ok", "ECART"),
                                          stringsAsFactors = FALSE)
  }
  do.call(rbind, out)
}

# Inventaire des autres formulations "N lignes" / "N entrees".
inventaire_decomptes <- function(lignes) {
  norm <- normaliser_ligne(lignes)
  rx <- paste0("(?i)(?<![A-Za-z\u00c0-\u00ff-])", MOT_NOMBRE, "\\s+(lignes|entr\u00e9es)\\b")
  k <- grep(rx, norm, perl = TRUE)
  data.frame(ligne = k, extrait = trimws(substr(norm[k], 1L, 110L)), stringsAsFactors = FALSE)
}

# Prefixes de famille (deux premiers caracteres) de tous les champs
# "famille" d'un objet, a toute profondeur.
familles_produites <- function(o) {
  res <- character(0)
  if (is.list(o)) {
    if (!is.null(o$famille) && is.character(o$famille)) res <- c(res, o$famille)
    for (x in o) res <- c(res, familles_produites(x))
  }
  unique(res)
}

# ---------------------------------------------------------------------------
#  Colonne "Cle MC" de l'index des fonctions (issue #91)
# ---------------------------------------------------------------------------

# Cles de la colonne "Cle MC" (derniere colonne) du longtable dont l'en-tete
# porte \textbf{Clé MC}, avec la methode de leur section : "MW" sous un
# intertitre \multicolumn qui contient "Merz", "USP" sous tout autre
# intertitre, NA avant le premier. Seules les lignes apres \endlastfoot sont
# lues (les en-tetes repetes du longtable ne portent pas de cle). Une ligne
# du tableau se termine par \\ ; les cellules sont separees par les &
# non echappes. Renvoie NULL si le tableau est introuvable, sinon un
# data.frame (ligne, cle, methode), une ligne par \code{} de la derniere
# cellule (texte sans \code{}, tiret ou "toutes les cles ci-dessus", ne
# produit aucune cle).
cles_mc_index <- function(lignes) {
  lignes <- retirer_commentaires(lignes)
  deb <- grep("\\textbf{Clé MC}", lignes, fixed = TRUE)[1L]
  if (is.na(deb)) return(NULL)
  fin <- grep("\\end{longtable}", lignes, fixed = TRUE)
  fin <- fin[fin > deb][1L]
  pied <- grep("\\endlastfoot", lignes, fixed = TRUE)
  pied <- pied[pied > deb & pied < fin][1L]
  if (is.na(fin) || is.na(pied)) return(NULL)
  res <- data.frame(ligne = integer(0), cle = character(0), methode = character(0), stringsAsFactors = FALSE)
  methode <- NA_character_; tampon <- character(0); l0 <- NA_integer_
  for (k in seq.int(pied + 1L, fin - 1L)) {
    l <- lignes[k]
    if (!length(tampon) && grepl("^\\s*(\\\\(midrule|toprule|bottomrule))?\\s*$", l)) next
    if (!length(tampon)) l0 <- k
    tampon <- c(tampon, l)
    if (!grepl("\\\\\\\\\\s*$", l)) next
    rangee <- paste(tampon, collapse = "\n"); tampon <- character(0)
    if (grepl("\\multicolumn", rangee, fixed = TRUE)) {
      methode <- if (grepl("Merz", rangee, fixed = TRUE)) "MW" else "USP"
      next
    }
    esp <- gregexpr("(?<!\\\\)&", rangee, perl = TRUE)[[1]]
    if (esp[1L] == -1L) next
    p <- esp[length(esp)]
    cellule <- sub("\\\\\\\\\\s*$", "", substring(rangee, p + 1L))
    decal <- l0 + lengths(regmatches(substr(rangee, 1L, p), gregexpr("\n", substr(rangee, 1L, p))))
    cod <- extraire_codes(strsplit(cellule, "\n", fixed = TRUE)[[1]])
    if (nrow(cod))
      res <- rbind(res, data.frame(ligne = decal + cod$ligne - 1L, cle = desechapper(cod$brut),
                                   methode = methode, stringsAsFactors = FALSE))
  }
  res
}

# Ecarts de la colonne "Cle MC" : cle absente du catalogue de la methode de
# sa section (catalogues : liste nommee USP, MW de noms de cles), ou cle
# hors de toute section. Renvoie un data.frame (ligne, cle, methode, motif).
verifier_cles_mc <- function(cles, catalogues) {
  ok <- vapply(seq_len(nrow(cles)), function(i)
    !is.na(cles$methode[i]) && cles$cle[i] %in% catalogues[[cles$methode[i]]], logical(1))
  e <- cles[!ok, , drop = FALSE]
  motif <- vapply(seq_len(nrow(e)), function(i) {
    if (is.na(e$methode[i])) return("hors de toute section de methode")
    autres <- names(catalogues)[vapply(catalogues, function(cat) e$cle[i] %in% cat, logical(1))]
    sprintf("absente du catalogue %s%s", e$methode[i],
            if (length(autres)) sprintf(" (cle du catalogue %s)", paste(autres, collapse = ", ")) else "")
  }, character(1))
  data.frame(ligne = e$ligne, cle = e$cle, methode = e$methode, motif = motif, stringsAsFactors = FALSE)
}

# ---------------------------------------------------------------------------
#  Nombre de replications bootstrap
# ---------------------------------------------------------------------------

# Seuil de B sous lequel la table des tests lognormale perd une ligne :
# run_engine() ne calcule l'IC bootstrap (et usp_tests() la ligne "Largeur
# relative de l'IC bootstrap 90%") que si length(usp_b) > 20, usp_b ayant
# la longueur de boot$sigma_boot (replications finies). Voir l'en-tete.
B_MIN <- 21L

# Valide la valeur de --B (chaine ou nombre) ; erreur explicite si ce n'est
# pas un entier ou s'il est sous B_MIN. Renvoie B entier.
valider_B <- function(x) {
  B <- suppressWarnings(as.integer(x))
  if (length(B) != 1L || is.na(B) || as.character(B) != trimws(as.character(x)))
    stop(sprintf("--B : entier attendu, recu \"%s\"", paste(x, collapse = " ")), call. = FALSE)
  if (B < B_MIN)
    stop(sprintf(paste0("--B = %d refuse : B >= %d requis. Sous ce seuil, run_engine() ne calcule pas ",
                        "l'IC bootstrap (R/engine.R : ic <- if (length(usp_b) > 20) ... else NULL) et la ",
                        "table des tests lognormale perd la ligne \"Largeur relative de l'IC bootstrap 90%%\" ",
                        "(famille G.) : les decomptes du document ne seraient plus comparables."), B, B_MIN),
         call. = FALSE)
  B
}

# ---------------------------------------------------------------------------
#  Programme principal
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  strict <- "--strict" %in% args
  B <- 99L
  k <- match("--B", args)
  if (!is.na(k)) {
    if (k == length(args)) stop("--B sans valeur")
    B <- valider_B(args[k + 1L])
  }
  k <- match("--tex", args)
  fichier_tex <- if (is.na(k)) NULL else {
    if (k == length(args)) stop("--tex sans valeur")
    args[k + 1L]
  }
  RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
    stop("R/engine.R introuvable : lancer depuis la racine du depot.")

  env <- new.env(parent = globalenv())
  sys.source(file.path(RACINE, "R", "engine.R"), envir = env)
  sys.source(file.path(RACINE, "R", "display_helpers.R"), envir = env)
  if (is.null(fichier_tex)) fichier_tex <- file.path(RACINE, "docs", "latex", "doc_tests_usp.tex")
  tex <- readLines(fichier_tex, warn = FALSE, encoding = "UTF-8")
  n_ecarts <- 0L

  # 1. Fonctions citees
  desc <- read.dcf(file.path(RACINE, "DESCRIPTION"), fields = c("Imports", "Suggests"))
  paquets <- setdiff(trimws(unlist(strsplit(gsub("\\([^)]*\\)", "", paste(desc[!is.na(desc)], collapse = ",")), ","))), "")
  # Sources lues sans etre executees : app.R (lancerait Shiny) et les
  # scripts de tests/ (le document cite aussi l'outillage de
  # non-regression, par ex. comparer_objets()).
  defs <- definitions_fonctions(c(file.path(RACINE, c("R/engine.R", "R/display_helpers.R", "app.R")),
                                  list.files(file.path(RACINE, "tests"), pattern = "[.]R$", full.names = TRUE)))
  cit <- citations_fonctions(extraire_codes(tex))
  noms <- unique(cit$nom)
  statuts <- statuts_citations(noms, env = env, paquets = paquets, defs = defs)
  cat(sprintf("=== 1. Fonctions citees par \\code{nom()} : %d citation(s), %d nom(s) distinct(s)\n",
              nrow(cit), length(noms)))
  # Recapitulatif par nom distinct, APRES exemptions : un nom introuvable
  # dont toutes les citations sont exemptees est compte comme exempte ; un
  # nom dont une citation au moins reste introuvable est un ecart.
  ex <- appliquer_exemptions(cit, statuts, tex)
  recap <- sub(" \\(.*$", "", statuts)
  recap[statuts == "INTROUVABLE"] <- "exempte (EXEMPTES_CODE)"
  recap[names(statuts) %in% ex$ecarts$nom] <- "INTROUVABLE non exempte"
  tab <- table(recap)
  for (s in names(tab)) cat(sprintf("  %-26s %d\n", s, tab[[s]]))
  autres <- noms[!statuts %in% c("moteur ou affichage", "INTROUVABLE")]
  if (length(autres)) {
    cat("  Hors moteur et affichage (pour information) :\n")
    for (n in autres) cat(sprintf("    %-32s %s\n", n, statuts[[n]]))
  }
  if (nrow(ex$exemptees)) {
    cat(sprintf("  Exemptees nommement (EXEMPTES_CODE, %d citation(s), pas des ecarts) :\n", nrow(ex$exemptees)))
    for (i in seq_len(nrow(ex$exemptees)))
      cat(sprintf("    %-32s ligne %-5d %s\n", paste0(ex$exemptees$nom[i], "()"), ex$exemptees$ligne[i],
                  ex$exemptees$motif[i]))
  }
  n_ecarts <- n_ecarts + nrow(ex$ecarts) + nrow(ex$perimees)
  if (nrow(ex$ecarts)) {
    cat(sprintf("  ECART -- %d nom(s) introuvable(s) non exempte(s) :\n", nrow(ex$ecarts)))
    for (i in seq_len(nrow(ex$ecarts)))
      cat(sprintf("    %-32s ligne(s) %s\n", paste0(ex$ecarts$nom[i], "()"), ex$ecarts$lignes[i]))
  }
  if (nrow(ex$perimees)) {
    cat(sprintf("  ECART -- %d exemption(s) perimee(s) (aucune citation introuvable ne lui correspond) :\n",
                nrow(ex$perimees)))
    for (i in seq_len(nrow(ex$perimees)))
      cat(sprintf("    %-32s contexte \"%s\"\n", paste0(ex$perimees$nom[i], "()"), ex$perimees$contexte[i]))
  }

  # 2. Decomptes
  outils <- new.env(parent = globalenv())
  sys.source(file.path(RACINE, "tests", "outils_tests.R"), envir = outils)
  resultats <- with(outils, list(
    premium  = run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium", segment = 1, annexe = "II", B = B,
                          nature_donnees = "brutes"),
    reserve1 = run_engine(xt = .ln$xt, yt = .ln$yt, methode = "reserve1", segment = 1, annexe = "II", B = B),
    reserve2 = run_engine(methode = "reserve2", triangle = .tri, segment = 1, annexe = "II", B = B)))
  n_finies <- vapply(resultats[c("premium", "reserve1")], function(r) length(r$bootstrap$sigma_boot), integer(1))
  if (any(n_finies <= 20L))
    stop(sprintf(paste0("replications bootstrap finies insuffisantes (%s) : run_engine() ne calcule l'IC ",
                        "bootstrap que si length(usp_b) > 20 ; augmenter --B."),
                 paste(sprintf("%s %d", names(n_finies), n_finies), collapse = ", ")), call. = FALSE)
  grandeurs <- lapply(resultats, function(r) grandeurs_moteur(r$tests))
  cat(sprintf("\n=== 2. Decomptes (moteur execute sur tests/donnees/, B = %d)\n", B))
  for (m in names(grandeurs))
    cat(sprintf("  %-9s %d lignes de tests ; familles : %s\n", m, grandeurs[[m]][["lignes (total)"]],
                paste(sprintf("%s=%d", sub("famille ", "", grep("^famille", names(grandeurs[[m]]), value = TRUE)),
                              grandeurs[[m]][grep("^famille", names(grandeurs[[m]]))]), collapse = " ")))
  v <- verifier_decomptes(tex, grandeurs)
  cat("  a) Phrases du registre DECOMPTES (verifiees) :\n")
  for (i in seq_len(nrow(v)))
    cat(sprintf("    [%-11s] l.%-5s %-60s %-28s annonce %-4s mesure %s\n", v$statut[i],
                ifelse(is.na(v$ligne[i]), "?", v$ligne[i]), substr(v$assertion[i], 1, 60), v$grandeur[i],
                ifelse(is.na(v$annonce[i]), "-", format(v$annonce[i])),
                ifelse(is.na(v$mesure[i]), "-", format(v$mesure[i]))))
  n_ecarts <- n_ecarts + sum(v$statut != "ok")
  inv <- inventaire_decomptes(tex)
  couvertes <- unlist(lapply(which(!is.na(v$ligne)), function(i) v$ligne[i]:v$ligne_fin[i]))
  inv <- inv[!inv$ligne %in% couvertes, , drop = FALSE]
  cat(sprintf("  b) Inventaire NON VERIFIE : %d formulation(s) \"N lignes\" / \"N entrees\" hors registre (a relire ; jamais comptees comme ecarts) :\n",
              nrow(inv)))
  for (i in seq_len(nrow(inv))) cat(sprintf("    l.%-5d %s\n", inv$ligne[i], inv$extrait[i]))

  # 3. Familles. GROUPES regroupe les lignes de res$tests (groupe_de() de
  # display_helpers.R, appele sur la table des tests) : c'est la que tout
  # prefixe doit etre declare. Les champs famille rencontres ailleurs dans
  # le resultat (par ex. res$controles) sont signales pour information.
  fam <- unique(unlist(lapply(resultats, function(r) familles_produites(r$tests))))
  pref <- unique(substr(fam, 1L, 2L))
  fam_aut <- unique(unlist(lapply(resultats, function(r) familles_produites(r[setdiff(names(r), "tests")]))))
  non_decl <- setdiff(pref, names(env$GROUPES))
  cat(sprintf("\n=== 3. Prefixes de famille produits dans res$tests : %s ; declares dans GROUPES : %s\n",
              paste(sort(pref), collapse = " "), paste(names(env$GROUPES), collapse = " ")))
  hors <- setdiff(unique(substr(fam_aut, 1L, 2L)), names(env$GROUPES))
  if (length(hors))
    cat("  (information) famille(s) hors res$tests, non regroupees par GROUPES :",
        paste(fam_aut[substr(fam_aut, 1L, 2L) %in% hors], collapse = " ; "), "\n")
  if (length(non_decl)) {
    n_ecarts <- n_ecarts + length(non_decl)
    cat("  ECART -- prefixe(s) non declare(s) dans GROUPES :\n")
    for (p in non_decl) cat(sprintf("    \"%s\" : %s\n", p, paste(fam[substr(fam, 1L, 2L) == p], collapse = " ; ")))
  }
  inutilises <- setdiff(names(env$GROUPES), pref)
  if (length(inutilises)) cat("  (information) cle(s) de GROUPES non produites sur ces jeux :",
                              paste(inutilises, collapse = " "), "\n")

  # 4. Colonne "Cle MC" de l'index des fonctions (issue #91) : chaque cle
  # appartient au catalogue de la methode de sa section.
  catalogues <- list(USP = names(env$USP_CATALOGUE_MC), MW = names(env$MW_CATALOGUE_MC))
  cles <- cles_mc_index(tex)
  if (is.null(cles)) {
    n_ecarts <- n_ecarts + 1L
    cat("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions\n  ECART -- tableau introuvable (en-tete \\textbf{Clé MC} et \\endlastfoot attendus)\n")
  } else {
    e_mc <- verifier_cles_mc(cles, catalogues)
    cat(sprintf("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions : %d cle(s) (USP %d, MW %d)\n",
                nrow(cles), sum(cles$methode %in% "USP"), sum(cles$methode %in% "MW")))
    for (m in names(catalogues)) {
      nc <- setdiff(catalogues[[m]], cles$cle[cles$methode %in% m])
      if (length(nc)) cat(sprintf("  (information) cle(s) du catalogue %s non citee(s) : %s\n", m, paste(nc, collapse = " ")))
    }
    n_ecarts <- n_ecarts + nrow(e_mc)
    if (nrow(e_mc)) {
      cat(sprintf("  ECART -- %d cle(s) hors du catalogue de leur methode :\n", nrow(e_mc)))
      for (i in seq_len(nrow(e_mc)))
        cat(sprintf("    l.%-5d %-12s %s\n", e_mc$ligne[i], e_mc$cle[i], e_mc$motif[i]))
    }
  }

  cat(sprintf("\nBILAN : %d ecart(s)%s ; inventaire non verifie : %d formulation(s) (information, sans effet sur le code de sortie : un decompte faux hors registre DECOMPTES n'est pas detecte, issue #75)\n",
              n_ecarts, if (strict) " (mode strict)" else " (mode rapport : code de sortie 0)", nrow(inv)))
  if (strict && n_ecarts) quit(status = 1)
}
