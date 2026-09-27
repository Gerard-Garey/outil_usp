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
#    2. les decomptes annonces par le document (issue #75) :
#       a) VERIFIES automatiquement pour les phrases du registre DECOMPTES
#          (plus bas), chacune ancree sur sa formulation exacte et rattachee a
#          une grandeur mesuree : table des tests ou res$controles d'une
#          methode (grandeurs_moteur()), ou constante du moteur
#          (grandeurs_code()) ; une phrase du registre introuvable
#          (reformulee) est un ecart, pour que le registre ne perime pas en
#          silence ;
#       b) CLASSES : toute formulation "N lignes" / "N entrees" / "N tests"
#          du document (chiffres, nombre en mode mathematique $6$ ou nombre
#          en lettres jusqu'a cent, au pluriel, avec au plus deux
#          qualificatifs intercales -- "cinq autres lignes", "les deux
#          dernieres entrees" (liste QUALIFICATIFS) --, y compris coupee par
#          un retour a la ligne ; classer_formulations()) est soit verifiee
#          (son nombre est a la position d'un nombre capture par une phrase
#          du registre), soit exemptee nommement (liste EXEMPTES_DECOMPTES :
#          id, contexte, motif ecrit), soit NON CLASSEE, et c'est alors un
#          ecart. Une exemption qui n'exempte plus rien est un ecart
#          (perimee).
#
#       LIMITES : (i) une formulation exemptee n'est pas verifiee (anaphore,
#       provenance par fonction, lignes d'un tableau du document, constat
#       de simulation) ; (ii) un decompte ecrit sans les mots "lignes",
#       "entrees" ou "tests" apres le nombre ("six verdicts", "quinze
#       p-values", "un test") n'est pas inventorie, pas plus qu'un nombre
#       separe de ces mots par un qualificatif hors de la liste
#       QUALIFICATIFS ("six lignes" oui, "six grandes lignes" non) ou par
#       plus de deux qualificatifs ; (iii) une phrase du registre mesure sa
#       grandeur sur les jeux de tests/donnees/ : un decompte qui depend des
#       donnees (par ex. une nature de p-value, "restent en Monte-Carlo dans
#       tous les regimes") n'est verifie que sur ces jeux ; (iv) nombres en
#       lettres lus jusqu'a cent ("quatre-vingts", "quatre-vingt-dix-neuf",
#       "cent") : au-dela ("deux cents"), la formulation n'est pas
#       inventoriee ; (v) les formules mathematiques sont lues sans leurs
#       delimiteurs $ : "$6$ lignes" est inventorie, mais un nombre calcule
#       dans une formule ("$2k/T$ lignes") ne l'est pas ;
#    3. chaque prefixe de famille produit par le moteur dans res$tests (deux
#       premiers caracteres du champ famille, cle de GROUPES) est declare
#       dans GROUPES de R/display_helpers.R ; les familles rencontrees
#       ailleurs dans le resultat (res$controles : "A. Qualite des donnees")
#       ne passent pas par GROUPES et sont signalees pour information ;
#    4. chaque cle de la colonne "Cle MC" de l'index des fonctions appartient
#       au catalogue Monte-Carlo de la methode de sa section (intertitres
#       H1 a H4, stabilite, robustesse -> USP_CATALOGUE_MC ; intertitres
#       "Methode Merz--Wuthrich" -> MW_CATALOGUE_MC) : une cle du mauvais
#       catalogue ou d'aucun est un ecart (issue #91), de meme qu'une
#       rangee non terminee avant \end{longtable} et un tableau sans aucune
#       cle. Les cles d'un catalogue non citees sont signalees pour
#       information. Limite : l'appartenance au catalogue est verifiee, pas
#       la correspondance cle <-> test (voir cles_mc_index()).
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
#  replications echouent). Les methodes lognormales sont en outre executees
#  a volumes constants (x_t = 100, pertes de tests/donnees/donnees_ln.csv ;
#  issue #59) pour les seules phrases du registre qui les nomment.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/concordance_doc_moteur.R              # mode rapport
#      Rscript tests/concordance_doc_moteur.R --strict     # code 1 si ecart
#      Rscript tests/concordance_doc_moteur.R --B 999
#      Rscript tests/concordance_doc_moteur.R --strict --tex autre.tex
#
#  Mode rapport (defaut) : code de sortie 0 meme en cas d'ecart. --strict
#  (branche O, issue #65, --strict minimal de la decision Q-O3) : code de
#  sortie 1 des qu'il y a un ecart -- nom introuvable non exempte,
#  exemption perimee (de citation ou de decompte), phrase du registre
#  DECOMPTES absente ou fausse, formulation de decompte ni verifiee ni
#  exemptee (issue #75), prefixe de famille non declare dans GROUPES, cle
#  MC hors du catalogue de sa methode, tableau de l'index introuvable, sans
#  cle ou a rangee non terminee. --tex remplace le document lu (tests du
#  mode strict sur une copie modifiee).
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
# commandes de mise en forme et accolades retirees, delimiteurs de mode
# mathematique $ retires ("$6$ lignes" -> "6 lignes", "$u_t$" -> "u_t"),
# espaces insecables (~, \,) -> espace.
normaliser_ligne <- function(l) {
  l <- retirer_commentaires(l)
  l <- gsub("\\_", "_", l, fixed = TRUE)
  l <- gsub("\\\\(textbf|emph|textit|code|texttt)\\{", "", l)
  l <- gsub("[{}$]", "", l)
  l <- gsub("~|\\\\,", " ", l)
  l
}

# Mots-nombres lus (jusqu'a cent). "quatre-vingt(s)" vaut 80 d'un seul
# tenant (lu avant "quatre" par MOT_NOMBRE) ; "vingts" n'existe qu'apres
# "quatre".
NOMBRES_FR <- c(un = 1, une = 1, deux = 2, trois = 3, quatre = 4, cinq = 5, six = 6, sept = 7,
                huit = 8, neuf = 9, dix = 10, onze = 11, douze = 12, treize = 13, quatorze = 14,
                quinze = 15, seize = 16, vingt = 20, trente = 30, quarante = 40, cinquante = 50,
                soixante = 60, "quatre-vingts" = 80, "quatre-vingt" = 80, cent = 100)

# Nombre ecrit en chiffres ou en lettres (jusqu'a cent : dix-neuf,
# vingt-et-un, soixante-douze, quatre-vingts, quatre-vingt-dix-neuf, cent) ;
# NA si illisible.
nombre_fr <- function(x) {
  x <- tolower(trimws(x))
  if (grepl("^[0-9]+$", x)) return(as.numeric(x))
  x <- gsub("quatre-vingts?", "quatrevingt", x)
  parties <- strsplit(gsub("-et-| et ", "-", x), "-")[[1]]
  parties[parties == "quatrevingt"] <- "quatre-vingt"
  v <- NOMBRES_FR[parties]
  if (anyNA(v)) return(NA_real_)
  sum(v)
}

# Alternatives triees par longueur decroissante : "quatre-vingts" avant
# "quatre-vingt" avant "quatre", "une" avant "un".
.MOTS_NOMBRES <- names(NOMBRES_FR)[order(-nchar(names(NOMBRES_FR)))]
MOT_NOMBRE <- paste0("(?:[0-9]+|(?:", paste(.MOTS_NOMBRES, collapse = "|"), ")(?:-(?:et-)?(?:",
                     paste(.MOTS_NOMBRES, collapse = "|"), "))*)")

# Qualificatifs admis entre le nombre et "lignes" / "entrees" / "tests"
# dans l'inventaire (au plus deux) : "les cinq autres lignes", "les deux
# dernieres entrees", "les six memes tests".
QUALIFICATIFS <- c("autres", "premi(?:e|\u00e8)res", "premiers", "derni(?:e|\u00e8)res", "derniers",
                   "seules", "seuls", "m(?:e|\u00ea)mes", "nouvelles", "nouveaux", "principales",
                   "principaux", "restantes", "restants", "suivantes", "suivants",
                   "pr(?:e|\u00e9)c(?:e|\u00e9)dentes", "pr(?:e|\u00e9)c(?:e|\u00e9)dents")

# Capture d'un nombre en chiffres ou en lettres, pour les motifs du registre :
# un nombre modifie dans le document reste capture (ECART), il ne rend pas la
# phrase introuvable.
N_ <- paste0("(", MOT_NOMBRE, ")")

# Registre des phrases de decompte verifiees. motif : expression reguliere
# (perl, insensible a la casse) sur le texte normalise ; une espace du motif
# vaut n'importe quel blanc, retour a la ligne compris ; chaque groupe
# capturant est un nombre annonce. methode : cle (ou vecteur de cles) de la
# liste des grandeurs mesurees -- "premium", "reserve1", "reserve2" (sortie de
# grandeurs_moteur() sur le resultat de run_engine()), "code" (sortie de
# grandeurs_code(), constantes du moteur) ; plusieurs cles : l'annonce est
# comparee a la mesure de chacune. champs : grandeur comparee a chaque
# capture, dans l'ordre (le nombre de groupes capturants doit egaler celui
# des champs). Une phrase du registre couvre les formulations de
# l'inventaire (N lignes / entrees / tests) dont le nombre est a la position
# de l'un de ses groupes capturants.
DECOMPTES <- list(
  list(id = "prime : nature des p-values retenues (calibration des p-values MC)",
       methode = "premium",
       motif = paste0("m\u00e9thode prime.{0,40}?(\\d+) des (\\d+) lignes de la table auditable retiennent ",
                      "une p-value de Monte-Carlo, contre (\\d+) une p-value exacte, (\\d+) une p-value ",
                      "sous le mod\u00e8le auxiliaire MCO et (\\d+) une p-value asymptotique, les (\\d+) derni\u00e8res n'ayant aucune ",
                      "p-value retenue \\((\\d+) diagnostics, (\\d+) proc\u00e9dure de d\u00e9cision et (\\d+) ",
                      "ligne non applicable\\)"),
       champs = c("nature Monte-Carlo", "lignes (total)", "nature exacte", "nature modele auxiliaire MCO",
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
       motif = "M2 \\((\\d+) entr\u00e9es\\)", champs = "famille M2"),
  # Issue #75 : formulations de l'ancien inventaire non verifie, rattachees
  # a une grandeur mesurable du moteur.
  list(id = "catalogues Monte-Carlo (index des fonctions)", methode = "code",
       motif = paste0("catalogues des statistiques Monte-Carlo \\(", N_, " et ", N_, " entr\u00e9es\\)"),
       champs = c("catalogue USP", "catalogue MW")),
  list(id = "Merz-Wuthrich : lignes fondees sur les residus (controle d'entree)", methode = "code",
       motif = paste0(N_, " lignes de M1 \u00e0 M5 fond\u00e9es sur les r\u00e9sidus"),
       champs = "lignes MW sur residus"),
  list(id = "Merz-Wuthrich : lignes qui consomment les residus (M1 a M5)", methode = "code",
       motif = paste0(N_, " lignes de M1 \u00e0 M5 qui consomment ces r\u00e9sidus"),
       champs = "lignes MW sur residus"),
  list(id = "lognormale : entrees de res$controles", methode = c("premium", "reserve1"),
       motif = paste0("res.{0,2}controles \u00e0 ", N_, " entr\u00e9es pour les m\u00e9thodes lognormales"),
       champs = "controles (total)"),
  list(id = "lognormale : entrees de la famille H de res$controles", methode = c("premium", "reserve1"),
       motif = paste0("qui produit les ", N_, " entr\u00e9es ajout\u00e9es \u00e0 res.{0,2}controles"),
       champs = "controles famille H."),
  list(id = "prime : lignes a p exacte attribuee (loi pour observations echangeables)", methode = "premium",
       motif = paste0(N_, " lignes de la table auditable se voient attribuer, .{0,40}?une p-value exacte ",
                      "dont la loi de r\u00e9f\u00e9rence"),
       champs = "p exacte hors base r"),
  # Suite de la meme phrase (jeu de controle, delta = 1) : parmi ces lignes,
  # celles dont la p-value retenue est la p-value exacte.
  list(id = "prime : lignes a p exacte attribuee qui la retiennent (jeu de controle)", methode = "premium",
       motif = paste0("sur le jeu de contr\u00f4le\\s+\\(.{1,20}\\), ", N_,
                      " d'entre elles retiennent leur p-value exacte"),
       champs = "p exacte hors base r retenue"),
  list(id = "prime : lignes sur la base u_t", methode = "premium",
       motif = paste0(N_, " lignes de la table auditable sont calcul\u00e9es sur la base"),
       champs = "base r"),
  list(id = "prime : lignes sur u_t et homologues sur z_t", methode = "premium",
       motif = paste0("les ", N_, " lignes sur base u_t et leurs ", N_, " homologues sur"),
       champs = c("base r", "base z")),
  list(id = "prime : lignes sur u_t (restent exactes)", methode = "premium",
       motif = paste0("les ", N_, " lignes restent exactes"), champs = "base r"),
  list(id = "prime : lignes sur u_t (detail CONTROLE SANS OBJET ICI)", methode = "premium",
       motif = paste0("detail de chacune des ", N_, " lignes contient .{1,3}CONTROLE SANS OBJET ICI"),
       champs = "detail sans objet ici"),
  list(id = "prime : lignes sur u_t (quasi-doublons)", methode = "premium",
       motif = paste0("les ", N_, " lignes correspondantes sont des quasi-doublons"), champs = "base r"),
  list(id = "prime : lignes sur u_t (index des decisions)", methode = "premium",
       motif = paste0("champ detail des ", N_, " lignes de base r dans usp_tests"), champs = "base r"),
  list(id = "prime : lignes sur u_t (index des fonctions, usp_regime)", methode = "premium",
       motif = paste0("champ detail des ", N_, " lignes sur ratios bruts"), champs = "base r"),
  list(id = "prime : lignes sur u_t (graphe d'appels)", methode = "premium",
       motif = paste0(N_, " lignes sur u_t, construit par"), champs = "base r"),
  list(id = "prime : lignes sur u_t (loi de reference simulee)", methode = "premium",
       motif = paste0("la statistique observ\u00e9e de ces ", N_, " lignes"), champs = "base r"),
  list(id = "prime : tests sous deux formes (variante secondaire)", methode = c("premium", "reserve1"),
       motif = paste0(N_, " tests existent dans le dispositif sous deux formes concurrentes"),
       champs = "variante secondaire"),
  list(id = "prime : lignes du test des suites (p-values differentes avant #29)", methode = "premium",
       motif = paste0("les ", N_, " lignes affichaient n\u00e9anmoins des p-values diff\u00e9rentes"),
       champs = "lignes du test des suites"),
  list(id = "prime : lignes du test des suites (meme p exacte depuis #29)", methode = "premium",
       motif = paste0("les ", N_, " lignes portent d\u00e9sormais la m\u00eame p-value exacte"),
       champs = "lignes du test des suites"),
  list(id = "prime : lignes du test des suites (fiche des suites, rubrique 5)", methode = "premium",
       motif = paste0("0,743 sur les ", N_, " lignes, p_mc"), champs = "lignes du test des suites"),
  list(id = "prime : lignes du test des suites (fiche des suites sur u_t)", methode = "premium",
       motif = paste0("0,743 retenue sur les ", N_, " lignes, p_mc"), champs = "lignes du test des suites"),
  list(id = "prime : grandeurs rivees par l'estimation", methode = "premium",
       motif = paste0("Ces ", N_, " lignes sont restitu\u00e9es comme diagnostics, sans p-value retenue"),
       champs = "grandeur rivee"),
  list(id = "prime : tests de H2 (graphe d'appels)", methode = "premium",
       motif = paste0("Chacun des ", N_, " tests dispose de sa propre fonction"),
       champs = "famille C. type test"),
  list(id = "Merz-Wuthrich : tests de normalite (M5)", methode = "reserve2",
       motif = paste0("Les ", N_, " tests de normalit\u00e9 sont compt\u00e9s parmi les tests"),
       champs = "famille M5 type test"),
  list(id = "Merz-Wuthrich : tests reposant sur le bootstrap", methode = "reserve2",
       motif = paste0(N_, " de ces ", N_, " tests reposent sur le bootstrap"),
       champs = c("nature Monte-Carlo", "type test")),
  # Formulation a qualificatif intercale ("cinq autres lignes"), inventoriee
  # depuis l'audit de #75 (C2). Le meme nombre est capture deux fois (groupe
  # dans une assertion avant, puis groupe ordinaire, a la meme position) :
  # le nombre de lignes de base r hors test des suites, et le nombre de ces
  # lignes dont la p-value retenue est de Monte-Carlo ; une ligne de base r
  # ajoutee ou sortie de Monte-Carlo fait diverger l'un des deux.
  list(id = "prime : lignes de base r hors suites (restent en Monte-Carlo)", methode = "premium",
       motif = paste0("Les (?=", N_, ")", N_, " autres lignes de la base .{1,3}ratios bruts.{1,3} ",
                      "restent en Monte-Carlo"),
       champs = c("base r hors suites", "base r hors suites Monte-Carlo")),
  # Issue #59 : lignes restituees non applicables a volumes constants,
  # mesurees sur une execution supplementaire (volumes x_t = 100 constants,
  # pertes y_t de tests/donnees/donnees_ln.csv ; cles premium_vc et
  # reserve1_vc, voir le programme principal).
  list(id = "lognormale : lignes non applicables a volumes constants (#59)",
       methode = c("premium_vc", "reserve1_vc"),
       motif = paste0(N_, " lignes d'usp_tests\\(\\) sont restitu\u00e9es .{1,3}non applicable"),
       champs = "non applicable volumes constants")
)

# ---------------------------------------------------------------------------
#  Exemptions nominatives des decomptes (issue #75)
# ---------------------------------------------------------------------------

# Formulations "N lignes / N entrees / N tests" du document qui ne
# denombrent pas une grandeur de res$tests, res$controles ou des constantes
# du moteur, et que le script ne doit donc ni verifier ni compter comme
# ecarts. Chaque exemption porte : id ; contexte (expression reguliere, perl,
# insensible a la casse, cherchee dans le texte normalise entier ; une espace
# vaut n'importe quel blanc ; elle doit contenir la formulation, qu'elle
# exempte si celle-ci commence dans son etendue) ; motif (raison ecrite). Une
# exemption qui n'exempte plus aucune formulation est PERIMEE et comptee
# comme ecart.
MOTIF_ANAPHORE <- "reprise anaphorique de tests nommes dans le texte qui precede, pas un decompte de la table"
MOTIF_PROVENANCE <- paste("provenance d'entrees (graphe d'appels du moteur) : la fonction qui produit",
                          "une ligne n'est pas restituee dans res$tests ; risque residuel : si le code",
                          "change (la fonction alimente plus ou moins d'entrees) et que le document ne",
                          "change pas, le decompte devenu faux n'est pas detecte")
EXEMPTES_DECOMPTES <- list(
  list(id = "pente et Fisher (cas sans p Monte-Carlo possible)",
       contexte = "Ces deux tests conservent donc leur loi", motif = MOTIF_ANAPHORE),
  list(id = "tableau 2 : deux lignes du tableau du document",
       contexte = "document\u00e9s sur deux lignes distinctes",
       motif = "lignes du tableau du document, pas de la table des tests"),
  list(id = "TOST : deux tests unilateraux", contexte = "D\u00e9composition en deux tests unilat\u00e9raux",
       motif = "construction statistique de la procedure TOST (intersection-union), pas un decompte de la table"),
  list(id = "TOST : formulation ecartee", contexte = "comme deux tests s\u00e9par\u00e9s sans",
       motif = "formulation hypothetique ecartee par le document, pas un decompte de la table"),
  list(id = "constante et pente : deux tests complementaires",
       contexte = "Les deux tests sont compl\u00e9mentaires", motif = MOTIF_ANAPHORE),
  list(id = "Merz-Wuthrich : entrees en gras du schema",
       contexte = "Les six entr\u00e9es en gras ci-dessus",
       motif = "element de mise en forme du document (entrees en gras de la liste qui precede)"),
  list(id = "Merz-Wuthrich : complement aux deux tests precedents",
       contexte = "Compl\u00e9ment aux deux tests pr\u00e9c\u00e9dents", motif = MOTIF_ANAPHORE),
  list(id = "calibration Merz-Wuthrich : trois tests s'ecartent",
       contexte = "Trois tests s'en \u00e9cartent fortement",
       motif = "constat de simulation de la calibration des lois de reference, pas un decompte de la table"),
  list(id = "test_lm_complet() (index des fonctions)", contexte = "quatre entr\u00e9es issues d'un seul appel",
       motif = MOTIF_PROVENANCE),
  list(id = "test_lm_complet() (graphe H1)", contexte = "alimente quatre entr\u00e9es de la table des tests",
       motif = MOTIF_PROVENANCE),
  list(id = ".shapiro_sur() (graphe H3-H4)", contexte = "shapiro_sur\\(\\) alimente deux entr\u00e9es",
       motif = MOTIF_PROVENANCE),
  list(id = ".fisher_combine() (graphe Merz-Wuthrich)", contexte = "dessert 4 tests M1",
       motif = MOTIF_PROVENANCE),
  list(id = "noeud M3 correlations (graphe Merz-Wuthrich)", contexte = "\\(q4\\) M3 \\(2 entr\u00e9es\\)",
       motif = paste(MOTIF_PROVENANCE, "(sous-ensemble de la famille M3 rattache a un noeud du schema)")),
  list(id = "test_lm_complet() (tableau des portees)", contexte = "test_lm_complet\\(\\) \\(4 entr\u00e9es\\)",
       motif = MOTIF_PROVENANCE),
  list(id = ".shapiro_sur() (tableau des portees)", contexte = "shapiro_sur\\(\\) \\(2 entr\u00e9es\\)",
       motif = MOTIF_PROVENANCE),
  list(id = "stat_dw() ... test_grubbs() (tableau des portees)", contexte = "test_grubbs\\(\\) \\(2 entr\u00e9es chacune",
       motif = MOTIF_PROVENANCE)
)

# Grandeurs structurelles de la table des tests d'un resultat du moteur
# (et, si fourni, de res$controles). Un champ absent d'une ligne vaut NA :
# la ligne n'est alors comptee dans aucune grandeur qui porte sur ce champ.
grandeurs_moteur <- function(tests, controles = NULL) {
  champ <- function(n, l = tests) vapply(l, function(t) { v <- t[[n]]; if (is.null(v) || !length(v)) NA_character_ else as.character(v)[1] },
                                         character(1))
  nat <- champ("nature_p"); typ <- champ("type"); fam <- substr(champ("famille"), 1L, 2L)
  base <- champ("base"); det <- champ("detail"); nom <- champ("test")
  pmc <- vapply(tests, function(t) !is.null(t$p_mc) && length(t$p_mc) && !is.na(t$p_mc), logical(1))
  pex <- vapply(tests, function(t) !is.null(t$p_exacte) && length(t$p_exacte) && is.finite(t$p_exacte[1]), logical(1))
  g <- c("lignes (total)" = length(tests),
         "nature exacte" = sum(grepl("^exacte", nat)),
         "nature modele auxiliaire MCO" = sum(grepl("^sous le modele auxiliaire MCO", nat)),
         "nature Monte-Carlo" = sum(grepl("^Monte-Carlo", nat)),
         "nature asymptotique" = sum(grepl("^asymptotique", nat)),
         "sans p-value retenue" = sum(is.na(nat)),
         "exacte avec p_mc" = sum(grepl("^exacte", nat) & pmc),
         "type test" = sum(typ %in% "test"),
         "type diagnostic" = sum(typ %in% "diagnostic"),
         "type procedure de decision" = sum(typ %in% "procedure de decision"),
         "type non applicable" = sum(typ %in% "non applicable"),
         # Issue #75 : grandeurs des formulations de l'ancien inventaire.
         # base : "z" (residus standardises), "r" (ratios bruts u_t),
         # "commun" ; variante : "secondaire" pour la forme non retenue d'un
         # test present sous deux formes.
         "base z" = sum(base %in% "z"),
         "base r" = sum(base %in% "r"),
         "p exacte hors base r" = sum(pex & !base %in% "r"),
         "p exacte hors base r retenue" = sum(pex & !base %in% "r" & grepl("^exacte", nat)),
         "variante secondaire" = sum(champ("variante") %in% "secondaire"),
         "lignes du test des suites" = sum(startsWith(nom, "Test des suites") %in% TRUE),
         "base r hors suites" = sum(base %in% "r" & !startsWith(nom, "Test des suites") %in% TRUE),
         "base r hors suites Monte-Carlo" = sum(base %in% "r" & !startsWith(nom, "Test des suites") %in% TRUE &
                                                  grepl("^Monte-Carlo", nat)),
         "grandeur rivee" = sum(startsWith(det, "Grandeur rivee par l'estimation") %in% TRUE),
         "detail sans objet ici" = sum(grepl("CONTROLE SANS OBJET ICI", det, fixed = TRUE)),
         "non applicable volumes constants" =
           sum(startsWith(det, "volumes x_t constants a la tolerance relative") %in% TRUE))
  for (f in unique(fam)) g[paste("famille", f)] <- sum(fam == f)
  for (f in unique(fam)) for (ty in unique(typ[fam %in% f]))
    g[paste("famille", f, "type", ty)] <- sum(fam %in% f & typ %in% ty)
  if (!is.null(controles)) {
    fc <- substr(champ("famille", controles), 1L, 2L)
    g["controles (total)"] <- length(controles)
    for (f in unique(fc)) g[paste("controles famille", f)] <- sum(fc %in% f)
  }
  g
}

# Grandeurs tirees des constantes du moteur (env : environnement ou
# R/engine.R a ete charge) : tailles des catalogues Monte-Carlo et nombre de
# lignes Merz-Wuthrich fondees sur les residus (.MW_LIGNES_RESIDUS).
grandeurs_code <- function(env) {
  c("catalogue USP" = length(env$USP_CATALOGUE_MC),
    "catalogue MW" = length(env$MW_CATALOGUE_MC),
    "lignes MW sur residus" = sum(lengths(env$.MW_LIGNES_RESIDUS)))
}

# Applique le registre au texte (vecteur de lignes LaTeX). grandeurs : liste
# nommee par methode de sorties de grandeurs_moteur() (et "code" :
# grandeurs_code()). Renvoie un data.frame (assertion, ligne, ligne_fin,
# pos, pos_fin, pos_cap, grandeur, annonce, mesure, statut), pos et pos_fin
# etant les positions de debut et de fin de la phrase dans le texte
# normalise (lignes jointes par "\n"), pos_cap la position de debut du
# groupe capturant (nombre annonce) de la grandeur ; une assertion
# introuvable donne une ligne de statut "INTROUVABLE". Une grandeur absente des mesures vaut 0 (famille ou type
# non produit).
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
                                            pos = NA_integer_, pos_fin = NA_integer_, pos_cap = NA_integer_,
                                            grandeur = "(phrase)",
                                            annonce = NA_real_, mesure = NA_real_, statut = "INTROUVABLE",
                                            stringsAsFactors = FALSE)
      next
    }
    pos <- m[[1]][1]; pos_fin <- pos + attr(m[[1]], "match.length")[1] - 1L
    ligne <- findInterval(pos, debuts)
    ligne_fin <- findInterval(pos_fin, debuts)
    ann <- unname(vapply(cap[-1L], nombre_fr, numeric(1)))
    pos_cap <- as.integer(m[[1]][-1L])
    if (length(pos_cap) != length(a$champs))
      stop("registre DECOMPTES, \"", a$id, "\" : ", length(pos_cap), " groupe(s) capturant(s) pour ",
           length(a$champs), " champ(s)", call. = FALSE)
    for (meth in a$methode) {
      g <- grandeurs[[meth]]
      mes <- unname(ifelse(a$champs %in% names(g), g[a$champs], 0))
      out[[length(out) + 1L]] <- data.frame(assertion = a$id, ligne = ligne, ligne_fin = ligne_fin,
                                            pos = pos, pos_fin = pos_fin, pos_cap = pos_cap,
                                            grandeur = if (length(a$methode) > 1L) paste0(meth, " : ", a$champs) else a$champs,
                                            annonce = ann, mesure = mes,
                                            statut = ifelse(!is.na(ann) & ann == mes, "ok", "ECART"),
                                            stringsAsFactors = FALSE)
    }
  }
  do.call(rbind, out)
}

# Inventaire de toutes les formulations "N lignes" / "N entrees" / "N tests"
# (nombre en chiffres, y compris en mode mathematique, ou en lettres
# jusqu'a cent, au pluriel ; un article singulier, "un test", n'est pas un
# decompte), avec au plus deux qualificatifs intercales (QUALIFICATIFS :
# "cinq autres lignes"), une par occurrence, cherchees dans le texte
# normalise entier : une formulation coupee par un retour a la ligne est
# trouvee. pos est la position du nombre. Renvoie un data.frame (ligne,
# ligne_fin, pos, formulation, extrait), extrait etant la ligne de debut
# normalisee.
RX_FORMULATION <- paste0("(?i)(?<![A-Za-z\u00c0-\u00ff-])", MOT_NOMBRE, "\\s+(?:(?:",
                         paste(QUALIFICATIFS, collapse = "|"), ")\\s+){0,2}(lignes|entr\u00e9es|tests)\\b")
inventaire_decomptes <- function(lignes) {
  norm <- normaliser_ligne(lignes)
  texte <- paste(norm, collapse = "\n")
  debuts <- cumsum(c(1L, nchar(norm) + 1L))[seq_along(norm)]
  m <- gregexpr(RX_FORMULATION, texte, perl = TRUE)[[1]]
  if (m[1L] == -1L)
    return(data.frame(ligne = integer(0), ligne_fin = integer(0), pos = integer(0), formulation = character(0),
                      extrait = character(0), stringsAsFactors = FALSE))
  fin <- m + attr(m, "match.length") - 1L
  l1 <- findInterval(m, debuts)
  data.frame(ligne = l1, ligne_fin = findInterval(fin, debuts), pos = as.integer(m),
             formulation = gsub("\\s+", " ", substring(texte, m, fin)),
             extrait = trimws(substr(norm[l1], 1L, 110L)), stringsAsFactors = FALSE)
}

# Classe chaque formulation de l'inventaire (issue #75) : "verifiee" si
# son nombre est a la position d'un groupe capturant d'une phrase trouvee du
# registre DECOMPTES (v : sortie de verifier_decomptes(), colonne pos_cap) --
# un nombre non capture situe dans l'etendue d'une phrase du registre n'est
# pas verifie (audit de #75, C3) --, sinon "exemptee" si elle commence
# dans l'etendue d'une occurrence du contexte d'une exemption, sinon
# "NON CLASSEE" (ecart). Renvoie une liste :
#   formulations  inventaire complete des colonnes statut et par (id de la
#                 phrase du registre ou de l'exemption) ;
#   perimees      data.frame (id, contexte) des exemptions qui n'exemptent
#                 aucune formulation (ecarts).
classer_formulations <- function(lignes, v, exemptions = EXEMPTES_DECOMPTES) {
  inv <- inventaire_decomptes(lignes)
  texte <- paste(normaliser_ligne(lignes), collapse = "\n")
  statut <- rep("NON CLASSEE", nrow(inv)); par <- rep(NA_character_, nrow(inv))
  vt <- v[!is.na(v$pos_cap), , drop = FALSE]
  vt <- vt[!duplicated(vt[c("assertion", "pos_cap")]), , drop = FALSE]
  for (i in seq_len(nrow(vt))) {
    k <- which(statut == "NON CLASSEE" & inv$pos == vt$pos_cap[i])
    statut[k] <- "verifiee"; par[k] <- vt$assertion[i]
  }
  utilisee <- logical(length(exemptions))
  for (j in seq_along(exemptions)) {
    e <- exemptions[[j]]
    m <- gregexpr(gsub(" ", "\\s+", e$contexte, fixed = TRUE), texte, perl = TRUE, ignore.case = TRUE)[[1]]
    if (m[1L] == -1L) next
    for (d in seq_along(m)) {
      k <- which(statut == "NON CLASSEE" & inv$pos >= m[d] & inv$pos <= m[d] + attr(m, "match.length")[d] - 1L)
      if (length(k)) { statut[k] <- "exemptee"; par[k] <- e$id; utilisee[j] <- TRUE }
    }
  }
  inv$statut <- statut; inv$par <- par
  list(formulations = inv,
       perimees = data.frame(id = vapply(exemptions[!utilisee], `[[`, character(1), "id"),
                             contexte = vapply(exemptions[!utilisee], `[[`, character(1), "contexte"),
                             stringsAsFactors = FALSE))
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
# porte \textbf{Cle MC} (e accent aigu, ecrit par l'echappement unicode 00E9 dans le code pour ne
# pas dependre de la locale de lecture du script), avec la methode de leur
# section : "MW" sous un
# intertitre \multicolumn qui contient "Merz", "USP" sous tout autre
# intertitre, NA avant le premier. Seules les lignes apres \endlastfoot sont
# lues (les en-tetes repetes du longtable ne portent pas de cle). Une ligne
# du tableau se termine par \\, \\* ou \\[espacement] ; les cellules sont
# separees par les & non echappes. Renvoie NULL si le tableau est
# introuvable, sinon un data.frame (ligne, cle, methode), une ligne par
# \code{} de la derniere cellule (texte sans \code{}, tiret ou "toutes les
# cles ci-dessus", ne produit aucune cle), avec l'attribut "non_terminee" :
# ligne de debut d'une rangee non terminee avant \end{longtable} (NA sinon),
# que l'appelant compte comme ecart.
# LIMITE de conception : seule l'appartenance de la cle au catalogue de sa
# methode est verifiee, pas la correspondance cle <-> test de la ligne. Une
# cle commune aux deux catalogues (DW, Grubbs, BP, Runs) ou une cle du bon
# catalogue portee par la mauvaise ligne n'est pas detectee.
FIN_RANGEE <- "\\\\\\\\\\*?(\\[[^]]*\\])?\\s*$"
cles_mc_index <- function(lignes) {
  lignes <- retirer_commentaires(lignes)
  deb <- grep("\\textbf{Cl\u00e9 MC}", lignes, fixed = TRUE)[1L]
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
    if (!grepl(FIN_RANGEE, l, perl = TRUE)) next
    rangee <- paste(tampon, collapse = "\n"); tampon <- character(0)
    if (grepl("\\multicolumn", rangee, fixed = TRUE)) {
      methode <- if (grepl("Merz", rangee, fixed = TRUE)) "MW" else "USP"
      next
    }
    esp <- gregexpr("(?<!\\\\)&", rangee, perl = TRUE)[[1]]
    if (esp[1L] == -1L) next
    p <- esp[length(esp)]
    cellule <- sub(FIN_RANGEE, "", substring(rangee, p + 1L), perl = TRUE)
    decal <- l0 + lengths(regmatches(substr(rangee, 1L, p), gregexpr("\n", substr(rangee, 1L, p))))
    cod <- extraire_codes(strsplit(cellule, "\n", fixed = TRUE)[[1]])
    if (nrow(cod))
      res <- rbind(res, data.frame(ligne = decal + cod$ligne - 1L, cle = desechapper(cod$brut),
                                   methode = methode, stringsAsFactors = FALSE))
  }
  attr(res, "non_terminee") <- if (length(tampon) && any(nzchar(trimws(tampon)))) l0 else NA_integer_
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
  # Executions supplementaires a volumes constants (issue #59) : leurs
  # grandeurs ne servent qu'aux phrases du registre qui les nomment
  # (premium_vc, reserve1_vc) ; elles n'entrent ni dans le recapitulatif des
  # familles ci-dessous, ni dans la section 3.
  resultats_vc <- with(outils, list(
    premium_vc  = run_engine(xt = rep(100, length(.ln$yt)), yt = .ln$yt, methode = "premium", segment = 1,
                             annexe = "II", B = B, nature_donnees = "brutes"),
    reserve1_vc = run_engine(xt = rep(100, length(.ln$yt)), yt = .ln$yt, methode = "reserve1", segment = 1,
                             annexe = "II", B = B)))
  if (!all(vapply(resultats_vc, function(r) isTRUE(r$ok), logical(1))))
    stop("run_engine() a volumes constants : resultat ok = FALSE", call. = FALSE)
  grandeurs <- c(lapply(resultats, function(r) grandeurs_moteur(r$tests, r$controles)),
                 lapply(resultats_vc, function(r) grandeurs_moteur(r$tests, r$controles)),
                 list(code = grandeurs_code(env)))
  cat(sprintf("\n=== 2. Decomptes (moteur execute sur tests/donnees/, B = %d)\n", B))
  for (m in names(resultats))
    cat(sprintf("  %-9s %d lignes de tests ; familles : %s\n", m, grandeurs[[m]][["lignes (total)"]],
                paste(sprintf("%s=%d", sub("famille ", "", grep("^famille [^ ]+$", names(grandeurs[[m]]), value = TRUE)),
                              grandeurs[[m]][grep("^famille [^ ]+$", names(grandeurs[[m]]))]), collapse = " ")))
  v <- verifier_decomptes(tex, grandeurs)
  cat("  a) Phrases du registre DECOMPTES (verifiees) :\n")
  for (i in seq_len(nrow(v)))
    cat(sprintf("    [%-11s] l.%-5s %-60s %-28s annonce %-4s mesure %s\n", v$statut[i],
                ifelse(is.na(v$ligne[i]), "?", v$ligne[i]), substr(v$assertion[i], 1, 60), v$grandeur[i],
                ifelse(is.na(v$annonce[i]), "-", format(v$annonce[i])),
                ifelse(is.na(v$mesure[i]), "-", format(v$mesure[i]))))
  n_ecarts <- n_ecarts + sum(v$statut != "ok")
  cl <- classer_formulations(tex, v)
  fo <- cl$formulations
  cat(sprintf(paste0("  b) Formulations \"N lignes\" / \"N entrees\" / \"N tests\" du document : %d ",
                     "(verifiees par le registre %d, exemptees %d, NON CLASSEES %d)\n"),
              nrow(fo), sum(fo$statut == "verifiee"), sum(fo$statut == "exemptee"), sum(fo$statut == "NON CLASSEE")))
  ex_f <- fo[fo$statut == "exemptee", , drop = FALSE]
  if (nrow(ex_f)) {
    cat("    Exemptees nommement (EXEMPTES_DECOMPTES, pas des ecarts) :\n")
    motifs <- setNames(vapply(EXEMPTES_DECOMPTES, `[[`, character(1), "motif"),
                       vapply(EXEMPTES_DECOMPTES, `[[`, character(1), "id"))
    for (i in seq_len(nrow(ex_f)))
      cat(sprintf("      l.%-5d %-18s [%s] %s\n", ex_f$ligne[i], ex_f$formulation[i], ex_f$par[i], motifs[[ex_f$par[i]]]))
  }
  nc <- fo[fo$statut == "NON CLASSEE", , drop = FALSE]
  n_ecarts <- n_ecarts + nrow(nc) + nrow(cl$perimees)
  if (nrow(nc)) {
    cat(sprintf("  ECART -- %d formulation(s) ni verifiee(s) par le registre DECOMPTES ni exemptee(s) (EXEMPTES_DECOMPTES) :\n",
                nrow(nc)))
    for (i in seq_len(nrow(nc))) cat(sprintf("    l.%-5d %-18s %s\n", nc$ligne[i], nc$formulation[i], nc$extrait[i]))
  }
  if (nrow(cl$perimees)) {
    cat(sprintf("  ECART -- %d exemption(s) de decompte perimee(s) (aucune formulation ne lui correspond) :\n",
                nrow(cl$perimees)))
    for (i in seq_len(nrow(cl$perimees)))
      cat(sprintf("    %-50s contexte \"%s\"\n", cl$perimees$id[i], cl$perimees$contexte[i]))
  }

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
    cat("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions\n  ECART -- tableau introuvable (en-tete \\textbf{Cl\u00e9 MC} et \\endlastfoot attendus)\n")
  } else {
    e_mc <- verifier_cles_mc(cles, catalogues)
    cat(sprintf("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions : %d cle(s) (USP %d, MW %d)\n",
                nrow(cles), sum(cles$methode %in% "USP"), sum(cles$methode %in% "MW")))
    if (!nrow(cles)) {
      n_ecarts <- n_ecarts + 1L
      cat("  ECART -- tableau trouve mais aucune cle lue (colonne vide ou fins de rangee non reconnues)\n")
    }
    nt <- attr(cles, "non_terminee")
    if (!is.null(nt) && !is.na(nt)) {
      n_ecarts <- n_ecarts + 1L
      cat(sprintf("  ECART -- rangee commencee l.%d non terminee (\\\\, \\\\* ou \\\\[...]) avant \\end{longtable} : ses cles ne sont pas lues\n", nt))
    }
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

  cat(sprintf("\nBILAN : %d ecart(s)%s ; formulations de decompte : %d verifiee(s), %d exemptee(s), %d non classee(s)\n",
              n_ecarts, if (strict) " (mode strict)" else " (mode rapport : code de sortie 0)",
              sum(fo$statut == "verifiee"), sum(fo$statut == "exemptee"), sum(fo$statut == "NON CLASSEE")))
  if (strict && n_ecarts) quit(status = 1)
}
