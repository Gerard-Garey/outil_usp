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
#  verifier_regeneration() et tableau_markdown() sont testees par
#  tests/unitaires/test_regenerer_et_rendre_compte.R.
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

# Longueur maximale d'une valeur affichee dans le tableau (caracteres).
LARGEUR_CELLULE <- 60L

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
commande_rejouable <- function(nom, motifs, issue, ecrire, batteries) {
  sq <- function(x) paste0("'", gsub("'", "'\\''", x, fixed = TRUE), "'")
  paste(c("Rscript tests/regenerer_et_rendre_compte.R", nom,
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

# Cellule de tableau : une ligne, pas de barre verticale ni d'accent grave
# non echappes, tronquee lisiblement au-dela de largeur caracteres.
une_ligne <- function(x) trimws(gsub("[\r\n\t]+", " ", x))
echapper <- function(x) gsub("|", "\\|", gsub("`", "'", x, fixed = TRUE), fixed = TRUE)
cellule <- function(x, largeur = LARGEUR_CELLULE) {
  x <- une_ligne(x)
  long <- nchar(x) > largeur
  x[long] <- sprintf("%s\u2026 (%d car.)", substr(x[long], 1L, largeur - 1L), nchar(x[long]))
  echapper(x)
}

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

plateforme <- function() sprintf("%s, %s", R.version.string, Sys.info()[["sysname"]])

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
      sprintf(" (%s, `%s`)", a$comparaison$mesure_max, cellule(a$comparaison$feuille_max)))
  c(sprintf("# Tableau avant / apr\u00e8s \u2014 r\u00e9f\u00e9rence `%s`%s", nom,
            if (is.na(issue)) "" else sprintf(" (issue #%s)", issue)),
    "",
    sprintf("- Date : %s", format(date, "%Y-%m-%d")),
    sprintf("- Plateforme : %s", plateforme_txt),
    if (!is.na(commande)) sprintf("- Commande : `%s`", cellule(commande, 500L)),
    sprintf("- Motifs attendus : %s",
            if (length(motifs)) paste0("`", cellule(motifs, 200L), "`", collapse = ", ") else "(aucun)"),
    sprintf("- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil 0 pour lister, seuil %g pour juger ; `INSTABLES` non neutralis\u00e9", TOLERANCE),
    "",
    synthese,
    "",
    if (length(a$motifs_larges))
      c(sprintf("**Avertissement** : motif `%s` : %d feuilles d\u00e9sign\u00e9es (seuil d'avertissement %d) ; v\u00e9rifier qu'il n'est pas trop large.",
                cellule(names(a$motifs_larges), 200L), a$motifs_larges, SEUIL_MOTIF_LARGE), ""),
    if (length(a$comparaison$structure))
      c(sprintf("N\u0153uds de structure modifi\u00e9s (type ou attributs) : %s",
                paste0("`", cellule(a$comparaison$structure), "`", collapse = ", ")), ""),
    "| Feuille | Avant | Apr\u00e8s | \u00c9cart | Mesure |",
    "|---|---|---|---|---|",
    if (nrow(l)) {
      paires <- lapply(seq_len(nrow(l)), function(i) cellules_paire(avant[i], apres[i]))
      sprintf("| `%s` | %s | %s | %s | %s |", cellule(l$chemin, 120L),
              vapply(paires, `[[`, character(1), "avant"), vapply(paires, `[[`, character(1), "apres"),
              ecart, mesure)
    })
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

# ---------------------------------------------------------------------------
#  Programme principal : execute seulement par Rscript.
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  ecrire <- "--ecrire" %in% args
  batteries <- !"--sans-batteries" %in% args
  args <- args[!args %in% c("--ecrire", "--sans-batteries")]
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
  commande <- commande_rejouable(nom, motifs, issue, ecrire, batteries)

  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) stop("Reference absente : ", ref_f)
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

  dest <- file.path(RACINE, "docs", "tableaux",
                    sprintf("%s-issue%s-%s.md", format(Sys.Date(), "%Y%m%d"),
                            if (is.na(issue)) "NN" else issue, nom))
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

  bilan <- c("", "## Batteries", "")
  echec <- FALSE
  if (batteries) {
    for (s in c("test_reproductibilite.R", "test_unitaires.R")) {
      cat("Lancement de", s, "...\n")
      b <- lancer_batterie(s)
      echec <- echec || b$statut != 0L
      bilan <- c(bilan, sprintf("- `Rscript tests/%s` : code de sortie %d", s, b$statut),
                 paste0("  - `", cellule(b$synthese, 300L), "`"))
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
    cat("\nUNE BATTERIE ECHOUE : reference regeneree mais a examiner (git restore pour revenir).\n")
    quit(status = 1)
  }
}
