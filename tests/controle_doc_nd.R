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
#        E3 : docs/suivi-documentation/ admis en partie IV seulement.
#        E10 : date figee, ligne de definition de \datedoc (preambule) seulement.
#      L'exception transitoire E7 (chaines du moteur qui portaient un numero
#      d'issue) est retiree au lot L1 (#452), qui a retire ces numeros du moteur.
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
#        conforme   : sinon ;
#        exception  : une fiche sous exception, non conforme sans elle, n'est
#                     "conforme (exception)" que si son etendue tient dans le
#                     plafond accorde ET sa source dans le budget en caracteres
#                     accorde ; sinon elle garde son verdict sans exception.
#                     Le rapport imprime cette regle complete
#                     (nd_imprimer_pages()).
#      Liste EXCEPTIONS_PLAFOND (label, plafond accorde en pages, budget
#      accorde en caracteres, raison), tranchee lot par lot ; le budget est celui
#      de la liste des exceptions de docs/latex/CONVENTIONS.md, section 1, et n'est
#      ecrit qu'une fois dans le script (champ `caracteres`) : le texte "source
#      au plus N caracteres" de la raison imprimee en est construit a l'impression
#      (nd_raison_imprimee()), la raison stockee ne porte pas le nombre. Le
#      verdict avec exception n'est jamais plus severe que sans elle (#465) : une
#      fiche non conforme sans exception devient "conforme (exception)" si son
#      etendue tient dans le plafond accorde ET sa source dans le budget, sinon
#      garde son verdict sans exception (un budget depasse laisse donc une
#      violation) ; une fiche conforme sans exception reste "conforme" et son
#      exception est PERIMEE, budget compris. Sans .aux, ou sans labels -fin,
#      le controle le signale et retombe sur les caracteres seuls ("a verifier
#      (sans pages)"), en avertissement : jamais une violation pour les pages ;
#      sous --bloquant, ce repli est refuse (code 2, voir plus bas). L'appariement
#      des fiches du .tex et des labels fiche:N du .aux est controle (decompte).
#
#  (c) Debordements, lus dans le journal LaTeX docs/latex/doc_tests_usp.log :
#      Overfull \hbox = violation ; Overfull \vbox = avertissement jusqu'a
#      1,5 pt, violation au-dela. Modele : outils/controles/journal.R du depot
#      docu_actu.
#
#  (d) Remplissage des pages, par une passe de mesure a part, jamais bloquante.
#      Modele : outils/controles/remplissage.R du depot docu_actu, avec
#      tests/marques_remplissage.tex (marques adaptees a l'environnement framed). La passe
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
#      --tex=CHEMIN, --aux=CHEMIN, --log=CHEMIN, --pdf=CHEMIN   # autres fichiers (tests)
#      --remp=CHEMIN --pdf-mesure=CHEMIN                # (d) sur les fichiers d'une passe deja
#                                                       # faite (CI : tests/doc_remplissage.tex)
#  Code 2 pour un argument inconnu, plusieurs options de controle a la fois, ou
#  un fichier introuvable. Sous --bloquant, le code 2 vaut aussi pour un .aux
#  absent ou sans label fiche:N-fin quand le controle (b) est lance (le .tex ayant
#  des fiches), pour un nombre de fiches du .tex different du nombre de labels
#  fiche:N du .aux, et pour un journal .log absent quand le controle (c) l'est :
#  un controle bloquant qui n'a rien lu ne doit pas passer pour un controle vert
#  (#465). Hors --bloquant, ces cas restent des avertissements. Le controle (a),
#  qui ne lit ni le .aux ni le .log, est lance et imprime AVANT ce refus : le code
#  de sortie reste 2, mais le rapport de (a) n'est pas masque (#475). Ce rapport
#  comprend aussi la liste B (nd_imprimer_motifs()).
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

# --- Exceptions au plafond de pages (label, pages, budget en caracteres, raison) --
# Chaque exception est tranchee au tri de son lot, sur accord du mainteneur, et
# inscrite aussi dans docs/latex/CONVENTIONS.md, section 1 (budget en caracteres).
# Le label est celui de la fiche (fiche:student-pente) ou son numero automatique.
# `caracteres` : budget de la source (caracteres de \begin{fiche} a \end{fiche}),
# le meme que la colonne Budget de CONVENTIONS.md ; au-dela, violation. Champ
# facultatif (NULL ou NA : budget non controle, exception de repli sans budget).
# La raison ne porte pas le budget : nd_raison_imprimee() y ajoute "source au plus N
# caracteres" a l'impression, depuis `caracteres`.
EXCEPTIONS_PLAFOND <- list(
  list(label = "fiche:student-pente", pages = 3L, caracteres = 13000L,
       raison = "second fondement d'exactitude (loi de permutation exacte sous l'echangeabilite), reserve d'echangeabilite et constat C6 gardes integralement"),
  list(label = "fiche:foc", pages = 3L, caracteres = 15000L,
       raison = "controle numerique qui fonde la validite de l'estimation : derivation, regle au moins un demarrage et sa reserve, identite FOC, lecture a T = 8, libelle courbure"),
  list(label = "fiche:rosner-esd", pages = 3L, caracteres = 13000L,
       raison = "source valable pour n >= 25 seulement : lecture critique de l'article, niveau exact de la premiere etape et son domaine, constat C7, raisons de l'absence de verdict"),
  list(label = "fiche:ic-bootstrap", pages = 3L, caracteres = 15000L,
       raison = "seule mesure de la validite du bootstrap parametrique pour sigma_USP a T = 8 : couverture a cinq intervalles, biais, Andrews (2000), intervalle basic logarithmique, dependance de L a la table"),
  list(label = "mw:m1", pages = 3L, caracteres = 14000L,
       raison = "seule ligne de M1 qui agrege les colonnes, construction de l'outil : pente relative a effets fixes et ponderation MCG avec la justification chiffree de l'effet fixe, forme close de Frisch et Waugh et sa verification, loi de Student approchee, critere de recevabilite a posteriori et sa reserve, puissance appariee, nature de l'alternative, non-specificite"),
  list(label = "mw:m1a", pages = 3L, caracteres = 15000L,
       raison = "test central de M1 apres transfert des regles communes et des phrases de B effectif : argument de la loi chi2(2K) exacte sous erreurs gaussiennes et ses deux reserves, colonnes non identifiables propres a la ligne, p-value conditionnelle a la definition de la statistique et sa mesure, puissance et dispersion intra-colonne"),
  list(label = "mw:m1c", pages = 3L, caracteres = 14000L,
       raison = "statistique definie par sa forme close (Cauchy-Binet, Cramer, Schur) et verifiee en precision etendue, colonnes non identifiables et ensemble fige propres a la ligne, loi chi2(2K) exacte sous erreurs gaussiennes et sa reserve, cout de la forme close, arbitrage de la colonne a un degre de liberte"),
  list(label = "mw:m1d", pages = 3L, caracteres = 12000L,
       raison = "construction de l'outil sans test publie : sources de la famille alpha (Mack 1994 et 1999), lecture des deux branches de H1 au regard de D(2)(h)(iii), absence de loi analytique, colonnes degenerees, puissance, exposants de variance sous H0 vraie, profils compares a la pente relative"),
  list(label = "mw:m1id", pages = 3L, caracteres = 12000L,
       raison = "diagnostic qui conditionne la lecture de la puissance de M1 et M2 : identite exacte de la variance de l'ordonnee, proprietes algebriques de e_a (Jensen, sigma2 gonfle sous H1), multiplicateurs de Student decentree et variante dementie par la mesure, lectures de R_j et CV_j"),
  list(label = "mw:m2bp", pages = 3L, caracteres = 12000L,
       raison = "construction de l'outil (nR2 de Koenker partialise par Frisch et Waugh) : artefacts ecartes et justification, loi chi2(1) asymptotique non adossee, statistique sans effet de colonne non retenue, lecture de l'exposant 1, absence de puissance mesurable, non-specificite"),
  list(label = "mw:m2b", pages = 3L, caracteres = 14500L,
       raison = "H0 ne traduit l'hypothese reglementaire qu'a l'effet de levier pres : variance exacte 1 - h, trois causes d'un rejet lues au regard de D(2)(h)(iv), mecanisme sous un ecart regulier, troisieme reserve de la loi chi2(2K), portee d'un rejet (art. 219 et 220), absence de puissance et non-specificite"),
  list(label = "mw:m3cal", pages = 3L, caracteres = 13000L,
       raison = "procedure de l'annexe H de Mack et ses trois ecarts, moments exacts et exemple publie, regle de decision de Mack et niveau des p asymptotiques, puissance en queue basse contre bilaterale, sous-triangle 5x5"),
  list(label = "mw:m4gr", pages = 3L, caracteres = 15500L,
       raison = "test central de M4, construction de l'outil : loi de Student conditionnelle et borne de Bonferroni mesuree non utilisable, cellule a influence non bornee et sa frontiere numerique, choix du minimum et exclusion des colonnes de trois facteurs, trois limites, remplacement de Grubbs")
)

# --- Liste A : motifs interdits (bloquants a L7) --------------------------------
.mois <- paste0("(?:janvier|f\u00e9vrier|mars|avril|mai|juin|juillet|ao\u00fbt|",
                "septembre|octobre|novembre|d\u00e9cembre)")
# Une date suivie d'une annee <= 2025 reste admise (dates du reglement : 17 janvier
# 2015, 14 novembre 2024), que l'annee suive par ~ ou par une espace.
.annee_admise <- "(?![~\\s]*(?:19[0-9]{2}|20(?:0[0-9]|1[0-9]|2[0-5]))(?![0-9]))"

# Mots de definition de macro ou d'environnement : sur une ligne ou un mot de definition
# precede un #, ce # est un parametre de macro (#1 a #9, #10 = #1 suivi de 0), jamais un
# numero d'issue. La liste est celle de CONVENTIONS.md, section 5.
.def_macro <- "(?:[gex]?def|newcommand|renewcommand|providecommand|newenvironment|renewenvironment|NewDocumentCommand|RenewDocumentCommand|DeclareDocumentCommand)"
.ligne_definition <- paste0("^(?=.*\\\\", .def_macro, "\\b.*#).*(*SKIP)(*FAIL)")
.arg_url <- "\\\\(?:url|href)\\{[^}]*\\}"

MOTIFS_A <- list(
  # A1, quatre regex :
  #  1. \# suivi d'un numero, avec espace, ~ ou \, entre les deux ;
  #  2. # non echappe suivi d'au moins deux chiffres, hors ligne de definition de macro et
  #     hors argument de \url ou \href (ancre d'URL) ;
  #  3. # non echappe suivi d'un numero (un seul chiffre compris) dans un commentaire %, tous
  #     les numeros du commentaire (\G reprend apres chaque numero). Le % ouvre un commentaire
  #     s'il n'est pas precede d'un nombre impair de \ (fin\\% est un commentaire, \% non) et
  #     s'il n'est pas dans un argument de \url ou \href. Rien n'est lu sur une ligne de
  #     definition de macro, ni sur une ligne dont la partie avant le % contient un # (corps
  #     de macro, ancre d'URL hors \url) ;
  #  4. "issue" (casse indifferente) ou "PR" suivi d'un numero, lu sur deux lignes (fenetre2).
  # Limites : (i) un # a un chiffre dans un commentaire est lu comme un numero d'issue (le
  # commentaire "% le parametre #1 est le titre" est releve) ; (ii) le commentaire final d'une
  # ligne de definition de macro ou d'une ligne dont la partie code contient un # n'est pas lu.
  list(id = "A1", desc = "numero d'issue ou de PR (\\#N, # N en commentaire, issue N, PR N)",
       fenetre2 = 4L,
       regex = c("\\\\#(?:[~\\s]|\\\\[,;:!])*[0-9]+",
                 paste0(.ligne_definition, "|", .arg_url, "(*SKIP)(*FAIL)|(?<![\\\\#])#[0-9]{2,}"),
                 paste0(.ligne_definition, "|(?:^(?:", .arg_url, "|[^\\\\%#]|\\\\.)*+%|(?!^)\\G).*?\\K(?<![\\\\#])#[0-9]+"),
                 "\\b(?:(?i:issues?)|PR)[~\\s]+[0-9]+")),
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
       regex = "\\bM(?:[7-9]|[1-9][0-9]+)\\b"),
  list(id = "A8", desc = "sigle de branche",
       regex = c("\\b(?:E2[a-z]?|F[a-z]|JF)\\b", "\\bbranche~?(?:R[0-9]{2}|ND)\\b")),
  list(id = "A9", desc = "mainteneur, agents, modeles",
       regex = c("\\bmainteneur\\b",
                 "\\\\code\\{(?:actuary|coder|audit|docwriter|architect|regulatory|app-review)\\}",
                 paste0("\\b(?:actuary|docwriter|architect|regulatory|app-review|Claude|Codex|",
                        "ChatGPT|GPT|Fable|Opus|Sonnet)\\b"),
                 "\\bcas d'audit~?[0-9]+")),
  list(id = "A10", desc = "date de la vie du depot (jour-mois sans annee, annee >= 2026, mois et annee >= 2026)",
       fenetre2 = c(1L, 4L),   # le premier motif lit l'annee dans la ligne et la suivante ; le quatrieme, le mois et l'annee
       regex = c(paste0("\\b[0-9]{1,2}(?:\\\\textsuperscript\\{er\\})?[~\\s]?", .mois, "\\b", .annee_admise),
                 "\\b[0-9]{2}/[0-9]{2}/202[6-9]\\b",
                 "\\b202[6-9]-[0-9]{2}-[0-9]{2}(?![0-9])",
                 paste0("\\b", .mois, "[~\\s]+(?:202[6-9]|20[3-9][0-9])(?![0-9])"))),
  list(id = "A11", desc = "SHA de commit (7 a 40 hexadecimaux avec lettre et chiffre)",
       regex = "\\b(?=[0-9a-f]*[a-f])(?=[0-9a-f]*[0-9])[0-9a-f]{7,40}\\b"),
  list(id = "A12", desc = "l'issue comme objet du depot, sans numero",
       regex = c("\\b(?:cette|chaque|une|la m\u00eame)~?\\s*issue\\b",
                 "\\bl'issue\\b(?!\\s+d[eu]\\b)(?![~\\s]*(?:\\\\#(?:[~\\s]|\\\\[,;:!])*|#)?[0-9])",
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

exceptions_motifs_defaut <- function() {
  list(
    list(id = "E3", motifs = "A4", zone = "docs/suivi-documentation/", fenetre = 1L,
         parties = "Partie IV", actif = TRUE, permanente = TRUE,
         raison = "regle permanente : dossier de suivi cite comme piece de tracabilite, en partie IV seulement"),
    list(id = "E10", motifs = "A10", zone = "\\\\newcommand\\{\\\\datedoc\\}\\{[^}]*\\}", fenetre = 1L,
         parties = "Preambule", actif = TRUE, permanente = TRUE,
         raison = "regle permanente : date d'etablissement figee, ligne de definition de \\datedoc")
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
    # Recouvrement : les occurrences d'un meme motif qui se contiennent ou se chevauchent
    # sur une ligne sont fusionnees en une seule (leur union) : "6~novembre 2026" est une
    # date, que deux regex de A10 en lisent chacune une part (#465). Deux occurrences
    # qui se touchent sans se chevaucher restent deux occurrences.
    d <- d[order(d$ligne, d$debut, -d$fin), , drop = FALSE]
    garde <- rep(TRUE, nrow(d))
    cour <- 1L
    for (i in seq_len(nrow(d))[-1L]) {
      if (d$ligne[i] == d$ligne[cour] && d$debut[i] <= d$fin[cour]) {
        d$fin[cour] <- max(d$fin[cour], d$fin[i]); garde[i] <- FALSE
      } else cour <- i
    }
    d <- d[garde, , drop = FALSE]
    d$texte <- substring(lignes[d$ligne], d$debut, d$fin)
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
  # Fiche indentee admise (#465) : un \begin{fiche} precede d'espaces compte comme les autres.
  deb <- grep("^[[:space:]]*\\\\begin\\{fiche\\}", lignes)
  fin <- grep("^[[:space:]]*\\\\end\\{fiche\\}", lignes)
  if (length(deb) != length(fin))
    stop(sprintf("%d \\begin{fiche} pour %d \\end{fiche} : le .tex est mal forme.", length(deb), length(fin)))
  if (any(fin <= deb) || (length(deb) > 1L && any(deb[-1L] <= fin[-length(fin)])))
    stop("fiches imbriquees ou mal appariees.")
  titre <- sub("\\}[[:space:]]*$", "", sub("^[[:space:]]*\\\\begin\\{fiche\\}\\{", "", lignes[deb]))
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

# Verdict d'une fiche. `plafond_accorde` : plafond d'une exception (pages), NA sinon ;
# `budget_accorde` : budget d'une exception (caracteres), NA si non controle.
# Une exception est une derogation : elle ne rend jamais le verdict plus severe que sans
# elle (#465). Le verdict sans exception est d'abord calcule ; avec une exception et des
# pages connues, une fiche qui n'est pas conforme sans elle devient "conforme (exception)"
# si son etendue tient dans le plafond accorde ET si sa source tient dans le budget, et
# garde sinon son verdict sans exception. Une fiche deja conforme sans exception reste
# "conforme" : l'exception est PERIMEE et n'a aucun effet, budget compris. Sans pages,
# le verdict est celui des caracteres seuls (jamais une violation).
nd_verdict_fiche <- function(etendue, caracteres, plafond_accorde = NA_integer_,
                             seuil_pages = SEUIL_PAGES_PLAFOND,
                             seuil_caracteres = SEUIL_CARACTERES_PLAFOND,
                             budget_accorde = NA_integer_) {
  if (is.na(etendue))
    return(if (caracteres > seuil_caracteres) "a verifier (sans pages)" else "conforme (sans pages)")
  sans <- if (etendue >= seuil_pages) {
    if (caracteres > seuil_caracteres) "violation" else "a verifier"
  } else "conforme"
  if (is.na(plafond_accorde) || identical(sans, "conforme")) return(sans)
  if (etendue <= plafond_accorde && (is.na(budget_accorde) || caracteres <= budget_accorde))
    "conforme (exception)" else sans
}

nd_msg_decompte <- function(n_tex, n_aux)
  sprintf("%d fiche(s) dans le .tex pour %d label(s) fiche:N dans le .aux : appariement douteux (fiche non reconnue ou .aux perime).", n_tex, n_aux)

# Controle (b) : fiches de la partie III, avec etendue et verdict. `aux` : sortie
# de nd_lire_aux() ou NULL. Renvoie list(fiches, exceptions, avis) ; `avis` :
# messages sur l'absence de .aux ou de labels -fin.
nd_controle_pages <- function(lignes, aux, exceptions = EXCEPTIONS_PLAFOND) {
  f <- nd_fiches(lignes)
  n_fiches_tex <- nrow(f)
  f <- f[f$partie == "Partie III", , drop = FALSE]
  avis <- character(0)
  if (is.null(aux)) {
    avis <- "aucun fichier .aux : controle (b) sur les caracteres seuls (avertissement)."
    aux <- data.frame(label = character(0), page = integer(0), stringsAsFactors = FALSE)
  } else if (!any(grepl("-fin$", aux$label))) {
    avis <- "aucun label fiche:N-fin dans le .aux : controle (b) sur les caracteres seuls (avertissement)."
  }
  # Appariement : une fiche du .tex, un label fiche:N du .aux. Un decompte different
  # decale tous les labels suivants (fiche non reconnue dans le .tex, .aux perime) :
  # avertissement ici, code 2 sous --bloquant (nd_main, decision du 07/11/2026).
  n_labels_aux <- sum(grepl("^fiche:[0-9]+$", aux$label))
  if (n_labels_aux > 0L && n_labels_aux != n_fiches_tex)
    avis <- c(avis, nd_msg_decompte(n_fiches_tex, n_labels_aux))
  if (any(is.na(aux$page)))
    avis <- c(avis, sprintf("%d label(s) du .aux ont une page non numerique (chiffres romains ?) : etendue non calculee pour ces fiches.",
                            sum(is.na(aux$page))))
  pg <- function(lab) aux$page[match(lab, aux$label)]
  # sprintf et non paste0 : sans fiche en partie III, paste0("fiche:", integer(0)) vaut "fiche:" (#465).
  f$debut <- pg(sprintf("fiche:%d", f$id))
  f$fin <- pg(sprintf("fiche:%d-fin", f$id))
  f$etendue <- ifelse(is.na(f$debut) | is.na(f$fin), NA_integer_, f$fin - f$debut + 1L)
  f$exception <- rep(NA_character_, nrow(f))
  f$plafond_accorde <- rep(NA_integer_, nrow(f))
  f$budget_accorde <- rep(NA_integer_, nrow(f))
  bilan <- data.frame(label = character(0), pages = integer(0), caracteres = integer(0),
                      statut = character(0), raison = character(0), stringsAsFactors = FALSE)
  for (e in exceptions) {
    k <- which(f$label %in% e$label | sprintf("fiche:%d", f$id) %in% e$label)
    budget <- if (is.null(e$caracteres)) NA_integer_ else as.integer(e$caracteres)
    if (length(k)) {
      f$exception[k] <- e$label; f$plafond_accorde[k] <- as.integer(e$pages); f$budget_accorde[k] <- budget
    }
    sans <- if (length(k)) nd_verdict_fiche(f$etendue[k[1L]], f$caracteres[k[1L]]) else NA_character_
    statut <- if (!length(k)) "PERIMEE (fiche introuvable en partie III)" else
              if (identical(sans, "conforme")) "PERIMEE (conforme sans exception)" else "appliquee"
    bilan[nrow(bilan) + 1L, ] <- list(e$label, as.integer(e$pages), budget, statut, e$raison)
  }
  f$verdict <- vapply(seq_len(nrow(f)), function(i)
    nd_verdict_fiche(f$etendue[i], f$caracteres[i], f$plafond_accorde[i],
                     budget_accorde = f$budget_accorde[i]), character(1))
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

# Raison imprimee d'une exception : la raison stockee, suivie du budget en caracteres
# construit depuis le champ `caracteres` (milliers separes par une espace), ou telle
# quelle si le budget n'est pas controle (NA). Le budget n'est ecrit qu'a un endroit.
nd_raison_imprimee <- function(raison, caracteres) {
  if (is.na(caracteres)) return(raison)
  sprintf("%s ; source au plus %s caracteres", raison,
          format(as.integer(caracteres), big.mark = " ", scientific = FALSE, trim = TRUE))
}

# Regle du controle (b), imprimee en entier : le critere de pages et de caracteres de la
# fiche, puis celui du budget en caracteres d'une exception, qui peut a lui seul donner une
# violation (budget depasse : la fiche non conforme garde son verdict sans exception).
nd_texte_regle_pages <- function()
  sprintf(paste("Regle : violation si etendue >= %d pages ET source > %d caracteres ; a verifier si etendue >= %d pages, source plus courte ;",
                "fiche sous exception, non conforme sans elle : conforme (exception) si etendue <= plafond accorde ET source <= budget accorde en caracteres,",
                "sinon verdict sans exception.\n"),
          SEUIL_PAGES_PLAFOND, SEUIL_CARACTERES_PLAFOND, SEUIL_PAGES_PLAFOND)

nd_imprimer_pages <- function(r) {
  op <- options(width = 200); on.exit(options(op), add = TRUE)
  cat("\n== (b) Plafond de pages des fiches de la partie III ==\n")
  for (a in r$avis) cat("AVERTISSEMENT :", a, "\n")
  f <- r$fiches
  cat(nd_texte_regle_pages())
  if (nrow(f)) {
    t <- data.frame(id = f$id, fiche = ifelse(is.na(f$label), substr(f$titre, 1L, 40L), f$label),
                    debut = f$debut, fin = f$fin, pages = f$etendue,
                    caracteres = f$caracteres, budget = f$budget_accorde, verdict = f$verdict, stringsAsFactors = FALSE)
    print(t, row.names = FALSE)
  } else cat("Aucune fiche en partie III.\n")
  cat("\nExceptions au plafond :\n")
  if (nrow(r$exceptions)) {
    for (i in seq_len(nrow(r$exceptions)))
      cat(sprintf("  %s : %s (plafond accorde %d pages, %s) -- %s\n", r$exceptions$label[i],
                  r$exceptions$statut[i], r$exceptions$pages[i],
                  if (is.na(r$exceptions$caracteres[i])) "budget non controle"
                  else sprintf("budget %d caracteres", r$exceptions$caracteres[i]),
                  nd_raison_imprimee(r$exceptions$raison[i], r$exceptions$caracteres[i])))
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

# Entites HTML de pdftotext -bbox. &amp; est decode en dernier : decode en premier,
# "&amp;lt;" (texte "&lt;") serait decode une seconde fois en "<" (#465).
nd_decoder_entites <- function(x)
  gsub("&amp;", "&", gsub("&lt;", "<", gsub("&gt;", ">", gsub("&quot;", "\"", gsub("&#39;", "'", x, fixed = TRUE),
                                                           fixed = TRUE), fixed = TRUE), fixed = TRUE), fixed = TRUE)

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
  mot <- nd_decoder_entites(mot)
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
  # Nombre de pages : numero de page maximal des marques, non le nombre de lignes P (une ligne
  # P dupliquee le gonflerait, une ligne manquante ferait echouer l'analyse, #465).
  nb_pages <- if (nrow(marques$pages)) max(marques$pages$page) else 0L
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

  # (1) blanc en bas de page (pages en paysage non mesurees). `blanc` a une valeur par
  # ligne P du .remp, rangee comme `pg` ; le numero de page est lu dans pg$page, jamais
  # confondu avec l'indice de rangee (une ligne P dupliquee ou manquante, #465).
  pg <- marques$pages[order(marques$pages$page), , drop = FALSE]
  blanc <- rep(NA_real_, nrow(pg))
  for (i in which(!(pg$page %in% paysage))) {
    c_p <- corps[corps$page == pg$page[i], , drop = FALSE]
    blanc[i] <- if (nrow(c_p) == 0L) 1 else max(0, (bas - max(c_p$y1)) / g$hauteur_utile)
  }
  for (i in which(!pg$volontaire & !is.na(blanc) & blanc > SEUIL_BLANC_REMPLISSAGE))
    ajouter("blanc", pg$page[i], sprintf("%s de la hauteur utile vide en bas de page, hors saut voulu", pct(blanc[i])))

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
  libres <- blanc[!pg$volontaire & !is.na(blanc)]
  list(constats = cons, avis = character(0),
       resume = list(pages = nb_pages, paysage = length(paysage), encadres = length(unique(enc$debut$id)),
                     titres = nrow(ti), rubriques = nrow(ru), blanc_max = if (length(libres)) max(libres) else 0))
}

# Evalue `expr` avec les variables d'environnement `vars` (vecteur nomme) posees par
# Sys.setenv(), puis restaure l'etat exact d'avant (on.exit) : une variable absente
# redevient absente (Sys.unsetenv), une variable presente retrouve sa valeur. Lancement
# portable d'un processus fils : l argument env de system2() est ignore ou echoue sous Windows (#477).
# `vars` vide : rien a poser (Sys.getenv(character(0)) renverrait tout l'environnement).
nd_avec_env <- function(vars, expr) {
  noms <- names(vars)
  if (length(vars)) {
    avant <- Sys.getenv(noms, unset = NA_character_)
    on.exit({
      for (i in seq_along(noms)) {
        if (is.na(avant[[i]])) Sys.unsetenv(noms[i])
        else do.call(Sys.setenv, stats::setNames(list(avant[[i]]), noms[i]))
      }
    })
    do.call(Sys.setenv, as.list(vars))
  }
  expr
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
  # Separateur de chemins de la plateforme (":" ou ";") ; le separateur final, qui designe
  # les chemins par defaut pour kpathsea, suit la meme regle.
  sep <- .Platform$path.sep
  env <- c(TEXINPUTS = paste0(paste(rep, dirname(normalizePath(marques_tex)), tmp, sep = sep), sep),
           max_print_line = "10000", error_line = "254", half_error_line = "238")
  ancien <- setwd(rep); on.exit(setwd(ancien))
  code <- nd_avec_env(env,
    system2("pdflatex", c("-interaction=nonstopmode", "-halt-on-error", paste0("-jobname=", nom),
                          paste0("-output-directory=", shQuote(tmp)),
                          shQuote(sprintf("\\input{%s}\\input{%s.tex}", sub("[.]tex$", "", basename(marques_tex)), nom))),
            stdout = FALSE, stderr = FALSE))
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
  # pdftotext et pdfinfo sont verifies une fois, en tete de la fonction : nd_lire_mots()
  # ne rend donc pas NULL ici (la seconde verification, branche morte, est retiree, #465).
  nd_analyser_remplissage(marques, nd_lire_mots(pdf_normal))
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

# Annotation GitHub Actions (sous GITHUB_ACTIONS=true, si une occurrence, une violation ou un
# avertissement de remplissage existe), emise de la meme facon par le chemin normal et par le
# refus en code 2 de --bloquant (#475) ; les compteurs des controles non lances valent 0.
nd_annotation_ga <- function(n_a, n_b, n_c, n_d) {
  if (Sys.getenv("GITHUB_ACTIONS") == "true" && (n_a > 0L || n_b > 0L || n_c > 0L || n_d > 0L))
    cat(sprintf(paste("::warning title=Controle ND::%d occurrence(s) de la liste A, %d fiche(s) en violation du plafond,",
                      "%d debordement(s) en violation, %d avertissement(s) de remplissage.\n"), n_a, n_b, n_c, n_d))
  invisible(NULL)
}

nd_main <- function(args) {
  selecteurs <- c("--motifs-seuls", "--pages-seules", "--debordements", "--remplissage")
  connus <- c("--bloquant", selecteurs)
  inconnus <- args[!(args %in% connus | grepl("^--(max-lignes|tex|aux|log|pdf|remp|pdf-mesure)=.+$", args))]
  if (length(inconnus)) {
    cat("Argument(s) inconnu(s) :", paste(inconnus, collapse = " "),
        "\nUsage : Rscript tests/controle_doc_nd.R [--bloquant]",
        "[--motifs-seuls | --pages-seules | --debordements | --remplissage]",
        "[--max-lignes=N] [--tex=CHEMIN] [--aux=CHEMIN] [--log=CHEMIN] [--pdf=CHEMIN]",
        "[--remp=CHEMIN --pdf-mesure=CHEMIN]\n")
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
  aux_lu <- if (sel("pages")) nd_lire_aux(aux) else NULL
  lignes <- nd_lire_lignes(tex)
  # Sous --bloquant, un controle qui n'a rien lu ne passe pas pour un controle vert (#465) :
  # code 2 si le .aux (controle b) ou le journal (controle c) manque, si le .aux n'a aucun
  # label fiche:N-fin alors que le .tex a des fiches (retouche du preambule qui desarmerait
  # le plafond de pages), ou si le nombre de fiches du .tex differe du nombre de labels
  # fiche:N du .aux (appariement decale, decision du 07/11/2026).
  entete <- sprintf("Controle ND de %s (%d lignes). Mode : %s.\n\n", tex, length(lignes),
                    if (bloquant) "BLOQUANT" else "avertissement (code de sortie 0)")
  manque <- character(0)
  if (bloquant) {
    if (sel("pages") && is.null(aux_lu)) manque <- c(manque, sprintf("fichier .aux introuvable (%s)", aux))
    if (sel("pages") && !is.null(aux_lu)) {
      n_tex <- nrow(nd_fiches(lignes))
      n_aux <- sum(grepl("^fiche:[0-9]+$", aux_lu$label))
      if (n_tex > 0L && !any(grepl("^fiche:[0-9]+-fin$", aux_lu$label)))
        manque <- c(manque, sprintf("aucun label fiche:N-fin dans %s", aux))
      else if (n_aux != n_tex) manque <- c(manque, sub(" : appariement douteux.*$", "", nd_msg_decompte(n_tex, n_aux)))
    }
    if (sel("debordements") && !file.exists(journal)) manque <- c(manque, sprintf("journal LaTeX .log introuvable (%s)", journal))
  }
  # Le controle (a) n'a besoin ni du .aux ni du .log : il est lance et imprime une seule fois,
  # avant le test du refus, pour que son rapport ne soit pas masque par le code 2 (#475).
  # L'en-tete n'est imprime qu'avec (a) ou hors refus.
  n_a <- 0L; n_b <- 0L; n_c <- 0L; n_d <- 0L
  if (sel("motifs") || !length(manque)) cat(entete)
  if (sel("motifs")) {
    n_a <- nd_imprimer_motifs(nd_controle_motifs(lignes, exceptions_motifs_defaut()), max_lignes)
  }
  if (length(manque)) {
    # Le code de sortie reste 2, quel que soit le resultat de (a).
    if (sel("motifs"))
      cat(sprintf("\nListe A controlee avant le refus : %d occurrence(s) ; le code de sortie reste 2.\n\n", n_a))
    cat("--bloquant : controle impossible, ", paste(manque, collapse = " ; "),
        ".\nCompiler le document avant le controle, ou retirer --bloquant pour un simple avertissement.\n", sep = "")
    nd_annotation_ga(n_a, n_b, n_c, n_d)
    return(2L)
  }
  if (sel("pages")) n_b <- nd_imprimer_pages(nd_controle_pages(lignes, aux_lu))
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
  nd_annotation_ga(n_a, n_b, n_c, n_d)
  if (bloquant && viol) return(1L)
  0L
}

if (sys.nframe() == 0L) quit(status = nd_main(commandArgs(trailingOnly = TRUE)))
