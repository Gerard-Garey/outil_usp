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
#          id, contexte, motif ecrit) ou par une garde de contexte (liste
#          GARDES_DECOMPTES : "N lignes" precede de "tableau de", "fichier
#          de"..., dimension d'un format d'entree), soit NON CLASSEE, et
#          c'est alors un ecart. Une exemption nominative qui n'exempte plus
#          rien est un ecart (perimee) ; une garde ne perime pas.
#
#       LIMITES : (i) une formulation exemptee n'est pas verifiee (anaphore,
#       provenance indirecte par fonction (#111), lignes d'un tableau du
#       document, constat de simulation, dimension d'un tableau ou d'un fichier d'entree --
#       garde de contexte : un vrai decompte ecrit "tableau de N lignes"
#       serait lui aussi exempte) ; (ii) un decompte ecrit sans les mots "lignes",
#       "entrees" ou "tests" apres le nombre ("six verdicts", "quinze
#       p-values", "un test") n'est pas inventorie, pas plus qu'un nombre
#       separe de ces mots par un qualificatif hors de la liste
#       QUALIFICATIFS ("six lignes" oui, "six grandes lignes" non) ou par
#       plus de deux qualificatifs ; (iii) une phrase du registre mesure sa
#       grandeur sur les jeux de tests/donnees/ : un decompte qui depend des
#       donnees (par ex. une nature de p-value, "restent en Monte-Carlo dans
#       tous les regimes") n'est verifie que sur ces jeux ; (iv) nombres en
#       lettres lus jusqu'a cent ("quatre-vingts", "quatre-vingt-dix-neuf",
#       "cent") : au-dela ("deux cents"), ou pour une graphie fautive, la
#       formulation n'est pas inventoriee ou peut etre lue tronquee ("cent
#       vingt et un" et "quatre-vingt et un" sont inventories entiers et
#       lus NA, voir MOT_NOMBRE) ; (v) les formules mathematiques sont lues sans leurs
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
#    5. la rubrique 7 "Pertinence et puissance a faible T" (issue #114,
#       decisions du mainteneur du 27/09/2026, points 3 et 5) :
#       a) le registre REGISTRE_RUBRIQUE7 (label de fiche -> noms exacts des
#          lignes du moteur) est confronte aux lignes de res$tests de toutes
#          les executions (J1 et volumes constants pour premium et reserve1,
#          J2 -- delta interieur, xi, yi de
#          tests/unitaires/test_controles_numeriques.R -- pour premium et
#          reserve1, triangle pour reserve2) : toute ligne de type "test" ou
#          "procedure de decision" doit etre rattachee a une et une seule
#          fiche du registre ; chaque nom du registre doit etre produit par
#          une execution ; chaque fiche du registre doit avoir une ligne de
#          ce type, sauf declaration hors_jeux motivee (qui devient un ecart
#          si elle ne sert plus) ; une declaration hors_jeux est verifiee
#          positivement (issue #121) : la ligne doit etre de type test ou
#          procedure sur un jeu lognormal synthetique de taille t_positif
#          (jeu_synthetique(), methode prime, T = 10 pour Cox-Stuart, 20 pour
#          Anscombe-Glynn) ;
#       b) dans le .tex, chaque environnement fiche qui porte \Pertinence le
#          porte une seule fois, apres \Usage ; l'ensemble des fiches (label
#          nomme de la ligne qui suit \begin{fiche}{...}) qui la portent est
#          exactement celui du registre ; \Pertinence hors de toute fiche
#          (definition \newcommand exceptee) est un ecart ;
#       c) le tableau \label{tab:tracabilite-puissance} a une rangee et une
#          seule par fiche a rubrique 7 (premiere cellule "Nom
#          (\ref{label})"), aucune pour une autre fiche ; chaque chemin de
#          fichier cite par \code{} dans sa sous-section (tests/*.R,
#          docs/tableaux/*.md, recolles s'ils sont coupes en deux \code{})
#          existe dans le depot. Les fonctions citees par \code{nom()} dans
#          ce tableau sont jugees par le controle 1, qui lit tout le document.
#
#       LIMITES : (i) le lien ligne du moteur -> fiche n'existe pas dans le
#       moteur (issue #111) : il est ecrit a la main dans REGISTRE_RUBRIQUE7,
#       et le script verifie sa coherence avec le moteur (couverture des
#       lignes de type test ou procedure, noms existants), pas qu'une ligne
#       est rattachee a la BONNE fiche ; (ii) le type d'une ligne depend des
#       donnees (regle R1, R4, regimes) : l'ensemble attendu n'est mesure
#       que sur les jeux executes (T = 8) ; une fiche dont la ligne n'est de
#       type test qu'a d'autres T (Cox-Stuart, au plus tot a T = 10 ;
#       Anscombe-Glynn, T >= 20) est declaree hors_jeux avec son motif,
#       verifie en ce que la ligne existe, n'est pas de type test sur ces
#       jeux, et l'est sur le jeu synthetique de taille t_positif (issue
#       #121) ; ce jeu est unique (sans ex aequo, methode prime) : le type
#       n'est pas verifie pour les autres jeux de meme T ;
#       (iii) le contenu de la rubrique 7 et des cellules du tableau
#       (valeurs, natures) n'est pas verifie ; un chemin ecrit hors de
#       \code{}, ou dans \code{} avec un blanc, n'est pas controle.
#    6. les constantes et les champs cites (issue #160) :
#       a) chaque \code{} dont le texte desechappe est un identifiant en
#          majuscules, ou un identifiant sans souligne commencant par une
#          majuscule (casse mixte : CoxStuart, Inf), eventuellement suivi de
#          $champ ou de [...] (noms coupes en deux \code{} recolles par
#          extraire_codes()), est classe (classer_majuscules()) : constante
#          (au moins un souligne, MOTIF_CONSTANTE, ou nom de
#          CONSTANTES_SANS_SOULIGNE ; joker MOTIF_MC_* admis), qui doit etre
#          definie par affectation de premier niveau dans R/engine.R,
#          R/display_helpers.R, app.R ou tests/*.R (definitions_constantes(),
#          lues sans execution ; le rapport dit ou chaque nom est defini) ;
#          cle d'un catalogue Monte-Carlo (DW, BP, CoxStuart...) ou argument
#          de run_engine() (B, T), verifies ; hors controle par liste fermee
#          (MAJUSCULES_HORS_CONTROLE : verdicts, litteraux R, marqueurs de
#          valeur manquante, notations du texte) ; sinon NON CLASSE, et c'est
#          un ecart, comme un fragment termine par _ reste seul ;
#       b) chaque chemin de champ (\code{} contenant $, desechappe ;
#          chemins_champs()) est decoupe en segments ; racine .Machine
#          exemptee (RACINES_EXEMPTEES) ; une racine constante chargee
#          (USP_CATALOGUE_MC$CoxStuart) impose que le segment soit un nom de
#          la constante ; une autre racine commencant par une majuscule n'est
#          pas jugee sur ses segments (elle l'est en a) ; sinon le segment
#          doit etre le nom d'un element, a toute profondeur, d'au moins un
#          des objets run_engine() deja construits pour les sections 2 a 5
#          (aucun appel supplementaire), ou, par liste fermee et commentee
#          (CHAMPS_HORS_OBJETS : champs d'objets intermediaires comme
#          usp_regime(), chemin de refus validation$erreur_r, chemin non
#          exerce plots_data$influence_motif), un nom encore pose par
#          R/engine.R (champs_poses(), analyse syntaxique : arguments nommes
#          de list(), c(), data.frame(), structure(), membre gauche
#          x$nom <- ...) ;
#       c) un nom introuvable (constante ou champ) peut etre exempte
#          nommement dans EXEMPTES_CODE (objet "constante" ou "champ") s'il
#          s'agit d'une mention historique que son contexte dit retiree ;
#          une exemption perimee est un ecart, de meme qu'une entree perimee
#          des listes fermees (perimees_listes()).
#
#       LIMITES : (i) le controle porte sur les noms, pas sur les chemins
#       complets : un champ retire d'un objet mais present sous le meme nom
#       dans un autre objet construit n'est pas detecte, et un champ de
#       CHAMPS_HORS_OBJETS reste admis tant qu'un nom identique est pose
#       quelque part dans R/engine.R ; (ii) un identifiant ecrit hors de
#       \code{}, ou dans \code{} avec un blanc, ou a racine en minuscules
#       non suivie de $, n'est pas controle ; (iii) les noms hors controle de
#       MAJUSCULES_HORS_CONTROLE sont admis partout, sans contexte ; (iv) une
#       constante est cherchee par affectation en debut de ligne : une
#       definition indentee ou par assign() n'est pas vue ; (v) les segments
#       d'une racine constante definie hors du moteur (CAS$x) ne sont pas
#       juges ; (vi) une cle Monte-Carlo est verifiee contre l'union des deux
#       catalogues, pas contre celui de la methode de la section (ce que fait
#       le controle 4, pour l'index seulement) ; (vii) une constante citee est
#       jugee definie si elle est affectee au premier niveau de n'importe quel
#       tests/*.R : une constante retiree de R/engine.R mais encore copiee
#       dans un script de mesure passerait (aucune redefinition de ce type a
#       ce jour).
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
#  (famille G.) que si fit$largeur_ic n'est pas NULL (meme regle, issue #45,
#  pour la ligne de l'IC restreint, sur boot$sigma_boot_restreint, de
#  longueur celle de boot$sigma_boot moins boot$n_echec_restreint). Mesure sur
#  tests/donnees/ : 47 lignes pour premium et reserve1 a B = 19 et 20, 48 a
#  B = 21 et 22 ; reserve2 : 19 lignes a B = 19, 20, 21, 22 (mesure faite
#  avant le seuil B_MIN_USAGE). run_engine() refuse desormais tout
#  B < B_MIN_USAGE = 99 (R/engine.R, .engine_verifier_usage(), constat C1 de
#  la revue finale d'E1), seuil qui couvre celui de l'IC. Le script lit
#  B_MIN = B_MIN_USAGE dans R/engine.R, refuse tout --B < B_MIN (erreur,
#  code de sortie 1, moteur non execute), et verifie apres execution que
#  chaque resultat lognormal a bien plus de 20 replications finies (B >= 21
#  est necessaire, pas suffisant si des replications echouent). Les methodes lognormales sont en outre executees
#  a volumes constants (x_t = 100, pertes de tests/donnees/donnees_ln.csv ;
#  issue #59) pour les seules phrases du registre qui les nomment, et sur
#  le jeu J2 pour le seul controle 5 (issue #114) ; la methode prime l'est
#  sur les jeux synthetiques T = 10 et T = 20 pour la seule verification
#  positive des declarations hors_jeux (issue #121).
#
#  Locale : lecture, traitement et sortie en UTF-8 quelle que soit la
#  locale du processus (vers_utf8(), ecrire(), ordre_stable() ; issue #113) :
#  sous LC_ALL=C comme sous LC_ALL=C.UTF-8, la sortie est la meme.
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
#  cle ou a rangee non terminee, ecart de la rubrique 7 (registre au
#  moteur, verification positive des declarations hors_jeux, presence,
#  unicite, position, fiches concernees) ou du tableau de
#  tracabilite (introuvable, rangee manquante, en double, non reconnue ou
#  pour une fiche sans rubrique 7, chemin cite inexistant ; issue #114),
#  constante ou champ cite introuvable non exempte, identifiant en
#  majuscules non classe, exemption de constante ou de champ perimee
#  (issue #160).
#  --tex remplace le document lu (tests du mode strict sur une copie
#  modifiee ; les chemins cites restent cherches depuis la racine du depot).
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions d'extraction, testees sur des chaines LaTeX en memoire par
#  tests/unitaires/test_concordance_doc_moteur.R.
#  R base + stats + utils uniquement.
###############################################################################

# ---------------------------------------------------------------------------
#  Lecture du LaTeX
# ---------------------------------------------------------------------------

# Chaines lues comme de l'UTF-8, quelle que soit la locale du processus
# (issue #113). Le document et les sources R sont en UTF-8 ; sous une locale
# C/POSIX, les chaines non ASCII d'encodage "unknown" -- litteraux d'un source
# R, "\u00e9" compris, et resultats de paste0() ou de gsub() sur elles --
# portent des octets UTF-8 que R ne sait pas traduire depuis la locale : une
# expression reguliere perl sur un vecteur qui mele de telles chaines a des
# chaines marquees UTF-8 echoue ("input string k is invalid UTF-8").
# Une chaine "unknown" valide en UTF-8 est donc marquee UTF-8 (ses octets ne
# changent pas) ; une chaine marquee latin1 est convertie. S'applique aux
# textes lus (retirer_commentaires()) et aux motifs non ASCII du script, a
# leur usage. Sous une locale UTF-8, ces chaines sont deja marquees UTF-8.
vers_utf8 <- function(x) {
  x <- as.character(x)
  inconnu <- !is.na(x) & Encoding(x) == "unknown" & validUTF8(x)
  Encoding(x)[inconnu] <- "UTF-8"
  latin <- !is.na(x) & Encoding(x) == "latin1"
  x[latin] <- enc2utf8(x[latin])
  x
}

# Retire les commentaires LaTeX (% non precede d'une barre oblique inverse),
# ligne par ligne : les numeros de ligne restent ceux du fichier. Point
# d'entree de toutes les lectures du texte LaTeX : les lignes y sont ramenees
# en UTF-8 (vers_utf8(), issue #113).
retirer_commentaires <- function(lignes) sub("(?<!\\\\)%.*$", "", vers_utf8(lignes), perl = TRUE)

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
#
# Issue #160 : la liste est etendue, avec la meme semantique (un nom absent du
# code, cite a juste titre, ancre sur son contexte), aux constantes et aux
# champs cites par le document (controle 6) ; le champ objet ("fonction",
# "constante" ou "champ" ; "fonction" si absent) dit a quel controle
# l'exemption s'applique, et chaque controle ne lit que les siennes
# (exemptions_objet()) : une exemption de constante n'est jamais jugee
# perimee par le controle des fonctions. Pour un champ, nom est le segment
# precede de $ ("$foc"). Les constantes et les champs exemptes sont des
# MENTIONS HISTORIQUES, que le texte de leur contexte dit retirees
# ("remplace", "supprime", "jusqu'a l'issue") : jamais une citation qui
# presente le nom comme existant.
MOTIF_INTERDIT_SHINY <- paste0("primitive Shiny citée dans la colonne « Interdit » du tableau ",
                               "d'architecture, pour être exclue")
EXEMPTES_CODE <- list(
  list(nom = "reactive", objet = "fonction", contexte = "Toute primitive Shiny", fenetre = 2L,
       motif = MOTIF_INTERDIT_SHINY),
  list(nom = "render*", objet = "fonction", contexte = "Toute primitive Shiny", fenetre = 2L,
       motif = MOTIF_INTERDIT_SHINY),
  list(nom = "REP_PAS_KKT", objet = "constante",
       contexte = "qui remplace le rep\u00e8re REP_PAS_KKT de la d\u00e9cision M17", fenetre = 0L,
       motif = "mention historique : repere de la decision M17 remplace par REP_SIGMA_KKT (issue #71)"),
  list(nom = "$hessien_gamma", objet = "champ", contexte = "qui remplacent depuis l'issue", fenetre = 1L,
       motif = "mention historique : champ de res$ajustement remplace depuis l'issue #71"),
  list(nom = "$pas_newton_gamma", objet = "champ", contexte = "qui remplacent depuis l'issue", fenetre = 1L,
       motif = "mention historique : champ de res$ajustement remplace depuis l'issue #71"),
  list(nom = "$foc", objet = "champ", contexte = "champ .?foc de l'ajustement, supprim\u00e9", fenetre = 1L,
       motif = "mention historique : champ de l'ajustement supprime (ligne de diagnostic retiree a l'issue #22)")
)

# Exemptions de EXEMPTES_CODE qui s'appliquent a un controle (objet :
# "fonction", "constante" ou "champ" ; une exemption sans champ objet est une
# exemption de fonction).
exemptions_objet <- function(objet, exemptions = EXEMPTES_CODE)
  Filter(function(e) identical(if (is.null(e$objet)) "fonction" else e$objet, objet), exemptions)

# Applique les exemptions aux citations. cit : sortie de
# citations_fonctions() ; statuts : vecteur nomme (par nom) de
# statut_fonction() ; lignes : texte LaTeX. Renvoie une liste :
#   ecarts    data.frame (nom, lignes) des noms introuvables non exemptes ;
#   exemptees data.frame (nom, ligne, motif) des citations exemptees ;
#   perimees  data.frame (nom, contexte) des exemptions sans effet.
appliquer_exemptions <- function(cit, statuts, lignes, exemptions = exemptions_objet("fonction")) {
  norm <- normaliser_ligne(lignes)
  introuv <- cit[unname(statuts[cit$nom]) %in% "INTROUVABLE", , drop = FALSE]
  exemptee <- logical(nrow(introuv)); motif <- rep(NA_character_, nrow(introuv))
  utilisee <- logical(length(exemptions))
  for (k in seq_along(exemptions)) {
    e <- exemptions[[k]]
    for (i in which(introuv$nom == e$nom & !exemptee)) {
      fen <- norm[max(1L, introuv$ligne[i] - e$fenetre):introuv$ligne[i]]
      if (grepl(vers_utf8(e$contexte), paste(fen, collapse = " "), perl = TRUE)) {
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
statuts_citations <- function(noms, env, paquets = character(0), defs = NULL,
                              exemptions = exemptions_objet("fonction")) {
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

# Table des graphies valides de un a cent (issue #113), orthographe
# traditionnelle ("vingt et un", "soixante et onze", "dix-sept") et
# rectifiee ("vingt-et-un", "soixante-et-onze") ; "un" et "une" dans toutes
# les compositions ; "quatre-vingt" (sans s) admis pour 80, comme avant.
# Nom : graphie en minuscules, blancs reduits a une espace ; valeur : nombre.
.table_nombres_fr <- function() {
  u <- NOMBRES_FR[c("un", "une", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf")]
  t <- c(u, NOMBRES_FR[c("dix", "onze", "douze", "treize", "quatorze", "quinze", "seize")],
         "dix-sept" = 17, "dix-huit" = 18, "dix-neuf" = 19)
  for (d in c("vingt", "trente", "quarante", "cinquante", "soixante")) {
    v <- NOMBRES_FR[[d]]
    t[d] <- v
    for (k in c("un", "une")) t[c(paste(d, "et", k), paste0(d, "-et-", k))] <- v + 1
    for (k in names(u)[-(1:2)]) t[paste0(d, "-", k)] <- v + u[[k]]
  }
  # 70 a 79 : soixante-dix, soixante et onze, soixante-douze ... soixante-dix-neuf
  for (k in names(t)[t >= 10 & t <= 19]) {
    if (k == "onze") t[c("soixante et onze", "soixante-et-onze")] <- 71
    else t[paste0("soixante-", k)] <- 60 + t[[k]]
  }
  # 80 a 99 : quatre-vingts, quatre-vingt-un ... quatre-vingt-dix-neuf (sans "et")
  t[c("quatre-vingts", "quatre-vingt")] <- 80
  for (k in names(t)[t >= 1 & t <= 19 & !grepl(" ", names(t)) & !grepl("^(vingt|trente|quarante|cinquante|soixante)", names(t))])
    t[paste0("quatre-vingt-", k)] <- 80 + t[[k]]
  t["cent"] <- 100
  t
}
NOMBRES_FR_VALIDES <- .table_nombres_fr()

# Nombre ecrit en chiffres ou en lettres (jusqu'a cent : dix-neuf,
# vingt et un, vingt-et-un, soixante-douze, quatre-vingts,
# quatre-vingt-dix-neuf, cent) ; NA si illisible ou si la composition n'est
# pas une graphie valide ("dix-dix", "cent-cent", "vingts" : issue #113 ;
# ces compositions etaient additionnees auparavant).
nombre_fr <- function(x) {
  x <- gsub("\\s+", " ", tolower(trimws(vers_utf8(x))))
  if (grepl("^[0-9]+$", x)) return(as.numeric(x))
  v <- NOMBRES_FR_VALIDES[x]
  if (is.na(v)) NA_real_ else unname(v)
}

# Nombre en chiffres ou en lettres dans les expressions regulieres.
# Alternatives triees par longueur decroissante : "quatre-vingts" avant
# "quatre-vingt" avant "quatre", "une" avant "un". La composition par
# traits d'union reste permissive (tout enchainement de mots-nombres) : une
# composition invalide ("dix-dix") est inventoriee comme une seule
# formulation, que nombre_fr() lit NA, donc NON CLASSEE ou ECART, et non
# lue en partie. La composition par " et " (orthographe traditionnelle,
# issue #113 : "vingt et une lignes" etait inventorie comme "une lignes", lu
# 1) est limitee aux seules graphies valides (dizaine de vingt a soixante,
# puis un, une ou onze) : un "et" de coordination ("deux et trois tests")
# ne soude pas deux nombres. Le motif reste en ASCII (lettres accentuees de
# la garde ecrites \x{00c0}-\x{00ff}, syntaxe PCRE) : sous une locale C,
# paste0() d'une chaine non ASCII d'encodage "unknown" et d'une chaine
# marquee UTF-8 ecrit les octets de la premiere en toutes lettres
# ("<c3><80>"), ce qui corromprait les motifs du registre DECOMPTES
# construits sur MOT_NOMBRE (issue #113). Deux graphies hors table sont
# aussi consommees en entier, pour ne pas etre lues en partie : "et" apres
# quatre-vingt(s) ou cent ("quatre-vingt et une lignes" etait inventorie
# "une lignes", lu 1) et "cent" suivi d'un nombre ("cent vingt et un
# tests" etait inventorie "vingt et un tests", lu 21) ; nombre_fr() les lit
# NA, et la formulation est NON CLASSEE (ecart) sous son libelle complet.
# LIMITE : lecture jusqu'a cent ; au-dela ("deux cents"), ou pour une
# graphie fautive non prevue ici, la formulation lue peut etre tronquee
# ou absente de l'inventaire.
.MOTS_NOMBRES <- names(NOMBRES_FR)[order(-nchar(names(NOMBRES_FR)))]
MOT_NOMBRE <- paste0("(?:[0-9]+|(?:cent\\s+)?(?:(?:quatre-vingts?|vingt|trente|quarante|cinquante|soixante|cent)\\s+et\\s+(?:une|un|onze)(?![A-Za-z\\x{00c0}-\\x{00ff}-])|",
                     "(?:", paste(.MOTS_NOMBRES, collapse = "|"), ")(?:-(?:et-)?(?:",
                     paste(.MOTS_NOMBRES, collapse = "|"), "))*))")

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
       champs = "non applicable volumes constants"),
  # Issue #111 : provenance directe par fonction, lue dans le champ fonction
  # de res$tests (grandeur "fonction <nom>" de grandeurs_moteur()). Les cinq
  # phrases qui nomment une seule fonction sont comparees a son nombre de
  # lignes ; celle qui en nomme cinq ("2 entrees chacune") a leur compte
  # commun, NA (donc ECART) s'ils different.
  list(id = "provenance : test_lm_complet() (index des fonctions)", methode = c("premium", "reserve1"),
       motif = paste0("test_lm_complet\\(\\) & LN & [^&]{0,160}?", N_, " entr\u00e9es issues d'un seul appel"),
       champs = "fonction test_lm_complet"),
  list(id = "provenance : test_lm_complet() (graphe H1)", methode = c("premium", "reserve1"),
       motif = paste0("test_lm_complet\\(\\) alimente ", N_, " entr\u00e9es de la table des tests"),
       champs = "fonction test_lm_complet"),
  list(id = "provenance : .shapiro_sur() (graphe H3-H4)", methode = c("premium", "reserve1"),
       motif = paste0("\\.shapiro_sur\\(\\) alimente ", N_, " entr\u00e9es"),
       champs = "fonction .shapiro_sur"),
  list(id = "provenance : test_lm_complet() (tableau des portees)", methode = c("premium", "reserve1"),
       motif = paste0("test_lm_complet\\(\\) \\(", N_, " entr\u00e9es\\)"),
       champs = "fonction test_lm_complet"),
  list(id = "provenance : .shapiro_sur() (tableau des portees)", methode = c("premium", "reserve1"),
       motif = paste0("\\.shapiro_sur\\(\\) \\(", N_, " entr\u00e9es\\)"),
       champs = "fonction .shapiro_sur"),
  list(id = "provenance : stat_dw() ... test_grubbs() (tableau des portees)", methode = c("premium", "reserve1"),
       motif = paste0("stat_dw\\(\\), test_runs\\(\\), stat_supF\\(\\), stat_cusum\\(\\) et test_grubbs\\(\\) \\(",
                      N_, " entr\u00e9es chacune"),
       champs = "fonctions z et u (compte commun)")
)

# Fonctions declinees sur z_t et sur u_t (phrase "2 entrees chacune" du
# tableau des portees) : grandeur derivee "fonctions z et u (compte commun)"
# de grandeurs_moteur().
FONCTIONS_Z_ET_U <- c("stat_dw", "test_runs", "stat_supF", "stat_cusum", "test_grubbs")

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
# Provenance par fonction (issue #111) : le champ fonction de chaque ligne de
# res$tests nomme la fonction du moteur qui en calcule la statistique ; une
# provenance DIRECTE ("test_lm_complet() alimente N entrees") est donc une
# phrase verifiee du registre DECOMPTES (grandeur "fonction <nom>" de
# grandeurs_moteur()). Restent exemptees les provenances INDIRECTES : une
# fonction appelee par la fonction qui calcule la statistique (profondeur 2,
# .fisher_combine()) ou un noeud du schema qui regroupe des lignes sans
# nommer de fonction.
MOTIF_PROVENANCE_INDIRECTE <- paste("provenance indirecte d'entrees (graphe d'appels du moteur) : le champ",
                                    "fonction de res$tests ne nomme que la fonction qui calcule la statistique",
                                    "de la ligne, pas les fonctions qu'elle appelle ni les regroupements du",
                                    "schema ; risque residuel : si le code change (la fonction alimente plus ou",
                                    "moins d'entrees) et que le document ne change pas, le decompte devenu faux",
                                    "n'est pas detecte")
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
  list(id = ".fisher_combine() (graphe Merz-Wuthrich)", contexte = "dessert 4 tests M1",
       motif = MOTIF_PROVENANCE_INDIRECTE),
  list(id = "noeud M3 correlations (graphe Merz-Wuthrich)", contexte = "\\(q4\\) M3 \\(2 entr\u00e9es\\)",
       motif = paste(MOTIF_PROVENANCE_INDIRECTE, "(sous-ensemble de la famille M3 rattache a un noeud du schema)"))
)

# Gardes de contexte des decomptes (constat 4 de la fin d'E0b, decision du
# mainteneur du 28/09/2026) : formulations "N lignes" qui donnent la
# dimension d'un tableau ou d'un fichier (format d'entree du lecteur,
# "un tableau de deux lignes", "un fichier de 3 lignes"), pas un decompte de
# la table des tests. Une garde s'applique a toute formulation "N lignes"
# (pas "entrees" ni "tests") dont le nombre suit immediatement l'un des mots
# du motif (texte normalise, casse ignoree), une fois le registre DECOMPTES
# et les exemptions nominatives appliques. A la difference d'une exemption
# nominative, une garde n'est pas ancree sur une phrase et ne perime pas :
# elle ne couvre aucune formulation tant que le document n'en porte pas.
# Chaque formulation gardee est rapportee (statut "exemptee", par = id).
# id ; avant : expression reguliere (perl) que doit terminer le texte qui
# precede le nombre ; motif : raison ecrite.
GARDES_DECOMPTES <- list(
  list(id = "garde : dimension d'un tableau ou d'un fichier",
       avant = "\\b(?:tableaux?|fichiers?|matrices?)\\s+(?:de|\\x{00e0})\\s+$",
       motif = paste("dimension d'un tableau ou d'un fichier (format d'entree), pas un decompte",
                     "de la table des tests ni de res$controles"))
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
         # #169 : la ligne du test de Pitman (p exacte par permutation, sous une
         # H0 d'echangeabilite hors modele reglementaire, attribuee quel que
         # soit pi_t) n'entre pas dans ces decomptes de la regle R7.
         "p exacte hors base r" = sum(pex & !base %in% "r" &
                                        !champ("fonction") %in% "usp_permutation_pente"),
         "p exacte hors base r retenue" = sum(pex & !base %in% "r" & grepl("^exacte", nat) &
                                                !champ("fonction") %in% "usp_permutation_pente"),
         "variante secondaire" = sum(champ("variante") %in% "secondaire"),
         "lignes du test des suites" = sum(startsWith(nom, "Test des suites") %in% TRUE),
         "base r hors suites" = sum(base %in% "r" & !startsWith(nom, "Test des suites") %in% TRUE),
         "base r hors suites Monte-Carlo" = sum(base %in% "r" & !startsWith(nom, "Test des suites") %in% TRUE &
                                                  grepl("^Monte-Carlo", nat)),
         "grandeur rivee" = sum(startsWith(det, "Grandeur rivee par l'estimation") %in% TRUE),
         "detail sans objet ici" = sum(grepl("CONTROLE SANS OBJET ICI", det, fixed = TRUE)),
         "non applicable volumes constants" =
           sum(startsWith(det, "volumes x_t constants a la tolerance relative") %in% TRUE))
  # Provenance par fonction (#111) : nombre de lignes par valeur du champ
  # fonction ; compte commun des FONCTIONS_Z_ET_U, NA s'ils different (une
  # annonce n'est jamais egale a NA : ECART).
  fon <- champ("fonction")
  for (f in unique(fon[!is.na(fon)])) g[paste("fonction", f)] <- sum(fon %in% f)
  n_zu <- vapply(FONCTIONS_Z_ET_U, function(f) sum(fon %in% f), numeric(1))
  g["fonctions z et u (compte commun)"] <- if (length(unique(n_zu)) == 1L) n_zu[[1]] else NA_real_
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
    rx <- vers_utf8(gsub(" ", "\\s+", a$motif, fixed = TRUE))
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
                                            statut = ifelse(!is.na(ann) & !is.na(mes) & ann == mes, "ok", "ECART"),
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
  m <- gregexpr(vers_utf8(RX_FORMULATION), texte, perl = TRUE)[[1]]
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
# dans l'etendue d'une occurrence du contexte d'une exemption, ou si une
# garde de contexte la couvre (GARDES_DECOMPTES, "N lignes" seulement), sinon
# "NON CLASSEE" (ecart). Renvoie une liste :
#   formulations  inventaire complete des colonnes statut et par (id de la
#                 phrase du registre ou de l'exemption) ;
#   perimees      data.frame (id, contexte) des exemptions qui n'exemptent
#                 aucune formulation (ecarts).
classer_formulations <- function(lignes, v, exemptions = EXEMPTES_DECOMPTES, gardes = GARDES_DECOMPTES) {
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
    m <- gregexpr(vers_utf8(gsub(" ", "\\s+", e$contexte, fixed = TRUE)), texte, perl = TRUE, ignore.case = TRUE)[[1]]
    if (m[1L] == -1L) next
    for (d in seq_along(m)) {
      k <- which(statut == "NON CLASSEE" & inv$pos >= m[d] & inv$pos <= m[d] + attr(m, "match.length")[d] - 1L)
      if (length(k)) { statut[k] <- "exemptee"; par[k] <- e$id; utilisee[j] <- TRUE }
    }
  }
  for (g in if (nrow(inv)) gardes) {
    k <- which(statut == "NON CLASSEE" & grepl("lignes$", inv$formulation) &
                 grepl(vers_utf8(g$avant), substring(texte, pmax(1L, inv$pos - 40L), inv$pos - 1L),
                       perl = TRUE, ignore.case = TRUE))
    statut[k] <- "exemptee"; par[k] <- g$id
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
# section : "MW" sous un intertitre (rangee qui commence par \multicolumn,
# RX_INTERTITRE, issue #121) qui contient "Merz", "USP" sous tout autre
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
# Intertitre d'un longtable : rangee qui COMMENCE par \multicolumn, filets
# eventuels en tete (issue #121). Une rangee qui porte \multicolumn hors de
# sa premiere cellule est une rangee de donnees.
RX_INTERTITRE <- "^\\s*(?:\\\\(?:midrule|toprule|bottomrule|hline)\\s*)*\\\\multicolumn(?![A-Za-z])"
FIN_RANGEE <- "\\\\\\\\\\*?(\\[[^]]*\\])?\\s*$"
cles_mc_index <- function(lignes) {
  lignes <- retirer_commentaires(lignes)
  deb <- grep(vers_utf8("\\textbf{Cl\u00e9 MC}"), lignes, fixed = TRUE)[1L]
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
    if (grepl(RX_INTERTITRE, rangee, perl = TRUE)) {
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
#  Rubrique 7 "Pertinence et puissance a faible T" (issue #114)
# ---------------------------------------------------------------------------

# Registre des fiches qui portent la rubrique 7 (decisions du mainteneur du
# 27/09/2026 sur #114, points 1 et 3) : fiches dont une ligne du moteur est de
# type "test" ou "procedure de decision" dans au moins un regime. Le moteur
# ne porte pas le lien ligne -> fiche (objet de l'issue #111) : ce registre
# l'ecrit, une entree par fiche. label : label nomme de la fiche (ligne qui
# suit \begin{fiche}{...}, docs/latex/CONVENTIONS.md) ; tests : champ test
# exact des lignes du moteur rattachees a la fiche ; hors_jeux : NULL, ou
# motif ecrit pour une fiche dont aucune ligne n'est de type test ou
# procedure sur les jeux executes par le script (le type n'y est atteint
# qu'a d'autres T) ; t_positif : pour une entree hors_jeux, la taille T du
# jeu synthetique (jeu_synthetique()) sur lequel la ligne doit etre de type
# test ou procedure (verification positive, issue #121). Le registre est
# confronte au moteur par verifier_registre_rubrique7() (jeux a T = 8) et
# verifier_hors_jeux_positifs() (jeux synthetiques).
MOTIF_COX_STUART_T8 <- paste("inoperant pour T <= 9 (regle R1, p_min = 0,125 a T = 8) : ligne de type test",
                             "au plus tot a T = 10 (p_min = 0,0625 < 0,10 sans ex aequo ; avec ex aequo,",
                             "m < n_p et la ligne peut rester inoperante), hors des jeux executes (T = 8)")
MOTIF_ANSCOMBE_T8 <- paste("ligne non applicable pour T < 20 : type test a partir de T = 20 seulement,",
                           "hors des jeux executes (T = 8)")
REGISTRE_RUBRIQUE7 <- list(
  # Methode lognormale
  list(label = "fiche:student-constante", tests = "Nullite de la constante (proportionnalite stricte)"),
  list(label = "fiche:tost-constante", tests = "Equivalence de la constante a zero (TOST)"),
  list(label = "fiche:student-pente", tests = "Test de Pitman sur la pente (lien positif pertes / volume)"),
  # fiche:fisher-global retiree (#169) : la ligne Fisher est un diagnostic permanent.
  list(label = "fiche:reset", tests = "RESET (forme fonctionnelle)"),
  list(label = "fiche:spearman", tests = c("Independance ratio S/P vs volume", "Correlation ratio S/P vs temps")),
  list(label = "fiche:mann-kendall", tests = "Tendance monotone du ratio S/P"),
  list(label = "fiche:cox-stuart", tests = "Tendance par signes du ratio S/P", hors_jeux = MOTIF_COX_STUART_T8,
       t_positif = 10L),
  list(label = "fiche:breusch-pagan-koenker",
       tests = "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)"),
  list(label = "fiche:breusch-pagan-1979",
       tests = "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)"),
  list(label = "fiche:white", tests = "Heteroscedasticite (forme quadratique)"),
  list(label = "fiche:goldfeld-quandt", tests = "Egalite des variances petits vs gros volumes"),
  list(label = "fiche:brown-forsythe", tests = "Homogeneite des dispersions (mediane)"),
  list(label = "fiche:smirnov", tests = "Egalite des lois petits vs gros volumes (2 ech.)"),
  list(label = "fiche:shapiro-wilk", tests = "Shapiro-Wilk sur residus standardises"),
  list(label = "fiche:shapiro-wilk-sans-royston",
       tests = "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)"),
  list(label = "fiche:shapiro-francia", tests = "Shapiro-Francia"),
  list(label = "fiche:anderson-darling", tests = "Anderson-Darling"),
  list(label = "fiche:cramer-von-mises", tests = "Cramer-von Mises"),
  list(label = "fiche:kolmogorov-smirnov", tests = "Kolmogorov-Smirnov contre N(0,1)"),
  list(label = "fiche:lilliefors", tests = "Lilliefors (KS a parametres estimes)"),
  list(label = "fiche:jarque-bera", tests = "Jarque-Bera"),
  list(label = "fiche:dagostino-asymetrie", tests = "Asymetrie (D'Agostino, T >= 8)"),
  list(label = "fiche:anscombe-glynn-aplatissement", tests = "Aplatissement (Anscombe-Glynn, T >= 20)",
       hors_jeux = MOTIF_ANSCOMBE_T8, t_positif = 20L),
  list(label = "fiche:durbin-watson", tests = "Autocorrelation d'ordre 1 (Durbin-Watson)"),
  list(label = "fiche:ljung-box", tests = c("Ljung-Box (retard 1)", "Ljung-Box (retard 2)", "Box-Pierce (retard 2)")),
  list(label = "fiche:suites-wald-wolfowitz", tests = "Test des suites (aleatoire des signes)"),
  list(label = "fiche:sup-f", tests = "Rupture de niveau (sup-F)"),
  list(label = "fiche:ols-cusum", tests = "Stabilite cumulee (OLS-CUSUM)"),
  list(label = "fiche:grubbs", tests = "Valeur aberrante isolee (Grubbs)"),
  list(label = "fiche:rosner-esd", tests = "Valeurs aberrantes multiples (ESD generalise)"),
  list(label = "fiche:durbin-watson-ratios-bruts", tests = "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts"),
  list(label = "fiche:ljung-box-ratios-bruts", tests = "Ljung-Box (retard 1) sur ratios bruts"),
  list(label = "fiche:suites-ratios-bruts", tests = "Test des suites sur ratios bruts"),
  list(label = "fiche:sup-f-ratios-bruts", tests = "Rupture de niveau (sup-F) sur ratios bruts"),
  list(label = "fiche:ols-cusum-ratios-bruts", tests = "Stabilite cumulee (OLS-CUSUM) sur ratios bruts"),
  list(label = "fiche:grubbs-ratios-bruts", tests = "Valeur aberrante isolee (Grubbs) sur ratios bruts"),
  # Methode Merz-Wuthrich
  list(label = "mw:m1", tests = "Absence de tendance des facteurs avec le cumul, a colonne donnee"),
  list(label = "mw:m1a", tests = "Nullite de l'ordonnee a l'origine, colonne par colonne"),
  list(label = "mw:m1b", tests = "Homogeneite de f_j entre annees de survenance"),
  list(label = "mw:m1c", tests = "Absence de courbure de la regression"),
  list(label = "mw:m1d", tests = "Stabilite du facteur selon la ponderation (famille alpha)"),
  list(label = "mw:m2bp", tests = "Heteroscedasticite residuelle vs cumul"),
  list(label = "mw:m2b", tests = "Adequation de l'exposant de variance, colonne par colonne"),
  list(label = "mw:m3cal", tests = "Effets d'annee calendaire (test de Mack)"),
  list(label = "mw:m3acc", tests = "Homogeneite des residus entre annees de survenance"),
  list(label = "mw:m3cor", tests = "Correlation entre annees de developpement adjacentes"),
  list(label = "mw:m3dw", tests = "Autocorrelation des residus (Durbin-Watson)"),
  list(label = "mw:m3runs", tests = "Test des suites sur les residus de Mack"),
  list(label = "mw:m4gr", tests = "Cellule aberrante du triangle (Grubbs)"),
  list(label = "mw:m4ros", tests = "Cellules aberrantes multiples (ESD generalise)"),
  list(label = "mw:m5sw", tests = "Shapiro-Wilk sur les residus de Mack"),
  list(label = "mw:m5li", tests = "Lilliefors sur les residus de Mack")
)
TYPES_RUBRIQUE7 <- c("test", "procedure de decision")

# Fiches du document et leur rubrique 7. Pour chaque environnement fiche
# (\begin{fiche} ... premier \end{fiche} qui suit ; commentaires retires) :
# label nomme (ligne qui suit \begin{fiche}{...} si elle porte \label{...},
# NA sinon), nombre de \Pertinence et de \Usage, ligne du premier
# \Pertinence et apres_usage (VRAI si chaque \Pertinence suit le dernier
# \Usage de la fiche). Renvoie un data.frame (debut, fin, label, n_pertinence,
# n_usage, ligne_pertinence, apres_usage), avec les attributs hors_fiche
# (lignes portant \Pertinence hors de tout environnement fiche, definition
# \newcommand exceptee) et non_terminee (lignes de \begin{fiche} sans
# \end{fiche} avant la fiche suivante).
RX_PERTINENCE <- "\\\\Pertinence(?![A-Za-z])"
RX_USAGE <- "\\\\Usage(?![A-Za-z])"
fiches_rubrique7 <- function(lignes) {
  l <- retirer_commentaires(lignes)
  deb <- grep("\\begin{fiche}", l, fixed = TRUE)
  fins <- grep("\\end{fiche}", l, fixed = TRUE)
  res <- data.frame(debut = integer(0), fin = integer(0), label = character(0), n_pertinence = integer(0),
                    n_usage = integer(0), ligne_pertinence = integer(0), apres_usage = logical(0),
                    stringsAsFactors = FALSE)
  non_term <- integer(0); couvertes <- logical(length(l))
  for (i in seq_along(deb)) {
    d <- deb[i]; f <- fins[fins > d][1L]
    suiv <- if (i < length(deb)) deb[i + 1L] else Inf
    if (is.na(f) || f > suiv) { non_term <- c(non_term, d); next }
    couvertes[d:f] <- TRUE
    lab <- if (d < length(l)) regmatches(l[d + 1L], regexec("^\\s*\\\\label\\{([^}]+)\\}", l[d + 1L]))[[1]] else character(0)
    bloc <- l[d:f]; txt <- paste(bloc, collapse = "\n")
    debuts <- cumsum(c(1L, nchar(bloc) + 1L))[seq_along(bloc)]
    pp <- gregexpr(RX_PERTINENCE, txt, perl = TRUE)[[1]]; pp <- pp[pp > 0L]
    pu <- gregexpr(RX_USAGE, txt, perl = TRUE)[[1]]; pu <- pu[pu > 0L]
    res <- rbind(res, data.frame(debut = d, fin = f, label = if (length(lab) == 2L) lab[2L] else NA_character_,
                                 n_pertinence = length(pp), n_usage = length(pu),
                                 ligne_pertinence = if (length(pp)) d - 1L + findInterval(pp[1L], debuts) else NA_integer_,
                                 apres_usage = length(pp) > 0L && length(pu) > 0L && all(pp > max(pu)),
                                 stringsAsFactors = FALSE))
  }
  hors <- which(grepl(RX_PERTINENCE, l, perl = TRUE) & !couvertes &
                  !grepl("\\\\(re)?newcommand\\{?\\\\Pertinence", l, perl = TRUE))
  attr(res, "hors_fiche") <- hors
  attr(res, "non_terminee") <- non_term
  res
}

# Ecarts de la rubrique 7 : fiches (sortie de fiches_rubrique7()) confrontees
# a l'ensemble attendu des labels (attendus : labels du registre). Renvoie un
# data.frame (ligne, label, motif), un ecart par ligne.
verifier_rubrique7 <- function(fiches, attendus) {
  e <- list()
  ajoute <- function(ligne, label, motif)
    e[[length(e) + 1L]] <<- data.frame(ligne = as.integer(ligne), label = label, motif = motif, stringsAsFactors = FALSE)
  for (d in attr(fiches, "non_terminee")) ajoute(d, NA_character_, "environnement fiche non termine avant la fiche suivante")
  for (h in attr(fiches, "hors_fiche")) ajoute(h, NA_character_, "rubrique 7 hors de tout environnement fiche")
  for (i in seq_len(nrow(fiches))) {
    fi <- fiches[i, ]
    if (fi$n_pertinence == 0L) next
    if (is.na(fi$label)) ajoute(fi$ligne_pertinence, NA_character_,
                                "rubrique 7 dans une fiche sans label nomme sur la ligne qui suit \\begin{fiche}")
    if (fi$n_pertinence > 1L) ajoute(fi$ligne_pertinence, fi$label,
                                     sprintf("rubrique 7 presente %d fois dans la fiche", fi$n_pertinence))
    if (!fi$apres_usage) ajoute(fi$ligne_pertinence, fi$label,
                                if (fi$n_usage == 0L) "rubrique 7 dans une fiche sans \\Usage" else
                                  "rubrique 7 avant \\Usage (rubrique 6)")
    if (!is.na(fi$label) && !fi$label %in% attendus)
      ajoute(fi$ligne_pertinence, fi$label,
             "rubrique 7 sur une fiche hors du registre REGISTRE_RUBRIQUE7 (aucune ligne de type test ou procedure de decision)")
  }
  for (a in attendus) {
    k <- which(fiches$label %in% a)
    if (!length(k)) ajoute(NA_integer_, a, "label du registre REGISTRE_RUBRIQUE7 introuvable dans le document")
    else if (all(fiches$n_pertinence[k] == 0L)) ajoute(fiches$debut[k[1L]], a, "rubrique 7 absente de la fiche")
  }
  if (!length(e)) return(data.frame(ligne = integer(0), label = character(0), motif = character(0),
                                    stringsAsFactors = FALSE))
  do.call(rbind, e)
}

# Registre confronte au moteur. lignes_moteur : data.frame (test, type) des
# lignes de res$tests de toutes les executions (jeux et methodes). Ecarts :
# ligne de type test ou procedure de decision rattachee a aucune entree (une
# ligne nouvelle sans fiche a rubrique 7 au registre) ou a plusieurs ; nom
# du registre absent de toutes les executions (registre perime) ; entree
# sans hors_jeux dont aucune ligne n'est de type test ou procedure ; entree
# hors_jeux dont une ligne l'est (declaration perimee). Renvoie un
# data.frame (label, test, motif).
verifier_registre_rubrique7 <- function(lignes_moteur, registre = REGISTRE_RUBRIQUE7) {
  e <- list()
  ajoute <- function(label, test, motif)
    e[[length(e) + 1L]] <<- data.frame(label = label, test = test, motif = motif, stringsAsFactors = FALSE)
  noms_reg <- unlist(lapply(registre, `[[`, "tests"))
  labels_reg <- rep(vapply(registre, `[[`, character(1), "label"), lengths(lapply(registre, `[[`, "tests")))
  tp <- unique(lignes_moteur$test[lignes_moteur$type %in% TYPES_RUBRIQUE7])
  for (n in tp) {
    k <- which(noms_reg == n)
    if (!length(k)) ajoute(NA_character_, n, "ligne de type test ou procedure de decision rattachee a aucune fiche du registre")
    else if (length(k) > 1L) ajoute(paste(labels_reg[k], collapse = ", "), n, "ligne rattachee a plusieurs fiches du registre")
  }
  for (r in registre) {
    abs <- setdiff(r$tests, lignes_moteur$test)
    for (n in abs) ajoute(r$label, n, "nom de ligne du registre produit par aucune execution du moteur")
    actif <- any(r$tests %in% tp)
    if (is.null(r$hors_jeux) && !actif && !length(abs))
      ajoute(r$label, paste(r$tests, collapse = " ; "), "aucune ligne de type test ou procedure de decision sur les jeux executes")
    if (!is.null(r$hors_jeux) && actif)
      ajoute(r$label, paste(intersect(r$tests, tp), collapse = " ; "),
             "declaration hors_jeux perimee : ligne de type test ou procedure sur les jeux executes")
  }
  if (!length(e)) return(data.frame(label = character(0), test = character(0), motif = character(0),
                                    stringsAsFactors = FALSE))
  do.call(rbind, e)
}

# Verification positive des declarations hors_jeux (issue #121).
# lignes_synth : data.frame (T, test, type) des lignes de res$tests des
# executions sur les jeux synthetiques (jeu_synthetique()). Ecarts : entree
# hors_jeux sans t_positif ; t_positif sans hors_jeux ; entree hors_jeux
# dont aucune ligne n'est de type test ou procedure de decision sur le jeu
# synthetique de taille t_positif (ou dont ce jeu n'a pas ete execute).
# Renvoie un data.frame (label, test, motif).
verifier_hors_jeux_positifs <- function(lignes_synth, registre = REGISTRE_RUBRIQUE7) {
  e <- list()
  ajoute <- function(label, test, motif)
    e[[length(e) + 1L]] <<- data.frame(label = label, test = test, motif = motif, stringsAsFactors = FALSE)
  for (r in registre) {
    tst <- paste(r$tests, collapse = " ; ")
    if (is.null(r$hors_jeux)) {
      if (!is.null(r$t_positif)) ajoute(r$label, tst, "t_positif declare sans hors_jeux")
      next
    }
    if (is.null(r$t_positif)) { ajoute(r$label, tst, "declaration hors_jeux sans t_positif (aucune verification positive)"); next }
    sur_t <- lignes_synth[lignes_synth$T %in% r$t_positif, , drop = FALSE]
    if (!nrow(sur_t))
      ajoute(r$label, tst, sprintf("declaration hors_jeux non verifiee : jeu synthetique T = %d non execute", r$t_positif))
    else if (!any(sur_t$test %in% r$tests & sur_t$type %in% TYPES_RUBRIQUE7))
      ajoute(r$label, tst, sprintf(paste("declaration hors_jeux infirmee : aucune ligne de type test ou procedure",
                                         "de decision sur le jeu synthetique T = %d"), r$t_positif))
  }
  if (!length(e)) return(data.frame(label = character(0), test = character(0), motif = character(0),
                                    stringsAsFactors = FALSE))
  do.call(rbind, e)
}

# Jeu lognormal synthetique de taille T (issue #121), deterministe (aucun
# tirage) : volumes x_t = 100 + 10 (t - 1) croissants, pertes
# y_t = x_t exp(0,1 sin(1,7 t) - 0,3). Ratios y_t / x_t deux a deux
# distincts, donc sans difference nulle pour Cox-Stuart (m = n_p). Sert a la
# seule verification positive des declarations hors_jeux.
jeu_synthetique <- function(T) {
  t <- seq_len(T); x <- 100 + 10 * (t - 1)
  list(x = x, y = x * exp(0.1 * sin(1.7 * t) - 0.3))
}

# Tableau de tracabilite de la rubrique 7 (\label{tab:tracabilite-puissance},
# puis premier \end{longtable}) : une rangee par fiche, dont la premiere
# cellule se termine par (\ref{label}). Seules les rangees apres
# \endlastfoot sont lues ; les intertitres (rangees qui COMMENCENT par
# \multicolumn, filets eventuels en tete) et les filets sont ignores ; une
# rangee qui porte \multicolumn hors de sa premiere cellule est lue comme
# une rangee ordinaire, et signalee non reconnue si sa premiere cellule n'a
# pas la forme attendue (issue #121) ; fin de rangee : FIN_RANGEE. Renvoie NULL si le tableau est
# introuvable, sinon un data.frame (ligne, label), avec les attributs
# non_reconnues (lignes des rangees dont la premiere cellule n'a pas cette
# forme) et non_terminee (ligne de debut d'une rangee non terminee, NA sinon).
RX_PREMIERE_CELLULE <- "\\(\\\\ref\\{([^}]+)\\}\\)\\s*$"
lignes_tracabilite <- function(lignes) {
  l <- retirer_commentaires(lignes)
  deb <- grep("\\label{tab:tracabilite-puissance}", l, fixed = TRUE)[1L]
  if (is.na(deb)) return(NULL)
  fin <- grep("\\end{longtable}", l, fixed = TRUE); fin <- fin[fin > deb][1L]
  pied <- grep("\\endlastfoot", l, fixed = TRUE); pied <- pied[pied > deb & pied < fin][1L]
  if (is.na(fin) || is.na(pied)) return(NULL)
  res <- data.frame(ligne = integer(0), label = character(0), stringsAsFactors = FALSE)
  non_rec <- integer(0); tampon <- character(0); l0 <- NA_integer_
  for (k in seq.int(pied + 1L, fin - 1L)) {
    x <- l[k]
    if (!length(tampon) && grepl("^\\s*(\\\\(midrule|toprule|bottomrule))?\\s*$", x)) next
    if (!length(tampon)) l0 <- k
    tampon <- c(tampon, x)
    if (!grepl(FIN_RANGEE, x, perl = TRUE)) next
    rangee <- paste(tampon, collapse = "\n"); tampon <- character(0)
    if (grepl(RX_INTERTITRE, rangee, perl = TRUE)) next
    esp <- regexpr("(?<!\\\\)&", rangee, perl = TRUE)
    cell <- if (esp > 0L) substr(rangee, 1L, esp - 1L) else rangee
    m <- regmatches(cell, regexec(RX_PREMIERE_CELLULE, cell, perl = TRUE))[[1]]
    if (esp > 0L && length(m) == 2L) res <- rbind(res, data.frame(ligne = l0, label = m[2L], stringsAsFactors = FALSE))
    else non_rec <- c(non_rec, l0)
  }
  attr(res, "non_reconnues") <- non_rec
  attr(res, "non_terminee") <- if (length(tampon) && any(nzchar(trimws(tampon)))) l0 else NA_integer_
  res
}

# Ecarts du tableau de tracabilite (rangees : sortie de lignes_tracabilite() ;
# labels_r7 : labels des fiches portant la rubrique 7 dans le document).
# Renvoie un data.frame (ligne, label, motif).
verifier_tracabilite <- function(rangees, labels_r7) {
  e <- list()
  ajoute <- function(ligne, label, motif)
    e[[length(e) + 1L]] <<- data.frame(ligne = as.integer(ligne), label = label, motif = motif, stringsAsFactors = FALSE)
  for (k in attr(rangees, "non_reconnues"))
    ajoute(k, NA_character_, "rangee sans premiere cellule de la forme Nom (\\ref{label})")
  nt <- attr(rangees, "non_terminee")
  if (!is.null(nt) && !is.na(nt)) ajoute(nt, NA_character_, "rangee non terminee avant \\end{longtable}")
  for (lab in unique(rangees$label[duplicated(rangees$label)]))
    ajoute(rangees$ligne[rangees$label == lab][2L], lab,
           sprintf("fiche citee par %d rangees (une attendue)", sum(rangees$label == lab)))
  for (i in which(!rangees$label %in% labels_r7 & !duplicated(rangees$label)))
    ajoute(rangees$ligne[i], rangees$label[i], "rangee pour une fiche sans rubrique 7")
  for (lab in setdiff(labels_r7, rangees$label))
    ajoute(NA_integer_, lab, "fiche a rubrique 7 sans rangee dans le tableau")
  if (!length(e)) return(data.frame(ligne = integer(0), label = character(0), motif = character(0),
                                    stringsAsFactors = FALSE))
  do.call(rbind, e)
}

# Chemins de fichier cites par \code{} dans la sous-section du tableau de
# tracabilite (de \label{tab:tracabilite-puissance} au premier
# \end{longtable} qui suit) : contenu sans blanc ni parenthese qui contient
# une barre oblique ou se termine par une extension de fichier. Un chemin
# coupe en deux \code{} pour la mise en page (\code{docs/tableaux/}\newline
# \code{fichier.md}) est recolle : le premier se termine par / et n'est
# separe du second que par des blancs ou une commande de coupure. Les
# citations de fonction (avec parentheses) relevent de la section 1.
# Renvoie NULL si la sous-section est introuvable, sinon un data.frame
# (ligne, chemin).
RX_CHEMIN <- "^[A-Za-z0-9_.*-]+(/[A-Za-z0-9_.*-]*)*$"
chemins_tracabilite <- function(lignes) {
  l <- retirer_commentaires(lignes)
  deb <- grep("\\label{tab:tracabilite-puissance}", l, fixed = TRUE)[1L]
  if (is.na(deb)) return(NULL)
  fin <- grep("\\end{longtable}", l, fixed = TRUE); fin <- fin[fin > deb][1L]
  if (is.na(fin)) return(NULL)
  bloc <- l[deb:fin]; txt <- paste(bloc, collapse = "\n")
  debuts <- cumsum(c(1L, nchar(bloc) + 1L))[seq_along(bloc)]
  m <- gregexpr("\\\\code\\{((?:[^{}\\\\]|\\\\.)*)\\}", txt, perl = TRUE)[[1]]
  vide <- data.frame(ligne = integer(0), chemin = character(0), stringsAsFactors = FALSE)
  if (m[1L] == -1L) return(vide)
  lg <- attr(m, "match.length")
  cont <- desechapper(substring(txt, m + 6L, m + lg - 2L))
  res <- list(); fin_prec <- -1L
  for (i in seq_along(m)) {
    entre <- if (fin_prec > 0L) substring(txt, fin_prec, m[i] - 1L) else NA_character_
    n <- length(res)
    if (n && endsWith(res[[n]]$chemin, "/") && !is.na(entre) &&
        grepl("^(\\s|\\\\\\\\|\\\\allowbreak|\\\\-|\\\\linebreak|\\\\newline)*$", entre))
      res[[n]]$chemin <- paste0(res[[n]]$chemin, cont[i])
    else res[[n + 1L]] <- list(ligne = deb - 1L + findInterval(m[i], debuts), chemin = cont[i])
    fin_prec <- m[i] + lg[i]
  }
  ch <- vapply(res, `[[`, character(1), "chemin")
  ok <- grepl(RX_CHEMIN, ch) & (grepl("/", ch, fixed = TRUE) | grepl("\\.(R|md|csv|rds|tex|pdf)$", ch))
  if (!any(ok)) return(vide)
  data.frame(ligne = vapply(res[ok], function(r) as.integer(r$ligne), integer(1)), chemin = ch[ok],
             stringsAsFactors = FALSE)
}

# Chemins cites inexistants dans le depot (racine : racine du depot ; un
# chemin a joker * doit designer au moins un fichier). Renvoie le
# sous-ensemble (ligne, chemin) des chemins introuvables.
verifier_chemins <- function(chemins, racine) {
  existe <- vapply(chemins$chemin, function(p) {
    f <- file.path(racine, p)
    if (grepl("*", p, fixed = TRUE)) length(Sys.glob(f)) > 0L else file.exists(f)
  }, logical(1), USE.NAMES = FALSE)
  chemins[!existe, , drop = FALSE]
}

# Jeu J2 (delta estime interieur, section sec:verif du document) : vecteurs
# xi, yi lus dans tests/unitaires/test_controles_numeriques.R, comme le fait
# tests/taux_franchissement_reperes.R, pour que les deux scripts partagent
# une seule source du jeu.
lire_jeu_j2 <- function(racine) {
  f <- file.path(racine, "tests", "unitaires", "test_controles_numeriques.R")
  l <- readLines(f, warn = FALSE)
  env <- new.env()
  for (v in c("xi", "yi")) {
    li <- grep(sprintf("^%s <- c\\(", v), l, value = TRUE)
    if (length(li) != 1L) stop("J2 : ligne '", v, " <- c(' introuvable ou multiple dans ", f, call. = FALSE)
    eval(parse(text = li), envir = env)
  }
  list(x = env$xi, y = env$yi)
}

# ---------------------------------------------------------------------------
#  Constantes et champs cites (issue #160)
# ---------------------------------------------------------------------------

# Nom de constante : majuscules et chiffres, au moins un souligne
# (TOL_DELTA_BORD, B_MIN_USAGE), point initial admis pour une constante
# interne (.MW_LIGNES_RESIDUS). Un \code{} dont le texte desechappe est un
# tel nom, eventuellement suivi d'un chemin $champ ou d'un indice [...], cite
# la constante. Un nom coupe en deux \code{} est recolle par
# extraire_codes() ; un fragment termine par _ qui reste seul n'est pas juge
# comme constante (NON CLASSE, voir classer_majuscules()).
MOTIF_CONSTANTE <- "^\\.?[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+$"

# Objets en majuscules SANS souligne controles comme des constantes (objets
# nommes par le document : table reglementaire SEGMENTS de R/engine.R, cas et
# liste des cas instables de tests/outils_tests.R).
CONSTANTES_SANS_SOULIGNE <- c("SEGMENTS", "CAS", "INSTABLES")

# Identifiants sans souligne commencant par une majuscule (en majuscules :
# OK, DW ; ou en casse mixte : CoxStuart, Inf) HORS du controle, par liste
# fermee : chaque categorie porte ses noms et son motif. Tout autre
# identifiant sans souligne commencant par une majuscule, qui n'est ni dans
# CONSTANTES_SANS_SOULIGNE, ni une cle d'un catalogue Monte-Carlo
# (USP_CATALOGUE_MC, MW_CATALOGUE_MC : DW, BP, CoxStuart, Grubbs...), ni un
# argument de run_engine() (B, T), est NON CLASSE, et c'est un ecart. Un nom
# de la liste qui n'est plus cite par le document est une entree PERIMEE
# (ecart), pour que la liste ne perime pas en silence.
MAJUSCULES_HORS_CONTROLE <- list(
  list(categorie = "valeur de verdict", noms = c("OK", "ALERTE", "ECHEC", "INFO"),
       motif = "valeur du champ verdict d'une ligne de la table des tests, pas un objet du code"),
  list(categorie = "litteral R", noms = c("NA", "NULL", "TRUE", "FALSE", "Inf", "NaN"),
       motif = "constante du langage R"),
  list(categorie = "marqueur de valeur manquante", noms = c("NAN", "ND", "NR", "NONE", "NIL", "NC"),
       motif = paste("marqueur de la liste fermee des valeurs manquantes du lecteur, ecrite dans une",
                     "expression reguliere de R/engine.R, pas une constante")),
  list(categorie = "notation ou exemple du texte", noms = c("DESCRIPTION", "S1", "O", "C", "LoB12", "ChainLadder"),
       motif = paste("fichier DESCRIPTION, exemple de saisie (S1, LoB12, lettre O), locale C ou paquet R",
                     "(ChainLadder), pas un objet du code"))
)

# Racines de chemin de champ hors du controle : objets qui ne sont pas des
# resultats du moteur. Une racine de la liste qui n'est plus citee est une
# entree PERIMEE (ecart).
RACINES_EXEMPTEES <- c(.Machine = "objet de R de base")

# Champs cites par le document et ABSENTS des objets run_engine() construits
# par le script (J1, volumes constants, J2, triangle ; absence mesuree), par
# liste fermee : chacun n'est admis que s'il reste pose par R/engine.R
# (champs_poses()). Hors de cette liste, un segment absent des objets
# construits est INTROUVABLE (ecart), meme s'il est pose ailleurs dans le
# moteur sous le meme nom (audit de #160, mutant A : erreur_sigma retire de
# res$ajustement, encore pose par usp_condition_premier_ordre()). Une entree
# est PERIMEE (ecart) si elle n'est plus citee, si elle est retrouvee dans
# les objets construits ou si R/engine.R ne la pose plus.
MOTIF_REGIME <- "champ de la liste rendue par usp_regime(), drapeaux de regime non restitues sous ce nom dans res"
MOTIF_DEGENERESCENCE_MW <- paste("champ de la liste rendue par mw_extrapolation_sigma2() (degenerescence des",
                                 "colonnes J-3 et J-2), non restitue sous ce nom dans les objets construits")
CHAMPS_HORS_OBJETS <- c(
  angle = "champ de la liste rendue par .ligne_annees() (premiere ligne lue comme ligne d'annees), objet intermediaire du lecteur",
  cause = "champ de la liste rendue par .ligne_annees() (premiere ligne lue comme ligne d'annees), objet intermediaire du lecteur",
  volumes_constants = MOTIF_REGIME, pi_constant = MOTIF_REGIME, pi_constant_exact = MOTIF_REGIME,
  delta_dans_bande = MOTIF_REGIME, volumes_dans_bande = MOTIF_REGIME,
  colonne = MOTIF_DEGENERESCENCE_MW, nb_facteurs = MOTIF_DEGENERESCENCE_MW, ecart_relatif = MOTIF_DEGENERESCENCE_MW,
  f_colonne = MOTIF_DEGENERESCENCE_MW, degeneree = MOTIF_DEGENERESCENCE_MW, degeneree_Jm3 = MOTIF_DEGENERESCENCE_MW,
  degeneree_Jm2 = MOTIF_DEGENERESCENCE_MW, nb_facteurs_Jm2 = MOTIF_DEGENERESCENCE_MW,
  ecart_relatif_Jm2 = MOTIF_DEGENERESCENCE_MW, f_colonne_Jm2 = MOTIF_DEGENERESCENCE_MW,
  erreur_r = paste("chemin de refus : validation$erreur_r, pose par .engine_calcul_protege() quand un calcul",
                   "leve une erreur R, absent d'un resultat ok = TRUE"),
  influence_motif = paste("chemin non exerce par les jeux : plots_data$influence_motif, pose par",
                          "engine_plots_data() seulement si un residu standardise ou une distance de Cook",
                          "n'est pas fini")
)

# Citations d'identifiants en majuscules : contenus de \code{} dont le texte
# desechappe est un identifiant en majuscules (chiffres et soulignes admis,
# point initial admis, joker * final admis : MOTIF_MC_*) ou un identifiant
# SANS souligne commencant par une majuscule, en casse mixte (CoxStuart,
# Inf ; audit de #160, C4 : cles Monte-Carlo citees hors de l'index),
# eventuellement suivi d'un chemin $champ ou d'un indice [...]. Les \code{}
# qui contiennent un blanc, un point, une barre oblique (N/A, C.UTF-8,
# R/engine.R), ou une minuscule et un souligne (B_effectif, champ) ne sont pas
# des identifiants en majuscules.
citations_majuscules <- function(codes) {
  txt <- desechapper(codes$brut)
  m <- regmatches(txt, regexec("^(\\.?[A-Z][A-Z0-9_]*\\*?|[A-Z][A-Za-z0-9]*)(?:\\$.*|\\[.*)?$", txt, perl = TRUE))
  ok <- lengths(m) == 2L
  data.frame(ligne = codes$ligne[ok], citation = txt[ok], nom = vapply(m[ok], `[`, character(1), 2L),
             stringsAsFactors = FALSE)
}

# Constantes definies dans des sources R, par lecture du texte (sans les
# executer) : affectations de premier niveau (debut de ligne) d'un nom en
# majuscules, point initial admis. fichier : chemin relatif a la racine du depot.
definitions_constantes <- function(fichiers) {
  res <- data.frame(nom = character(0), fichier = character(0), stringsAsFactors = FALSE)
  for (f in fichiers) {
    l <- readLines(f, warn = FALSE, encoding = "UTF-8")
    m <- regmatches(l, regexec("^(\\.?[A-Z][A-Z0-9_]*)\\s*(?:<-|=)", l, perl = TRUE))
    m <- m[lengths(m) == 2L]
    if (length(m))
      res <- rbind(res, data.frame(nom = vapply(m, `[`, character(1), 2L),
                                   fichier = sub("^(\\.\\.?/)+", "", f), stringsAsFactors = FALSE))
  }
  unique(res)
}

# Classe les citations de citations_majuscules(). constantes : sortie de
# definitions_constantes() ; cles : cles des catalogues Monte-Carlo ;
# arguments : noms des arguments de run_engine(). Ajoute categorie, statut
# ("verifie", "hors controle", "INTROUVABLE", "NON CLASSE") et ou (fichier
# de definition, catalogue, ou motif de la liste fermee).
classer_majuscules <- function(cit, constantes, cles = character(0), arguments = character(0),
                               hors = MAJUSCULES_HORS_CONTROLE, sans_souligne = CONSTANTES_SANS_SOULIGNE) {
  hors_noms <- unlist(lapply(hors, `[[`, "noms"))
  hors_cat <- rep(vapply(hors, `[[`, character(1), "categorie"), lengths(lapply(hors, `[[`, "noms")))
  fichiers_de <- function(n) paste(unique(constantes$fichier[constantes$nom %in% n]), collapse = ", ")
  un <- function(n) {
    if (grepl("\\*$", n)) {
      t <- grep(utils::glob2rx(n), constantes$nom, value = TRUE)
      return(c("constante (joker)", if (length(t)) "verifie" else "INTROUVABLE", fichiers_de(t)))
    }
    if (grepl("_$", n)) return(c("fragment non recolle", "NON CLASSE", ""))
    if (grepl(MOTIF_CONSTANTE, n, perl = TRUE) || n %in% sans_souligne)
      return(c("constante", if (n %in% constantes$nom) "verifie" else "INTROUVABLE", fichiers_de(n)))
    if (n %in% hors_noms) return(c(hors_cat[match(n, hors_noms)], "hors controle", ""))
    if (n %in% cles) return(c("cle de catalogue Monte-Carlo", "verifie", ""))
    if (n %in% arguments) return(c("argument de run_engine()", "verifie", ""))
    c("identifiant sans souligne", "NON CLASSE", "")
  }
  r <- if (nrow(cit)) do.call(rbind, lapply(cit$nom, un)) else matrix(character(0), 0L, 3L)
  cit$categorie <- r[, 1L]; cit$statut <- r[, 2L]; cit$ou <- r[, 3L]
  cit
}

# Noms de tous les elements nommes d'un objet, a toute profondeur (listes,
# data.frames : noms de colonnes ; classes retirees).
noms_recursifs <- function(x) {
  if (!is.list(x)) return(character(0))
  n <- names(x)
  unique(c(n[!is.na(n) & nzchar(n)], unlist(lapply(unclass(x), noms_recursifs), use.names = FALSE)))
}

# Noms de champs poses par un source R (par analyse syntaxique, sans
# l'executer) : noms des arguments de list(), c(), data.frame() et
# structure(), et champs affectes par x$nom <- ... ou x[["nom"]] <- ...
# (a toute profondeur du membre gauche). Les arguments formels des fonctions
# (volumes_constants = FALSE) n'en sont pas.
champs_poses <- function(fichier) {
  acc <- character(0)
  # Argument vide (x[, 1]) : compare a quote(expr = ) sans etre affecte, une
  # variable qui le contiendrait etant lue comme un argument manquant.
  gauche <- function(e) {
    if (!is.call(e)) return(invisible())
    f <- if (is.name(e[[1L]])) as.character(e[[1L]]) else ""
    if (f == "$" && length(e) == 3L) acc <<- c(acc, as.character(e[[3L]]))
    if (f == "[[" && length(e) >= 3L && is.character(e[[3L]])) acc <<- c(acc, e[[3L]])
    if (length(e) >= 2L && !identical(e[[2L]], quote(expr = ))) gauche(e[[2L]])
  }
  marcher <- function(e) {
    if (is.call(e)) {
      f <- if (is.name(e[[1L]])) as.character(e[[1L]]) else ""
      if (f %in% c("list", "c", "data.frame", "structure") && !is.null(names(e)))
        acc <<- c(acc, names(e)[-1L])
      if (f %in% c("<-", "=", "<<-") && length(e) == 3L) gauche(e[[2L]])
      for (i in seq_along(e)) if (!identical(e[[i]], quote(expr = ))) marcher(e[[i]])
    } else if (is.pairlist(e)) {
      for (i in seq_along(e)) if (!identical(e[[i]], quote(expr = ))) marcher(e[[i]])
    }
  }
  for (e in parse(fichier, keep.source = FALSE, encoding = "UTF-8")) marcher(e)
  unique(acc[!is.na(acc) & nzchar(acc)])
}

# Chemins de champs cites : dans chaque \code{} qui contient $ (texte
# desechappe), chaque chemin racine$a$b (racine facultative : \code{\$ok},
# \code{\$metadata\$T} ; racine appel de fonction admise : usp_noyau()$obj) ;
# une enumeration "$a \ $b \ $c" donne un chemin par champ. Une ligne par
# segment : ligne, chemin, racine ("" si absente), segment.
chemins_champs <- function(codes) {
  txt <- desechapper(codes$brut)
  rx <- "((?:[A-Za-z.][A-Za-z0-9._]*(?:\\(\\))?)?)((?:\\$[A-Za-z.][A-Za-z0-9._]*)+)"
  res <- list()
  for (i in which(grepl("$", txt, fixed = TRUE))) {
    for (ch in regmatches(txt[i], gregexpr(rx, txt[i], perl = TRUE))[[1]]) {
      racine <- sub("\\$.*$", "", ch)
      segs <- strsplit(substring(ch, nchar(racine) + 2L), "$", fixed = TRUE)[[1]]
      res[[length(res) + 1L]] <- data.frame(ligne = codes$ligne[i], chemin = ch, racine = racine,
                                            segment = segs, stringsAsFactors = FALSE)
    }
  }
  if (!length(res)) return(data.frame(ligne = integer(0), chemin = character(0), racine = character(0),
                                      segment = character(0), stringsAsFactors = FALSE))
  do.call(rbind, res)
}

# Classe les segments de chemins_champs(). noms_objets : noms_recursifs() des
# objets run_engine() construits par le script ; poses : champs_poses() de
# R/engine.R ; objets_constantes : liste nommee des constantes du moteur
# (environnement charge). Statut par segment :
#   "racine exemptee"         racine de RACINES_EXEMPTEES ;
#   "cle d'une constante"     racine constante chargee (USP_CATALOGUE_MC$CoxStuart) :
#                             le segment doit etre un nom de la constante
#                             (sinon INTROUVABLE) ; la racine est jugee par le
#                             controle des constantes ;
#   "racine non jugee"        autre racine commencant par une majuscule
#                             (COUL$trait, CAS$x hors du moteur) : le segment
#                             n'est pas juge, la racine l'est par le controle
#                             des identifiants (NON CLASSE, ou constante
#                             definie hors du moteur) ;
#   "objet run_engine()"      nom d'un element d'au moins un objet construit ;
#   "hors objets (liste fermee)"  absent des objets construits, nom de
#                             CHAMPS_HORS_OBJETS encore pose par R/engine.R ;
#   "INTROUVABLE"             sinon (absent des objets construits et hors de
#                             la liste, ou de la liste mais plus pose).
classer_champs <- function(ch, noms_objets, poses, objets_constantes = list(),
                           racines = RACINES_EXEMPTEES, hors_objets = CHAMPS_HORS_OBJETS) {
  statut <- vapply(seq_len(nrow(ch)), function(i) {
    r <- ch$racine[i]; s <- ch$segment[i]
    if (r %in% names(racines)) return("racine exemptee")
    if (r %in% names(objets_constantes))
      return(if (s %in% noms_recursifs(objets_constantes[[r]])) "cle d'une constante" else "INTROUVABLE")
    if (grepl("^\\.?[A-Z]", r)) return("racine non jugee")
    if (s %in% noms_objets) return("objet run_engine()")
    if (s %in% names(hors_objets) && s %in% poses) return("hors objets (liste fermee)")
    "INTROUVABLE"
  }, character(1))
  ch$statut <- statut
  ch
}

# Juge les constantes et les champs cites par le document (controle 6).
# tex : lignes du document ; constantes : definitions_constantes() ;
# objets : liste des resultats run_engine() ; poses : champs_poses() de
# R/engine.R ; env : moteur charge (catalogues, run_engine(), constantes).
# Renvoie une liste : maj (citations classees), champs (segments classes),
# ex_const et ex_champs (sorties d'appliquer_exemptions() sur les citations
# INTROUVABLE), non_classes (citations NON CLASSE), perimees_listes
# (entrees perimees des listes fermees, perimees_listes()).
verifier_constantes_champs <- function(tex, constantes, objets, poses, env, exemptions = EXEMPTES_CODE,
                                       hors = MAJUSCULES_HORS_CONTROLE, sans_souligne = CONSTANTES_SANS_SOULIGNE,
                                       racines = RACINES_EXEMPTEES, hors_objets = CHAMPS_HORS_OBJETS) {
  codes <- extraire_codes(tex)
  cles <- c(names(env$USP_CATALOGUE_MC), names(env$MW_CATALOGUE_MC))
  args <- if (is.function(env$run_engine)) names(formals(env$run_engine)) else character(0)
  maj <- classer_majuscules(citations_majuscules(codes), constantes, cles, args, hors, sans_souligne)
  noms_const <- intersect(unique(constantes$nom), ls(env, all.names = TRUE))
  noms_objets <- unique(unlist(lapply(objets, noms_recursifs)))
  ch <- classer_champs(chemins_champs(codes), noms_objets, poses, mget(noms_const, envir = env),
                       racines, hors_objets)
  ic <- maj[maj$statut == "INTROUVABLE", c("ligne", "nom"), drop = FALSE]
  ex_const <- appliquer_exemptions(ic, setNames(rep("INTROUVABLE", nrow(ic)), ic$nom), tex,
                                   exemptions_objet("constante", exemptions))
  # sprintf() et non paste0() : paste0("$", character(0)) rend "$" (audit de
  # #160, C1 : plantage quand aucun champ n'est introuvable).
  ich <- ch[ch$statut == "INTROUVABLE", , drop = FALSE]
  ich <- data.frame(ligne = ich$ligne, nom = sprintf("$%s", ich$segment), stringsAsFactors = FALSE)
  ex_champs <- appliquer_exemptions(ich, setNames(rep("INTROUVABLE", nrow(ich)), ich$nom), tex,
                                    exemptions_objet("champ", exemptions))
  list(maj = maj, champs = ch, ex_const = ex_const, ex_champs = ex_champs,
       non_classes = maj[maj$statut == "NON CLASSE", , drop = FALSE],
       perimees_listes = perimees_listes(maj, ch, noms_objets, poses, hors, sans_souligne, racines, hors_objets))
}

# Entrees perimees des listes fermees du controle 6 (audit de #160, C5), sur
# le modele des exemptions perimees : data.frame (liste, nom, motif).
#   MAJUSCULES_HORS_CONTROLE, CONSTANTES_SANS_SOULIGNE : nom plus cite ;
#   RACINES_EXEMPTEES : racine plus citee ;
#   CHAMPS_HORS_OBJETS : champ plus cite, retrouve dans les objets construits
#   (l'entree ne sert plus), ou plus pose par R/engine.R.
perimees_listes <- function(maj, ch, noms_objets, poses, hors = MAJUSCULES_HORS_CONTROLE,
                            sans_souligne = CONSTANTES_SANS_SOULIGNE, racines = RACINES_EXEMPTEES,
                            hors_objets = CHAMPS_HORS_OBJETS) {
  res <- list()
  ajouter <- function(liste, noms, motif)
    if (length(noms)) res[[length(res) + 1L]] <<- data.frame(liste = liste, nom = noms, motif = motif,
                                                             stringsAsFactors = FALSE)
  ajouter("MAJUSCULES_HORS_CONTROLE", setdiff(unlist(lapply(hors, `[[`, "noms")), maj$nom), "plus cite")
  ajouter("CONSTANTES_SANS_SOULIGNE", setdiff(sans_souligne, maj$nom), "plus cite")
  ajouter("RACINES_EXEMPTEES", setdiff(names(racines), ch$racine), "plus citee")
  cites <- ch$segment[!ch$statut %in% c("racine exemptee", "cle d'une constante", "racine non jugee")]
  ho <- names(hors_objets)
  ajouter("CHAMPS_HORS_OBJETS", setdiff(ho, cites), "plus cite")
  ajouter("CHAMPS_HORS_OBJETS", intersect(ho, noms_objets), "retrouve dans les objets run_engine() construits")
  ajouter("CHAMPS_HORS_OBJETS", setdiff(ho, poses), "plus pose par R/engine.R")
  if (!length(res)) return(data.frame(liste = character(0), nom = character(0), motif = character(0),
                                      stringsAsFactors = FALSE))
  do.call(rbind, res)
}

# ---------------------------------------------------------------------------
#  Nombre de replications bootstrap
# ---------------------------------------------------------------------------

# Seuil de B : B_MIN_USAGE de R/engine.R, le minimum admis par run_engine()
# (.engine_verifier_usage(), erreur d'usage en dessous). Il couvre le seuil
# sous lequel la table des tests lognormale perd une ligne : run_engine() ne
# calcule l'IC bootstrap (et usp_tests() la ligne "Largeur relative de l'IC
# bootstrap 90%") que si length(usp_b) > 20, usp_b ayant la longueur de
# boot$sigma_boot (replications finies). Voir l'en-tete. La constante est lue
# par analyse syntaxique de R/engine.R (sans le charger : valider_B() tourne
# avant le chargement du moteur) ; le depot est cherche depuis le repertoire
# courant, comme dans le programme principal.
lire_B_MIN_USAGE <- function(racine = NULL) {
  if (is.null(racine))
    racine <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
      if (file.exists("../../R/engine.R")) "../.." else
        stop("R/engine.R introuvable : lancer depuis la racine du depot.", call. = FALSE)
  exprs <- parse(file.path(racine, "R", "engine.R"), keep.source = FALSE, encoding = "UTF-8")
  for (e in exprs)
    if (is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name("B_MIN_USAGE")))
      return(as.integer(eval(e[[3]], baseenv())))
  stop("B_MIN_USAGE introuvable dans R/engine.R", call. = FALSE)
}
B_MIN <- lire_B_MIN_USAGE()

# Valide la valeur de --B (chaine ou nombre) ; erreur explicite si ce n'est
# pas un entier ou s'il est sous B_MIN. Renvoie B entier.
valider_B <- function(x) {
  B <- suppressWarnings(as.integer(x))
  if (length(B) != 1L || is.na(B) || as.character(B) != trimws(as.character(x)))
    stop(sprintf("--B : entier attendu, recu \"%s\"", paste(x, collapse = " ")), call. = FALSE)
  if (B < B_MIN)
    stop(sprintf(paste0("--B = %d refuse : B >= B_MIN_USAGE = %d requis (R/engine.R, ",
                        ".engine_verifier_usage() : run_engine() refuse un B inferieur, erreur d'usage). ",
                        "Ce seuil couvre celui de l'IC bootstrap (R/engine.R : ic <- if (length(usp_b) > 20) ",
                        "... else NULL), sous lequel la table des tests lognormale perdrait la ligne ",
                        "\"Largeur relative de l'IC bootstrap 90%%\" (famille G.) et les decomptes du ",
                        "document ne seraient plus comparables."), B, B_MIN),
         call. = FALSE)
  B
}

# ---------------------------------------------------------------------------
#  Sortie console
# ---------------------------------------------------------------------------

# Ecrit sur la sortie standard les octets UTF-8 des chaines, sans traduction
# vers la locale (issue #113, comme ecrire_console() de
# tests/regenerer_et_rendre_compte.R, issue #82) : sous une locale C/POSIX,
# cat() ecrirait "entr<U+00E9>es" pour "entrees" accentue ; la sortie est
# ainsi la meme sous toute locale. Les arguments sont concatenes sans
# separateur.
ecrire <- function(...) writeLines(vers_utf8(paste0(...)), sep = "", useBytes = TRUE)

# Tri independant de la locale (issue #113) : ordre alphabetique sans
# distinction de casse, puis octets ; sort() et table() suivraient l'ordre de
# collation de la locale, qui differe entre C et C.UTF-8.
ordre_stable <- function(x) order(tolower(x), x, method = "radix")

# ---------------------------------------------------------------------------
#  Programme principal
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  strict <- "--strict" %in% args
  B <- B_MIN
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
  ecrire(sprintf("=== 1. Fonctions citees par \\code{nom()} : %d citation(s), %d nom(s) distinct(s)\n",
              nrow(cit), length(noms)))
  # Recapitulatif par nom distinct, APRES exemptions : un nom introuvable
  # dont toutes les citations sont exemptees est compte comme exempte ; un
  # nom dont une citation au moins reste introuvable est un ecart.
  ex <- appliquer_exemptions(cit, statuts, tex)
  recap <- sub(" \\(.*$", "", statuts)
  recap[statuts == "INTROUVABLE"] <- "exempte (EXEMPTES_CODE)"
  recap[names(statuts) %in% ex$ecarts$nom] <- "INTROUVABLE non exempte"
  tab <- table(recap); tab <- tab[ordre_stable(names(tab))]
  for (s in names(tab)) ecrire(sprintf("  %-26s %d\n", s, tab[[s]]))
  autres <- noms[!statuts %in% c("moteur ou affichage", "INTROUVABLE")]
  if (length(autres)) {
    ecrire("  Hors moteur et affichage (pour information) :\n")
    for (n in autres) ecrire(sprintf("    %-32s %s\n", n, statuts[[n]]))
  }
  if (nrow(ex$exemptees)) {
    ecrire(sprintf("  Exemptees nommement (EXEMPTES_CODE, %d citation(s), pas des ecarts) :\n", nrow(ex$exemptees)))
    for (i in seq_len(nrow(ex$exemptees)))
      ecrire(sprintf("    %-32s ligne %-5d %s\n", paste0(ex$exemptees$nom[i], "()"), ex$exemptees$ligne[i],
                  ex$exemptees$motif[i]))
  }
  n_ecarts <- n_ecarts + nrow(ex$ecarts) + nrow(ex$perimees)
  if (nrow(ex$ecarts)) {
    ecrire(sprintf("  ECART -- %d nom(s) introuvable(s) non exempte(s) :\n", nrow(ex$ecarts)))
    for (i in seq_len(nrow(ex$ecarts)))
      ecrire(sprintf("    %-32s ligne(s) %s\n", paste0(ex$ecarts$nom[i], "()"), ex$ecarts$lignes[i]))
  }
  if (nrow(ex$perimees)) {
    ecrire(sprintf("  ECART -- %d exemption(s) perimee(s) (aucune citation introuvable ne lui correspond) :\n",
                nrow(ex$perimees)))
    for (i in seq_len(nrow(ex$perimees)))
      ecrire(sprintf("    %-32s contexte \"%s\"\n", paste0(ex$perimees$nom[i], "()"), ex$perimees$contexte[i]))
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
  # Executions supplementaires sur le jeu J2 (delta estime interieur, issue
  # #114) : elles ne servent qu'a la section 5 (registre de la rubrique 7),
  # la pente et Fisher n'etant de type test que sur ce jeu.
  j2 <- lire_jeu_j2(RACINE)
  resultats_j2 <- with(outils, list(
    premium_j2  = run_engine(xt = j2$x, yt = j2$y, methode = "premium", segment = 1, annexe = "II", B = B,
                             nature_donnees = "brutes"),
    reserve1_j2 = run_engine(xt = j2$x, yt = j2$y, methode = "reserve1", segment = 1, annexe = "II", B = B)))
  if (!all(vapply(resultats_j2, function(r) isTRUE(r$ok), logical(1))))
    stop("run_engine() sur le jeu J2 : resultat ok = FALSE", call. = FALSE)
  grandeurs <- c(lapply(resultats, function(r) grandeurs_moteur(r$tests, r$controles)),
                 lapply(resultats_vc, function(r) grandeurs_moteur(r$tests, r$controles)),
                 list(code = grandeurs_code(env)))
  ecrire(sprintf("\n=== 2. Decomptes (moteur execute sur tests/donnees/, B = %d)\n", B))
  for (m in names(resultats))
    ecrire(sprintf("  %-9s %d lignes de tests ; familles : %s\n", m, grandeurs[[m]][["lignes (total)"]],
                paste(sprintf("%s=%d", sub("famille ", "", grep("^famille [^ ]+$", names(grandeurs[[m]]), value = TRUE)),
                              grandeurs[[m]][grep("^famille [^ ]+$", names(grandeurs[[m]]))]), collapse = " ")))
  v <- verifier_decomptes(tex, grandeurs)
  ecrire("  a) Phrases du registre DECOMPTES (verifiees) :\n")
  for (i in seq_len(nrow(v)))
    ecrire(sprintf("    [%-11s] l.%-5s %-60s %-28s annonce %-4s mesure %s\n", v$statut[i],
                ifelse(is.na(v$ligne[i]), "?", v$ligne[i]), substr(v$assertion[i], 1, 60), v$grandeur[i],
                ifelse(is.na(v$annonce[i]), "-", format(v$annonce[i])),
                ifelse(is.na(v$mesure[i]), "-", format(v$mesure[i]))))
  n_ecarts <- n_ecarts + sum(v$statut != "ok")
  cl <- classer_formulations(tex, v)
  fo <- cl$formulations
  ecrire(sprintf(paste0("  b) Formulations \"N lignes\" / \"N entrees\" / \"N tests\" du document : %d ",
                     "(verifiees par le registre %d, exemptees %d, NON CLASSEES %d)\n"),
              nrow(fo), sum(fo$statut == "verifiee"), sum(fo$statut == "exemptee"), sum(fo$statut == "NON CLASSEE")))
  ex_f <- fo[fo$statut == "exemptee", , drop = FALSE]
  if (nrow(ex_f)) {
    ecrire("    Exemptees (nommement : EXEMPTES_DECOMPTES ; par garde de contexte : GARDES_DECOMPTES ; pas des ecarts) :\n")
    motifs <- setNames(vapply(c(EXEMPTES_DECOMPTES, GARDES_DECOMPTES), `[[`, character(1), "motif"),
                       vapply(c(EXEMPTES_DECOMPTES, GARDES_DECOMPTES), `[[`, character(1), "id"))
    for (i in seq_len(nrow(ex_f)))
      ecrire(sprintf("      l.%-5d %-18s [%s] %s\n", ex_f$ligne[i], ex_f$formulation[i], ex_f$par[i], motifs[[ex_f$par[i]]]))
  }
  nc <- fo[fo$statut == "NON CLASSEE", , drop = FALSE]
  n_ecarts <- n_ecarts + nrow(nc) + nrow(cl$perimees)
  if (nrow(nc)) {
    ecrire(sprintf("  ECART -- %d formulation(s) ni verifiee(s) par le registre DECOMPTES ni exemptee(s) (EXEMPTES_DECOMPTES) :\n",
                nrow(nc)))
    for (i in seq_len(nrow(nc))) ecrire(sprintf("    l.%-5d %-18s %s\n", nc$ligne[i], nc$formulation[i], nc$extrait[i]))
  }
  if (nrow(cl$perimees)) {
    ecrire(sprintf("  ECART -- %d exemption(s) de decompte perimee(s) (aucune formulation ne lui correspond) :\n",
                nrow(cl$perimees)))
    for (i in seq_len(nrow(cl$perimees)))
      ecrire(sprintf("    %-50s contexte \"%s\"\n", cl$perimees$id[i], cl$perimees$contexte[i]))
  }

  # 3. Familles. GROUPES regroupe les lignes de res$tests (groupe_de() de
  # display_helpers.R, appele sur la table des tests) : c'est la que tout
  # prefixe doit etre declare. Les champs famille rencontres ailleurs dans
  # le resultat (par ex. res$controles) sont signales pour information.
  fam <- unique(unlist(lapply(resultats, function(r) familles_produites(r$tests))))
  pref <- unique(substr(fam, 1L, 2L))
  fam_aut <- unique(unlist(lapply(resultats, function(r) familles_produites(r[setdiff(names(r), "tests")]))))
  non_decl <- setdiff(pref, names(env$GROUPES))
  ecrire(sprintf("\n=== 3. Prefixes de famille produits dans res$tests : %s ; declares dans GROUPES : %s\n",
              paste(pref[ordre_stable(pref)], collapse = " "), paste(names(env$GROUPES), collapse = " ")))
  hors <- setdiff(unique(substr(fam_aut, 1L, 2L)), names(env$GROUPES))
  if (length(hors))
    ecrire("  (information) famille(s) hors res$tests, non regroupees par GROUPES : ",
           paste(fam_aut[substr(fam_aut, 1L, 2L) %in% hors], collapse = " ; "), " \n")
  if (length(non_decl)) {
    n_ecarts <- n_ecarts + length(non_decl)
    ecrire("  ECART -- prefixe(s) non declare(s) dans GROUPES :\n")
    for (p in non_decl) ecrire(sprintf("    \"%s\" : %s\n", p, paste(fam[substr(fam, 1L, 2L) == p], collapse = " ; ")))
  }
  inutilises <- setdiff(names(env$GROUPES), pref)
  if (length(inutilises)) ecrire("  (information) cle(s) de GROUPES non produites sur ces jeux : ",
                                 paste(inutilises, collapse = " "), " \n")

  # 4. Colonne "Cle MC" de l'index des fonctions (issue #91) : chaque cle
  # appartient au catalogue de la methode de sa section.
  catalogues <- list(USP = names(env$USP_CATALOGUE_MC), MW = names(env$MW_CATALOGUE_MC))
  cles <- cles_mc_index(tex)
  if (is.null(cles)) {
    n_ecarts <- n_ecarts + 1L
    ecrire("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions\n  ECART -- tableau introuvable (en-tete \\textbf{Cl\u00e9 MC} et \\endlastfoot attendus)\n")
  } else {
    e_mc <- verifier_cles_mc(cles, catalogues)
    ecrire(sprintf("\n=== 4. Colonne \"Cle MC\" de l'index des fonctions : %d cle(s) (USP %d, MW %d)\n",
                nrow(cles), sum(cles$methode %in% "USP"), sum(cles$methode %in% "MW")))
    if (!nrow(cles)) {
      n_ecarts <- n_ecarts + 1L
      ecrire("  ECART -- tableau trouve mais aucune cle lue (colonne vide ou fins de rangee non reconnues)\n")
    }
    nt <- attr(cles, "non_terminee")
    if (!is.null(nt) && !is.na(nt)) {
      n_ecarts <- n_ecarts + 1L
      ecrire(sprintf("  ECART -- rangee commencee l.%d non terminee (\\\\, \\\\* ou \\\\[...]) avant \\end{longtable} : ses cles ne sont pas lues\n", nt))
    }
    for (m in names(catalogues)) {
      nc <- setdiff(catalogues[[m]], cles$cle[cles$methode %in% m])
      if (length(nc)) ecrire(sprintf("  (information) cle(s) du catalogue %s non citee(s) : %s\n", m, paste(nc, collapse = " ")))
    }
    n_ecarts <- n_ecarts + nrow(e_mc)
    if (nrow(e_mc)) {
      ecrire(sprintf("  ECART -- %d cle(s) hors du catalogue de leur methode :\n", nrow(e_mc)))
      for (i in seq_len(nrow(e_mc)))
        ecrire(sprintf("    l.%-5d %-12s %s\n", e_mc$ligne[i], e_mc$cle[i], e_mc$motif[i]))
    }
  }

  # 5. Rubrique 7 "Pertinence et puissance a faible T" (issue #114) :
  # a) registre REGISTRE_RUBRIQUE7 confronte aux lignes du moteur (toutes les
  #    executions : J1, volumes constants, J2, triangle) ;
  # b) presence de la rubrique 7 (une fois, apres \Usage) sur les fiches du
  #    registre, et sur elles seules ;
  # c) tableau de tracabilite : une rangee par fiche a rubrique 7, aucune
  #    autre ; chemins de fichier cites existants.
  tous <- c(resultats, resultats_vc, resultats_j2)
  lm7 <- do.call(rbind, lapply(tous, function(r) data.frame(
    test = vapply(r$tests, function(t) as.character(t$test)[1], character(1)),
    type = vapply(r$tests, function(t) if (is.null(t$type)) NA_character_ else as.character(t$type)[1], character(1)),
    stringsAsFactors = FALSE)))
  attendus <- vapply(REGISTRE_RUBRIQUE7, `[[`, character(1), "label")
  tp7 <- unique(lm7$test[lm7$type %in% TYPES_RUBRIQUE7])
  n_hj <- sum(vapply(REGISTRE_RUBRIQUE7, function(r) !is.null(r$hors_jeux), logical(1)))
  ecrire(sprintf(paste0("\n=== 5. Rubrique 7 (issue #114) : registre de %d fiche(s) (dont %d hors jeux) ; ",
                     "%d ligne(s) distincte(s) de type test ou procedure de decision sur %d execution(s) du moteur\n"),
              length(attendus), n_hj, length(tp7), length(tous)))
  for (r in REGISTRE_RUBRIQUE7) if (!is.null(r$hors_jeux))
    ecrire(sprintf("  (information) %s hors jeux : %s\n", r$label, r$hors_jeux))
  e_reg <- verifier_registre_rubrique7(lm7)
  n_ecarts <- n_ecarts + nrow(e_reg)
  if (nrow(e_reg)) {
    ecrire(sprintf("  ECART -- %d ecart(s) du registre REGISTRE_RUBRIQUE7 au moteur :\n", nrow(e_reg)))
    for (i in seq_len(nrow(e_reg)))
      ecrire(sprintf("    %-34s %s : %s\n", ifelse(is.na(e_reg$label[i]), "-", e_reg$label[i]), e_reg$test[i], e_reg$motif[i]))
  }
  # Verification positive des declarations hors_jeux (issue #121) : methode
  # prime seule, sur un jeu synthetique par valeur de t_positif. Ces
  # executions ne servent qu'a ce controle (ni registre a T = 8, ni sections
  # 2 et 3).
  t_pos <- sort(unique(unlist(lapply(REGISTRE_RUBRIQUE7, `[[`, "t_positif"))))
  lsy <- do.call(rbind, c(list(data.frame(T = integer(0), test = character(0), type = character(0),
                                          stringsAsFactors = FALSE)),
                          lapply(t_pos, function(Tn) {
    j <- jeu_synthetique(Tn)
    r <- outils$run_engine(xt = j$x, yt = j$y, methode = "premium", segment = 1, annexe = "II", B = B,
                           nature_donnees = "brutes")
    if (!isTRUE(r$ok)) stop(sprintf("run_engine() sur le jeu synthetique T = %d : resultat ok = FALSE", Tn), call. = FALSE)
    data.frame(T = Tn, test = vapply(r$tests, function(t) as.character(t$test)[1], character(1)),
               type = vapply(r$tests, function(t) if (is.null(t$type)) NA_character_ else as.character(t$type)[1],
                             character(1)), stringsAsFactors = FALSE)
  })))
  e_hj <- verifier_hors_jeux_positifs(lsy)
  labels_hj <- vapply(Filter(function(r) !is.null(r$hors_jeux), REGISTRE_RUBRIQUE7), `[[`, character(1), "label")
  ecrire(sprintf("  Declarations hors_jeux verifiees positivement (prime, jeux synthetiques T = %s) : %d sur %d\n",
                 paste(t_pos, collapse = ", "), sum(!labels_hj %in% e_hj$label), n_hj))
  n_ecarts <- n_ecarts + nrow(e_hj)
  if (nrow(e_hj)) {
    ecrire(sprintf("  ECART -- %d ecart(s) des declarations hors_jeux :\n", nrow(e_hj)))
    for (i in seq_len(nrow(e_hj)))
      ecrire(sprintf("    %-34s %s : %s\n", e_hj$label[i], e_hj$test[i], e_hj$motif[i]))
  }
  fi7 <- fiches_rubrique7(tex)
  labels_r7 <- fi7$label[fi7$n_pertinence > 0L & !is.na(fi7$label)]
  ecrire(sprintf("  Fiches du document : %d ; portant la rubrique 7 : %d\n", nrow(fi7), sum(fi7$n_pertinence > 0L)))
  e_r7 <- verifier_rubrique7(fi7, attendus)
  n_ecarts <- n_ecarts + nrow(e_r7)
  if (nrow(e_r7)) {
    ecrire(sprintf("  ECART -- %d ecart(s) de la rubrique 7 :\n", nrow(e_r7)))
    for (i in seq_len(nrow(e_r7)))
      ecrire(sprintf("    l.%-5s %-34s %s\n", ifelse(is.na(e_r7$ligne[i]), "?", e_r7$ligne[i]),
                  ifelse(is.na(e_r7$label[i]), "-", e_r7$label[i]), e_r7$motif[i]))
  }
  rg <- lignes_tracabilite(tex)
  if (is.null(rg)) {
    n_ecarts <- n_ecarts + 1L
    ecrire("  ECART -- tableau de tracabilite introuvable (\\label{tab:tracabilite-puissance}, \\endlastfoot et \\end{longtable} attendus)\n")
  } else {
    e_tr <- verifier_tracabilite(rg, labels_r7)
    ecrire(sprintf("  Tableau de tracabilite : %d rangee(s) de fiche\n", nrow(rg)))
    n_ecarts <- n_ecarts + nrow(e_tr)
    if (nrow(e_tr)) {
      ecrire(sprintf("  ECART -- %d ecart(s) du tableau de tracabilite :\n", nrow(e_tr)))
      for (i in seq_len(nrow(e_tr)))
        ecrire(sprintf("    l.%-5s %-34s %s\n", ifelse(is.na(e_tr$ligne[i]), "?", e_tr$ligne[i]),
                    ifelse(is.na(e_tr$label[i]), "-", e_tr$label[i]), e_tr$motif[i]))
    }
    ch <- chemins_tracabilite(tex)
    manq <- verifier_chemins(ch, RACINE)
    ecrire(sprintf("  Chemins de fichier cites dans la sous-section : %d (%d distinct(s))\n", nrow(ch), length(unique(ch$chemin))))
    n_ecarts <- n_ecarts + nrow(manq)
    if (nrow(manq)) {
      ecrire(sprintf("  ECART -- %d chemin(s) cite(s) inexistant(s) dans le depot :\n", nrow(manq)))
      for (i in seq_len(nrow(manq))) ecrire(sprintf("    l.%-5d %s\n", manq$ligne[i], manq$chemin[i]))
    }
  }

  # 6. Constantes et champs cites (issue #160) : sur les objets run_engine()
  # deja construits pour les sections 2 a 5 (J1, volumes constants, J2,
  # triangle), sans nouvel appel au moteur.
  constantes <- definitions_constantes(c(file.path(RACINE, c("R/engine.R", "R/display_helpers.R", "app.R")),
                                         list.files(file.path(RACINE, "tests"), pattern = "[.]R$", full.names = TRUE)))
  cc6 <- verifier_constantes_champs(tex, constantes, tous, champs_poses(file.path(RACINE, "R", "engine.R")), env)
  mj <- cc6$maj
  ecrire(sprintf("\n=== 6. Constantes et champs cites (issue #160)\n  a) Identifiants en majuscules : %d citation(s), %d nom(s) distinct(s)\n",
                 nrow(mj), length(unique(mj$nom))))
  rec6 <- sprintf("%s : %s", mj$categorie, mj$statut)
  rec6[mj$statut == "INTROUVABLE" & !paste(mj$ligne, mj$nom) %in% paste(cc6$ex_const$exemptees$ligne, cc6$ex_const$exemptees$nom)] <-
    "constante : INTROUVABLE non exemptee"
  rec6[mj$statut == "INTROUVABLE" & paste(mj$ligne, mj$nom) %in% paste(cc6$ex_const$exemptees$ligne, cc6$ex_const$exemptees$nom)] <-
    "constante : exemptee (EXEMPTES_CODE)"
  t6 <- vapply(split(mj$nom, rec6), function(x) sprintf("%d citation(s), %d nom(s)", length(x), length(unique(x))), character(1))
  for (s in names(t6)[ordre_stable(names(t6))]) ecrire(sprintf("    %-58s %s\n", s, t6[[s]]))
  cv <- unique(mj[mj$categorie %in% c("constante", "constante (joker)") & mj$statut == "verifie", c("nom", "ou")])
  for (f in unique(cv$ou)[ordre_stable(unique(cv$ou))]) {
    n_f <- sort(cv$nom[cv$ou == f], method = "radix")
    ecrire(sprintf("    definies dans %s (%d) : %s\n", f, length(n_f), paste(n_f, collapse = " ")))
  }
  if (nrow(cc6$ex_const$exemptees)) {
    ecrire(sprintf("    Exemptees nommement (EXEMPTES_CODE, objet constante, %d citation(s), pas des ecarts) :\n",
                   nrow(cc6$ex_const$exemptees)))
    for (i in seq_len(nrow(cc6$ex_const$exemptees)))
      ecrire(sprintf("      %-30s ligne %-5d %s\n", cc6$ex_const$exemptees$nom[i], cc6$ex_const$exemptees$ligne[i],
                     cc6$ex_const$exemptees$motif[i]))
  }
  ch6 <- cc6$champs
  ecrire(sprintf("  b) Chemins de champs ($) : %d segment(s) cite(s), %d champ(s) distinct(s)\n",
                 nrow(ch6), length(unique(ch6$segment))))
  st6 <- ch6$statut
  ex_ch <- paste(cc6$ex_champs$exemptees$ligne, cc6$ex_champs$exemptees$nom)
  st6[st6 == "INTROUVABLE"] <- ifelse(paste(ch6$ligne, sprintf("$%s", ch6$segment))[st6 == "INTROUVABLE"] %in% ex_ch,
                                      "exempte (EXEMPTES_CODE)", "INTROUVABLE non exempte")
  t6c <- vapply(split(ch6$segment, st6), function(x) sprintf("%d segment(s), %d champ(s)", length(x), length(unique(x))),
                character(1))
  for (s in names(t6c)[ordre_stable(names(t6c))]) ecrire(sprintf("    %-58s %s\n", s, t6c[[s]]))
  pz <- unique(ch6$segment[ch6$statut == "hors objets (liste fermee)"])
  if (length(pz))
    ecrire(sprintf("    (information) absents des objets construits, admis par CHAMPS_HORS_OBJETS et poses par R/engine.R : %s\n",
                   paste(pz[ordre_stable(pz)], collapse = " ")))
  if (nrow(cc6$ex_champs$exemptees)) {
    ecrire(sprintf("    Exemptes nommement (EXEMPTES_CODE, objet champ, %d citation(s), pas des ecarts) :\n",
                   nrow(cc6$ex_champs$exemptees)))
    for (i in seq_len(nrow(cc6$ex_champs$exemptees)))
      ecrire(sprintf("      %-30s ligne %-5d %s\n", cc6$ex_champs$exemptees$nom[i], cc6$ex_champs$exemptees$ligne[i],
                     cc6$ex_champs$exemptees$motif[i]))
  }
  n6 <- nrow(cc6$ex_const$ecarts) + nrow(cc6$ex_const$perimees) + nrow(cc6$ex_champs$ecarts) +
    nrow(cc6$ex_champs$perimees) + nrow(cc6$non_classes) + nrow(cc6$perimees_listes)
  n_ecarts <- n_ecarts + n6
  if (nrow(cc6$ex_const$ecarts)) {
    ecrire(sprintf("  ECART -- %d constante(s) citee(s) introuvable(s) non exemptee(s) :\n", nrow(cc6$ex_const$ecarts)))
    for (i in seq_len(nrow(cc6$ex_const$ecarts)))
      ecrire(sprintf("    %-32s ligne(s) %s\n", cc6$ex_const$ecarts$nom[i], cc6$ex_const$ecarts$lignes[i]))
  }
  if (nrow(cc6$ex_champs$ecarts)) {
    ecrire(sprintf("  ECART -- %d champ(s) cite(s) introuvable(s) non exempte(s) :\n", nrow(cc6$ex_champs$ecarts)))
    for (i in seq_len(nrow(cc6$ex_champs$ecarts)))
      ecrire(sprintf("    %-32s ligne(s) %s\n", cc6$ex_champs$ecarts$nom[i], cc6$ex_champs$ecarts$lignes[i]))
  }
  if (nrow(cc6$non_classes)) {
    ecrire(sprintf("  ECART -- %d identifiant(s) en majuscules non classe(s) :\n", nrow(cc6$non_classes)))
    for (i in seq_len(nrow(cc6$non_classes)))
      ecrire(sprintf("    l.%-5d %-32s %s\n", cc6$non_classes$ligne[i], cc6$non_classes$nom[i], cc6$non_classes$categorie[i]))
  }
  pe6 <- rbind(cc6$ex_const$perimees, cc6$ex_champs$perimees)
  if (nrow(pe6)) {
    ecrire(sprintf("  ECART -- %d exemption(s) de constante ou de champ perimee(s) :\n", nrow(pe6)))
    for (i in seq_len(nrow(pe6))) ecrire(sprintf("    %-32s contexte \"%s\"\n", pe6$nom[i], pe6$contexte[i]))
  }
  pl6 <- cc6$perimees_listes
  if (nrow(pl6)) {
    ecrire(sprintf("  ECART -- %d entree(s) perimee(s) des listes fermees du controle 6 :\n", nrow(pl6)))
    for (i in seq_len(nrow(pl6))) ecrire(sprintf("    %-26s %-24s %s\n", pl6$liste[i], pl6$nom[i], pl6$motif[i]))
  }

  ecrire(sprintf("\nBILAN : %d ecart(s)%s ; formulations de decompte : %d verifiee(s), %d exemptee(s), %d non classee(s)\n",
              n_ecarts, if (strict) " (mode strict)" else " (mode rapport : code de sortie 0)",
              sum(fo$statut == "verifiee"), sum(fo$statut == "exemptee"), sum(fo$statut == "NON CLASSEE")))
  if (strict && n_ecarts) quit(status = 1)
}
