###############################################################################
#  tests/comparer_references.R  --  TABLEAU AVANT / APRES DES RESULTATS
#
#  Recalcule chaque cas et le compare a la reference enregistree avec le
#  comparateur unique de non-regression (comparer_objets() de
#  outils_tests.R, le meme que test_reproductibilite.R) : liste, grandeur par
#  grandeur, les valeurs en ecart au seuil -- chemin dans l'objet retourne par
#  run_engine(), valeur de reference (avant), nouvelle valeur (apres), ecart
#  (relatif, ou absolu pour une reference nulle ou quasi nulle) --, puis une
#  ligne de synthese par fichier, affichee meme quand tout est conforme :
#  nombre de feuilles non strictement identiques (derive de plateforme
#  comprise) et ecart maximal, avec la feuille qui l'atteint. Sert a
#  documenter un changement de resultats avant de regenerer les references.
#  Ne modifie aucun fichier, hormis, avec --markdown, le fichier designe
#  (en ajout).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/comparer_references.R            # tous les cas
#      Rscript tests/comparer_references.R premium    # un seul cas
#  Options :
#      --tout          inclure les grandeurs de INSTABLES et les champs
#                      EXCLUS_AJUSTEMENT (issue #22), exclus sinon ;
#      --seuil <tol>   afficher les ecarts au-dela de tol au lieu de
#                      TOLERANCE (par ex. --seuil 0 pour lister toutes les
#                      feuilles non strictement identiques) ; n'influe que
#                      sur le seuil d'affichage : ni sur la bascule relatif /
#                      absolu (toujours TOLERANCE), ni sur le critere de la CI ;
#      --markdown <fichier>
#                      ajoute en plus au fichier (mode ajout, UTF-8) le meme
#                      tableau en markdown : une section par cas (etat,
#                      synthese, tableau Feuille | Reference | Valeur | Ecart
#                      | Seuil des grandeurs en ecart au seuil). Sert au
#                      resume du job de CI ($GITHUB_STEP_SUMMARY, issue #66) ;
#      --max-lignes <n>
#                      au plus n lignes de tableau par cas dans le markdown
#                      (defaut 200), les lignes omises etant decomptees ;
#      --max-octets <n>
#                      taille maximale du fichier markdown apres ajout
#                      (defaut 1000000 octets : GitHub borne le resume d'une
#                      etape a 1 Mio) ; au-dela, le texte ajoute est tronque
#                      a une fin de ligne, avec le nombre de lignes omises.
#
#  Une erreur sur un cas (reference illisible, erreur du moteur) est
#  signalee, a l'ecran et dans le markdown, et n'arrete pas les cas
#  suivants ; le code de sortie est alors 1. Sinon 0, que les cas soient
#  conformes ou non : le script est un rapport, le critere de la CI reste
#  test_reproductibilite.R.
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions : markdown_cas() et borner_markdown() sont testees par
#  tests/unitaires/test_comparer_references.R.
###############################################################################

# Dossier tests/ : meme logique que regenerer_et_rendre_compte.R (fourni par
# l'appelant, sinon deduit du chemin du script, sinon du repertoire courant).
DOSSIER_TESTS <- if (exists("DOSSIER_TESTS", envir = environment(), inherits = FALSE)) DOSSIER_TESTS else
  local({
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(f) == 1L && basename(f) == "comparer_references.R") dirname(f)
    else if (file.exists("tests/outils_tests.R")) "tests" else "."
  })
source(file.path(DOSSIER_TESTS, "outils_tests.R"), local = TRUE)

# aplatir() et comparer_objets() sont definies dans outils_tests.R,
# partagees avec test_reproductibilite.R et patcher_reference.R : les chemins
# affiches ici sont exactement les motifs que le patcher accepte, et un ecart
# signale ici est exactement ce qui fait echouer la CI (au seuil TOLERANCE).

# ---------------------------------------------------------------------------
#  Markdown (--markdown, issue #66)
# ---------------------------------------------------------------------------

MAX_LIGNES_CAS <- 200L
MAX_OCTETS_MARKDOWN <- 1000000

# Colonne Seuil : le critere applique a la feuille par comparer_objets().
seuil_applique <- function(mesure, seuil) {
  ifelse(mesure %in% c("relatif", "absolu"), sprintf("%s (%s)", format(seuil), mesure),
  ifelse(mesure == "absente", "feuille absente du r\u00e9sultat",
  ifelse(mesure == "ajoutee", "feuille absente de la r\u00e9f\u00e9rence",
  ifelse(mesure %in% c("non numerique", "non fini"), sprintf("identit\u00e9 exig\u00e9e (%s)", mesure),
         mesure))))
}

# Valeur en police de code (un $ isole ne declenche pas le rendu
# mathematique de GitHub) ; cellule vide laissee vide.
code <- function(x) ifelse(nzchar(x), paste0("`", x, "`"), "")

# Section markdown d'un cas : r, sortie de comparer_objets() ; erreur,
# message d'erreur (r ignore). Au plus max_lignes lignes de tableau, les
# autres decomptees.
markdown_cas <- function(nom, r = NULL, seuil = TOLERANCE, max_lignes = MAX_LIGNES_CAS,
                         erreur = NULL) {
  if (!is.null(erreur))
    return(c(sprintf("### `%s` : ERREUR", nom), "",
             sprintf("Comparaison impossible : `%s`", cellule(erreur, 500L)), ""))
  md <- c(sprintf("### `%s` : %s", nom, if (r$conforme) "CONFORME" else "NON CONFORME"), "",
          sprintf("- Synth\u00e8se : `%s`", cellule(resumer_comparaison(r)[1], 500L)))
  if (length(r$structure))
    md <- c(md, sprintf("- Structure (type ou attributs) diff\u00e9rente : %s%s",
                        paste0("`", cellule(utils::head(r$structure, 20L), 120L), "`", collapse = ", "),
                        if (length(r$structure) > 20L) sprintf(" et %d autre(s)", length(r$structure) - 20L) else ""))
  md <- c(md, "")
  if (!r$n_ecarts) return(md)
  e <- utils::head(r$ecarts, max_lignes)
  ecart <- ifelse(is.na(e$ecart), "", formatC(e$ecart, format = "e", digits = 3))
  md <- c(md,
          "| Feuille | R\u00e9f\u00e9rence | Valeur | \u00c9cart | Seuil |",
          "|---|---|---|---|---|",
          sprintf("| `%s` | %s | %s | %s | %s |", cellule(e$chemin, 120L), code(cellule(e$reference)),
                  code(cellule(e$obtenu)), ecart, seuil_applique(e$mesure, seuil)))
  if (r$n_ecarts > max_lignes)
    md <- c(md, "", sprintf(paste0("*%d ligne(s) omise(s) sur %d (au plus %d par cas) ; liste compl\u00e8te : ",
                                   "`Rscript tests/comparer_references.R %s`.*"),
                            r$n_ecarts - max_lignes, r$n_ecarts, max_lignes,
                            paste0(nom, if (seuil != TOLERANCE) paste(" --seuil", format(seuil)) else "")))
  c(md, "")
}

# En-tete du markdown.
markdown_entete <- function(seuil, tout) {
  c("## \u00c9carts aux r\u00e9f\u00e9rences de non-r\u00e9gression (`tests/comparer_references.R`)", "",
    sprintf("- Plateforme : %s", plateforme()),
    sprintf(paste0("- Comparateur : `comparer_objets()` (tests/outils_tests.R), seuil %s, bascule relatif / absolu %g ; ",
                   "%s"), format(seuil), TOLERANCE,
            if (tout) "`INSTABLES` et `EXCLUS_AJUSTEMENT` inclus (`--tout`)"
            else "`INSTABLES` et `EXCLUS_AJUSTEMENT` neutralis\u00e9s, comme dans `test_reproductibilite.R`"),
    paste0("- Non repris ici : le volet `identical()` de `test_reproductibilite.R` (deux appels \u00e0 graine \u00e9gale) ",
           "et les tests unitaires ; voir le journal de l'\u00e9tape en \u00e9chec."),
    "")
}

# Borne un texte markdown a max_octets octets (UTF-8, fin de ligne comprise
# pour chaque ligne). S'il depasse, garde le plus long debut qui tienne avec
# la mention de troncature, coupe a une fin de ligne (jamais au milieu d'une
# ligne ni d'un caractere), et ajoute la mention du nombre de lignes omises.
# limite : taille annoncee dans la mention (celle du fichier entier quand
# max_octets n'en est que le reste disponible, voir ajouter_markdown()).
borner_markdown <- function(lignes, max_octets = MAX_OCTETS_MARKDOWN, limite = max_octets) {
  lignes <- enc2utf8(lignes)
  octets <- nchar(lignes, type = "bytes") + 1
  if (sum(octets) <= max_octets) return(lignes)
  mention <- function(n) c("", sprintf(paste0(
    "**R\u00e9sum\u00e9 tronqu\u00e9** : %d ligne(s) omise(s) sur %d (limite de %s octets ; ",
    "GitHub borne le r\u00e9sum\u00e9 d'une \u00e9tape \u00e0 1 Mio). Liste compl\u00e8te : ",
    "`Rscript tests/comparer_references.R`."), n, length(lignes), format(limite, scientific = FALSE)))
  reserve <- sum(nchar(enc2utf8(mention(length(lignes))), type = "bytes") + 1)
  if (reserve > max_octets) stop("borner_markdown : max_octets trop petit (", max_octets, ")")
  k <- sum(cumsum(octets) <= max_octets - reserve)
  c(lignes[seq_len(k)], enc2utf8(mention(length(lignes) - k)))
}

# Ajoute les lignes au fichier, en UTF-8, en ne depassant pas max_octets
# pour le fichier entier (contenu deja present compris).
ajouter_markdown <- function(lignes, fichier, max_octets = MAX_OCTETS_MARKDOWN) {
  deja <- if (file.exists(fichier)) file.size(fichier) else 0
  lignes <- borner_markdown(lignes, max_octets - deja, limite = max_octets)
  con <- file(fichier, open = "ab")
  on.exit(close(con))
  writeLines(lignes, con, sep = "\n", useBytes = TRUE)
  invisible(lignes)
}

# ---------------------------------------------------------------------------
#  Programme principal : execute seulement par Rscript.
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  tout <- "--tout" %in% args
  args <- setdiff(args, "--tout")
  seuil <- TOLERANCE
  k <- match("--seuil", args)
  if (!is.na(k)) {
    if (k == length(args)) stop("--seuil sans valeur")
    seuil <- as.numeric(args[k + 1L])
    if (!is.finite(seuil) || seuil < 0) stop("--seuil : valeur invalide")
    args <- args[-c(k, k + 1L)]
  }
  entier_option <- function(opt, defaut) {
    if (!length(opt$valeurs)) return(defaut)
    if (length(opt$valeurs) > 1L) stop("option donnee plusieurs fois")
    v <- suppressWarnings(as.numeric(opt$valeurs))
    if (!is.finite(v) || v < 1 || v != round(v)) stop("valeur entiere positive attendue, recu ", opt$valeurs)
    v
  }
  o_md <- extraire_option(args, "--markdown")
  if (length(o_md$valeurs) > 1L) stop("--markdown donne plusieurs fois")
  fichier_md <- if (length(o_md$valeurs)) o_md$valeurs else NA_character_
  o_l <- extraire_option(o_md$reste, "--max-lignes")
  max_lignes <- entier_option(o_l, MAX_LIGNES_CAS)
  o_o <- extraire_option(o_l$reste, "--max-octets")
  max_octets <- entier_option(o_o, MAX_OCTETS_MARKDOWN)
  noms <- o_o$reste
  if (!length(noms)) noms <- names(CAS)
  inconnus <- setdiff(noms, names(CAS))
  if (length(inconnus)) stop("Cas inconnu(s) : ", paste(inconnus, collapse = ", "))

  md <- markdown_entete(seuil, tout)
  erreurs <- 0L
  for (nom in noms) {
    ref_f <- chemin_reference(nom)
    if (!file.exists(ref_f)) {
      cat(nom, ": reference absente\n\n")
      md <- c(md, markdown_cas(nom, erreur = paste("r\u00e9f\u00e9rence absente :", ref_f)))
      next
    }
    r <- tryCatch({
      avant <- readRDS(ref_f); apres <- executer_cas(nom)
      if (!tout) { avant <- neutraliser_instables(avant); apres <- neutraliser_instables(apres) }
      # --seuil ne change que le seuil de conformite affiche (tol) ; la bascule
      # relatif / absolu reste celle de la CI (TOLERANCE).
      comparer_objets(avant, apres, tol = seuil, bascule = TOLERANCE)
    }, error = function(e) e)
    if (inherits(r, "error")) {
      erreurs <- erreurs + 1L
      cat("=== ", nom, " : ERREUR -- ", conditionMessage(r), "\n\n", sep = "")
      md <- c(md, markdown_cas(nom, erreur = conditionMessage(r)))
      next
    }
    cat("=== ", nom, " : ", r$n_ecarts, " grandeur(s) en ecart au seuil ",
        format(seuil), "\n", sep = "")
    if (r$n_ecarts) {
      tab <- r$ecarts
      names(tab)[names(tab) == "reference"] <- "avant"
      names(tab)[names(tab) == "obtenu"] <- "apres"
      tab$ecart <- ifelse(is.na(tab$ecart), "", formatC(tab$ecart, digits = 3, format = "e"))
      print(tab, row.names = FALSE, right = FALSE)
    }
    if (length(r$structure))
      cat("Structure (type ou attributs) differente :", paste(r$structure, collapse = ", "), "\n")
    cat("Synthese :", resumer_comparaison(r)[1], "\n\n")
    md <- c(md, markdown_cas(nom, r, seuil, max_lignes))
  }
  if (!is.na(fichier_md)) {
    ecrit <- ajouter_markdown(md, fichier_md, max_octets)
    cat(sprintf("Markdown ajoute a %s : %d ligne(s)%s.\n", fichier_md, length(ecrit),
                if (identical(ecrit, enc2utf8(md))) "" else " (tronque)"))
  }
  if (erreurs) quit(status = 1)
}
