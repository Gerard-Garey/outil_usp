###############################################################################
#  tests/patcher_reference.R  --  PATCH CHIRURGICAL D'UNE REFERENCE
#
#  Met a jour tests/reference/<cas>.rds en ne touchant QUE les grandeurs
#  designees par des motifs explicites, et en laissant toutes les autres a
#  leur valeur enregistree, au bit pres.
#
#  Pourquoi ce script existe. Regenerer une reference (generer_references.R)
#  reecrit les ~12 400 valeurs du fichier avec celles de la machine qui lance
#  la commande : une regeneration faite ailleurs que sur la plateforme
#  designee par l'ADR 0006 y injecte une derive de plateforme (mesuree :
#  jusqu'a 3,5e-07 en relatif sur les tirages bootstrap de la branche
#  lognormale) que plus rien ne distingue ensuite du changement voulu par la
#  PR. Le patch chirurgical fait l'inverse : il prend dans le resultat
#  recalcule les seules grandeurs que la PR change, et ne touche a rien
#  d'autre.
#
#  INVARIANT DE SURETE, verifie avant toute ecriture : le patch ne pose
#  AUCUNE valeur numerique. Il n'accepte que des chaines, des booleens, des
#  NA, ou la suppression d'une entree -- c'est-a-dire uniquement des
#  grandeurs insensibles a la plateforme. Sont explicitement REFUSES : tout
#  nombre fini, NaN, Inf, -Inf, et tout objet porteur d'attributs autres que
#  names (facteur, Date, difftime...), dont la valeur sous-jacente est un
#  nombre. Un changement de resultat NUMERIQUE (sigma_USP, p-value,
#  statistique) n'est donc pas patchable et reste soumis a la regeneration
#  sur la plateforme de reference (ADR 0006), avec le visa du mainteneur sur
#  le tableau avant / apres.
#
#  CE SCRIPT NE NEUTRALISE PAS `INSTABLES` (ni les champs exclus par
#  conception `EXCLUS_AJUSTEMENT`, issue #22), a la difference de
#  comparer_references.R qui le fait par defaut pour l'affichage. C'est
#  voulu : comparer_references.R produit un TABLEAU, ou masquer une grandeur
#  connue pour dependre de la plateforme le rend lisible ; le present script
#  ECRIT le fichier, et y masquer une difference reviendrait a la laisser
#  passer sans qu'elle soit nommee. Les deux outils ne regardent donc pas
#  tout a fait le meme objet, et c'est le patcher qui regarde le plus.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/patcher_reference.R <cas> --motif "<regex>" [--motif ...]
#      Rscript tests/patcher_reference.R <cas> --motif "<regex>" --ecrire
#
#  Sans --ecrire, le script ne fait qu'afficher ce qu'il ferait (essai a
#  blanc). Avec --ecrire et aucune grandeur a patcher, le fichier n'est pas
#  reecrit. Les motifs sont des expressions regulieres appliquees aux chemins
#  aplatis, ceux qu'affiche tests/comparer_references.R.
#
#  Source (plutot que lance par Rscript), le fichier ne fait que definir ses
#  fonctions, dont patcher_objets(avant, apres, motifs) qui porte tout le
#  patch sans lire ni ecrire de fichier : c'est ce que teste
#  tests/unitaires/test_patcher_reference.R.
#
#  Voir : docs/adr/0006-plateforme-de-production-des-references.md
#  (l'amendement du 22 septembre 2026 decrit la procedure ; il est introduit
#  par la branche de la PR #17, qui doit donc etre fusionnee AVANT toute
#  branche qui emploie ce script.)
###############################################################################

# Dossier tests/ : fourni par l'appelant (DOSSIER_TESTS, pose dans
# l'environnement d'evaluation par le test unitaire, qui connait son propre
# chemin), sinon deduit du chemin de ce script lance par Rscript, sinon du
# repertoire courant (racine ou tests/).
DOSSIER_TESTS <- if (exists("DOSSIER_TESTS", envir = environment(), inherits = FALSE)) DOSSIER_TESTS else
  local({
    f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
    if (length(f) == 1L && basename(f) == "patcher_reference.R") dirname(f)
    else if (file.exists("tests/outils_tests.R")) "tests" else "."
  })
# local = TRUE : lance par Rscript, le fichier est evalue dans l'environnement
# global et rien ne change ; source par un test unitaire dans un environnement
# dedie, outils_tests.R y est evalue, et le moteur qu'il charge (lui aussi
# avec local = TRUE) y reste confine.
source(file.path(DOSSIER_TESTS, "outils_tests.R"), local = TRUE)

# Seuil de derive : c'est TOLERANCE (outils_tests.R), le seuil de la CI.
# "Different" signifie ici non conforme au sens de ecart_feuille(), la regle
# feuille par feuille de la non-regression (ADR 0006, second amendement) : un
# ecart en deca du seuil est de la derive de plateforme, laissee a sa valeur
# de reference sans etre listee ; un ecart au-dela, s'il n'est pas designe
# par un motif, n'est pas imputable a cette derive et fait refuser le patch.

# aplatir(), ecart_feuille() et comparer_objets() vivent dans outils_tests.R,
# partages avec comparer_references.R et test_reproductibilite.R : la
# garantie du present script est que les chemins affiches par l'un sont les
# motifs utilisables par l'autre, et qu'un ecart y a le meme sens que pour la
# CI ; deux copies d'une meme fonction sont le moyen le plus sur de perdre
# cette garantie.

# ---------------------------------------------------------------------------
#  Chemins : decoupage en pas d'acces, lecture, ecriture, suppression.
#  Les quatre formes produites par aplatir() -- $nom, [[k]], ["nom"], [k] --
#  s'accedent toutes par [[ ]], avec une cle caractere ou entiere.
# ---------------------------------------------------------------------------

decouper <- function(chemin) {
  pas <- list()
  reste <- chemin
  # Le premier pas n'a pas de $ introducteur.
  m <- regexpr("^[^$\\[]+", reste)
  if (m == -1L) stop("Chemin illisible : ", chemin)
  pas[[1]] <- regmatches(reste, m)
  reste <- substring(reste, attr(m, "match.length") + 1L)
  while (nzchar(reste)) {
    if (grepl("^\\$", reste)) {
      m <- regexpr("^\\$[^$\\[]+", reste)
      pas[[length(pas) + 1L]] <- substring(regmatches(reste, m), 2L)
    } else if (grepl("^\\[\\[", reste)) {
      m <- regexpr("^\\[\\[[0-9]+\\]\\]", reste)
      pas[[length(pas) + 1L]] <- as.integer(gsub("[^0-9]", "", regmatches(reste, m)))
    } else if (grepl("^\\[\"", reste)) {
      m <- regexpr("^\\[\"[^\"]*\"\\]", reste)
      txt <- regmatches(reste, m)
      pas[[length(pas) + 1L]] <- substring(txt, 3L, nchar(txt) - 2L)
    } else if (grepl("^\\[", reste)) {
      m <- regexpr("^\\[[0-9]+\\]", reste)
      pas[[length(pas) + 1L]] <- as.integer(gsub("[^0-9]", "", regmatches(reste, m)))
    } else stop("Chemin illisible : ", chemin)
    if (m == -1L) stop("Chemin illisible : ", chemin)
    reste <- substring(reste, attr(m, "match.length") + 1L)
  }
  pas
}

existe <- function(o, pas) {
  for (p in pas) {
    if (is.null(o)) return(FALSE)
    if (is.character(p)) { if (!p %in% names(o)) return(FALSE) }
    else if (p > length(o)) return(FALSE)
    o <- o[[p]]
  }
  TRUE
}

lire <- function(o, pas) {
  for (p in pas) {
    if (is.null(o)) return(NULL)
    if (is.character(p) && !p %in% names(o)) return(NULL)
    if (is.numeric(p) && p > length(o)) return(NULL)
    o <- o[[p]]
  }
  o
}

assigner <- function(o, pas, valeur) {
  if (length(pas) == 1L) { o[[pas[[1L]]]] <- valeur; return(o) }
  o[[pas[[1L]]]] <- assigner(o[[pas[[1L]]]], pas[-1L], valeur)
  o
}

# Retire PLUSIEURS entrees d'un MEME conteneur en une seule operation. C'est
# ce qui supprime toute question d'ordre : o[c(9, 10)] <- NULL retire les deux
# positions simultanement, la ou deux retraits successifs decalent la seconde.
# Le tri lexicographique employe auparavant -- rev(sort()) sur des chaines --
# placait "tests[[9]]" AVANT "tests[[10]]" et retirait les elements 9 et 11
# (constat d'audit, mesure). Cette voie n'existe plus.
retirer_lot <- function(o, cles) {
  car <- vapply(cles, is.character, logical(1))
  if (any(car) && !all(car))
    stop("Suppressions melangeant noms et indices dans un meme conteneur : patch refuse.")
  k <- unlist(cles)
  if (is.list(o)) { o[k] <- NULL; return(o) }
  if (all(car)) return(o[!names(o) %in% k])
  o[-k]
}

retirer_groupe <- function(o, pas_parent, cles) {
  if (!length(pas_parent)) return(retirer_lot(o, cles))
  o[[pas_parent[[1L]]]] <- retirer_groupe(o[[pas_parent[[1L]]]], pas_parent[-1L], cles)
  o
}

# Tous les attributs de l'arbre SAUF names, qui change legitimement des qu'une
# entree est retiree. aplatir() ne voit ni dim, ni class, ni row.names
# (constat d'audit) : cette fonction ferme l'angle mort.
attributs_arbre <- function(o, chemin = "") {
  a <- attributes(o)
  a <- a[setdiff(names(a), "names")]
  res <- if (length(a)) stats::setNames(list(a), chemin) else list()
  if (is.list(o)) {
    nm <- names(o)
    for (k in seq_along(o)) {
      etiq <- if (!is.null(nm) && nzchar(nm[k])) paste0("$", nm[k]) else sprintf("[[%d]]", k)
      res <- c(res, attributs_arbre(o[[k]], paste0(chemin, etiq)))
    }
  }
  res
}

# Valeur posable par un patch : rien qui soit un nombre, ni qui en cache un.
valeur_sans_nombre <- function(v) {
  if (is.null(v)) return(TRUE)
  if (length(v) == 0L) return(FALSE)
  if (length(setdiff(names(attributes(v)), "names"))) return(FALSE)
  if (is.character(v) || is.logical(v)) return(TRUE)
  # NA_real_ et NA_integer_ sont acceptes : ce sont des absences de valeur, pas
  # des nombres. NaN et les infinis sont refuses : ce sont des resultats.
  if (is.numeric(v)) return(all(is.na(v)) && !any(is.nan(v)))
  FALSE
}

# ---------------------------------------------------------------------------
#  Vecteurs de textes qui franchissent la longueur 1 (issue #32)
#
#  aplatir() range un vecteur de longueur <= 1 sous son propre chemin
#  (validation$avertissements) et un vecteur plus long sous des chemins
#  indexes (validation$avertissements[1], [2]...). Quand un vecteur passe
#  d'une forme a l'autre (1 -> 2 ou 2 -> 1), le meme objet apparait donc sous
#  deux familles de chemins disjointes : le chemin nu d'un cote, les chemins
#  indexes de l'autre. Traites feuille par feuille, les uns etaient poses et
#  les autres supprimes, et la suppression du chemin nu (ou des indices)
#  effacait ce qui venait d'etre ecrit. Un tel groupe est desormais traite
#  comme ce qu'il est : le remplacement d'UN vecteur, repris en entier du
#  resultat recalcule.
# ---------------------------------------------------------------------------

# Chemin du vecteur porteur d'une feuille indexee : retire le dernier pas
# [k] ou ["nom"] (crochets simples). Un chemin sans ce suffixe est rendu tel
# quel ; [[k]] (element de liste) n'est pas un suffixe de vecteur.
racine_vecteur <- function(cles) sub("(\\[[0-9]+\\]|\\[\"[^\"]*\"\\])$", "", cles)

# Chemins nus P tels que P ET au moins une feuille indexee P[...] figurent
# parmi les chemins a patcher : ce sont les vecteurs qui ont change de forme.
vecteurs_franchissant <- function(cles) {
  racines <- racine_vecteur(cles)
  indexees <- racines != cles
  unique(racines[indexees & racines %in% cles[!indexees]])
}

# ---------------------------------------------------------------------------
#  Patch d'un objet par un autre : comparaison, controles, application,
#  verification. Renvoie l'objet patche, ou s'arrete (stop) si le patch est
#  refuse. Aucune lecture ni ecriture de fichier : c'est ce qui rend la
#  fonction testable (tests/unitaires/test_patcher_reference.R).
# ---------------------------------------------------------------------------

patcher_objets <- function(avant, apres, motifs, nom = "objet") {
  fa <- aplatir(avant); fb <- aplatir(apres)

  # Un chemin en double signale une ambiguite d'aplatissement (un nom contenant
  # $, [ ou ") : motifs et decoupage deviendraient indeterministes.
  for (etiq in list(list("reference", fa), list("resultat recalcule", fb)))
    if (anyDuplicated(names(etiq[[2L]])))
      stop("Chemins ambigus dans le ", etiq[[1L]], " : ",
           paste(unique(names(etiq[[2L]])[duplicated(names(etiq[[2L]]))]), collapse = ", "))

  cles <- union(names(fa), names(fb))
  # Un chemin absent d'un cote vaut NULL : ecart_feuille() le juge non
  # conforme (NULL n'est identical() qu'a NULL).
  jugements <- stats::setNames(lapply(cles, function(cle) ecart_feuille(fa[[cle]], fb[[cle]], TOLERANCE)), cles)
  differents <- Filter(function(cle) !isTRUE(jugements[[cle]]$conforme), cles)

  designes <- designer(cles, motifs)
  inutiles <- setdiff(designes, differents)
  a_patcher <- intersect(designes, differents)
  laisses   <- setdiff(differents, designes)

  fmt <- function(v) if (is.null(v)) "(absent)" else paste(format(v, digits = 12), collapse = " ")

  cat(sprintf("\n=== %s : %d grandeur(s) differente(s) de la reference au seuil %g\n",
              nom, length(differents), TOLERANCE))
  cat("Comparaison avant patch :", resumer_comparaison(comparer_objets(avant, apres))[1], "\n")

  if (length(inutiles)) {
    cat("\nMOTIF SANS EFFET -- ces chemins sont designes mais ne different pas :\n")
    for (cle in inutiles) cat("  ", cle, "\n")
  }
  motifs_morts <- Filter(function(m) !any(grepl(m, cles)), motifs)
  if (length(motifs_morts)) {
    cat("\nMOTIF QUI NE FILTRE RIEN (faute de frappe ?) :\n")
    for (m in motifs_morts) cat("  ", m, "\n")
    stop("Motif sans correspondance : le patch est refuse.")
  }

  # Le decoupage de chaque chemin designe est confronte a la valeur aplatie : un
  # chemin mal lu est attrape ici, au lieu de faire ecrire au mauvais endroit.
  for (cle in a_patcher) {
    dans_apres <- cle %in% names(fb)
    attendu <- if (dans_apres) fb[[cle]] else fa[[cle]]
    src <- if (dans_apres) apres else avant
    if (!identical(lire(src, decouper(cle)), attendu))
      stop("Chemin mal interprete : ", cle, " -- le patch est refuse.")
  }

  cat(sprintf("\n--- PATCHEES (%d) : reprises du resultat recalcule\n", length(a_patcher)))
  for (cle in a_patcher)
    cat(sprintf("  %-34s %-28s -> %s\n", cle, substr(fmt(fa[[cle]]), 1, 28), substr(fmt(fb[[cle]]), 1, 40)))

  cat(sprintf("\n--- LAISSEES (%d) : conservees a leur valeur de reference\n", length(laisses)))
  for (cle in laisses)
    cat(sprintf("  %-34s %-24s vs %-24s  %s=%s\n", cle,
                substr(fmt(fa[[cle]]), 1, 24), substr(fmt(fb[[cle]]), 1, 24),
                jugements[[cle]]$mesure, formatC(jugements[[cle]]$ecart, format = "e", digits = 2)))

  # Par construction, toute grandeur laissee est en ecart au seuil TOLERANCE
  # (non numerique, non finie, absente d'un cote ou au-dela du seuil) : elle
  # n'est pas imputable a la derive de plateforme, que ce seuil absorbe.
  if (length(laisses)) {
    cat("\nSUSPECT -- ecart non designe, non numerique ou superieur au seuil de derive ",
        formatC(TOLERANCE, format = "e", digits = 0), " :\n", sep = "")
    for (cle in laisses) cat("  ", cle, "\n")
    stop("Des ecarts non designes ne sont pas imputables a la derive de plateforme : le patch est refuse.")
  }

  # ---------------------------------------------------------------------------
  #  Invariant de surete : aucune valeur numerique posee
  # ---------------------------------------------------------------------------

  introduits <- Filter(function(cle) !valeur_sans_nombre(fb[[cle]]), a_patcher)
  if (length(introduits)) {
    cat("\nREFUS -- ces grandeurs poseraient une valeur produite sur cette plateforme :\n")
    for (cle in introduits) cat(sprintf("  %-34s -> %s (%s)\n", cle, fmt(fb[[cle]]), class(fb[[cle]])[1L]))
    stop("Un changement de resultat numerique n'est pas patchable : regenerer sur la plateforme de l'ADR 0006.")
  }
  # Un vecteur remplace en entier (issue #32) est pose tel quel, noms compris :
  # l'invariant est verifie sur l'objet pose, pas seulement sur ses feuilles.
  vecteurs <- vecteurs_franchissant(a_patcher)
  for (v in vecteurs) {
    val <- lire(apres, decouper(v))
    if (is.list(val) || !valeur_sans_nombre(val)) {
      cat(sprintf("\nREFUS -- le vecteur %s poserait : %s (%s)\n", v, fmt(val), class(val)[1L]))
      stop("Un changement de resultat numerique n'est pas patchable : regenerer sur la plateforme de l'ADR 0006.")
    }
  }
  cat("\nInvariant verifie : le patch ne pose aucune valeur numerique (chaines, booleens, NA, suppressions).\n")

  # ---------------------------------------------------------------------------
  #  Application
  # ---------------------------------------------------------------------------

  patche <- avant
  # Vecteurs qui ont change de forme (issue #32) : chemin nu et chemins
  # indexes forment un seul remplacement, retire des poses et suppressions
  # feuille a feuille. Le vecteur existe dans les deux objets (seule sa forme
  # aplatie change) : le remplacer ne deplace aucune entree de son conteneur.
  couverts <- a_patcher[racine_vecteur(a_patcher) %in% vecteurs]
  for (v in vecteurs) patche <- assigner(patche, decouper(v), lire(apres, decouper(v)))
  reste     <- setdiff(a_patcher, couverts)
  supprimes <- Filter(function(cle) !cle %in% names(fb), reste)
  poses     <- setdiff(reste, supprimes)
  for (cle in poses) patche <- assigner(patche, decouper(cle), fb[[cle]])

  # Suppressions en dernier, regroupees par conteneur parent, les conteneurs les
  # plus profonds d'abord : un parent n'est jamais modifie avant les suppressions
  # qui le traversent.
  if (length(supprimes)) {
    pas_tous <- lapply(supprimes, decouper)
    parents <- vapply(pas_tous, function(p) paste(utils::head(p, -1L), collapse = "\r"), character(1))
    prof <- vapply(pas_tous, function(p) length(p) - 1L, numeric(1))
    uniq <- unique(parents)
    uniq <- uniq[order(vapply(uniq, function(u) prof[match(u, parents)], numeric(1)), decreasing = TRUE)]
    for (par in uniq) {
      idx <- which(parents == par)
      pas_parent <- utils::head(pas_tous[[idx[1L]]], -1L)
      cles_feuille <- lapply(idx, function(i) pas_tous[[i]][[length(pas_tous[[i]])]])
      patche <- retirer_groupe(patche, pas_parent, cles_feuille)
    }
  }

  # ---------------------------------------------------------------------------
  #  Verification du resultat du patch
  # ---------------------------------------------------------------------------

  fp <- aplatir(patche)
  # 1. Toute feuille non designee est au bit pres celle de la reference.
  intacts <- setdiff(names(fa), a_patcher)
  trahis <- Filter(function(cle) !identical(fa[[cle]], fp[[cle]]), intacts)
  if (length(trahis)) {
    for (cle in utils::head(trahis, 20)) cat("  ", cle, ":", fmt(fa[[cle]]), "->", fmt(fp[[cle]]), "\n")
    stop(length(trahis), " grandeur(s) non designee(s) ont bouge : le patch est refuse.")
  }
  cat(sprintf("Verifie : les %d FEUILLES non designees sont identiques au bit pres a la reference.\n",
              length(intacts)))

  # 1 bis. Les attributs (dim, class, row.names...) echappent a l'aplatissement :
  # ils sont compares a part, names exclu puisqu'une suppression le change.
  att_a <- attributs_arbre(avant); att_p <- attributs_arbre(patche)
  if (!identical(att_a, att_p)) {
    cat("  attributs divergents : ",
        paste(union(setdiff(names(att_a), names(att_p)), setdiff(names(att_p), names(att_a))),
              collapse = ", "), "\n")
    stop("Les attributs de l'objet patche different de ceux de la reference : le patch est refuse.")
  }
  cat(sprintf("Verifie : les attributs de l'arbre (%d porteurs, names exclu) sont identiques a la reference.\n",
              length(att_a)))

  # 2. Les grandeurs patchees valent bien celles du resultat recalcule.
  faux <- Filter(function(cle) !identical(fb[[cle]], fp[[cle]]), a_patcher)
  if (length(faux)) {
    for (cle in faux) cat("  ", cle, ":", fmt(fb[[cle]]), "vs", fmt(fp[[cle]]), "\n")
    stop(length(faux), " grandeur(s) designee(s) n'ont pas ete posees : le patch est refuse.")
  }
  cat(sprintf("Verifie : les %d grandeurs designees valent celles du resultat recalcule.\n", length(a_patcher)))

  # 3. La structure du fichier patche est celle du resultat recalcule.
  if (!identical(names(fp), names(fb)))
    stop("La structure du fichier patche differe de celle du resultat recalcule : patch refuse.")
  cat("Verifie : structure identique a celle du resultat recalcule.\n")

  # 4. Ce que verra la CI : le comparateur unique de test_reproductibilite.R
  #    (comparer_objets(), chemins, structure et chaque feuille au seuil
  #    TOLERANCE), la reference patchee tenant lieu de reference. C'est le
  #    dernier filet, et le seul qui porte sur l'objet entier. Comme
  #    test_reproductibilite.R, on neutralise ici les grandeurs exclues de la
  #    comparaison (neutraliser_instables()) : cette etape predit le verdict de
  #    la CI, elle ne change rien a ce qui est ecrit.
  verdict_ci <- comparer_objets(neutraliser_instables(patche),
                                neutraliser_instables(apres), tol = TOLERANCE)
  if (!verdict_ci$conforme) {
    cat("\ntest_reproductibilite.R resterait ROUGE :\n")
    cat(paste0("  ", resumer_comparaison(verdict_ci), collapse = "\n"), "\n")
    stop("Le patch ne rend pas la non-regression verte.")
  }
  cat("Verifie : comparer_objets(patche, recalcule) est conforme -- la CI passe au vert.\n")
  cat("  ", resumer_comparaison(verdict_ci)[1], "\n", sep = "")
  invisible(list(patche = patche, a_patcher = a_patcher))
}

# ---------------------------------------------------------------------------
#  Programme principal : execute seulement par Rscript. Source par un autre
#  script (test unitaire), le fichier ne definit que ses fonctions.
# ---------------------------------------------------------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  ecrire <- "--ecrire" %in% args
  args <- args[args != "--ecrire"]
  # Lecture des motifs : extraire_option() de outils_tests.R, partagee avec
  # regenerer_et_rendre_compte.R (--attendu).
  opt <- extraire_option(args, "--motif")
  motifs <- opt$valeurs
  noms <- opt$reste
  if (length(noms) != 1L) stop("Indiquer exactement un cas : ", paste(names(CAS), collapse = ", "))
  if (!noms %in% names(CAS)) stop("Cas inconnu : ", noms)
  if (!length(motifs)) stop("Aucun motif : le patch doit designer explicitement ce qu'il change.")
  nom <- noms

  ref_f <- chemin_reference(nom)
  if (!file.exists(ref_f)) stop("Reference absente : ", ref_f)
  r <- patcher_objets(readRDS(ref_f), executer_cas(nom), motifs, nom)

  if (!ecrire) {
    cat("\nEssai a blanc : rien n'a ete ecrit. Relancer avec --ecrire pour appliquer.\n")
  } else if (!length(r$a_patcher)) {
    # Patch vide : reecrire le fichier changerait ses octets (md5) sans rien
    # changer a son contenu. On ne touche pas au fichier.
    cat(sprintf("\n%s : aucune grandeur a patcher, reference laissee intacte (fichier non reecrit).\n", nom))
  } else {
    saveRDS(r$patche, ref_f, version = 3)
    cat(sprintf("\n%s : reference patchee (%d grandeur(s)).\n", nom, length(r$a_patcher)))
    cat("Motifs employes :\n"); for (m in motifs) cat("  ", m, "\n")
  }
}
