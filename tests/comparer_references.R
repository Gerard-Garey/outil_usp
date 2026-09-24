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
#                      a une fin de ligne, avec le nombre de lignes omises ;
#                      si la place restante ne suffit pas meme a cette
#                      mention, rien n'est ajoute (avertissement a l'ecran) ;
#      --deux-parts    tableau de BASCULE de plateforme (issue #67, Q-O4) :
#                      toute feuille non strictement identique est listee
#                      (seuil d'affichage 0, incompatible avec --seuil), en
#                      deux parts. Part numerique : feuilles numeriques
#                      finies des deux cotes (mesure relatif ou absolu de
#                      comparer_objets()) de type double, c'est-a-dire la
#                      derive de plateforme attendue. Part non numerique :
#                      tout le reste -- valeur ENTIERE modifiee (un
#                      decompte qui change n'est pas de la derive ; mesure
#                      "entier modifie"), chaine, booleen, verdict, NA ou valeur non
#                      finie d'un cote, type ou attributs differents, feuille
#                      absente ou ajoutee, structure differente --, qui doit
#                      etre VIDE. Code de sortie 1 (bascule refusee, message
#                      explicite) si la part non numerique n'est pas vide ou
#                      si un ecart numerique depasse TOLERANCE (ce ne serait
#                      plus de la derive). Console : liste complete, triee
#                      par ecart decroissant ; markdown : les deux parts,
#                      chacune plafonnee a --max-lignes. Incompatible avec
#                      --tout : la bascule juge ce que juge la CI.
#
#  Une erreur sur un cas (reference absente ou illisible, erreur du moteur) est
#  signalee, a l'ecran et dans le markdown, et n'arrete pas les cas
#  suivants ; le code de sortie est alors 1. Sinon 0, que les cas soient
#  conformes ou non : le script est un rapport, le critere de la CI reste
#  test_reproductibilite.R. Seule exception : --deux-parts, dont le code 1
#  signale aussi une bascule refusee (voir ci-dessus).
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions : markdown_cas(), borner_markdown(), separer_parts(),
#  refus_bascule() et markdown_deux_parts() sont testees par
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
# mathematique de GitHub) ; cellule vide laissee vide ; valeur manquante
# (na = TRUE, voir reference_na / obtenu_na de comparer_objets()) affichee
# <NA> hors police de code, pour la distinguer de la chaine "NA" (`NA`).
# Les chevrons sont echappes : nu, <NA> serait lu par GitHub comme une
# balise HTML et omis.
code <- function(x, na = rep(FALSE, length(x)))
  ifelse(na, "\\<NA\\>", ifelse(nzchar(x), paste0("`", x, "`"), ""))

# Section markdown d'un cas : r, sortie de comparer_objets() ; erreur,
# message d'erreur (r ignore). Au plus max_lignes lignes de tableau, les
# autres decomptees.
markdown_cas <- function(nom, r = NULL, seuil = TOLERANCE, max_lignes = MAX_LIGNES_CAS,
                         erreur = NULL) {
  if (!is.null(erreur))
    return(c(sprintf("### `%s` : ERREUR", nom), "",
             sprintf("Comparaison impossible : `%s`", texte_code(erreur, 500L)), ""))
  md <- c(sprintf("### `%s` : %s", nom, if (r$conforme) "CONFORME" else "NON CONFORME"), "",
          sprintf("- Synth\u00e8se : `%s`", texte_code(resumer_comparaison(r)[1], 500L)))
  if (length(r$structure))
    md <- c(md, sprintf("- Structure (type ou attributs) diff\u00e9rente : %s%s",
                        paste0("`", texte_code(utils::head(r$structure, 20L), 120L), "`", collapse = ", "),
                        if (length(r$structure) > 20L) sprintf(" et %d autre(s)", length(r$structure) - 20L) else ""))
  md <- c(md, "")
  if (!r$n_ecarts) return(md)
  e <- utils::head(r$ecarts, max_lignes)
  ecart <- ifelse(is.na(e$ecart), "", formatC(e$ecart, format = "e", digits = 3))
  md <- c(md,
          "| Feuille | R\u00e9f\u00e9rence | Valeur | \u00c9cart | Seuil |",
          "|---|---|---|---|---|",
          sprintf("| `%s` | %s | %s | %s | %s |", cellule(e$chemin, 120L), code(cellule(e$reference), e$reference_na),
                  code(cellule(e$obtenu), e$obtenu_na), ecart, seuil_applique(e$mesure, seuil)))
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
  if (reserve > max_octets)
    stop(structure(class = c("markdown_trop_petit", "error", "condition"),
                   list(message = paste0("borner_markdown : max_octets trop petit (", max_octets, ")"),
                        call = sys.call())))
  k <- sum(cumsum(octets) <= max_octets - reserve)
  c(lignes[seq_len(k)], enc2utf8(mention(length(lignes) - k)))
}

# Ajoute les lignes au fichier, en UTF-8, en ne depassant pas max_octets
# pour le fichier entier (contenu deja present compris). Si la place
# restante ne suffit pas meme a la mention de troncature, n'ajoute rien,
# avertit en console et renvoie character(0) : le markdown n'est qu'un
# rapport, son absence ne doit pas faire echouer l'etape.
ajouter_markdown <- function(lignes, fichier, max_octets = MAX_OCTETS_MARKDOWN) {
  deja <- if (file.exists(fichier)) file.size(fichier) else 0
  lignes <- tryCatch(borner_markdown(lignes, max_octets - deja, limite = max_octets),
                     markdown_trop_petit = function(e) NULL)
  if (is.null(lignes)) {
    cat(sprintf(paste0("AVERTISSEMENT : markdown non ajoute a %s : place restante (%s octets sur %s) ",
                       "insuffisante meme pour la mention de troncature.\n"),
                fichier, format(max_octets - deja, scientific = FALSE),
                format(max_octets, scientific = FALSE)))
    return(invisible(character(0)))
  }
  con <- file(fichier, open = "ab")
  on.exit(close(con))
  writeLines(lignes, con, sep = "\n", useBytes = TRUE)
  invisible(lignes)
}

# ---------------------------------------------------------------------------
#  Tableau de bascule en deux parts (--deux-parts, issue #67, Q-O4)
# ---------------------------------------------------------------------------

# Mesures de comparer_objets() qui relevent de la part numerique : feuille
# numerique, finie des deux cotes, de meme type et memes attributs, et de
# type double. Toute autre mesure (non numerique, non fini, absente,
# ajoutee, ordre ou doublons) releve de la part non numerique, de meme
# qu'une feuille ENTIERE (integer) modifiee : un decompte qui change n'est
# pas de la derive d'arrondi, quelle que soit la taille de l'ecart ; elle
# y figure sous la mesure "entier modifie".
MESURES_NUMERIQUES <- c("relatif", "absolu")

# Separe en deux parts la sortie de comparer_objets() appelee au seuil 0
# (toute feuille non strictement identique figure alors dans r$ecarts).
# ref : l'objet de reference compare (sert a reperer les feuilles
# entieres). Renvoie list(numerique, non_numerique, structure) : les deux
# data.frame de r$ecarts, la part numerique triee par ecart decroissant ;
# structure, les noeuds dont le type ou les attributs different (part non
# numerique).
separer_parts <- function(r, ref) {
  if (!identical(r$tolerance, 0))
    stop("separer_parts : comparer_objets() doit etre appelee au seuil 0 (tol = 0)")
  fa <- aplatir(ref)
  entiers <- names(fa)[vapply(fa, is.integer, logical(1))]
  num <- r$ecarts$mesure %in% MESURES_NUMERIQUES
  ent <- num & r$ecarts$chemin %in% entiers
  r$ecarts$mesure[ent] <- "entier modifie"
  num <- num & !ent
  numerique <- r$ecarts[num, , drop = FALSE]
  numerique <- numerique[order(-numerique$ecart), , drop = FALSE]
  list(numerique = numerique, non_numerique = r$ecarts[!num, , drop = FALSE],
       structure = r$structure)
}

# Motifs de refus de la bascule pour un cas (character(0) si aucun) : part
# non numerique non vide ; ecart numerique au-dela de tol (TOLERANCE, le
# seuil de la CI), qui ne serait plus de la derive de plateforme.
refus_bascule <- function(p, tol = TOLERANCE) {
  n_nn <- nrow(p$non_numerique); n_st <- length(p$structure)
  n_ent <- sum(p$non_numerique$mesure == "entier modifie")
  n_au_dela <- sum(p$numerique$ecart > tol)
  c(if (n_nn || n_st)
      sprintf(paste0("part non numerique non vide : %d feuille(s)%s%s -- une chaine, un booleen, un verdict ",
                     "ou un decompte qui differe n'est pas de la derive de plateforme"), n_nn,
              if (n_ent) sprintf(" dont %d valeur(s) entiere(s) modifiee(s)", n_ent) else "",
              if (n_st) sprintf(", %d noeud(s) de structure", n_st) else ""),
    if (n_au_dela)
      sprintf("%d ecart(s) numerique(s) au-dela du seuil %g de la CI : ce n'est plus de la derive de plateforme",
              n_au_dela, tol))
}

# Section markdown d'un cas en deux parts : p, sortie de separer_parts() ;
# n_feuilles, nombre de feuilles de la reference. Chaque part est plafonnee
# a max_lignes lignes, les autres decomptees.
markdown_deux_parts <- function(nom, p, n_feuilles, max_lignes = MAX_LIGNES_CAS, tol = TOLERANCE) {
  refus <- refus_bascule(p, tol)
  tableau <- function(e) {
    if (!nrow(e)) return(character(0))
    t <- utils::head(e, max_lignes)
    ecart <- ifelse(is.na(t$ecart), "", formatC(t$ecart, format = "e", digits = 3))
    c("| Feuille | R\u00e9f\u00e9rence | Valeur | \u00c9cart | Mesure |", "|---|---|---|---|---|",
      sprintf("| `%s` | %s | %s | %s | %s |", cellule(t$chemin, 120L), code(cellule(t$reference), t$reference_na),
              code(cellule(t$obtenu), t$obtenu_na), ecart, t$mesure),
      if (nrow(e) > max_lignes)
        c("", sprintf("*%d ligne(s) omise(s) sur %d (au plus %d par part) ; liste compl\u00e8te dans le journal.*",
                      nrow(e) - max_lignes, nrow(e), max_lignes)))
  }
  pn <- p$numerique
  c(sprintf("### `%s` : %s", nom, if (length(refus)) "BASCULE REFUS\u00c9E" else "d\u00e9rive num\u00e9rique seule"), "",
    sprintf(paste0("- Part num\u00e9rique : %d feuille(s) non strictement identique(s) sur %d ; \u00e9cart maximal %s%s ; ",
                   "%d au-del\u00e0 du seuil %g de la CI"),
            nrow(pn), n_feuilles, if (nrow(pn)) formatC(pn$ecart[1], format = "e", digits = 3) else "0",
            if (nrow(pn)) sprintf(" (%s, `%s`)", pn$mesure[1], texte_code(pn$chemin[1], 120L)) else "",
            sum(pn$ecart > tol), tol),
    sprintf("- Part non num\u00e9rique (doit \u00eatre vide) : %d feuille(s)%s", nrow(p$non_numerique),
            if (length(p$structure))
              sprintf(" ; structure (type ou attributs) diff\u00e9rente : %s",
                      paste0("`", texte_code(utils::head(p$structure, 20L), 120L), "`", collapse = ", "))
            else ""),
    if (length(refus)) paste0("- **Refus** : ", texte_code(refus, 300L)), "",
    if (nrow(p$non_numerique)) c("#### Part non num\u00e9rique", "", tableau(p$non_numerique), ""),
    if (nrow(pn)) c("#### Part num\u00e9rique (\u00e9cart d\u00e9croissant)", "", tableau(pn), ""))
}

# ---------------------------------------------------------------------------
#  Programme principal : execute seulement par Rscript.
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  tout <- "--tout" %in% args
  deux_parts <- "--deux-parts" %in% args
  args <- setdiff(args, c("--tout", "--deux-parts"))
  seuil <- TOLERANCE
  k <- match("--seuil", args)
  if (!is.na(k) && deux_parts) stop("--deux-parts impose le seuil d'affichage 0 : --seuil incompatible")
  if (tout && deux_parts)
    stop("--deux-parts juge ce que juge la CI (INSTABLES et EXCLUS_AJUSTEMENT neutralises) : --tout incompatible")
  if (deux_parts) seuil <- 0
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
  if (deux_parts)
    md <- c(md, paste0("Tableau de **bascule** (`--deux-parts`) : part num\u00e9rique (d\u00e9rive de plateforme attendue) ",
                       "et part non num\u00e9rique (cha\u00eenes, bool\u00e9ens, verdicts, valeurs non finies, structure), ",
                       "qui doit \u00eatre vide."), "")
  erreurs <- 0L
  refus <- character(0)
  for (nom in noms) {
    ref_f <- chemin_reference(nom)
    if (!file.exists(ref_f)) {
      erreurs <- erreurs + 1L
      cat("=== ", nom, " : ERREUR -- reference absente : ", ref_f, "\n\n", sep = "")
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
    if (deux_parts) {
      p <- separer_parts(r, avant)
      rf <- refus_bascule(p)
      refus <- c(refus, if (length(rf)) paste0(nom, " : ", rf))
      cat("=== ", nom, " : ", if (length(rf)) "BASCULE REFUSEE" else "derive numerique seule", "\n", sep = "")
      montrer <- function(titre, e) {
        cat(sprintf("--- %s : %d feuille(s)\n", titre, nrow(e)))
        if (!nrow(e)) return(invisible())
        e$ecart <- ifelse(is.na(e$ecart), "", formatC(e$ecart, digits = 3, format = "e"))
        e$reference[e$reference_na] <- NA; e$obtenu[e$obtenu_na] <- NA
        e$reference_na <- e$obtenu_na <- NULL
        op <- options(width = 250L); on.exit(options(op))
        print(e, row.names = FALSE, right = FALSE, max = .Machine$integer.max)
      }
      montrer("Part non numerique (doit etre vide)", p$non_numerique)
      if (length(p$structure))
        cat("Structure (type ou attributs) differente :", paste(p$structure, collapse = ", "), "\n")
      montrer("Part numerique (ecart decroissant)", p$numerique)
      cat(sprintf(paste0("Synthese : %d feuille(s) ; part numerique %d, ecart maximal %s, %d au-dela du seuil %g ",
                         "de la CI ; part non numerique %d feuille(s), %d noeud(s) de structure\n"),
                  r$n_feuilles, nrow(p$numerique),
                  formatC(if (nrow(p$numerique)) p$numerique$ecart[1] else 0, format = "e", digits = 3),
                  sum(p$numerique$ecart > TOLERANCE), TOLERANCE, nrow(p$non_numerique), length(p$structure)))
      for (m in rf) cat("REFUS :", m, "\n")
      cat("\n")
      md <- c(md, markdown_deux_parts(nom, p, r$n_feuilles, max_lignes))
      next
    }
    cat("=== ", nom, " : ", r$n_ecarts, " grandeur(s) en ecart au seuil ",
        format(seuil), "\n", sep = "")
    if (r$n_ecarts) {
      tab <- r$ecarts
      names(tab)[names(tab) == "reference"] <- "avant"
      names(tab)[names(tab) == "obtenu"] <- "apres"
      tab$ecart <- ifelse(is.na(tab$ecart), "", formatC(tab$ecart, digits = 3, format = "e"))
      # Valeur manquante affichee <NA> par print(), distincte de la chaine "NA".
      tab$avant[tab$reference_na] <- NA; tab$apres[tab$obtenu_na] <- NA
      tab$reference_na <- tab$obtenu_na <- NULL
      print(tab, row.names = FALSE, right = FALSE)
    }
    if (length(r$structure))
      cat("Structure (type ou attributs) differente :", paste(r$structure, collapse = ", "), "\n")
    cat("Synthese :", resumer_comparaison(r)[1], "\n\n")
    md <- c(md, markdown_cas(nom, r, seuil, max_lignes))
  }
  if (!is.na(fichier_md)) {
    ecrit <- ajouter_markdown(md, fichier_md, max_octets)
    if (length(ecrit)) cat(sprintf("Markdown ajoute a %s : %d ligne(s)%s.\n", fichier_md, length(ecrit),
                if (identical(ecrit, enc2utf8(md))) "" else " (tronque)"))
  }
  if (length(refus)) {
    cat("\nBASCULE REFUSEE -- ne pas commiter ces references :\n", paste0("  ", refus, "\n"), sep = "")
    cat(paste0("Une feuille non numerique qui differe entre plateformes est un libelle qui imprime encore un ",
               "artefact de l'optimiseur (M18, M23, M24) : retirer le libelle fautif (ou l'exclure, motif a ",
               "l'appui) dans le moteur, puis relancer la bascule.\n"))
  }
  if (erreurs || length(refus)) quit(status = 1)
}
