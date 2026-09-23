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
#       moins une fonction ;
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
#       Voie proposee pour le mode strict de la branche O (non implementee) :
#       toute formulation de l'inventaire doit etre soit couverte par une
#       phrase du registre DECOMPTES, soit exemptee nommement dans une liste
#       EXEMPTES (extrait ancre + motif de l'exemption, par ex. "sous-ensemble
#       d'une famille, schema") ; --strict echoue alors sur toute formulation
#       ni verifiee ni exemptee. Chaque nouveau decompte ecrit par docwriter
#       devrait ainsi etre enregistre (verifie) ou justifie (exempte), et le
#       faux negatif disparait. Etendre au passage l'inventaire aux
#       formulations "N tests" ;
#    3. chaque prefixe de famille produit par le moteur dans res$tests (deux
#       premiers caracteres du champ famille, cle de GROUPES) est declare
#       dans GROUPES de R/display_helpers.R ; les familles rencontrees
#       ailleurs dans le resultat (res$controles : "A. Qualite des donnees")
#       ne passent pas par GROUPES et sont signalees pour information.
#
#  Le moteur est execute sur les jeux de tests/donnees/ avec B petit
#  (defaut 99) : seule la STRUCTURE de la table des tests sert ici (nombre de
#  lignes, familles, types, nature de la p-value retenue). Voir le compte
#  rendu de l'issue #65 pour la mesure de l'independance de ces grandeurs a B.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/concordance_doc_moteur.R              # mode rapport
#      Rscript tests/concordance_doc_moteur.R --strict     # code 1 si ecart
#      Rscript tests/concordance_doc_moteur.R --B 999
#
#  Mode rapport (defaut) : code de sortie 0 meme en cas d'ecart. --strict :
#  code de sortie 1 des qu'il y a un ecart (branche O, issue #65).
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
#  Programme principal
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  strict <- "--strict" %in% args
  B <- 99L
  k <- match("--B", args)
  if (!is.na(k)) {
    if (k == length(args)) stop("--B sans valeur")
    B <- as.integer(args[k + 1L])
    if (is.na(B) || B < 1L) stop("--B : entier positif attendu")
  }
  RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
    stop("R/engine.R introuvable : lancer depuis la racine du depot.")

  env <- new.env(parent = globalenv())
  sys.source(file.path(RACINE, "R", "engine.R"), envir = env)
  sys.source(file.path(RACINE, "R", "display_helpers.R"), envir = env)
  tex <- readLines(file.path(RACINE, "docs", "latex", "doc_tests_usp.tex"), warn = FALSE, encoding = "UTF-8")
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
  statuts <- vapply(noms, statut_fonction, character(1), env = env, paquets = paquets, defs = defs)
  cat(sprintf("=== 1. Fonctions citees par \\code{nom()} : %d citation(s), %d nom(s) distinct(s)\n",
              nrow(cit), length(noms)))
  tab <- table(sub(" \\(.*$", "", statuts))
  for (s in names(tab)) cat(sprintf("  %-26s %d\n", s, tab[[s]]))
  autres <- noms[!statuts %in% c("moteur ou affichage", "INTROUVABLE")]
  if (length(autres)) {
    cat("  Hors moteur et affichage (pour information) :\n")
    for (n in autres) cat(sprintf("    %-32s %s\n", n, statuts[[n]]))
  }
  introuvables <- noms[statuts == "INTROUVABLE"]
  n_ecarts <- n_ecarts + length(introuvables)
  if (length(introuvables)) {
    cat(sprintf("  ECART -- %d nom(s) introuvable(s) :\n", length(introuvables)))
    for (n in introuvables) {
      l <- cit$ligne[cit$nom == n]
      cat(sprintf("    %-32s ligne(s) %s\n", paste0(n, "()"), paste(unique(l), collapse = ", ")))
    }
  }

  # 2. Decomptes
  outils <- new.env(parent = globalenv())
  sys.source(file.path(RACINE, "tests", "outils_tests.R"), envir = outils)
  resultats <- with(outils, list(
    premium  = run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium", segment = 1, annexe = "II", B = B),
    reserve1 = run_engine(xt = .ln$xt, yt = .ln$yt, methode = "reserve1", segment = 1, annexe = "II", B = B),
    reserve2 = run_engine(methode = "reserve2", triangle = .tri, segment = 1, annexe = "II", B = B)))
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

  cat(sprintf("\nBILAN : %d ecart(s)%s ; inventaire non verifie : %d formulation(s) (un decompte faux hors registre DECOMPTES n'est pas detecte)\n",
              n_ecarts, if (strict) " (mode strict)" else " (mode rapport : code de sortie 0)", nrow(inv)))
  if (strict && n_ecarts) quit(status = 1)
}
