###############################################################################
#  tests/controle_doc_nd.R  --  CONTROLES DE CI SUR LA DOCUMENTATION LATEX
#  (branche ND, lot L0, issue #451)
#
#  Deux controles sur docs/latex/doc_tests_usp.tex, en AVERTISSEMENT par
#  defaut (code de sortie 0, decompte publie) ; l'option --bloquant les rend
#  bloquants (lot L7).
#
#  (a) Motifs de "vie du depot". Le document decrit l'outil, pas le depot :
#      la liste A (13 motifs PCRE, A1 a A13) est interdite ; la liste B
#      (motifs a surveiller) est toujours comptee, jamais bloquante. Les
#      motifs s'appliquent a toutes les lignes du .tex, commentaires %
#      compris. Les exceptions nommees (liste EXCEPTIONS_MOTIFS : id, motifs
#      exemptes, zone, parties, raison) sont appliquees ; une exception qui
#      n'exempte plus rien est signalee PERIMEE.
#        E3 : docs/suivi-documentation/ admis en partie IV seulement ;
#        E7 : la chaine du moteur "Restituee en diagnostic par decision
#             (issue \#299)", transitoire (drapeau E7_TRANSITOIRE, a lever
#             au lot L1 apres retrait de la chaine du moteur).
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
#  Usage (depuis la racine du depot) :
#      Rscript tests/controle_doc_nd.R                  # deux controles, code 0
#      Rscript tests/controle_doc_nd.R --bloquant       # code 1 si violation A ou (b)
#      Rscript tests/controle_doc_nd.R --motifs-seuls   # controle (a) seul
#      Rscript tests/controle_doc_nd.R --pages-seules   # controle (b) seul
#      Rscript tests/controle_doc_nd.R --max-lignes=N   # lignes en cause par motif (defaut 5)
#      --tex=CHEMIN, --aux=CHEMIN                       # autres fichiers (tests)
#  Code 2 pour un argument inconnu ou un fichier introuvable.
#
#  R base uniquement. Les motifs sont ecrits en sequences \u (independants de
#  la locale du script) ; sous LC_ALL=C.UTF-8 les lignes en cause s'impriment
#  lisiblement. Sous POSIX, elles s'impriment avec des <U+xxxx>.
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
# TRUE tant que le .tex cite mot pour mot la chaine du moteur ; a lever (FALSE)
# par le commit du lot L1 qui retire la chaine du moteur. Numeros d'issue des
# chaines admises (la grille valide #299 seul).
E7_TRANSITOIRE <- TRUE
E7_ISSUES      <- 299L

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
                      "docs/(?!tableaux/|suivi-documentation/)[a-z]|docs/suivi-documentation/")),
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
       regex = c(paste0("\\b[0-9]{1,2}(?:\\\\textsuperscript\\{er\\})?~?", .mois, "\\b", .annee_admise),
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
       regex = c("\\b(?:sp\u00e9cification|avis|r\u00e9serve|visa|validation)\\s+d'\\\\code\\{",
                 "\\bvis\u00e9e?s? par\\b",
                 "\\bd\u00e9cisions? du\\b",
                 "\\bvalidation de l'issue"))
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

# --- Exceptions nommees de la liste A --------------------------------------------
# Une exception = id, motifs exemptes, zone (regex PCRE d'une zone de la ligne
# dans laquelle une occurrence est exemptee), parties (NULL : toutes), raison,
# actif. Une occurrence est exemptee si son motif est dans `motifs`, si sa
# partie est admise et si elle est contenue dans une occurrence de `zone` sur la
# meme ligne. Une zone coupee par un retour a la ligne n'est pas reconnue
# (controle ligne a ligne).
exceptions_motifs_defaut <- function(e7_actif = E7_TRANSITOIRE, e7_issues = E7_ISSUES) {
  list(
    list(id = "E3", motifs = "A4", zone = "docs/suivi-documentation/",
         parties = "Partie IV", actif = TRUE,
         raison = "dossier de suivi cite comme piece de tracabilite, en partie IV seulement"),
    list(id = "E7", motifs = "A1",
         zone = paste0("Restituee en diagnostic par decision \\(issue \\\\#(?:",
                       paste(e7_issues, collapse = "|"), ")\\)"),
         parties = NULL, actif = isTRUE(e7_actif),
         raison = paste("TRANSITOIRE (a lever au lot L1) : chaine du moteur citee mot pour mot,",
                        "retiree du moteur par L1"))
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
    for (rx in m$regex) {
      g <- gregexpr(rx, lignes, perl = TRUE)
      for (i in which(vapply(g, function(x) x[1L] > 0L, logical(1)))) {
        deb <- as.integer(g[[i]])
        lon <- attr(g[[i]], "match.length")
        k <- lon > 0L
        if (any(k)) pm[[length(pm) + 1L]] <- data.frame(
          ligne = i, debut = deb[k], fin = deb[k] + lon[k] - 1L,
          texte = substring(lignes[i], deb[k], deb[k] + lon[k] - 1L),
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
# exception : id, statut ("appliquee", "PERIMEE", "levee"), n, raison).
nd_appliquer_exceptions <- function(occ, lignes, exceptions) {
  occ$exception <- rep(NA_character_, nrow(occ))
  bilan <- data.frame(id = character(0), statut = character(0), n = integer(0),
                      raison = character(0), stringsAsFactors = FALSE)
  for (e in exceptions) {
    n <- 0L
    if (isTRUE(e$actif)) {
      cand <- which(is.na(occ$exception) & occ$motif %in% e$motifs &
                    (is.null(e$parties) | occ$partie %in% e$parties))
      for (k in cand) {
        z <- gregexpr(e$zone, lignes[occ$ligne[k]], perl = TRUE)[[1L]]
        if (z[1L] > 0L) {
          zd <- as.integer(z); zf <- zd + attr(z, "match.length") - 1L
          if (any(zd <= occ$debut[k] & zf >= occ$fin[k])) { occ$exception[k] <- e$id; n <- n + 1L }
        }
      }
    }
    statut <- if (!isTRUE(e$actif)) "levee" else if (n == 0L) "PERIMEE" else "appliquee"
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

# --- Programme principal ------------------------------------------------------------------
nd_main <- function(args) {
  connus <- c("--bloquant", "--motifs-seuls", "--pages-seules")
  inconnus <- args[!(args %in% connus | grepl("^--(max-lignes|tex|aux)=.+$", args))]
  if (length(inconnus)) {
    cat("Argument(s) inconnu(s) :", paste(inconnus, collapse = " "),
        "\nUsage : Rscript tests/controle_doc_nd.R [--bloquant] [--motifs-seuls | --pages-seules]",
        "[--max-lignes=N] [--tex=CHEMIN] [--aux=CHEMIN]\n")
    return(2L)
  }
  if (all(c("--motifs-seuls", "--pages-seules") %in% args)) {
    cat("--motifs-seuls et --pages-seules s'excluent.\n"); return(2L)
  }
  val <- function(nom, defaut) {
    a <- grep(paste0("^--", nom, "="), args, value = TRUE)
    if (length(a)) sub(paste0("^--", nom, "="), "", a[length(a)]) else defaut
  }
  max_lignes <- suppressWarnings(as.integer(val("max-lignes", "5")))
  if (is.na(max_lignes) || max_lignes < 0L) { cat("--max-lignes=N : entier >= 0 attendu.\n"); return(2L) }
  bloquant <- "--bloquant" %in% args
  tex <- val("tex", NULL)
  if (is.null(tex)) {
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    racine <- if (length(f)) normalizePath(file.path(dirname(f[1L]), ".."), mustWork = FALSE) else "."
    tex <- file.path(racine, FICHIER_TEX_DEFAUT)
  }
  if (!file.exists(tex)) { cat("Fichier introuvable :", tex, "\n"); return(2L) }
  aux <- val("aux", sub("[.]tex$", ".aux", tex))
  lignes <- nd_lire_lignes(tex)
  cat(sprintf("Controle ND de %s (%d lignes). Mode : %s.\n\n", tex, length(lignes),
              if (bloquant) "BLOQUANT" else "avertissement (code de sortie 0)"))
  n_a <- 0L; n_b <- 0L
  if (!"--pages-seules" %in% args) n_a <- nd_imprimer_motifs(nd_controle_motifs(lignes), max_lignes)
  if (!"--motifs-seuls" %in% args) n_b <- nd_imprimer_pages(nd_controle_pages(lignes, nd_lire_aux(aux)))
  cat(sprintf("\nBILAN : %d occurrence(s) de la liste A, %d fiche(s) en violation du plafond.\n", n_a, n_b))
  viol <- n_a > 0L || n_b > 0L
  if (viol && Sys.getenv("GITHUB_ACTIONS") == "true")
    cat(sprintf("::warning title=Controle ND::%d occurrence(s) de la liste A, %d fiche(s) en violation du plafond de pages.\n", n_a, n_b))
  if (bloquant && viol) return(1L)
  0L
}

if (sys.nframe() == 0L) quit(status = nd_main(commandArgs(trailingOnly = TRUE)))
