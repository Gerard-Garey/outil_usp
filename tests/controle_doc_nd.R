###############################################################################
#  tests/controle_doc_nd.R  --  CONTROLES DE CI SUR LA DOCUMENTATION LATEX
#  (branche ND, lot L0, issue #451)
#
#  Quatre controles sur docs/latex/doc_tests_usp.tex, en AVERTISSEMENT par
#  defaut (code de sortie 0, decompte publie) ; l'option --bloquant rend
#  bloquants (lot L7) les controles (a), (b) et les violations de (c). Le
#  controle (d) ne l'est jamais.
#
#  (a) Motifs de "vie du depot". Le document decrit l'outil, pas le depot :
#      la liste A (14 motifs PCRE, A1 a A14) est interdite ; la liste B
#      (motifs a surveiller) est toujours comptee, jamais bloquante. Les
#      motifs s'appliquent a toutes les lignes du .tex, commentaires %
#      compris. Les exceptions nommees (liste EXCEPTIONS_MOTIFS : id, motifs
#      exemptes, zone, parties, raison) sont appliquees ; une exception qui
#      n'exempte plus rien est signalee PERIMEE.
#        E3 : docs/suivi-documentation/ admis en partie IV seulement ;
#        E7 : les chaines du moteur (R/engine.R) qui portent "issue #N", N dans
#             E7_ISSUES, citees mot pour mot (zones lues dans le moteur, fenetre
#             de trois lignes), transitoire (drapeau E7_TRANSITOIRE, a lever au
#             lot L1 apres retrait des chaines du moteur).
#      Les exceptions E1, E2, E4, E5, E6, E8 et E9 de la grille sont
#      satisfaites par construction des motifs (rien a exempter) ; elles sont
#      couvertes par les cas negatifs de tests/unitaires/test_controle_doc_nd.R.
#
#  (b) Plafond de pages des fiches de la partie III. L'etendue d'une fiche est
#      lue dans docs/latex/doc_tests_usp.aux : page du label fiche:N (debut,
#      pose par l'environnement fiche) et page du label fiche:N-fin (fin de
#      fiche, pose par le meme environnement), etendue = fin - debut + 1. La
#      taille de la source est le nombre de caracteres de \begin{fiche} a
#      \end{fiche} inclus. Regle :
#        violation  : etendue >= 3 pages ET source > 10 500 caracteres ;
#        a verifier : etendue >= 3 pages, source plus courte (une fiche de
#                     1,2 page qui commence en bas de page compte 3 pages) ;
#        conforme   : sinon.
#      Liste EXCEPTIONS_PLAFOND (label, plafond accorde en pages, raison),
#      vide au depart ; une exception dont la fiche est conforme sans elle
#      est PERIMEE. Sans .aux, ou sans labels -fin, le controle le signale et
#      retombe sur les caracteres seuls ("a verifier (sans pages)"), en
#      avertissement : jamais une violation.
#
#  (c) Debordements, lus dans le journal LaTeX docs/latex/doc_tests_usp.log :
#      Overfull \hbox = violation ; Overfull \vbox = avertissement jusqu'a
#      1,5 pt, violation au-dela. Modele : outils/controles/journal.R du depot
#      docu_actu.
#
#  (d) Remplissage des pages, par une passe de mesure a part, jamais bloquante.
#      Modele : outils/controles/remplissage.R du depot docu_actu, avec
#      tests/marques_remplissage.tex (marques adaptees a mdframed). La passe
#      recompose le document (une passe de pdfLaTeX, dans un dossier temporaire,
#      avec les fichiers auxiliaires de la compilation normale) en chargeant les
#      marques avant le document : le depot n'est pas touche. Garde-fou : le
#      texte du PDF de la passe doit etre identique a celui du PDF compile,
#      sinon rien n'est controle. Mesures : blanc de plus de 30 % de la hauteur
#      utile en bas de page hors saut voulu ; encadre court coupe ou morceau de
#      moins de 3 lignes ; titre (bandeau de section compris) suivi de moins de
#      3 lignes, ou fiche dont le titre est separe de la rubrique 1 ; rubrique
#      commencee par une seule ligne en bas de page. Pages en paysage non
#      mesurees. Limites : voir les commentaires de nd_analyser_remplissage().
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/controle_doc_nd.R                  # (a), (b) et (c), code 0
#      Rscript tests/controle_doc_nd.R --bloquant       # code 1 si violation de (a), (b) ou (c)
#      Rscript tests/controle_doc_nd.R --motifs-seuls   # controle (a) seul
#      Rscript tests/controle_doc_nd.R --pages-seules   # controle (b) seul
#      Rscript tests/controle_doc_nd.R --debordements   # controle (c) seul
#      Rscript tests/controle_doc_nd.R --remplissage    # controle (d) seul (pdflatex requis)
#      --max-lignes=N                                   # lignes en cause par motif (defaut 5)
#      --tex=CHEMIN, --aux=CHEMIN, --log=CHEMIN, --pdf=CHEMIN, --moteur=CHEMIN   # autres fichiers (tests)
#      --remp=CHEMIN --pdf-mesure=CHEMIN                # (d) sur les fichiers d'une passe deja
#                                                       # faite (CI : tests/doc_remplissage.tex)
#  Code 2 pour un argument inconnu, plusieurs options de controle a la fois, ou
#  un fichier introuvable.
#
#  R base uniquement (pdflatex, pdftotext et pdfinfo pour le controle (d)). Les
#  motifs sont ecrits en sequences \u (independants de la locale du script) ;
#  sous LC_ALL=C.UTF-8 les lignes en cause s'impriment lisiblement. Sous POSIX,
#  elles s'impriment avec des <U+xxxx>.
###############################################################################

FICHIER_TEX_DEFAUT <- "docs/latex/doc_tests_usp.tex"

# --- Parametres du controle (b) ----------------------------------------------
SEUIL_PAGES_PLAFOND      <- 3L       # etendue (pages) a partir de laquelle on examine
SEUIL_CARACTERES_PLAFOND <- 10500L   # source (caracteres) au-dela de laquelle c'est une violation

# --- Exceptions au plafond de pages (label, plafond accorde en pages, raison) --
# Vide au depart : chaque exception est tranchee au tri de son lot. Le label est
# celui de la fiche (fiche:student-pente) ou son numero automatique (fiche:12).
EXCEPTIONS_PLAFOND <- list()

# --- Drapeau transitoire de l'exception E7 -------------------------------------
# TRUE tant que le .tex cite mot pour mot des chaines du moteur qui portent un
# numero d'issue ; a lever (FALSE) par le commit du lot L1 qui les retire du
# moteur. E7_ISSUES : numeros d'issue des 17 chaines du moteur que traite L1
# (decision du mainteneur du 06/11/2026) ; les zones exemptees sont lues dans
# R/engine.R (nd_zones_moteur()), de sorte que l'exception se resorbe d'elle-meme
# quand L1 retire les chaines.
E7_TRANSITOIRE <- TRUE
E7_ISSUES      <- c(29L, 55L, 114L, 297L, 299L, 302L, 304L, 312L)

# --- Liste A : motifs interdits (bloquants a L7) --------------------------------
.mois <- paste0("(?:janvier|f\u00e9vrier|mars|avril|mai|juin|juillet|ao\u00fbt|",
                "septembre|octobre|novembre|d\u00e9cembre)")
# Une date suivie d'une annee <= 2025 reste admise (dates du reglement : 17 janvier
# 2015, 14 novembre 2024), que l'annee suive par ~ ou par une espace.
.annee_admise <- "(?![~\\s]*(?:19[0-9]{2}|20(?:0[0-9]|1[0-9]|2[0-5]))(?![0-9]))"

MOTIFS_A <- list(
  list(id = "A1", desc = "numero d'issue ou de PR (\\#N)",
       regex = "\\\\#[0-9]+"),
  list(id = "A2", desc = "identifiant de commentaire de PR",
       regex = "\\bcommentaires?[~\\s]+[0-9]{8,}\\b"),
  list(id = "A3", desc = "renvoi a un ADR",
       regex = "\\bADR\\b"),
  list(id = "A4", desc = "fichier ou chemin de processus (E3 : suivi en partie IV)",
       regex = paste0("CONTEXT\\.md|CLAUDE\\.md|AGENTS\\.md|README\\.md|\\.claude/|\\.codex/|",
                      "\\.github/|feuille-de-route|",
                      "docs/\\}?(?:\\\\allowbreak|\\\\newline)?\\s*(?:\\\\code\\{)?(?!tableaux/|suivi-documentation/)[a-z]|",
                      "docs/suivi-documentation/")),
  list(id = "A5", desc = "identifiant de question / decision (Q-...)",
       regex = "\\bQ-[0-9A-Za-z]+(?:-[0-9A-Za-z]+)*-[0-9]+\\b"),
  list(id = "A6", desc = "decision D1-... / D2-...",
       regex = "\\bD[12]-(?:[0-9]+|F[a-z])\\b"),
  list(id = "A7", desc = "decision Mnn (M7 et au-dela)",
       regex = "\\bM(?:[7-9]|[1-9][0-9])\\b"),
  list(id = "A8", desc = "sigle de branche",
       regex = c("\\b(?:E2[a-z]?|F[a-z]|JF)\\b", "\\bbranche~?(?:R[0-9]{2}|ND)\\b")),
  list(id = "A9", desc = "mainteneur, agents, modeles",
       regex = c("\\bmainteneur\\b",
                 "\\\\code\\{(?:actuary|coder|audit|docwriter|architect|regulatory|app-review)\\}",
                 paste0("\\b(?:actuary|docwriter|architect|regulatory|app-review|Claude|Codex|",
                        "ChatGPT|GPT|Fable|Opus|Sonnet)\\b"),
                 "\\bcas d'audit~?[0-9]+")),
  list(id = "A10", desc = "date de la vie du depot (jour-mois sans annee ou annee >= 2026)",
       fenetre2 = 1L,   # le premier motif lit l'annee dans la ligne et la suivante
       regex = c(paste0("\\b[0-9]{1,2}(?:\\\\textsuperscript\\{er\\})?[~\\s]?", .mois, "\\b", .annee_admise),
                 "\\b[0-9]{2}/[0-9]{2}/202[6-9]\\b",
                 "\\b202[6-9]-[0-9]{2}-[0-9]{2}\\b")),
  list(id = "A11", desc = "SHA de commit (7 a 40 hexadecimaux avec lettre et chiffre)",
       regex = "\\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*[0-9])[0-9a-f]{7,40}\\b"),
  list(id = "A12", desc = "l'issue comme objet du depot, sans numero",
       regex = c("\\b(?:cette|chaque|une|la m\u00eame)~?\\s*issue\\b",
                 "\\bl'issue\\b(?!\\s+d[eu]\\b)(?![~\\s]*\\\\#[0-9])",
                 "\\ben issue\\b",
                 "\\bissues\\s+(?:ult\u00e9rieures|ant\u00e9rieures|pr\u00e9c\u00e9dentes|suivantes)\\b",
                 "jusqu'ici")),
  list(id = "A13", desc = "actes de processus (visa, decision du, avis d'...)",
       fenetre2 = 3L,   # "decision du" en fin de ligne : le mot suivant est lu sur la ligne suivante
       regex = c("\\b(?:sp\u00e9cification|avis|r\u00e9serve|visa|validation)\\s+d'\\\\code\\{",
                 "\\bvis\u00e9e?s? par\\b",
                 "\\bd\u00e9cisions? du (?:mainteneur|[0-9])",
                 "\\bvalidation de l'issue")),
  list(id = "A14", desc = "identifiant d'execution de CI (execution NNNNNNNNNN)",
       regex = c("\\bex\u00e9cutions?[~\\s]+(?:n\u00b0[~\\s]*)?[0-9]{8,}\\b",
                 "\\bruns?[~\\s]+[0-9]{8,}\\b", "actions/runs/[0-9]+"))
)

# --- Liste B : motifs a surveiller (avertissement permanent, jamais bloquants) --
MOTIFS_B <- list(
  list(id = "B1",  desc = "auparavant",           regex = "\\bauparavant\\b"),
  list(id = "B2",  desc = "desormais",            regex = "\\bd\u00e9sormais\\b"),
  list(id = "B3",  desc = "dorenavant",           regex = "\\bdor\u00e9navant\\b"),
  list(id = "B4",  desc = "remesure",             regex = "\\bremesur\u00e9"),
  list(id = "B5",  desc = "mesure anterieure",    regex = "\\bmesure ant\u00e9rieure\\b"),
  list(id = "B6",  desc = "avant / apres",        regex = "\\bavant / apr\u00e8s\\b"),
  list(id = "B7",  desc = "version(s) anterieure(s)", regex = "\\bversions? ant\u00e9rieures?\\b"),
  list(id = "B8",  desc = "n'est plus",           regex = "\\bn'est plus\\b"),
  list(id = "B9",  desc = "ne ... plus",          regex = "\\bne .{0,40} plus\\b"),
  list(id = "B10", desc = "non versionne",        regex = "\\bnon versionn\u00e9"),
  list(id = "B11", desc = "duree ... ~s",         regex = "\\bdur\u00e9e\\b.{0,20}~s\\b"),
  list(id = "B12", desc = "commit",               regex = "\\bcommit\\b")
)

# --- Motifs en Unicode ---------------------------------------------------------------
# Avec perl = TRUE, \b est ASCII : "Frequence" (F + e accentue) declencherait A8 et
# "Opuse" A9. Chaque motif des listes A et B est donc prefixe de (*UCP), verifie
# sous R 4.3 (PCRE2) : \b et \w deviennent Unicode.
.prefixer_ucp <- function(motifs) lapply(motifs, function(m) { m$regex <- paste0("(*UCP)", m$regex); m })
MOTIFS_A <- .prefixer_ucp(MOTIFS_A)
MOTIFS_B <- .prefixer_ucp(MOTIFS_B)

# --- Exceptions nommees de la liste A --------------------------------------------
# Une exception = id, motifs exemptes, zone (regex PCRE, une ou plusieurs, de la
# zone dans laquelle une occurrence est exemptee), fenetre (nombre de lignes
# regardees, la ligne de l'occurrence et les precedentes : une zone coupee par un
# retour a la ligne est reconnue), parties (NULL : toutes), raison, actif. Une
# occurrence est exemptee si son motif est dans `motifs`, si sa partie est admise
# et si elle est contenue dans une zone.
#
# E7 : zones = fragments des chaines du moteur qui portent "issue #N" (N dans
# E7_ISSUES), lus dans R/engine.R : jusqu'a quatre mots avant "issue", puis
# "issue \#N" ; les espaces tolerent "~" et le retour a la ligne.
nd_zones_moteur <- function(moteur, issues = E7_ISSUES) {
  if (is.null(moteur) || !file.exists(moteur)) return(character(0))
  l <- readLines(moteur, warn = FALSE, encoding = "UTF-8")
  l <- l[!grepl("^\\s*#", l)]
  rx <- sprintf("issue #(?:%s)\\b", paste(issues, collapse = "|"))
  zones <- character(0)
  for (ligne in l[grepl(rx, l, perl = TRUE)]) {
    g <- gregexpr(rx, ligne, perl = TRUE)[[1L]]
    lg <- attr(g, "match.length")
    for (j in seq_along(g)) {
      avant <- substr(ligne, 1L, g[j] - 1L)
      avant <- sub("^.*[^\\\\]\"", "", avant)   # dans la chaine litterale : apres le dernier guillemet non echappe
      jetons <- strsplit(trimws(paste0(avant, "issue")), "[[:space:]]+")[[1L]]
      jetons <- c(tail(jetons[nzchar(jetons)], 5L), paste0("\\#", sub("^issue #", "", substr(ligne, g[j], g[j] + lg[j] - 1L))))
      # Formats sprintf du moteur (%s, %d) : jokers (le .tex cite une valeur a leur place).
      jetons <- gsub("%d", "\001D", gsub("%s", "\001S", jetons, fixed = TRUE), fixed = TRUE)
      jetons <- gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", jetons)
      jetons <- gsub("\001D", "[0-9]+", gsub("\001S", "\\S+", jetons, fixed = TRUE), fixed = TRUE)
      zones <- c(zones, paste(jetons, collapse = "[~\\s]+"))
    }
  }
  unique(zones)
}

exceptions_motifs_defaut <- function(e7_actif = E7_TRANSITOIRE, e7_issues = E7_ISSUES, moteur = NULL) {
  list(
    list(id = "E3", motifs = "A4", zone = "docs/suivi-documentation/", fenetre = 1L,
         parties = "Partie IV", actif = TRUE, permanente = TRUE,
         raison = "regle permanente : dossier de suivi cite comme piece de tracabilite, en partie IV seulement"),
    list(id = "E7", motifs = "A1", zone = nd_zones_moteur(moteur, e7_issues), fenetre = 3L,
         parties = NULL, actif = isTRUE(e7_actif),
         raison = paste("TRANSITOIRE (a lever au lot L1) : chaines du moteur citees mot pour mot",
                        "(R/engine.R), retirees du moteur par L1"))
  )
}
EXCEPTIONS_MOTIFS <- exceptions_motifs_defaut()

PARTIES_DOC <- c("Preambule", "Partie I", "Partie II", "Partie III", "Partie IV", "Annexe")

# --- Lecture ------------------------------------------------------------------------
nd_lire_lignes <- function(chemin) {
  l <- readLines(chemin, warn = FALSE, encoding = "UTF-8")
  Encoding(l) <- "UTF-8"
  l
}

# Partie de chaque ligne : celle du dernier \partie{...} rencontre ; "Preambule"
# avant le premier.
nd_parties <- function(lignes) {
  m <- regmatches(lignes, regexec("^\\\\partie\\{(Partie [IV]+|Annexe)\\}", lignes))
  titre <- vapply(m, function(x) if (length(x)) x[2L] else NA_character_, character(1))
  p <- rep(NA_character_, length(lignes))
  p[!is.na(titre)] <- titre[!is.na(titre)]
  # report vers l'aval
  if (length(p)) {
    courant <- "Preambule"
    for (i in seq_along(p)) { if (is.na(p[i])) p[i] <- courant else courant <- p[i] }
  }
  p
}

# --- (a) Motifs -------------------------------------------------------------------------
# Occurrences de `motifs` dans `lignes` : data.frame (ligne, partie, motif, debut,
# fin, texte). Une occurrence contenue dans une autre du meme motif sur la meme
# ligne n'est pas recomptee (ex. \code{actuary} et le mot actuary).
nd_chercher <- function(lignes, parties, motifs) {
  res <- list()
  for (m in motifs) {
    pm <- list()
    for (r in seq_along(m$regex)) {
      rx <- m$regex[r]
      # Motif a fenetre de deux lignes : lu sur la ligne suivie de la suivante ; seules
      # les occurrences qui commencent dans la ligne comptent.
      texte <- if (r %in% m$fenetre2) paste(lignes, c(lignes[-1L], "")) else lignes
      g <- gregexpr(rx, texte, perl = TRUE)
      for (i in which(vapply(g, function(x) x[1L] > 0L, logical(1)))) {
        deb <- as.integer(g[[i]])
        lon <- attr(g[[i]], "match.length")
        k <- lon > 0L & deb <= nchar(lignes[i])
        if (any(k)) pm[[length(pm) + 1L]] <- data.frame(
          ligne = i, debut = deb[k], fin = pmin(deb[k] + lon[k] - 1L, nchar(lignes[i])),
          texte = substring(texte[i], deb[k], pmin(deb[k] + lon[k] - 1L, nchar(lignes[i]))),
          stringsAsFactors = FALSE)
      }
    }
    if (!length(pm)) next
    d <- do.call(rbind, pm)
    # Recouvrement : on garde les occurrences non contenues dans une autre.
    d <- d[order(d$ligne, d$debut, -d$fin), , drop = FALSE]
    garde <- rep(TRUE, nrow(d))
    for (i in seq_len(nrow(d))) {
      j <- i - 1L
      while (j >= 1L && d$ligne[j] == d$ligne[i]) {
        if (garde[j] && d$debut[j] <= d$debut[i] && d$fin[j] >= d$fin[i]) { garde[i] <- FALSE; break }
        j <- j - 1L
      }
    }
    d <- d[garde, , drop = FALSE]
    d$motif <- m$id
    d$partie <- parties[d$ligne]
    res[[length(res) + 1L]] <- d[, c("ligne", "partie", "motif", "debut", "fin", "texte")]
  }
  if (!length(res)) return(data.frame(ligne = integer(0), partie = character(0), motif = character(0),
                                      debut = integer(0), fin = integer(0), texte = character(0),
                                      stringsAsFactors = FALSE))
  d <- do.call(rbind, res)
  d <- d[order(d$ligne, d$debut), , drop = FALSE]
  rownames(d) <- NULL
  d
}

# Applique les exceptions. Renvoie list(occ = occurrences non exemptees,
# exemptees = occurrences exemptees (colonne exception), bilan = data.frame par
# exception : id, statut ("appliquee", "PERIMEE", "levee", "en attente" pour une regle
# permanente qui n'exempte encore rien), n, raison).
nd_appliquer_exceptions <- function(occ, lignes, exceptions) {
  occ$exception <- rep(NA_character_, nrow(occ))
  bilan <- data.frame(id = character(0), statut = character(0), n = integer(0),
                      raison = character(0), stringsAsFactors = FALSE)
  for (e in exceptions) {
    n <- 0L
    if (isTRUE(e$actif)) {
      cand <- which(is.na(occ$exception) & occ$motif %in% e$motifs &
                    (is.null(e$parties) | occ$partie %in% e$parties))
      fen <- if (is.null(e$fenetre)) 1L else e$fenetre
      for (k in cand) {
        i <- occ$ligne[k]
        debut_fen <- max(1L, i - fen + 1L)
        texte <- paste(lignes[debut_fen:i], collapse = " ")
        decalage <- nchar(texte) - nchar(lignes[i])
        for (zone in e$zone) {
          z <- gregexpr(zone, texte, perl = TRUE)[[1L]]
          if (z[1L] > 0L) {
            zd <- as.integer(z); zf <- zd + attr(z, "match.length") - 1L
            if (any(zd <= occ$debut[k] + decalage & zf >= occ$fin[k] + decalage)) {
              occ$exception[k] <- e$id; n <- n + 1L; break
            }
          }
        }
      }
    }
    statut <- if (!isTRUE(e$actif)) "levee" else if (n == 0L) {
      if (isTRUE(e$permanente)) "en attente" else "PERIMEE"
    } else "appliquee"
    bilan[nrow(bilan) + 1L, ] <- list(e$id, statut, n, e$raison)
  }
  list(occ = occ[is.na(occ$exception), , drop = FALSE],
       exemptees = occ[!is.na(occ$exception), , drop = FALSE], bilan = bilan)
}

# Controle (a) complet : listes A et B sur `lignes`.
nd_controle_motifs <- function(lignes, exceptions = EXCEPTIONS_MOTIFS) {
  parties <- nd_parties(lignes)
  a <- nd_appliquer_exceptions(nd_chercher(lignes, parties, MOTIFS_A), lignes, exceptions)
  b <- nd_chercher(lignes, parties, MOTIFS_B)
  list(a = a$occ, exemptees = a$exemptees, exceptions = a$bilan, b = b,
       parties = parties, lignes = lignes)
}

# Identifiants des motifs de la liste A touches par une chaine isolee (tests).
nd_motifs_de <- function(texte, exceptions = list(), partie_unique = NULL) {
  lignes <- as.character(texte)
  Encoding(lignes) <- "UTF-8"
  parties <- if (is.null(partie_unique)) nd_parties(lignes) else rep(partie_unique, length(lignes))
  r <- nd_appliquer_exceptions(nd_chercher(lignes, parties, MOTIFS_A), lignes, exceptions)
  unique(r$occ$motif)
}

# Table motif x partie (occurrences) avec lignes distinctes.
nd_table_motifs <- function(occ, motifs) {
  ids <- vapply(motifs, function(m) m$id, character(1))
  t <- matrix(0L, nrow = length(ids), ncol = length(PARTIES_DOC),
              dimnames = list(ids, PARTIES_DOC))
  for (i in seq_len(nrow(occ))) t[occ$motif[i], occ$partie[i]] <- t[occ$motif[i], occ$partie[i]] + 1L
  lignes_distinctes <- vapply(ids, function(id) length(unique(occ$ligne[occ$motif == id])), integer(1))
  data.frame(motif = ids, occurrences = rowSums(t), lignes = lignes_distinctes,
             as.data.frame(t, check.names = FALSE), check.names = FALSE, row.names = NULL)
}

# --- (b) Plafond de pages ------------------------------------------------------------------
# Fiches du .tex : une ligne par \begin{fiche}...\end{fiche} (non commente). `id`
# est le rang de la fiche (valeur du compteur ficheid, donc du label fiche:N).
# label : premier \label{fiche:...} ou \label{mw:...} du corps (les fiches de la
# methode Merz-Wuthrich portent mw:). caracteres : nombre de caracteres (pas
# d'octets) de \begin{fiche} a \end{fiche} inclus, retours a la ligne compris.
nd_fiches <- function(lignes, parties = nd_parties(lignes)) {
  deb <- grep("^\\\\begin\\{fiche\\}", lignes)
  fin <- grep("^\\\\end\\{fiche\\}", lignes)
  if (length(deb) != length(fin))
    stop(sprintf("%d \\begin{fiche} pour %d \\end{fiche} : le .tex est mal forme.", length(deb), length(fin)))
  if (any(fin <= deb) || (length(deb) > 1L && any(deb[-1L] <= fin[-length(fin)])))
    stop("fiches imbriquees ou mal appariees.")
  titre <- sub("\\}[[:space:]]*$", "", sub("^\\\\begin\\{fiche\\}\\{", "", lignes[deb]))
  label <- vapply(seq_along(deb), function(k) {
    corps <- lignes[deb[k]:fin[k]]
    m <- regmatches(corps, regexec("\\\\label\\{((?:fiche|mw):[^}]*)\\}", corps, perl = TRUE))
    m <- Filter(length, m)
    if (length(m)) m[[1L]][2L] else NA_character_
  }, character(1))
  car <- vapply(seq_along(deb), function(k) {
    corps <- lignes[deb[k]:fin[k]]
    as.integer(sum(nchar(corps, type = "chars") + 1L))
  }, integer(1))
  data.frame(id = seq_along(deb), titre = titre, label = label, ligne = deb, ligne_fin = fin,
             partie = parties[deb], caracteres = car, stringsAsFactors = FALSE)
}

# Pages des labels fiche:N et fiche:N-fin lues dans le .aux : data.frame (label,
# page), ou NULL si le fichier n'existe pas. Format \newlabel{fiche:3}{{4.2}{219}...}.
nd_lire_aux <- function(chemin) {
  if (is.null(chemin) || !file.exists(chemin)) return(NULL)
  l <- readLines(chemin, warn = FALSE, encoding = "UTF-8")
  l <- l[grepl("^\\\\newlabel\\{fiche:", l)]
  m <- regmatches(l, regexec("^\\\\newlabel\\{(fiche:[^}]*)\\}\\{\\{[^}]*\\}\\{([^}]*)\\}", l))
  m <- Filter(length, m)
  if (!length(m)) return(data.frame(label = character(0), page = integer(0), stringsAsFactors = FALSE))
  data.frame(label = vapply(m, `[`, character(1), 2L),
             page = suppressWarnings(as.integer(vapply(m, `[`, character(1), 3L))),
             stringsAsFactors = FALSE)
}

# Verdict d'une fiche. `plafond_accorde` : plafond d'une exception (pages), NA sinon.
nd_verdict_fiche <- function(etendue, caracteres, plafond_accorde = NA_integer_,
                             seuil_pages = SEUIL_PAGES_PLAFOND,
                             seuil_caracteres = SEUIL_CARACTERES_PLAFOND) {
  if (is.na(etendue))
    return(if (caracteres > seuil_caracteres) "a verifier (sans pages)" else "conforme (sans pages)")
  if (!is.na(plafond_accorde) && etendue <= plafond_accorde) return("conforme (exception)")
  if (etendue >= seuil_pages) {
    if (caracteres > seuil_caracteres) "violation" else "a verifier"
  } else "conforme"
}

# Controle (b) : fiches de la partie III, avec etendue et verdict. `aux` : sortie
# de nd_lire_aux() ou NULL. Renvoie list(fiches, exceptions, avis) ; `avis` :
# messages sur l'absence de .aux ou de labels -fin.
nd_controle_pages <- function(lignes, aux, exceptions = EXCEPTIONS_PLAFOND) {
  f <- nd_fiches(lignes)
  f <- f[f$partie == "Partie III", , drop = FALSE]
  avis <- character(0)
  if (is.null(aux)) {
    avis <- "aucun fichier .aux : controle (b) sur les caracteres seuls (avertissement)."
    aux <- data.frame(label = character(0), page = integer(0), stringsAsFactors = FALSE)
  } else if (!any(grepl("-fin$", aux$label))) {
    avis <- "aucun label fiche:N-fin dans le .aux : controle (b) sur les caracteres seuls (avertissement)."
  }
  if (any(is.na(aux$page)))
    avis <- c(avis, sprintf("%d label(s) du .aux ont une page non numerique (chiffres romains ?) : etendue non calculee pour ces fiches.",
                            sum(is.na(aux$page))))
  pg <- function(lab) aux$page[match(lab, aux$label)]
  f$debut <- pg(paste0("fiche:", f$id))
  f$fin <- pg(paste0("fiche:", f$id, "-fin"))
  f$etendue <- ifelse(is.na(f$debut) | is.na(f$fin), NA_integer_, f$fin - f$debut + 1L)
  f$exception <- NA_character_
  f$plafond_accorde <- NA_integer_
  bilan <- data.frame(label = character(0), pages = integer(0), statut = character(0),
                      raison = character(0), stringsAsFactors = FALSE)
  for (e in exceptions) {
    k <- which(f$label %in% e$label | paste0("fiche:", f$id) %in% e$label)
    if (length(k)) { f$exception[k] <- e$label; f$plafond_accorde[k] <- as.integer(e$pages) }
    sans <- if (length(k)) nd_verdict_fiche(f$etendue[k[1L]], f$caracteres[k[1L]]) else NA_character_
    statut <- if (!length(k)) "PERIMEE (fiche introuvable en partie III)" else
              if (identical(sans, "conforme")) "PERIMEE (conforme sans exception)" else "appliquee"
    bilan[nrow(bilan) + 1L, ] <- list(e$label, as.integer(e$pages), statut, e$raison)
  }
  f$verdict <- vapply(seq_len(nrow(f)), function(i)
    nd_verdict_fiche(f$etendue[i], f$caracteres[i], f$plafond_accorde[i]), character(1))
  list(fiches = f, exceptions = bilan, avis = avis)
}

# --- Sortie -------------------------------------------------------------------------------
nd_imprimer_motifs <- function(r, max_lignes) {
  op <- options(width = 200); on.exit(options(op), add = TRUE)
  cat("== (a) Motifs de vie du depot ==\n")
  cat("Liste A (interdits) :\n")
  ta <- nd_table_motifs(r$a, MOTIFS_A)
  print(ta, row.names = FALSE)
  cat(sprintf("TOTAL liste A : %d occurrences sur %d lignes (%d occurrences exemptees).\n",
              nrow(r$a), length(unique(r$a$ligne)), nrow(r$exemptees)))
  cat("\nListe B (a surveiller, jamais bloquante) :\n")
  tb <- nd_table_motifs(r$b, MOTIFS_B)
  print(tb, row.names = FALSE)
  cat(sprintf("TOTAL liste B : %d occurrences sur %d lignes.\n", nrow(r$b), length(unique(r$b$ligne))))
  cat("\nExceptions :\n")
  if (nrow(r$exceptions)) {
    for (i in seq_len(nrow(r$exceptions)))
      cat(sprintf("  %s : %s (%d occurrence(s) exemptee(s)) -- %s\n", r$exceptions$id[i],
                  r$exceptions$statut[i], r$exceptions$n[i], r$exceptions$raison[i]))
  } else cat("  aucune\n")
  n_per <- sum(r$exceptions$statut == "PERIMEE")
  if (n_per) cat(sprintf("AVERTISSEMENT : %d exception(s) PERIMEE(S) (n'exemptent plus rien) a retirer.\n", n_per))
  if (max_lignes > 0L) {
    for (liste in list(list("A", r$a, MOTIFS_A), list("B", r$b, MOTIFS_B))) {
      for (m in liste[[3L]]) {
        o <- liste[[2L]][liste[[2L]]$motif == m$id, , drop = FALSE]
        if (!nrow(o)) next
        cat(sprintf("\n-- %s (%s) : %d occurrence(s), %d ligne(s) ; %d premiere(s) :\n", m$id, m$desc,
                    nrow(o), length(unique(o$ligne)), min(max_lignes, nrow(o))))
        for (i in seq_len(min(max_lignes, nrow(o)))) {
          txt <- r$lignes[o$ligne[i]]
          if (nchar(txt) > 160L) txt <- paste0(substr(txt, 1L, 157L), "...")
          cat(sprintf("  l.%d [%s] %s | %s\n", o$ligne[i], o$partie[i], o$texte[i], txt))
        }
      }
    }
  }
  invisible(nrow(r$a))
}

nd_imprimer_pages <- function(r) {
  op <- options(width = 200); on.exit(options(op), add = TRUE)
  cat("\n== (b) Plafond de pages des fiches de la partie III ==\n")
  for (a in r$avis) cat("AVERTISSEMENT :", a, "\n")
  f <- r$fiches
  cat(sprintf("Regle : violation si etendue >= %d pages ET source > %d caracteres ; a verifier si etendue >= %d pages, source plus courte.\n",
              SEUIL_PAGES_PLAFOND, SEUIL_CARACTERES_PLAFOND, SEUIL_PAGES_PLAFOND))
  if (nrow(f)) {
    t <- data.frame(id = f$id, fiche = ifelse(is.na(f$label), substr(f$titre, 1L, 40L), f$label),
                    debut = f$debut, fin = f$fin, pages = f$etendue,
                    caracteres = f$caracteres, verdict = f$verdict, stringsAsFactors = FALSE)
    print(t, row.names = FALSE)
  } else cat("Aucune fiche en partie III.\n")
  cat("\nExceptions au plafond :\n")
  if (nrow(r$exceptions)) {
    for (i in seq_len(nrow(r$exceptions)))
      cat(sprintf("  %s : %s (plafond accorde %d pages) -- %s\n", r$exceptions$label[i],
                  r$exceptions$statut[i], r$exceptions$pages[i], r$exceptions$raison[i]))
  } else cat("  aucune\n")
  nv <- sum(f$verdict == "violation"); nav <- sum(grepl("^a verifier", f$verdict))
  cat(sprintf("TOTAL (b) : %d fiche(s) en partie III, %d violation(s), %d a verifier, %d conforme(s).\n",
              nrow(f), nv, nav, sum(grepl("^conforme", f$verdict))))
  invisible(nv)
}

# --- (c) Debordements (journal LaTeX) -------------------------------------------------------
# Lecture du journal de la derniere passe (docs/latex/doc_tests_usp.log) :
#   Overfull \hbox : violation (bloquante au lot L7) ;
#   Overfull \vbox : avertissement jusqu'a OVERFULL_VBOX_TOLERE pt, violation au-dela.
# Modele : outils/controles/journal.R du depot docu_actu.
OVERFULL_VBOX_TOLERE <- 1.5

nd_verdict_debordement <- function(type, taille, tolere = OVERFULL_VBOX_TOLERE) {
  if (identical(type, "vbox") && !is.na(taille) && taille <= tolere) "avertissement" else "violation"
}

# Debordements d'un journal : data.frame (type, taille, ligne_journal, lieu,
# ligne_tex, verdict), ou NULL si le fichier n'existe pas. `lieu` est la fin de
# la ligne du journal ; ligne_tex, la premiere ligne source citee ("lines A--B"),
# NA si le journal n'en cite pas.
nd_lire_journal <- function(chemin) {
  if (is.null(chemin) || !file.exists(chemin)) return(NULL)
  x <- readLines(chemin, warn = FALSE)
  x <- iconv(x, "UTF-8", "UTF-8", sub = "?")
  x[is.na(x)] <- ""
  k <- grep("^Overfull \\\\[hv]box \\([0-9.]+pt too (wide|high)\\)", x)
  if (!length(k)) return(data.frame(type = character(0), taille = numeric(0), ligne_journal = integer(0),
                                    lieu = character(0), ligne_tex = integer(0), verdict = character(0),
                                    stringsAsFactors = FALSE))
  m <- regmatches(x[k], regexec("^Overfull \\\\([hv])box \\(([0-9.]+)pt too (?:wide|high)\\)(.*)$", x[k], perl = TRUE))
  type <- paste0(vapply(m, `[`, "", 2L), "box")
  taille <- as.numeric(vapply(m, `[`, "", 3L))
  lieu <- trimws(vapply(m, `[`, "", 4L))
  lt <- regmatches(lieu, regexec("lines? ([0-9]+)", lieu))
  ligne_tex <- vapply(lt, function(v) if (length(v) == 2L) as.integer(v[2L]) else NA_integer_, integer(1))
  data.frame(type = type, taille = taille, ligne_journal = k, lieu = lieu, ligne_tex = ligne_tex,
             verdict = vapply(seq_along(k), function(i) nd_verdict_debordement(type[i], taille[i]), character(1)),
             stringsAsFactors = FALSE)
}

nd_controle_debordements <- function(journal) {
  if (is.null(journal)) return(list(deb = NULL, avis = "aucun journal LaTeX (.log) : debordements non lus (avertissement)."))
  list(deb = journal, avis = character(0))
}

nd_imprimer_debordements <- function(r) {
  op <- options(width = 200); on.exit(options(op), add = TRUE)
  cat("\n== (c) Debordements (journal LaTeX) ==\n")
  for (a in r$avis) cat("AVERTISSEMENT :", a, "\n")
  d <- r$deb
  if (is.null(d)) return(invisible(0L))
  cat(sprintf("Regle : Overfull \\hbox = violation ; Overfull \\vbox = avertissement jusqu'a %s pt, violation au-dela.\n",
              OVERFULL_VBOX_TOLERE))
  if (nrow(d)) {
    t <- data.frame(type = d$type, taille_pt = round(d$taille, 2), ligne_tex = d$ligne_tex,
                    ligne_journal = d$ligne_journal, verdict = d$verdict, stringsAsFactors = FALSE)
    print(t, row.names = FALSE)
  }
  nh <- sum(d$type == "hbox"); nv <- sum(d$type == "vbox")
  cat(sprintf("TOTAL (c) : %d \\hbox%s, %d \\vbox%s ; %d violation(s), %d avertissement(s).\n",
              nh, if (nh) sprintf(" (de %.2f a %.2f pt)", min(d$taille[d$type == "hbox"]), max(d$taille[d$type == "hbox"])) else "",
              nv, if (nv) sprintf(" (de %.2f a %.2f pt)", min(d$taille[d$type == "vbox"]), max(d$taille[d$type == "vbox"])) else "",
              sum(d$verdict == "violation"), sum(d$verdict == "avertissement")))
  invisible(sum(d$verdict == "violation"))
}

# --- (d) Remplissage des pages ----------------------------------------------------------------
# Passe de mesure a part (marques_remplissage.tex), jamais bloquante. Mesure :
#   (1) blanc de plus de SEUIL_BLANC_REMPLISSAGE de la hauteur utile en bas de
#       page, hors saut voulu (\newpage, \clearpage, fin du document) ;
#   (2) encadre court coupe (hauteur totale sous SEUIL_ENCADRE_COURT de la hauteur
#       utile), ou dont un morceau compte moins de MORCEAU_MIN_LIGNES lignes ;
#   (3) titre (\section, \subsection, \subsubsection) suivi de moins de
#       TITRE_LIGNES lignes de texte sur sa page ;
#   (4) rubrique de fiche (1. a 7.) dont l'intitule est suivi, sur sa page, de
#       moins de RUBRIQUE_LIGNES lignes (intitule compris).
# Garde-fou : le texte du PDF de la passe de mesure doit etre identique a celui
# de la compilation normale, sinon rien n'est controle.
SEUIL_BLANC_REMPLISSAGE <- 0.30
SEUIL_ENCADRE_COURT     <- 0.50
MORCEAU_MIN_LIGNES      <- 3L
TITRE_LIGNES            <- 3L
RUBRIQUE_LIGNES         <- 2L
BP <- 72 / 72.27          # point TeX -> point PDF
SP <- 65536               # sp par point TeX

# Premiers mots de l'intitule de chaque rubrique de fiche (macros \Cadre ... \Pertinence).
RUBRIQUES_FICHE <- c("1" = "Cadre,", "2" = "Hypoth\u00e8se", "3" = "Statistique", "4" = "Loi",
                     "5" = "p-value.", "6" = "Usage", "7" = "Pertinence")

nd_dim_bp <- function(s) as.numeric(sub("pt$", "", s)) * BP

# Marques du fichier .remp : list(pages, encadres, titres, geometrie).
nd_lire_marques <- function(chemin) {
  x <- readLines(chemin, warn = FALSE, encoding = "UTF-8")
  champs <- function(lettre) strsplit(x[startsWith(x, paste0(lettre, " "))], " ", fixed = TRUE)
  col <- function(l, i) vapply(l, `[`, "", i)
  p <- champs("P")
  pages <- data.frame(page = as.integer(col(p, 2L)), volontaire = col(p, 4L) == "1", stringsAsFactors = FALSE)
  pos <- function(l) data.frame(id = as.integer(col(l, 2L)), page = as.integer(col(l, 3L)),
                                y = as.numeric(col(l, 4L)) / SP * BP, stringsAsFactors = FALSE)
  encadres <- list(debut = pos(champs("B")), fin = pos(champs("F")),
                   inmesurables = as.integer(col(champs("X"), 2L)))
  t <- champs("T")
  titres <- data.frame(niveau = col(t, 2L), page = as.integer(col(t, 3L)),
                       y = as.numeric(col(t, 4L)) / SP * BP,
                       texte = vapply(t, function(v) paste(v[-(1:4)], collapse = " "), ""),
                       stringsAsFactors = FALSE)
  titres <- titres[titres$niveau %in% c("section", "subsection", "subsubsection"), , drop = FALSE]
  g <- champs("G")
  if (!length(g)) return(NULL)
  g <- g[[1L]]
  list(pages = pages, encadres = encadres, titres = titres,
       geometrie = list(feuille = nd_dim_bp(g[2L]), haut = nd_dim_bp(g[3L]),
                        hauteur_utile = nd_dim_bp(g[4L]), interligne = nd_dim_bp(g[5L])))
}

# Mots d'un PDF (pdftotext -bbox) : data.frame (page, x0, y0, x1, y1, mot), y depuis le haut.
nd_lire_mots <- function(pdf) {
  if (length(nd_outils_pdf_manquants())) return(NULL)
  f <- tempfile(fileext = ".html"); on.exit(unlink(f))
  system2("pdftotext", c("-bbox", shQuote(pdf), shQuote(f)), stdout = FALSE, stderr = FALSE)
  x <- readLines(f, warn = FALSE, encoding = "UTF-8")
  page <- cumsum(grepl("^\\s*<page ", x))
  w <- grep("^\\s*<word ", x)
  m <- regmatches(x[w], regexec('xMin="([0-9.]+)" yMin="([0-9.]+)" xMax="([0-9.]+)" yMax="([0-9.]+)">(.*)</word>', x[w]))
  ok <- lengths(m) == 6L
  m <- m[ok]
  mot <- vapply(m, `[`, "", 6L)
  mot <- gsub("&lt;", "<", gsub("&gt;", ">", gsub("&quot;", "\"", gsub("&#39;", "'", gsub("&amp;", "&", mot)))))
  Encoding(mot) <- "UTF-8"
  r <- data.frame(page = page[w][ok], x0 = as.numeric(vapply(m, `[`, "", 2L)), y0 = as.numeric(vapply(m, `[`, "", 3L)),
                  x1 = as.numeric(vapply(m, `[`, "", 4L)), y1 = as.numeric(vapply(m, `[`, "", 5L)),
                  mot = mot, stringsAsFactors = FALSE)
  # Pages en paysage (pdflscape) : pages portrait tournees de 90 degres (pdfinfo, "rot"),
  # dont les coordonnees des mots sont celles de la page tournee.
  inf <- suppressWarnings(system2("pdfinfo", c("-f", "1", "-l", as.character(max(page, 1L)), shQuote(pdf)),
                                  stdout = TRUE, stderr = FALSE))
  rot <- regmatches(inf, regexec("^Page +([0-9]+) rot: +([0-9]+)", inf))
  rot <- Filter(length, rot)
  attr(r, "paysage") <- as.integer(vapply(Filter(function(v) v[3L] %in% c("90", "270"), rot), `[`, "", 2L))
  r
}

nd_texte_pdf <- function(pdf) {
  f <- tempfile(fileext = ".txt"); on.exit(unlink(f))
  system2("pdftotext", c("-layout", shQuote(pdf), shQuote(f)), stdout = FALSE, stderr = FALSE)
  readLines(f, warn = FALSE, encoding = "UTF-8")
}

# Nombre de lignes distinctes parmi des ordonnees y0 de mots : une nouvelle ligne
# commence au-dela de ECART_LIGNES pt (indices et exposants d'une formule restent
# dans la ligne de leur base ; interligne du document : 14,7 pt).
ECART_LIGNES <- 6
nd_nb_lignes <- function(y) if (!length(y)) 0L else 1L + sum(diff(sort(y)) > ECART_LIGNES)

# Debuts de rubriques de fiche lus dans le texte : data.frame (page, y0, rubrique).
nd_rubriques <- function(mots, marge_gauche) {
  if (!nrow(mots)) return(data.frame(page = integer(0), y0 = numeric(0), rubrique = character(0), stringsAsFactors = FALSE))
  n <- nrow(mots)
  suivant <- c(mots$mot[-1L], NA_character_)
  meme <- c(mots$page[-1L] == mots$page[-n] & abs(mots$y0[-1L] - mots$y0[-n]) < 2, FALSE)
  num <- sub("\\.$", "", mots$mot)
  ok <- grepl("^[1-7]\\.$", mots$mot) & meme & mots$x0 < marge_gauche + 5 &
        !is.na(suivant) & suivant == RUBRIQUES_FICHE[num]
  k <- which(ok)
  data.frame(page = mots$page[k], y0 = mots$y0[k], rubrique = num[k], stringsAsFactors = FALSE)
}

# Analyse : constats de remplissage a partir des marques et des mots du PDF de
# mesure. Renvoie une liste (constats = data.frame(type, page, detail), resume,
# blanc, avis). Fonction pure : testable sur des marques construites a la main.
nd_analyser_remplissage <- function(marques, mots) {
  g <- marques$geometrie
  bas <- g$haut + g$hauteur_utile
  nb_pages <- nrow(marques$pages)
  if (nrow(mots) && max(mots$page) > nb_pages)
    return(list(constats = NULL, avis = "nombre de pages du PDF et des marques differents : remplissage non mesure."))
  paysage <- attr(mots, "paysage")
  if (is.null(paysage)) paysage <- integer(0)
  mots$h <- mots$y1 - mots$y0
  centre <- (mots$y0 + mots$y1) / 2
  corps <- mots[centre > g$haut & centre < bas & !(mots$page %in% paysage), , drop = FALSE]
  constats <- list()
  ajouter <- function(type, page, detail) constats[[length(constats) + 1L]] <<- data.frame(type = type, page = as.integer(page),
                                                                                         detail = detail, stringsAsFactors = FALSE)
  pct <- function(x) sprintf("%.0f %%", 100 * x)
  nettoyer <- function(x) substr(gsub("[{}]", "", gsub("\\\\[a-zA-Z@]+ *", "", x)), 1L, 60L)

  # (1) blanc en bas de page (pages en paysage non mesurees)
  blanc <- numeric(nb_pages)
  for (p in setdiff(seq_len(nb_pages), paysage)) {
    c_p <- corps[corps$page == p, , drop = FALSE]
    blanc[p] <- if (nrow(c_p) == 0L) 1 else max(0, (bas - max(c_p$y1)) / g$hauteur_utile)
  }
  pg <- marques$pages[order(marques$pages$page), , drop = FALSE]
  for (p in which(!pg$volontaire & blanc > SEUIL_BLANC_REMPLISSAGE & !(pg$page %in% paysage)))
    ajouter("blanc", p, sprintf("%s de la hauteur utile vide en bas de page, hors saut voulu", pct(blanc[p])))

  # (2) encadres coupes
  enc <- marques$encadres
  ids <- setdiff(intersect(enc$debut$id, enc$fin$id), enc$inmesurables)
  for (i in ids) {
    b <- enc$debut[enc$debut$id == i, ][1L, ]; f <- enc$fin[enc$fin$id == i, ][1L, ]
    if (f$page <= b$page || b$page %in% paysage || f$page %in% paysage) next
    base_b <- g$feuille - b$y; base_f <- g$feuille - f$y   # ordonnees depuis le haut
    n1 <- nd_nb_lignes(corps$y0[corps$page == b$page & corps$y1 > base_b - 2])
    n2 <- nd_nb_lignes(corps$y0[corps$page == f$page & corps$y1 < base_f + 5])
    total <- (bas - base_b) + 0.8 * g$interligne + (base_f - g$haut) + 0.3 * g$interligne +
             (f$page - b$page - 1L) * g$hauteur_utile
    court <- total < SEUIL_ENCADRE_COURT * g$hauteur_utile
    if (court || min(n1, n2) < MORCEAU_MIN_LIGNES)
      ajouter("encadre", b$page, sprintf("encadre n. %d coupe entre les pages %d et %d, morceaux de %d et %d ligne(s) (%s)",
                                         i, b$page, f$page, n1, n2,
                                         if (court) sprintf("court : %s de la hauteur utile en tout", pct(total / g$hauteur_utile))
                                         else sprintf("morceau de moins de %d lignes", MORCEAU_MIN_LIGNES)))
  }

  # (3) titres suivis de moins de TITRE_LIGNES lignes. La marque d'un titre de
  # niveau section (bandeau) est posee apres le saut de page quand le bandeau
  # reste seul en bas de page : ces titres sont juges sur le bandeau lui-meme,
  # reconnu a la hauteur de ses mots (calibree sur les bandeaux de la page de leur marque).
  ti <- marques$titres
  sec <- ti[ti$niveau == "section", , drop = FALSE]
  hb <- NA_real_
  if (nrow(sec) && nrow(mots)) {
    h_ref <- stats::median(mots$h)
    cand <- unlist(lapply(seq_len(nrow(sec)), function(k) {
      td <- g$feuille - sec$y[k]
      w <- mots[mots$page == sec$page[k] & mots$y0 > td - 80 & mots$y0 < td & mots$h > 1.4 * h_ref, , drop = FALSE]
      round(w$h, 1)
    }))
    if (length(cand)) hb <- as.numeric(names(which.max(table(cand))))
  }
  for (k in seq_len(nrow(ti))) {
    if (ti$page[k] %in% paysage || ti$page[k] >= nb_pages) next
    y_titre <- g$feuille - ti$y[k]
    page_t <- ti$page[k]; sous <- NULL
    if (ti$niveau[k] == "section" && !is.na(hb)) {
      ici <- mots[mots$page == page_t & abs(mots$h - hb) < 0.15 & mots$y0 > y_titre - 80 & mots$y0 < y_titre, , drop = FALSE]
      if (!nrow(ici) && page_t > 1L && !(page_t - 1L) %in% paysage) {
        prec <- mots[mots$page == page_t - 1L & abs(mots$h - hb) < 0.15, , drop = FALSE]
        if (nrow(prec)) {
          page_t <- page_t - 1L
          y_b <- max(prec$y1)
          sous <- nd_nb_lignes(corps$y0[corps$page == page_t & corps$y0 > y_b])
        }
      }
    }
    if (is.null(sous)) sous <- nd_nb_lignes(corps$y0[corps$page == page_t & (corps$y0 + corps$y1) / 2 > y_titre])
    if (sous < TITRE_LIGNES)
      ajouter("titre", page_t, sprintf("%d ligne(s) de texte sous le titre (moins de %d) : %s", sous, TITRE_LIGNES, nettoyer(ti$texte[k])))
  }

  # (4) rubriques de fiche : lues dans le texte (une marque posee apres leur
  # intitule deplace un saut de page). Rubrique commencee par moins de
  # RUBRIQUE_LIGNES lignes ; rubrique 1 sur une autre page que le titre de sa fiche.
  ru <- nd_rubriques(corps, if (nrow(corps)) as.numeric(stats::quantile(corps$x0, 0.01)) else 0)
  for (k in seq_len(nrow(ru))) {
    n <- nd_nb_lignes(corps$y0[corps$page == ru$page[k] & corps$y0 > ru$y0[k] - 1])
    if (n < RUBRIQUE_LIGNES && ru$page[k] < nb_pages)
      ajouter("rubrique", ru$page[k], sprintf("rubrique %s commencee par %d ligne(s) en bas de page", ru$rubrique[k], n))
  }
  sub_t <- ti[ti$niveau == "subsection", , drop = FALSE]
  sub_t$td <- g$feuille - sub_t$y
  for (k in which(ru$rubrique == "1")) {
    avant <- which(sub_t$page < ru$page[k] | (sub_t$page == ru$page[k] & sub_t$td < ru$y0[k]))
    if (!length(avant)) next
    t <- sub_t[avant[length(avant)], ]
    if (t$page < ru$page[k])
      ajouter("titre", t$page, sprintf("titre de fiche separe de la rubrique 1 (page %d) : %s", ru$page[k], nettoyer(t$texte)))
  }
  cons <- if (length(constats)) do.call(rbind, constats) else
    data.frame(type = character(0), page = integer(0), detail = character(0), stringsAsFactors = FALSE)
  cons <- unique(cons[order(cons$page, cons$type), , drop = FALSE])
  libres <- blanc[!pg$volontaire & !(pg$page %in% paysage)]
  list(constats = cons, avis = character(0),
       resume = list(pages = nb_pages, paysage = length(paysage), encadres = length(unique(enc$debut$id)),
                     titres = nrow(ti), rubriques = nrow(ru), blanc_max = if (length(libres)) max(libres) else 0))
}

# Passe de pdfLaTeX instrumentee, dans un repertoire temporaire, avec les fichiers
# auxiliaires de la compilation normale (.aux, .toc, .out...) : le depot n'est pas
# touche. Renvoie list(pdf, remp, tmp) ou list(erreur = message).
nd_passe_mesure <- function(tex, marques_tex) {
  if (!nzchar(Sys.which("pdflatex"))) return(list(erreur = "pdflatex absent : passe de mesure impossible."))
  tex <- normalizePath(tex, mustWork = TRUE)
  rep <- dirname(tex); nom <- sub("[.]tex$", "", basename(tex))
  aux <- list.files(rep, pattern = paste0("^", nom, "[.](aux|toc|out|lof|lot)$"), full.names = TRUE)
  if (!any(grepl("[.]aux$", aux))) return(list(erreur = sprintf("%s.aux absent : compiler le document avant la passe de mesure.", nom)))
  tmp <- tempfile("nd_remplissage_"); dir.create(tmp)
  file.copy(aux, tmp)
  env <- c(sprintf("TEXINPUTS=%s:%s:%s:", rep, dirname(normalizePath(marques_tex)), tmp),
           "max_print_line=10000", "error_line=254", "half_error_line=238")
  ancien <- setwd(rep); on.exit(setwd(ancien))
  code <- system2("pdflatex", c("-interaction=nonstopmode", "-halt-on-error", paste0("-jobname=", nom),
                                paste0("-output-directory=", shQuote(tmp)),
                                shQuote(sprintf("\\input{%s}\\input{%s.tex}", sub("[.]tex$", "", basename(marques_tex)), nom))),
                  stdout = FALSE, stderr = FALSE, env = env)
  remp <- file.path(tmp, paste0(nom, ".remp"))
  if (!identical(code, 0L) || !file.exists(remp)) {
    jr <- file.path(tmp, paste0(nom, ".log"))
    err <- if (file.exists(jr)) grep("^! ", iconv(readLines(jr, warn = FALSE), "UTF-8", "UTF-8", sub = "?"), value = TRUE) else character(0)
    unlink(tmp, recursive = TRUE)
    return(list(erreur = sprintf("passe de mesure en echec (code %s ; premiere erreur : %s).", code,
                                 if (length(err)) substr(err[1L], 1L, 120L) else "aucune")))
  }
  list(tmp = tmp, pdf = file.path(tmp, paste0(nom, ".pdf")), remp = remp)
}

# Controle (d) complet. `remp` et `pdf_mesure` : fichiers d'une passe deja faite
# (CI : tests/doc_remplissage.tex) ; sinon la passe est faite ici.
nd_outils_pdf_manquants <- function() c("pdftotext", "pdfinfo")[!nzchar(Sys.which(c("pdftotext", "pdfinfo")))]

nd_controle_remplissage <- function(tex, pdf_normal, marques_tex, remp = NULL, pdf_mesure = NULL) {
  manquants <- nd_outils_pdf_manquants()
  if (length(manquants))
    return(list(constats = NULL, avis = sprintf("%s absent (poppler-utils) : remplissage non mesure.", paste(manquants, collapse = " et "))))
  if (is.null(pdf_normal) || !file.exists(pdf_normal))
    return(list(constats = NULL, avis = "PDF de la compilation normale absent : remplissage non mesure."))
  tmp <- NULL
  if (is.null(remp) || is.null(pdf_mesure)) {
    passe <- nd_passe_mesure(tex, marques_tex)
    if (!is.null(passe$erreur)) return(list(constats = NULL, avis = passe$erreur))
    tmp <- passe$tmp; remp <- passe$remp; pdf_mesure <- passe$pdf
    on.exit(unlink(tmp, recursive = TRUE))
  }
  if (!file.exists(remp) || !file.exists(pdf_mesure))
    return(list(constats = NULL, avis = "fichiers de la passe de mesure absents : remplissage non mesure."))
  if (!identical(nd_texte_pdf(pdf_normal), nd_texte_pdf(pdf_mesure)))
    return(list(constats = NULL, avis = paste("la passe de mesure ne compose pas le meme texte que le PDF compile",
                                              "(PDF obsolete ou marques qui deplacent la composition) : remplissage non mesure.")))
  marques <- nd_lire_marques(remp)
  if (is.null(marques)) return(list(constats = NULL, avis = "marques incompletes (ligne G absente) : remplissage non mesure."))
  mots <- nd_lire_mots(pdf_normal)
  if (is.null(mots)) return(list(constats = NULL, avis = "mots du PDF illisibles (poppler-utils absent) : remplissage non mesure."))
  nd_analyser_remplissage(marques, mots)
}

nd_imprimer_remplissage <- function(r) {
  op <- options(width = 200); on.exit(options(op), add = TRUE)
  cat("\n== (d) Remplissage des pages (avertissement seulement) ==\n")
  for (a in r$avis) cat("AVERTISSEMENT :", a, "\n")
  if (is.null(r$constats)) return(invisible(0L))
  cat(sprintf(paste("Seuils : blanc > %.0f %% de la hauteur utile hors saut voulu ; encadre coupe court (< %.0f %%) ou morceau < %d lignes ;",
                    "titre suivi de < %d lignes ; rubrique commencee par < %d ligne.\n"),
              100 * SEUIL_BLANC_REMPLISSAGE, 100 * SEUIL_ENCADRE_COURT, MORCEAU_MIN_LIGNES, TITRE_LIGNES, RUBRIQUE_LIGNES))
  c_ <- r$constats
  libelle <- c(blanc = "Blancs en bas de page", encadre = "Encadres courts coupes", titre = "Titres isoles en bas de page",
               rubrique = "Rubriques commencees par une seule ligne")
  for (ty in names(libelle)) {
    z <- c_[c_$type == ty, , drop = FALSE]
    cat(sprintf("\n-- %s : %d\n", libelle[[ty]], nrow(z)))
    for (i in seq_len(nrow(z))) cat(sprintf("  p. %d : %s\n", z$page[i], z$detail[i]))
  }
  s <- r$resume
  cat(sprintf(paste("\nTOTAL (d) : %d pages (%d en paysage, non mesurees), %d encadre(s), %d titre(s), %d rubrique(s) ;",
                    "%d avertissement(s) (blanc maximal %.0f %% hors saut voulu).\n"),
              s$pages, s$paysage, s$encadres, s$titres, s$rubriques, nrow(c_), 100 * s$blanc_max))
  invisible(nrow(c_))
}

# --- Programme principal ------------------------------------------------------------------
# Marques de la passe de mesure du controle (d), a cote du script.
MARQUES_REMPLISSAGE_DEFAUT <- "marques_remplissage.tex"

nd_main <- function(args) {
  selecteurs <- c("--motifs-seuls", "--pages-seules", "--debordements", "--remplissage")
  connus <- c("--bloquant", selecteurs)
  inconnus <- args[!(args %in% connus | grepl("^--(max-lignes|tex|aux|log|pdf|remp|pdf-mesure|moteur)=.+$", args))]
  if (length(inconnus)) {
    cat("Argument(s) inconnu(s) :", paste(inconnus, collapse = " "),
        "\nUsage : Rscript tests/controle_doc_nd.R [--bloquant]",
        "[--motifs-seuls | --pages-seules | --debordements | --remplissage]",
        "[--max-lignes=N] [--tex=CHEMIN] [--aux=CHEMIN] [--log=CHEMIN] [--pdf=CHEMIN]",
        "[--remp=CHEMIN --pdf-mesure=CHEMIN] [--moteur=CHEMIN]\n")
    return(2L)
  }
  if (sum(selecteurs %in% args) > 1L) {
    cat(paste(selecteurs, collapse = ", "), ": au plus une de ces options.\n"); return(2L)
  }
  val <- function(nom, defaut) {
    a <- grep(paste0("^--", nom, "="), args, value = TRUE)
    if (length(a)) sub(paste0("^--", nom, "="), "", a[length(a)]) else defaut
  }
  max_lignes <- suppressWarnings(as.integer(val("max-lignes", "5")))
  if (is.na(max_lignes) || max_lignes < 0L) { cat("--max-lignes=N : entier >= 0 attendu.\n"); return(2L) }
  bloquant <- "--bloquant" %in% args
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  dossier_script <- if (length(f)) dirname(normalizePath(f[1L], mustWork = FALSE)) else "tests"
  tex <- val("tex", NULL)
  if (is.null(tex)) tex <- file.path(dossier_script, "..", FICHIER_TEX_DEFAUT)
  if (!file.exists(tex)) { cat("Fichier introuvable :", tex, "\n"); return(2L) }
  aux <- val("aux", sub("[.]tex$", ".aux", tex))
  journal <- val("log", sub("[.]tex$", ".log", tex))
  pdf <- val("pdf", sub("[.]tex$", ".pdf", tex))
  sel <- function(controle) {
    aucun <- !any(selecteurs %in% args)
    switch(controle, motifs = aucun || "--motifs-seuls" %in% args, pages = aucun || "--pages-seules" %in% args,
           debordements = aucun || "--debordements" %in% args, remplissage = "--remplissage" %in% args)
  }
  lignes <- nd_lire_lignes(tex)
  cat(sprintf("Controle ND de %s (%d lignes). Mode : %s.\n\n", tex, length(lignes),
              if (bloquant) "BLOQUANT" else "avertissement (code de sortie 0)"))
  n_a <- 0L; n_b <- 0L; n_c <- 0L; n_d <- 0L
  if (sel("motifs")) {
    moteur <- val("moteur", file.path(dossier_script, "..", "R", "engine.R"))
    n_a <- nd_imprimer_motifs(nd_controle_motifs(lignes, exceptions_motifs_defaut(moteur = moteur)), max_lignes)
  }
  if (sel("pages")) n_b <- nd_imprimer_pages(nd_controle_pages(lignes, nd_lire_aux(aux)))
  if (sel("debordements")) n_c <- nd_imprimer_debordements(nd_controle_debordements(nd_lire_journal(journal)))
  if (sel("remplissage")) {
    t0 <- Sys.time()
    r <- nd_controle_remplissage(tex, pdf, file.path(dossier_script, MARQUES_REMPLISSAGE_DEFAUT),
                                 remp = val("remp", NULL), pdf_mesure = val("pdf-mesure", NULL))
    n_d <- nd_imprimer_remplissage(r)
    cat(sprintf("Duree de la mesure du remplissage : %.1f s.\n", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  }
  cat(sprintf(paste("\nBILAN : %d occurrence(s) de la liste A, %d fiche(s) en violation du plafond,",
                    "%d debordement(s) en violation, %d avertissement(s) de remplissage.\n"), n_a, n_b, n_c, n_d))
  viol <- n_a > 0L || n_b > 0L || n_c > 0L
  if (Sys.getenv("GITHUB_ACTIONS") == "true" && (viol || n_d > 0L))
    cat(sprintf(paste("::warning title=Controle ND::%d occurrence(s) de la liste A, %d fiche(s) en violation du plafond,",
                      "%d debordement(s) en violation, %d avertissement(s) de remplissage.\n"), n_a, n_b, n_c, n_d))
  if (bloquant && viol) return(1L)
  0L
}

if (sys.nframe() == 0L) quit(status = nd_main(commandArgs(trailingOnly = TRUE)))
