###############################################################################
#  tests/regenerer_et_rendre_compte.R  --  REGENERATION CONTROLEE D'UNE
#  REFERENCE, AVEC TABLEAU AVANT / APRES (issue #64)
#
#  Enchaine ce que la regeneration de #29 a fait a la main : comparaison de la
#  reference au resultat recalcule, refus si une feuille change hors des
#  motifs attendus, regeneration, verification que toutes les feuilles hors
#  motifs sont restees identiques au bit pres, tableau avant / apres en
#  markdown, relance des batteries.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/regenerer_et_rendre_compte.R <cas> --attendu "<regex>" \
#              [--attendu ...] [--issue NN] [--ecrire] [--sans-batteries]
#
#  La commande reportee dans le tableau est ecrite pour un shell POSIX (bash,
#  Git Bash, CI) : les motifs y sont entre apostrophes, une apostrophe interne
#  devenant '\''. Sous PowerShell ou cmd.exe, elle ne se rejoue pas telle
#  quelle si un motif contient une apostrophe.
#
#  Motifs : meme grammaire que tests/patcher_reference.R --motif (expressions
#  regulieres appliquees aux chemins aplatis qu'affiche
#  comparer_references.R ; designer() de outils_tests.R). Un motif attendu
#  designe des feuilles dont on ATTEND qu'elles changent.
#
#  Sans --ecrire (essai a blanc) : affiche le tableau et ce qui serait fait ;
#  n'ecrit rien ; code de sortie 0 meme si l'ecriture serait refusee (c'est
#  un rapport).
#
#  Avec --ecrire (--issue obligatoire, il nomme le tableau) :
#    1. REFUS (code de sortie 1), sans rien ecrire, si une feuille non
#       strictement identique -- derive infime comprise, ajout et suppression
#       compris -- ou un noeud de structure (type, attributs) change hors des
#       motifs attendus (l'ancetre d'une feuille designee n'est couvert que
#       si seul son attribut names change, voir noeud_couvert()), ou si un
#       motif attendu ne designe aucun changement (changement annonce mais
#       absent), y compris quand le resultat est identical() a la
#       reference ;
#    2. rien a regenerer si le resultat recalcule est identical() a la
#       reference : le fichier n'est pas reecrit (son md5 ne bouge pas) ;
#    3. sinon, ecriture ATOMIQUE (remplacer_reference()) : fichier
#       temporaire du meme dossier ecrit par ecrire_reference()
#       (outils_tests.R, le code de generer_references.R), relu, verifie
#       (identical() au resultat recalcule, structure comprise ; feuilles
#       hors motifs identical() a l'ancienne reference), puis substitue par
#       file.rename() ; en cas d'echec la reference en place est intacte ;
#    4. tableau avant / apres ecrit dans
#       docs/tableaux/AAAAMMJJ-issueNN-<cas>.md ;
#    5. relance de test_reproductibilite.R (~2 min) et de test_unitaires.R,
#       lignes de synthese reportees dans le tableau et a l'ecran ; code de
#       sortie 1 si l'une echoue. --sans-batteries les omet (le tableau le
#       dit et donne les commandes a lancer).
#
#  Mode creation (decision M31, ADR 0011 amende ; mode creation de
#  .github/workflows/references.yml) : creer la reference d'un cas de CAS
#  (outils_tests.R) qui n'en a pas encore.
#      Rscript tests/regenerer_et_rendre_compte.R <cas> --creer [--issue NN]
#              [--ecrire] [--sans-batteries]
#    - REFUS (code de sortie 1, avec ou sans --ecrire), avant tout calcul, si
#      tests/reference/<cas>.rds existe deja (une reference existante se
#      regenere, elle ne se cree pas), si le cas n'est pas dans CAS, si son
#      nom sort de NOM_CAS_VALIDE, ou si --attendu est donne (une creation
#      n'a pas de motifs : toutes les feuilles sont ajoutees) ; apres le
#      calcul, si run_engine() renvoie ok = FALSE ;
#    - sans --ecrire : essai a blanc, rien n'est ecrit ;
#    - avec --ecrire (--issue obligatoire) : ecriture ATOMIQUE
#      (creer_reference() : temporaire du meme dossier, relu, verifie
#      identical() au resultat calcule, puis renomme) ; empreintes md5 des
#      autres .rds de tests/reference/ comparees avant / apres : code 1 si
#      l'une a change, a disparu, ou si un autre fichier est apparu ;
#      tableau "absent / ajoute" (tableau_creation_markdown(), pas de
#      tableau feuille a feuille : aucune feuille n'existait) dans
#      docs/tableaux/AAAAMMJJ-issueNN-<cas>.md, puis batteries comme
#      ci-dessus (test_reproductibilite.R couvre alors le nouveau cas).
#
#  Un motif qui designe plus de SEUIL_MOTIF_LARGE (50) feuilles est signale
#  (console et tableau), sans refus. La ligne "Commande" du tableau reprend
#  toutes les options, motifs entre apostrophes : rejouable dans un shell
#  POSIX telle quelle.
#
#  La comparaison ne neutralise PAS `INSTABLES` (comme patcher_reference.R et
#  pour la meme raison : le script ECRIT la reference, et masquer une
#  difference reviendrait a la laisser passer sans qu'elle soit nommee).
#
#  Juge : comparer_objets() de outils_tests.R, le comparateur unique de la
#  non-regression (ADR 0006), appele deux fois : au seuil 0 (toute feuille
#  non strictement identique, bascule relatif / absolu inchangee) et au seuil
#  TOLERANCE de la CI (colonne Mesure : "au-dela du seuil" ou "derive").
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions, sans lire ni ecrire de fichier : analyser_regeneration(),
#  verifier_regeneration(), tableau_markdown() et, pour le mode creation,
#  references_modifiees(), creer_reference() et tableau_creation_markdown()
#  sont testees par tests/unitaires/test_regenerer_et_rendre_compte.R.
###############################################################################

# Dossier tests/ : meme logique que patcher_reference.R (fourni par
# l'appelant, sinon deduit du chemin du script, sinon du repertoire courant).
DOSSIER_TESTS <- if (exists("DOSSIER_TESTS", envir = environment(), inherits = FALSE)) DOSSIER_TESTS else
  local({
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(f) == 1L && basename(f) == "regenerer_et_rendre_compte.R") dirname(f)
    else if (file.exists("tests/outils_tests.R")) "tests" else "."
  })
source(file.path(DOSSIER_TESTS, "outils_tests.R"), local = TRUE)

# LARGEUR_CELLULE, une_ligne(), echapper(), cellule(), texte_code() et
# plateforme() sont definies dans outils_tests.R, partagees avec
# comparer_references.R --markdown (issue #66). cellule() sert aux cellules
# du tableau ; texte_code() aux lignes hors tableau (commande, motifs,
# structure, feuille maximale, batteries), ou une barre verticale echappee
# afficherait l'antislash.

# ---------------------------------------------------------------------------
#  Analyse : quelles feuilles changent, sont-elles toutes attendues ?
# ---------------------------------------------------------------------------

# Seuil d'avertissement : un motif qui designe plus de SEUIL_MOTIF_LARGE
# feuilles differentes est signale (sans refus). Une ligne de res$tests
# compte 22 feuilles (mesure : tests[[50]] de premium, ajoute en bloc lors
# de la demonstration de l'issue #64) ; 50 feuilles, c'est plus de deux
# lignes de tests entieres, signe probable d'un motif trop large.
SEUIL_MOTIF_LARGE <- 50L

# Un noeud de structure (chemin de structure_arbre() ; sa, sb : structures
# de l'ancienne reference et du resultat recalcule) est couvert :
#   - s'il est lui-meme designe par un motif ;
#   - ou s'il est l'ancetre d'une feuille designee qui change ET que sa
#     difference se limite a l'attribut names (meme type, memes autres
#     attributs, present des deux cotes) : l'ajout ou la suppression d'une
#     feuille change legitimement les names de ses ancetres, rien d'autre.
# Un changement de classe, d'un autre attribut ou de type d'un ancetre n'est
# jamais couvert par la seule designation d'une feuille (audit R1, point 1).
noeud_couvert <- function(noeud, designees, motifs, sa, sb) {
  if (length(designer(noeud, motifs))) return(TRUE)
  ancetre <- if (identical(noeud, "(racine)")) length(designees) > 0L else
    any(startsWith(designees, paste0(noeud, "$")) | startsWith(designees, paste0(noeud, "[")))
  if (!ancetre) return(FALSE)
  x <- sa[[noeud]]; y <- sb[[noeud]]
  if (is.null(x) || is.null(y)) return(FALSE)
  x$attributs$names <- NULL; y$attributs$names <- NULL
  identical(x, y)
}

analyser_regeneration <- function(avant, apres, motifs) {
  # Seuil 0 : toute feuille non strictement identique ; la bascule relatif /
  # absolu reste TOLERANCE (voir ecart_feuille()).
  r0 <- comparer_objets(avant, apres, tol = 0, bascule = TOLERANCE)
  # Seuil de la CI : ce que test_reproductibilite.R jugerait en ecart.
  rs <- comparer_objets(avant, apres, tol = TOLERANCE, bascule = TOLERANCE)
  lignes <- r0$ecarts
  lignes$au_seuil <- lignes$chemin %in% rs$ecarts$chemin
  differentes <- lignes$chemin
  designees <- designer(differentes, motifs)
  hors_motifs <- setdiff(differentes, designees)
  sa <- structure_arbre(avant); sb <- structure_arbre(apres)
  struct_hors <- Filter(function(n) !noeud_couvert(n, designees, motifs, sa, sb), r0$structure)
  sans_effet <- Filter(function(m) !length(designer(c(differentes, r0$structure), m)), motifs)
  n_par_motif <- vapply(motifs, function(m) length(designer(differentes, m)), integer(1))
  larges <- n_par_motif[n_par_motif > SEUIL_MOTIF_LARGE]
  rien <- identical(avant, apres)
  # Garde-fou : un objet non identical() dont le comparateur ne localise
  # aucune difference ne peut pas etre justifie par des motifs.
  localise <- length(differentes) > 0L || length(r0$structure) > 0L
  n_id <- r0$n_feuilles - sum(lignes$mesure != "ajoutee" & lignes$chemin != "(ordre des feuilles)")
  list(comparaison = r0, comparaison_seuil = rs, lignes = lignes,
       designees = designees, hors_motifs = hors_motifs,
       structure_hors_motifs = struct_hors, motifs_sans_effet = sans_effet,
       motifs_larges = larges,
       rien_a_regenerer = rien,
       non_localise = !rien && !localise,
       acceptable = !rien && localise && !length(hors_motifs) && !length(struct_hors) && !length(sans_effet),
       n_feuilles_avant = r0$n_feuilles, n_feuilles_apres = length(aplatir(apres)),
       n_identiques = n_id)
}

# Messages expliquant un refus (character(0) si l'ecriture est acceptable).
motifs_de_refus <- function(a) {
  c(if (isTRUE(a$non_localise))
      "objets non identical() sans difference localisee par comparer_objets() : a examiner a la main",
    if (length(a$hors_motifs))
      c(sprintf("%d feuille(s) non strictement identique(s) hors des motifs attendus :",
                length(a$hors_motifs)), paste0("  ", a$hors_motifs)),
    if (length(a$structure_hors_motifs))
      c("structure (type ou attributs) changee hors des motifs attendus :",
        paste0("  ", a$structure_hors_motifs)),
    if (length(a$motifs_sans_effet))
      c("motif(s) attendu(s) ne designant aucun changement (changement annonce mais absent) :",
        paste0("  ", a$motifs_sans_effet)))
}

# Decision du programme principal : action ("rien", "refus", "blanc",
# "ecrire") et code de sortie. Le refus d'un motif sans effet vaut aussi
# quand le resultat est identical() a la reference (audit R1, point 4) : un
# changement annonce qui n'a pas lieu est un constat, pas un succes.
decider <- function(a, ecrire) {
  refus <- motifs_de_refus(a)
  if (isTRUE(a$rien_a_regenerer))
    return(list(action = "rien", code = if (ecrire && length(refus)) 1L else 0L, refus = refus))
  if (length(refus)) return(list(action = "refus", code = if (ecrire) 1L else 0L, refus = refus))
  list(action = if (ecrire) "ecrire" else "blanc", code = 0L, refus = character(0))
}

# Ligne de commande rejouable telle quelle dans un shell POSIX : toutes les
# options, motifs entre apostrophes (une apostrophe interne devient '\'').
commande_rejouable <- function(nom, motifs, issue, ecrire, batteries, creer = FALSE) {
  sq <- function(x) paste0("'", gsub("'", "'\\''", x, fixed = TRUE), "'")
  paste(c("Rscript tests/regenerer_et_rendre_compte.R", nom, if (creer) "--creer",
          if (length(motifs)) paste("--attendu", sq(motifs)),
          if (!is.na(issue)) paste("--issue", issue), if (ecrire) "--ecrire",
          if (!batteries) "--sans-batteries"), collapse = " ")
}

# ---------------------------------------------------------------------------
#  Verification apres ecriture : la reference relue est le resultat
#  recalcule, et rien hors motifs n'a bouge par rapport a l'ancienne.
# ---------------------------------------------------------------------------

verifier_regeneration <- function(avant, nouvelle, apres, designees) {
  if (!identical(nouvelle, apres))
    stop("La reference ecrite n'est pas identical() au resultat recalcule (structure comprise).")
  fa <- aplatir(avant); fn <- aplatir(nouvelle)
  hors <- setdiff(names(fa), designees)
  ia <- match(hors, names(fa)); inn <- match(hors, names(fn))
  meme <- vapply(seq_along(hors), function(k) !is.na(inn[k]) && identical(fa[[ia[k]]], fn[[inn[k]]]),
                 logical(1))
  bouge <- hors[!meme]
  if (length(bouge))
    stop(length(bouge), " feuille(s) hors motifs differe(nt) de l'ancienne reference : ",
         paste(utils::head(bouge, 10), collapse = ", "))
  invisible(length(hors))
}

# Ecriture atomique (audit R1, point 2) : le resultat est ecrit dans un
# fichier temporaire du MEME dossier (ecrire_reference(), le code de
# generer_references.R), relu et verifie (verifier_regeneration()), puis
# substitue a la reference par file.rename(). Si l'ecriture, la relecture ou
# la verification echoue, la reference en place n'a pas ete touchee et le
# temporaire est supprime. Renvoie le nombre de feuilles hors motifs
# verifiees identiques.
remplacer_reference <- function(apres, avant, designees, chemin) {
  tmp <- tempfile(pattern = paste0(".", sub("[.]rds$", "", basename(chemin)), "-"),
                  tmpdir = dirname(chemin), fileext = ".rds")
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  ecrire_reference(NA, apres, chemin = tmp)
  n <- verifier_regeneration(avant, readRDS(tmp), apres, designees)
  if (!file.rename(tmp, chemin)) stop("file.rename() a echoue : reference en place inchangee.")
  if (!identical(readRDS(chemin), apres)) stop("Reference relue apres substitution differente du resultat recalcule.")
  n
}

# ---------------------------------------------------------------------------
#  Tableau avant / apres en markdown
# ---------------------------------------------------------------------------

# Position du premier caractere different de deux chaines (NA si egales).
premiere_difference <- function(a, b) {
  ca <- strsplit(a, "")[[1]]; cb <- strsplit(b, "")[[1]]
  n <- min(length(ca), length(cb))
  d <- which(ca[seq_len(n)] != cb[seq_len(n)])
  if (length(d)) d[1L] else if (length(ca) != length(cb)) n + 1L else NA_integer_
}

# Paire de cellules Avant / Apres (audit R1, point 3). Deux chaines qui ne
# different qu'au-dela de la largeur affichee donneraient, tronquees, deux
# cellules identiques : on affiche alors pour chacune une fenetre de largeur
# caracteres autour du premier caractere different, avec sa position.
# Sinon, troncature ordinaire (cellule()).
cellules_paire <- function(avant, apres, largeur = LARGEUR_CELLULE) {
  a <- une_ligne(avant); b <- une_ligne(apres)
  p <- premiere_difference(a, b)
  if (is.na(p) || p < largeur || max(nchar(a), nchar(b)) <= largeur)
    return(list(avant = cellule(avant, largeur), apres = cellule(apres, largeur)))
  fen <- function(x) {
    debut <- max(1L, p - largeur %/% 3L); fin <- debut + largeur - 1L
    sprintf("%s%s%s (%d car., 1re diff\u00e9rence au car. %d)", if (debut > 1L) "\u2026" else "",
            substr(x, debut, fin), if (fin < nchar(x)) "\u2026" else "", nchar(x), p)
  }
  list(avant = echapper(fen(a)), apres = echapper(fen(b)))
}

tableau_markdown <- function(a, nom, issue = NA, motifs = character(0),
                             date = Sys.Date(), plateforme_txt = plateforme(),
                             commande = NA_character_) {
  l <- a$lignes
  avant <- ifelse(l$mesure == "ajoutee", "(absente)", l$reference)
  apres <- ifelse(l$mesure == "absente", "(absente)", l$obtenu)
  ecart <- ifelse(is.na(l$ecart), "", formatC(l$ecart, format = "e", digits = 3))
  mesure <- ifelse(l$mesure == "ajoutee", "ajout\u00e9e (absente avant)",
            ifelse(l$mesure == "absente", "supprim\u00e9e (absente apr\u00e8s)",
            paste0(l$mesure, ifelse(l$mesure %in% c("relatif", "absolu"),
                                    ifelse(l$au_seuil, sprintf(", au-del\u00e0 du seuil %g", TOLERANCE),
                                           sprintf(", d\u00e9rive \u2264 %g", TOLERANCE)), ""))))
  n_aj <- sum(l$mesure == "ajoutee"); n_su <- sum(l$mesure == "absente")
  rs <- a$comparaison_seuil
  synthese <- sprintf(paste0(
    "**Synth\u00e8se** : %d feuille(s) dans l'ancienne r\u00e9f\u00e9rence, %d dans le r\u00e9sultat recalcul\u00e9 ; ",
    "%d non strictement identique(s) (dont %d en \u00e9cart au seuil %g, %d ajout\u00e9e(s), %d supprim\u00e9e(s)), ",
    "%s ; %d feuille(s) identique(s) au bit pr\u00e8s ; \u00e9cart num\u00e9rique maximal %s%s."),
    a$n_feuilles_avant, a$n_feuilles_apres, nrow(l), rs$n_ecarts, TOLERANCE, n_aj, n_su,
    if (!length(a$hors_motifs)) "toutes d\u00e9sign\u00e9es par les motifs attendus"
    else sprintf("dont %d HORS des motifs attendus", length(a$hors_motifs)),
    a$n_identiques, formatC(a$comparaison$ecart_max, format = "e", digits = 3),
    if (is.na(a$comparaison$feuille_max)) "" else
      sprintf(" (%s, `%s`)", a$comparaison$mesure_max, texte_code(a$comparaison$feuille_max)))
  c(sprintf("# Tableau avant / apr\u00e8s \u2014 r\u00e9f\u00e9rence `%s`%s", nom,
            if (is.na(issue)) "" else sprintf(" (issue #%s)", issue)),
    "",
    sprintf("- Date : %s", format(date, "%Y-%m-%d")),
    sprintf("- Plateforme : %s", plateforme_txt),
    if (!is.na(commande)) sprintf("- Commande : `%s`", texte_code(commande, 500L)),
    sprintf("- Motifs attendus : %s",
            if (length(motifs)) paste0("`", texte_code(motifs, 200L), "`", collapse = ", ") else "(aucun)"),
    sprintf("- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil %g pour juger ; `INSTABLES` non neutralis\u00e9", TOLERANCE),
    "",
    synthese,
    "",
    if (length(a$motifs_larges))
      c(sprintf("**Avertissement** : motif `%s` : %d feuilles d\u00e9sign\u00e9es (seuil d'avertissement %d) ; v\u00e9rifier qu'il n'est pas trop large.",
                texte_code(names(a$motifs_larges), 200L), a$motifs_larges, SEUIL_MOTIF_LARGE), ""),
    if (length(a$comparaison$structure))
      c(sprintf("N\u0153uds de structure modifi\u00e9s (type ou attributs) : %s",
                paste0("`", texte_code(a$comparaison$structure), "`", collapse = ", ")), ""),
    "| Feuille | Avant | Apr\u00e8s | \u00c9cart | Mesure |",
    "|---|---|---|---|---|",
    if (nrow(l)) {
      paires <- lapply(seq_len(nrow(l)), function(i) cellules_paire(avant[i], apres[i]))
      c_avant <- vapply(paires, `[[`, character(1), "avant")
      c_apres <- vapply(paires, `[[`, character(1), "apres")
      # Valeur manquante (reference_na / obtenu_na de comparer_objets())
      # affichee \<NA\>, comme dans comparer_references.R : distincte de la
      # chaine "NA" ; chevrons echappes, sans quoi GitHub lirait une balise.
      c_avant[l$reference_na & l$mesure != "ajoutee"] <- "\\<NA\\>"
      c_apres[l$obtenu_na & l$mesure != "absente"] <- "\\<NA\\>"
      sprintf("| `%s` | %s | %s | %s | %s |", cellule(l$chemin, 120L),
              c_avant, c_apres, ecart, mesure)
    })
}

# ---------------------------------------------------------------------------
#  Mode creation (M31) : reference d'un cas de CAS qui n'en a pas encore
# ---------------------------------------------------------------------------

# Noms de cas admis : minuscules, chiffres et soulignes, une lettre en tete
# (premium, reserve1, premium_ii6...). Le nom devient un nom de fichier
# (tests/reference/<cas>.rds, docs/tableaux/...-<cas>.md) : ni point, ni
# barre oblique, ni espace. Meme expression dans references.yml.
NOM_CAS_VALIDE <- "^[a-z][a-z0-9_]*$"

# Empreintes md5 des .rds d'un dossier (vecteur nomme par nom de fichier,
# trie). Les temporaires de creer_reference() et remplacer_reference()
# commencent par un point : le motif ne les prend pas, ils ne doivent plus
# exister a la fin (le workflow le verifie par git status).
empreintes_references <- function(dossier) {
  f <- sort(list.files(dossier, pattern = "^[^.].*[.]rds$", full.names = TRUE))
  stats::setNames(unname(tools::md5sum(f)), basename(f))
}

# Ecarts entre deux jeux d'empreintes autres que l'ajout de `ajoute` (nom de
# fichier) : fichiers modifies, disparus, ou apparus en plus. character(0)
# si seul `ajoute` est apparu et que tous les autres fichiers sont intacts.
references_modifiees <- function(avant, apres, ajoute) {
  # Le fichier cree est traite par les deux dernieres lignes seulement.
  communs <- setdiff(intersect(names(avant), names(apres)), ajoute)
  diff <- communs[avant[communs] != apres[communs]]
  c(sprintf("%s : modifie (md5 %s -> %s)", diff, avant[diff], apres[diff]),
    sprintf("%s : disparu", setdiff(names(avant), names(apres))),
    sprintf("%s : apparu en plus de %s", setdiff(names(apres), c(names(avant), ajoute)), ajoute),
    if (ajoute %in% names(avant)) sprintf("%s : existait deja avant la creation", ajoute),
    if (!ajoute %in% names(apres)) sprintf("%s : absent apres la creation", ajoute))
}

# Ecriture atomique d'une reference NOUVELLE : refus si le fichier existe ;
# temporaire du meme dossier ecrit par ecrire_reference() (outils_tests.R,
# le code de generer_references.R), relu et verifie identical() au resultat
# calcule, puis renomme ; existence re-verifiee juste avant le renommage
# (file.rename() ecraserait un fichier apparu entre-temps). En cas d'echec,
# aucun fichier n'est laisse (temporaire supprime).
creer_reference <- function(res, chemin) {
  if (file.exists(chemin)) stop("Reference deja presente, creation refusee : ", chemin)
  tmp <- tempfile(pattern = paste0(".", sub("[.]rds$", "", basename(chemin)), "-"),
                  tmpdir = dirname(chemin), fileext = ".rds")
  on.exit(if (file.exists(tmp)) unlink(tmp), add = TRUE)
  ecrire_reference(NA, res, chemin = tmp)
  if (!identical(readRDS(tmp), res))
    stop("La reference ecrite n'est pas identical() au resultat calcule (structure comprise).")
  if (file.exists(chemin)) stop("Reference apparue pendant l'ecriture, creation refusee : ", chemin)
  if (!file.rename(tmp, chemin)) stop("file.rename() a echoue : aucune reference creee.")
  if (!identical(readRDS(chemin), res)) stop("Reference relue apres renommage differente du resultat calcule.")
  invisible(chemin)
}

# Tableau de non-regression d'une creation : "absent / ajoute" seulement
# (regle 2 du paragraphe 2 de la feuille de route, M31). Aucune feuille
# n'existait avant : pas de tableau feuille a feuille. La comparaison du
# nouveau cas a un cas existant, si elle est demandee, est produite a part.
# emp_avant, emp_apres : empreintes_references() avant et apres ; fichier :
# nom du .rds cree.
tableau_creation_markdown <- function(nom, res, fichier, emp_avant, emp_apres, issue = NA,
                                      date = Sys.Date(), plateforme_txt = plateforme(),
                                      commande = NA_character_) {
  modif <- references_modifiees(emp_avant, emp_apres, fichier)
  sigma <- res$parametre_final$sigma_usp
  existants <- names(emp_avant)
  c(sprintf("# Tableau avant / apr\u00e8s \u2014 cr\u00e9ation de la r\u00e9f\u00e9rence `%s`%s", nom,
            if (is.na(issue)) "" else sprintf(" (issue #%s)", issue)),
    "",
    sprintf("- Date : %s", format(date, "%Y-%m-%d")),
    sprintf("- Plateforme : %s", plateforme_txt),
    if (!is.na(commande)) sprintf("- Commande : `%s`", texte_code(commande, 500L)),
    "- Mode : cr\u00e9ation (M31) ; tableau de non-r\u00e9gression \u00ab absent / ajout\u00e9 \u00bb seulement",
    "",
    "| R\u00e9f\u00e9rence | Avant | Apr\u00e8s |",
    "|---|---|---|",
    sprintf("| `tests/reference/%s` | (absente) | ajout\u00e9e : %d feuille(s), md5 `%s` |",
            fichier, length(aplatir(res)),
            if (fichier %in% names(emp_apres)) emp_apres[[fichier]] else "?"),
    "",
    sprintf("- \u03c3_USP du cas ajout\u00e9 (`parametre_final$sigma_usp`) : %s",
            if (is.numeric(sigma) && length(sigma) == 1L) formatC(sigma, format = "f", digits = 10) else "(absent)"),
    if (!length(modif))
      sprintf("- R\u00e9f\u00e9rences existantes : %d fichier(s), md5 identiques avant / apr\u00e8s (%s) ; aucun autre fichier ajout\u00e9",
              length(existants), if (length(existants)) paste0("`", existants, "`", collapse = ", ") else "aucune")
    else c("- **R\u00e9f\u00e9rences existantes MODIFI\u00c9ES** :", paste0("  - `", texte_code(modif, 200L), "`")))
}

# ---------------------------------------------------------------------------
#  Batteries : relance et extraction des lignes de synthese
# ---------------------------------------------------------------------------

lancer_batterie <- function(script) {
  rs <- file.path(R.home("bin"), "Rscript")
  sortie <- suppressWarnings(system2(rs, file.path(RACINE, "tests", script), stdout = TRUE, stderr = TRUE))
  statut <- attr(sortie, "status"); if (is.null(statut)) statut <- 0L
  synth <- grep("^(TOTAL|OK|ECHEC)|CONFORME|sigma_USP", sortie, value = TRUE)
  list(script = script, statut = statut, synthese = trimws(synth))
}

# Fin commune aux modes regeneration et creation, apres ecriture de la
# reference : relance des batteries (sauf --sans-batteries), tableau md
# complete de leur bilan et ecrit dans dest, code de sortie 1 si une
# batterie echoue.
finir_avec_batteries <- function(md, dest, batteries) {
  bilan <- c("", "## Batteries", "")
  echec <- FALSE
  if (batteries) {
    for (s in c("test_reproductibilite.R", "test_unitaires.R")) {
      cat("Lancement de", s, "...\n")
      b <- lancer_batterie(s)
      echec <- echec || b$statut != 0L
      bilan <- c(bilan, sprintf("- `Rscript tests/%s` : code de sortie %d", s, b$statut),
                 paste0("  - `", texte_code(b$synthese, 300L), "`"))
    }
  } else {
    bilan <- c(bilan, "Non relanc\u00e9es (`--sans-batteries`). \u00c0 lancer :",
               "- `Rscript tests/test_reproductibilite.R`", "- `Rscript tests/test_unitaires.R`")
  }
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  if (file.exists(dest)) cat("Tableau existant remplace :", dest, "\n")
  con <- file(dest, open = "wb")
  writeLines(enc2utf8(c(md, bilan)), con, sep = "\n", useBytes = TRUE)
  close(con)
  cat("Tableau ecrit :", dest, "\n")
  writeLines(bilan)
  if (echec) {
    cat("\nUNE BATTERIE ECHOUE : reference ecrite mais a examiner (git restore, ou suppression du fichier cree, pour revenir).\n")
    quit(status = 1)
  }
  invisible(TRUE)
}

# Chemin du tableau avant / apres : docs/tableaux/AAAAMMJJ-issueNN-<cas>.md
# (motif que references.yml recherche pour le publier).
chemin_tableau <- function(nom, issue)
  file.path(RACINE, "docs", "tableaux",
            sprintf("%s-issue%s-%s.md", format(Sys.Date(), "%Y%m%d"),
                    if (is.na(issue)) "NN" else issue, nom))

# ---------------------------------------------------------------------------
#  Programme principal : execute seulement par Rscript.
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  ecrire <- "--ecrire" %in% args
  batteries <- !"--sans-batteries" %in% args
  creer <- "--creer" %in% args
  args <- args[!args %in% c("--ecrire", "--sans-batteries", "--creer")]
  opt <- extraire_option(args, "--attendu")
  motifs <- opt$valeurs
  opt_i <- extraire_option(opt$reste, "--issue")
  issue <- if (length(opt_i$valeurs)) opt_i$valeurs else NA
  noms <- opt_i$reste
  if (length(opt_i$valeurs) > 1L) stop("--issue donne plusieurs fois")
  if (!is.na(issue) && !grepl("^[0-9]+$", issue)) stop("--issue : numero attendu, recu ", issue)
  if (length(noms) != 1L) stop("Indiquer exactement un cas : ", paste(names(CAS), collapse = ", "))
  if (!noms %in% names(CAS)) stop("Cas inconnu : ", noms)
  if (ecrire && is.na(issue)) stop("--ecrire exige --issue NN (il nomme le tableau avant / apres).")
  nom <- noms
  commande <- commande_rejouable(nom, motifs, issue, ecrire, batteries, creer = creer)
  ref_f <- chemin_reference(nom)

  # ------------------------------------------------------------ creation (M31)
  if (creer) {
    refuser <- function(motif) {
      cat("\nREFUS -- ", motif, "\nCreation refusee : rien n'a ete ecrit.\n", sep = "")
      quit(status = 1)
    }
    if (length(motifs)) refuser("--creer et --attendu sont incompatibles (une creation n'a pas de motifs attendus).")
    if (!grepl(NOM_CAS_VALIDE, nom)) refuser(sprintf("nom de cas hors de %s.", NOM_CAS_VALIDE))
    if (file.exists(ref_f))
      refuser(sprintf("%s existe deja : une reference existante se regenere (mode regeneration), elle ne se cree pas.", ref_f))
    emp_avant <- empreintes_references(DOSSIER_REF)
    res <- executer_cas(nom)
    if (!isTRUE(res$ok)) refuser(sprintf("run_engine() renvoie ok = FALSE pour le cas %s.", nom))
    dest <- chemin_tableau(nom, issue)
    cat(sprintf("\n=== %s : creation ; %d feuille(s) ; sigma_USP = %.10f\n", nom,
                length(aplatir(res)), res$parametre_final$sigma_usp))
    if (!ecrire) {
      cat(sprintf(paste0("\nEssai a blanc : avec --ecrire, %s serait cree (%d reference(s) existante(s) ",
                         "verifiee(s) inchangee(s) par md5),\nle tableau absent / ajoute ecrit dans %s, ",
                         "puis les batteries relancees.\n"), ref_f, length(emp_avant), dest))
      quit(status = 0)
    }
    creer_reference(res, ref_f)
    emp_apres <- empreintes_references(DOSSIER_REF)
    md <- tableau_creation_markdown(nom, res, basename(ref_f), emp_avant, emp_apres, issue,
                                    commande = commande)
    cat("\n"); writeLines(md)
    modif <- references_modifiees(emp_avant, emp_apres, basename(ref_f))
    if (length(modif)) {
      cat("\nECHEC -- references existantes modifiees ou fichiers inattendus :\n",
          paste0("  ", modif, collapse = "\n"), "\n", sep = "")
      quit(status = 1)
    }
    cat(sprintf("\n%s cree. Verifie avant renommage : reference ecrite identical() au resultat calcule ; %d reference(s) existante(s) de md5 inchange.\n",
                ref_f, length(emp_avant)))
    finir_avec_batteries(md, dest, batteries)
    quit(status = 0)
  }

  # --------------------------------------------------------------- regeneration
  if (!file.exists(ref_f)) stop("Reference absente : ", ref_f, " (un cas nouveau se cree : --creer)")
  avant <- readRDS(ref_f)
  apres <- executer_cas(nom)
  a <- analyser_regeneration(avant, apres, motifs)
  d <- decider(a, ecrire)

  cat(sprintf("\n=== %s : comparaison au seuil %g\n", nom, TOLERANCE))
  cat(resumer_comparaison(a$comparaison_seuil)[1], "\n")
  cat(sprintf("Feuilles non strictement identiques : %d (dont %d designee(s) par les motifs attendus)\n",
              nrow(a$lignes), length(a$designees)))
  for (m in names(a$motifs_larges))
    cat(sprintf("AVERTISSEMENT : le motif %s designe %d feuilles (seuil d'avertissement %d) : trop large ?\n",
                m, a$motifs_larges[[m]], SEUIL_MOTIF_LARGE))

  if (d$action == "rien") {
    cat(sprintf("\n%s : resultat recalcule identical() a la reference -- rien a regenerer (fichier non reecrit, aucun tableau ecrit).\n", nom))
    if (length(d$refus)) {
      cat("REFUS -- ", paste(d$refus, collapse = "\n"), "\n", sep = "")
      cat(if (ecrire) "\nCode de sortie 1 : un changement annonce n'a pas lieu.\n"
          else "\nEssai a blanc : avec --ecrire, code de sortie 1 (changement annonce absent).\n")
    }
    quit(status = d$code)
  }

  md <- tableau_markdown(a, nom, issue, motifs, commande = commande)
  cat("\n"); writeLines(md)
  if (d$action == "refus") {
    cat("\nREFUS -- ", paste(d$refus, collapse = "\n"), "\n", sep = "")
    cat(if (ecrire) "\nRegeneration refusee : rien n'a ete ecrit.\n"
        else "\nEssai a blanc : avec --ecrire, la regeneration serait REFUSEE (rien ne serait ecrit).\n")
    quit(status = d$code)
  }

  dest <- chemin_tableau(nom, issue)
  if (!ecrire) {
    cat(sprintf(paste0("\nEssai a blanc : avec --ecrire, %s serait regeneree (%d feuille(s) designee(s) changent, ",
                       "%d identique(s)),\nle tableau ci-dessus ecrit dans %s, puis les batteries relancees.\n"),
                ref_f, length(a$designees), a$n_identiques, dest))
    quit(status = 0)
  }

  # Regeneration atomique : temporaire du meme dossier (code de
  # generer_references.R), relu et verifie, puis substitue a la reference.
  n_hors <- remplacer_reference(apres, avant, a$designees, ref_f)
  cat(sprintf("\n%s regeneree. Verifie avant substitution : reference ecrite identical() au resultat recalcule ; %d feuille(s) hors motifs identical() a l'ancienne reference.\n",
              ref_f, n_hors))
  finir_avec_batteries(md, dest, batteries)
}
