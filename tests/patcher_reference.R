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
#  INVARIANT DE SURETE, verifie avant toute ecriture : le patch n'introduit
#  AUCUNE valeur numerique finie. Il ne peut poser que des chaines, des NA,
#  des booleens, ou supprimer une entree -- c'est-a-dire uniquement des
#  grandeurs insensibles a la plateforme. Un changement de resultat NUMERIQUE
#  (sigma_USP, p-value, statistique) n'est pas patchable et reste soumis a la
#  regeneration sur la plateforme de reference (ADR 0006), avec le visa du
#  mainteneur sur le tableau avant / apres.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/patcher_reference.R <cas> --motif "<regex>" [--motif ...]
#      Rscript tests/patcher_reference.R <cas> --motif "<regex>" --ecrire
#
#  Sans --ecrire, le script ne fait qu'afficher ce qu'il ferait (essai a
#  blanc). Les motifs sont des expressions regulieres appliquees aux chemins
#  aplatis, ceux qu'affiche tests/comparer_references.R
#  (ex. "^tests\\[\\[33\\]\\]\\$", "^bootstrap\\$p_mc\\[\"MeanZ\"\\]$").
#
#  Voir : docs/adr/0006-plateforme-de-production-des-references.md
###############################################################################

source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R")

# Au-dela de ce seuil relatif, un ecart non designe par un motif n'est plus
# imputable a la derive de plateforme mesuree dans l'ADR 0006 : le script le
# signale comme suspect plutot que de le laisser passer en silence.
SEUIL_DERIVE <- 1e-6

# ---------------------------------------------------------------------------
#  Aplatissement (identique a celui de comparer_references.R : les chemins
#  affiches par l'un sont les motifs utilisables par l'autre).
# ---------------------------------------------------------------------------

aplatir <- function(o, chemin = "") {
  if (is.data.frame(o)) o <- as.list(o)
  if (is.list(o)) {
    nm <- names(o)
    res <- list()
    for (k in seq_along(o)) {
      etiq <- if (!is.null(nm) && nzchar(nm[k])) paste0("$", nm[k]) else sprintf("[[%d]]", k)
      res <- c(res, aplatir(o[[k]], paste0(chemin, etiq)))
    }
    return(res)
  }
  if (length(o) <= 1) return(stats::setNames(list(o), sub("^\\$", "", chemin)))
  noms_el <- if (!is.null(names(o))) paste0("[\"", names(o), "\"]") else sprintf("[%d]", seq_along(o))
  stats::setNames(as.list(o), paste0(sub("^\\$", "", chemin), noms_el))
}

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

assigner <- function(o, pas, valeur) {
  if (length(pas) == 1L) { o[[pas[[1L]]]] <- valeur; return(o) }
  o[[pas[[1L]]]] <- assigner(o[[pas[[1L]]]], pas[-1L], valeur)
  o
}

retirer <- function(o, pas) {
  if (length(pas) == 1L) {
    cle <- pas[[1L]]
    if (is.list(o)) { o[[cle]] <- NULL; return(o) }
    if (is.character(cle)) return(o[names(o) != cle])
    return(o[-cle])
  }
  o[[pas[[1L]]]] <- retirer(o[[pas[[1L]]]], pas[-1L])
  o
}

# ---------------------------------------------------------------------------
#  Arguments
# ---------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)
ecrire <- "--ecrire" %in% args
args <- args[args != "--ecrire"]
motifs <- character(0)
noms <- character(0)
k <- 1L
while (k <= length(args)) {
  if (identical(args[k], "--motif")) {
    if (k == length(args)) stop("--motif sans valeur")
    motifs <- c(motifs, args[k + 1L]); k <- k + 2L
  } else { noms <- c(noms, args[k]); k <- k + 1L }
}
if (length(noms) != 1L) stop("Indiquer exactement un cas : ", paste(names(CAS), collapse = ", "))
if (!noms %in% names(CAS)) stop("Cas inconnu : ", noms)
if (!length(motifs)) stop("Aucun motif : le patch doit designer explicitement ce qu'il change.")
nom <- noms

# ---------------------------------------------------------------------------
#  Comparaison
# ---------------------------------------------------------------------------

ref_f <- chemin_reference(nom)
if (!file.exists(ref_f)) stop("Reference absente : ", ref_f)
avant <- readRDS(ref_f)
apres <- executer_cas(nom)

fa <- aplatir(avant); fb <- aplatir(apres)
cles <- union(names(fa), names(fb))
differents <- Filter(function(cle) !isTRUE(all.equal(fa[[cle]], fb[[cle]], tolerance = TOLERANCE)), cles)

designes <- Filter(function(cle) any(vapply(motifs, grepl, logical(1), x = cle)), cles)
inutiles <- setdiff(designes, differents)
a_patcher <- intersect(designes, differents)
laisses   <- setdiff(differents, designes)

fmt <- function(v) if (is.null(v)) "(absent)" else paste(format(v, digits = 12), collapse = " ")

cat(sprintf("\n=== %s : %d grandeur(s) differente(s) de la reference\n", nom, length(differents)))

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

cat(sprintf("\n--- PATCHEES (%d) : reprises du resultat recalcule\n", length(a_patcher)))
for (cle in a_patcher)
  cat(sprintf("  %-34s %-28s -> %s\n", cle, substr(fmt(fa[[cle]]), 1, 28), substr(fmt(fb[[cle]]), 1, 40)))

cat(sprintf("\n--- LAISSEES (%d) : conservees a leur valeur de reference\n", length(laisses)))
ecarts <- stats::setNames(vapply(laisses, function(cle) {
  a <- fa[[cle]]; b <- fb[[cle]]
  if (is.numeric(a) && is.numeric(b) && length(a) == 1L && length(b) == 1L &&
      is.finite(a) && is.finite(b) && a != 0) abs(b - a) / abs(a) else NA_real_
}, numeric(1)), laisses)
for (cle in laisses)
  cat(sprintf("  %-34s %-24s vs %-24s  rel=%s\n", cle,
              substr(fmt(fa[[cle]]), 1, 24), substr(fmt(fb[[cle]]), 1, 24),
              formatC(ecarts[[cle]], format = "e", digits = 2)))
if (length(laisses))
  cat(sprintf("  ecart relatif maximal : %s\n", formatC(max(ecarts, na.rm = TRUE), format = "e", digits = 3)))

suspects <- laisses[is.na(ecarts) | ecarts > SEUIL_DERIVE]
if (length(suspects)) {
  cat("\nSUSPECT -- ecart non numerique ou superieur au seuil de derive ",
      formatC(SEUIL_DERIVE, format = "e", digits = 0), " :\n", sep = "")
  for (cle in suspects) cat("  ", cle, "\n")
  stop("Des ecarts non designes ne sont pas imputables a la derive de plateforme : le patch est refuse.")
}

# ---------------------------------------------------------------------------
#  Invariant de surete : aucune valeur numerique finie introduite
# ---------------------------------------------------------------------------

introduits <- Filter(function(cle) {
  v <- fb[[cle]]
  !is.null(v) && is.numeric(v) && any(is.finite(v))
}, a_patcher)
if (length(introduits)) {
  cat("\nREFUS -- ces grandeurs introduiraient une valeur numerique produite ici :\n")
  for (cle in introduits) cat(sprintf("  %-34s -> %s\n", cle, fmt(fb[[cle]])))
  stop("Un changement de resultat numerique n'est pas patchable : regenerer sur la plateforme de l'ADR 0006.")
}
cat("\nInvariant verifie : le patch n'introduit aucune valeur numerique finie.\n")

# ---------------------------------------------------------------------------
#  Application
# ---------------------------------------------------------------------------

patche <- avant
supprimes <- Filter(function(cle) !cle %in% names(fb), a_patcher)
poses     <- setdiff(a_patcher, supprimes)
for (cle in poses) patche <- assigner(patche, decouper(cle), fb[[cle]])
# Suppressions en dernier, et par index decroissant : retirer une entree
# decale les suivantes dans le meme conteneur.
for (cle in rev(sort(supprimes))) {
  pas <- decouper(cle)
  if (existe(patche, pas)) patche <- retirer(patche, pas)
}

# ---------------------------------------------------------------------------
#  Verification du resultat du patch
# ---------------------------------------------------------------------------

fp <- aplatir(patche)
# 1. Tout ce qui n'est pas patche est au bit pres celui de la reference.
intacts <- setdiff(names(fa), a_patcher)
trahis <- Filter(function(cle) !identical(fa[[cle]], fp[[cle]]), intacts)
if (length(trahis)) {
  for (cle in head(trahis, 20)) cat("  ", cle, ":", fmt(fa[[cle]]), "->", fmt(fp[[cle]]), "\n")
  stop(length(trahis), " grandeur(s) non designee(s) ont bouge : le patch est refuse.")
}
cat(sprintf("Verifie : les %d grandeurs non designees sont identiques au bit pres a la reference.\n",
            length(intacts)))

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

# 4. Ce que verra la CI.
verdict_ci <- all.equal(patche, apres, tolerance = TOLERANCE)
if (!isTRUE(verdict_ci)) {
  cat("\ntest_reproductibilite.R resterait ROUGE :\n"); print(verdict_ci)
  stop("Le patch ne rend pas la non-regression verte.")
}
cat(sprintf("Verifie : all.equal(patche, recalcule, tolerance = %g) vaut TRUE -- la CI passe au vert.\n", TOLERANCE))

if (!ecrire) {
  cat("\nEssai a blanc : rien n'a ete ecrit. Relancer avec --ecrire pour appliquer.\n")
} else {
  saveRDS(patche, ref_f, version = 3)
  cat(sprintf("\n%s : reference patchee (%d grandeur(s)).\n", nom, length(a_patcher)))
}
