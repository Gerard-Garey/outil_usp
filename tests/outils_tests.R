###############################################################################
#  tests/outils_tests.R  --  OUTILS COMMUNS AUX TESTS DE NON-REGRESSION
#
#  Definit les cas de test (une methode, un jeu de donnees, des parametres) et
#  la maniere d'executer le moteur pour chacun, et le comparateur unique de
#  non-regression (comparer_objets). Source par test_reproductibilite.R,
#  generer_references.R, comparer_references.R et patcher_reference.R ;
#  R base uniquement.
###############################################################################

# Repertoire racine du depot : les scripts peuvent etre lances depuis la
# racine, depuis tests/ ou depuis tests/unitaires/ (la batterie unitaire
# charge ce fichier via patcher_reference.R).
RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
          if (file.exists("../../R/engine.R")) "../.." else
          stop("R/engine.R introuvable : lancer depuis la racine du depot.")
# local = TRUE : le moteur est charge dans l'environnement ou ce fichier est
# evalue. Source normalement (test_reproductibilite.R, generer_references.R,
# comparer_references.R), c'est l'environnement global, comme auparavant ;
# source avec local = TRUE dans un environnement dedie (patcher_reference.R
# charge par un test unitaire), le moteur y reste confine au lieu d'etre
# recharge dans l'environnement global. Le moteur est toujours recharge ici,
# jamais repris d'une session : une reference ne doit pas etre produite par
# une version perimee de R/engine.R.
source(file.path(RACINE, "R", "engine.R"), local = TRUE)

DOSSIER_REF <- file.path(RACINE, "tests", "reference")

# Tolerance de comparaison aux references, appliquee a CHAQUE valeur
# elementaire par comparer_objets() (plus bas) : relative si |reference| >
# TOLERANCE, absolue sinon. Decision M9 du mainteneur (issue #14, point 1 ;
# ADR 0006, second amendement) : 1e-6, soit environ trois fois la derive
# maximale mesuree entre le poste du mainteneur (plateforme de production des
# references) et Linux R 4.3.3 (3,508e-07 sur bootstrap$sigma_boot). Seuil
# empirique, cale sur cette mesure : il absorbe la derive d'optimiseur entre
# plateformes et detecte, valeur par valeur, tout changement de methode.
TOLERANCE <- 1e-6

.ln  <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
.tri <- local({
  df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")])
  storage.mode(m) <- "double"
  unname(m)
})

# Chaque cas est un appel complet de run_engine() avec ses parametres par
# defaut (B = 999, graine 20260831, alpha = 0,10).
CAS <- list(
  premium  = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium",
                                   segment = 1, annexe = "II"),
  reserve1 = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "reserve1",
                                   segment = 1, annexe = "II"),
  reserve2 = function() run_engine(methode = "reserve2", triangle = .tri,
                                   segment = 1, annexe = "II")
)

# Retire les champs qui varient d'un appel a l'autre ou d'une machine a
# l'autre sans rapport avec les calculs.
nettoyer <- function(res) {
  res$metadata[c("horodatage", "duree_sec", "version_R")] <- NULL
  res
}

executer_cas <- function(nom) nettoyer(CAS[[nom]]())

# Resultats CONNUS pour dependre de la plateforme, exclus provisoirement de la
# comparaison aux references (pas du controle de reproductibilite a graine
# egale, qui reste integral). Chaque entree renvoie a l'issue qui la justifie
# et doit etre retiree une fois l'issue resolue.
#
# La liste est VIDE : la seule entree qu'elle ait comportee (issue #3, p-value
# Monte-Carlo du centrage des residus, qui se decidait au signe du bruit
# d'arrondi) est sans objet depuis que le centrage et la variance unitaire
# sont restitues comme diagnostics et que MeanZ et VarZ ont quitte les
# statistiques simulees (ADR 0001). Le mecanisme est conserve pour un futur
# cas. N'y ajouter une grandeur que si, a code identique, son ecart d'une
# plateforme a l'autre DEPASSE la tolerance de comparaison TOLERANCE (valeur
# par valeur, voir comparer_objets()) : les ecarts d'arrondi inferieurs a
# cette tolerance sont la regle et sont precisement ce qu'elle absorbe.
INSTABLES <- list()

# Champs de res$ajustement EXCLUS PAR CONCEPTION de la comparaison aux
# references (decision du mainteneur, issue #22). Categorie distincte de
# INSTABLES : l'exclusion ne repose pas sur un constat de CI entre
# plateformes mais sur la nature de la grandeur, etablie sur une meme
# machine. Grandeur dont la valeur attendue est un residu ~0 dependant du
# demarrage retenu ; mesure : 54 points d'arret a objectif egal (1,88e-12),
# g_gamma dans [-3,8e-7 ; 1,09e-5] ; issue #22. Les champs restent dans
# l'objet resultat ; restent compares le pas de Newton (stat du controle et
# pas_newton_gamma, en absolu), hessien_gamma, les verdicts, les comptes de
# demarrages, delta et gamma estimes.
EXCLUS_AJUSTEMENT <- c("gradient", "gradient_projete")

# Remplace par NA les grandeurs instables (INSTABLES) et les champs exclus par
# conception (EXCLUS_AJUSTEMENT), dans le resultat comme dans la reference,
# avant comparaison. Les NA conservent la longueur et les noms du champ : la
# structure de l'objet reste comparee.
neutraliser_instables <- function(res) {
  if (is.list(res$ajustement))
    for (champ in EXCLUS_AJUSTEMENT)
      if (!is.null(res$ajustement[[champ]])) res$ajustement[[champ]][] <- NA_real_
  for (ins in INSTABLES) {
    for (k in seq_along(res$tests)) {
      if (identical(res$tests[[k]]$test, ins$test))
        res$tests[[k]][c("p_mc", "err_mc", "p_retenue", "verdict")] <- NA
    }
    for (champ in c("p_mc", "err_mc")) {
      if (ins$mc_nom %in% names(res$bootstrap[[champ]]))
        res$bootstrap[[champ]][[ins$mc_nom]] <- NA
    }
  }
  res
}

chemin_reference <- function(nom) file.path(DOSSIER_REF, paste0(nom, ".rds"))

# Aplatit un objet en feuilles atomiques nommees par leur chemin
# (ex. "parametre_final$sigma_usp", "tests[[12]]$p_mc", "donnees$xt[3]").
# Partage par comparer_references.R et patcher_reference.R : le second prend
# pour motifs les chemins que le premier affiche, et deux copies d'une meme
# fonction seraient le moyen le plus sur de perdre cette correspondance.
# Attention : l'aplatissement ne restitue que les FEUILLES. Les attributs
# (dim, class, row.names) et les listes vides n'y apparaissent pas ; toute
# verification qui doit porter sur l'objet ENTIER passe par comparer_objets(),
# qui y ajoute la comparaison de structure_arbre().
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
#  COMPARATEUR UNIQUE DE NON-REGRESSION (issue #14, point 1 ; ADR 0006,
#  second amendement)
#
#  Une seule definition de "meme resultat", employee par
#  test_reproductibilite.R (volet non-regression), comparer_references.R
#  (tableau avant / apres) et patcher_reference.R (tri des grandeurs
#  differentes et verification 4). Aucune de ces trois utilisations ne doit
#  recopier la regle : elles appellent ecart_feuille() ou comparer_objets().
# ---------------------------------------------------------------------------

# Structure de l'arbre : pour chaque noeud (liste, data.frame, vecteur
# atomique), son type et TOUS ses attributs (names, dim, class, row.names...),
# indexes par le chemin du noeud dans la notation d'aplatir(). C'est ce
# qu'aplatir() perd : il ne restitue que les feuilles, sans dim, class ni
# row.names, et une liste vide n'y produit aucune feuille.
# Comparaison par identical() : les attributs rencontres dans les references
# sont des chaines et des entiers (mesure au moment de l'issue #14 :
# class, names, row.names, dim, de type character ou integer uniquement),
# insensibles a la plateforme. Un futur attribut numerique en double precision
# serait donc juge au bit pres, ce qui peut produire une fausse alerte mais
# jamais laisser passer un ecart.
structure_arbre <- function(o, chemin = "") {
  res <- stats::setNames(list(list(type = typeof(o), attributs = attributes(o))),
                         if (nzchar(chemin)) sub("^\\$", "", chemin) else "(racine)")
  if (is.list(o)) {
    nm <- names(o)
    for (k in seq_along(o)) {
      etiq <- if (!is.null(nm) && nzchar(nm[k])) paste0("$", nm[k]) else sprintf("[[%d]]", k)
      res <- c(res, structure_arbre(o[[k]], paste0(chemin, etiq)))
    }
  }
  res
}

# Juge UNE feuille atomique (sortie d'aplatir()) de la reference, ref, contre
# celle du resultat courant, val. Renvoie list(conforme, ecart, mesure) :
#   mesure = "identique"     : identical(ref, val) ; ecart = 0 ;
#            "relatif"       : |val - ref| / |ref|, compare a tol ;
#            "absolu"        : |val - ref|, compare a tol ;
#            "non numerique" : feuille non numerique (chaine, booleen, facteur,
#                              NULL...) ou de type ou d'attributs differents
#                              d'un cote a l'autre : seule identical() vaut ;
#            "non fini"      : NA, NaN ou +-Inf d'un cote au moins, non
#                              identiques : ecart.
# Regle pour une feuille numerique (valeurs finies) :
#   si |ref| > bascule : |val - ref| / |ref| <= tol   (tolerance relative)
#   sinon              : |val - ref|         <= tol   (tolerance absolue)
# avec, pour la CI, tol = bascule = TOLERANCE. C'est la regle de
# all.equal.numeric appliquee a chaque valeur. all.equal, lui, descend
# composant par composant et, dans un vecteur, juge la difference relative
# moyenne des seuls elements differents (countEQ = FALSE) : un changement
# localise y etait donc detecte s'il etait seul, mais dilue des que les
# autres elements du meme vecteur derivaient aussi -- le cas reel des
# tirages bootstrap (issue #14). Ici aucune moyenne n'intervient.
# Les deux roles sont separes : tol est le seuil de conformite, bascule le
# seuil |ref| en deca duquel l'ecart est mesure en absolu. Abaisser tol (par
# ex. comparer_references.R --seuil 0, pour afficher toute feuille non
# identique) ne doit pas deplacer la bascule, faute de quoi un bruit
# d'arrondi de 1e-16 sur une grandeur nulle se lirait en relatif (ecart
# d'ordre 1) et masquerait la vraie derive. La bascule vers
# l'absolu est necessaire : une grandeur nulle par construction (residu,
# somme centree des residus Sum sqrt(pi_t) z_t) vaut ~1e-16 par pur arrondi,
# et son ecart relatif d'une plateforme a l'autre serait d'ordre 1 sans
# qu'aucun resultat ait change.
# Plus strict que all.equal sur un point : une feuille entiere (integer)
# contre une feuille double de meme valeur est un ecart (changement de type,
# donc de code), la ou all.equal les tient pour egales.
ecart_feuille <- function(ref, val, tol = TOLERANCE, bascule = TOLERANCE) {
  if (identical(ref, val)) return(list(conforme = TRUE, ecart = 0, mesure = "identique"))
  numerique <- is.numeric(ref) && is.numeric(val) && identical(typeof(ref), typeof(val)) &&
               length(ref) == 1L && length(val) == 1L &&
               identical(attributes(ref), attributes(val))
  if (!numerique) return(list(conforme = FALSE, ecart = NA_real_, mesure = "non numerique"))
  if (!is.finite(ref) || !is.finite(val))
    return(list(conforme = FALSE, ecart = NA_real_, mesure = "non fini"))
  d <- abs(as.numeric(val) - as.numeric(ref))
  if (abs(ref) > bascule) { e <- d / abs(as.numeric(ref)); m <- "relatif" }
  else                    { e <- d;                        m <- "absolu" }
  list(conforme = e <= tol, ecart = e, mesure = m)
}

# Compare l'objet obtenu a la reference, feuille par feuille, plus la
# structure. Renvoie une liste auditable :
#   conforme       : TRUE si et seulement si memes chemins, meme structure et
#                    toutes les feuilles conformes (ecart_feuille) ;
#   tolerance      : tol employee (bascule relatif / absolu : argument
#                    bascule, TOLERANCE par defaut, voir ecart_feuille()) ;
#   n_feuilles     : nombre de feuilles de la reference ;
#   n_differentes  : feuilles non strictement identiques (derive comprise) ;
#   n_ecarts       : feuilles non conformes (au-dela de tol, ou non
#                    numeriques differentes, ou absentes d'un cote) ;
#   ecart_max      : plus grand ecart numerique mesure (relatif ou absolu,
#                    tous deux compares a tol), 0 si tout est identique ;
#   feuille_max, mesure_max : ou il est atteint et selon quelle mesure ;
#   ecarts         : data.frame des feuilles non conformes (chemin, reference,
#                    obtenu, ecart, mesure), chemins absents compris ;
#   structure      : chemins des noeuds dont le type ou les attributs
#                    different (character(0) si aucun).
comparer_objets <- function(ref, obtenu, tol = TOLERANCE, bascule = TOLERANCE) {
  fa <- aplatir(ref); fb <- aplatir(obtenu)
  na <- names(fa); nb <- names(fb)
  fmt <- function(v) if (is.null(v)) "(absent)" else if (!length(v)) sprintf("%s(0)", typeof(v)) else
    paste(if (is.numeric(v)) formatC(v, digits = 10, format = "g") else as.character(v), collapse = " ")

  lignes <- list()
  ajouter <- function(chemin, a, b, ecart, mesure)
    lignes[[length(lignes) + 1L]] <<- data.frame(chemin = chemin, reference = fmt(a), obtenu = fmt(b),
                                                 ecart = ecart, mesure = mesure, stringsAsFactors = FALSE)

  # Chemins : memes chemins, dans le meme ordre. Un chemin en double (nom
  # contenant $, [ ou ") rendrait l'appariement par nom ambigu : on apparie
  # alors par position si les deux listes de chemins sont identiques, ce qui
  # reste exact ; sinon l'ecart est deja etabli et l'appariement par nom ne
  # sert qu'au diagnostic.
  memes_chemins <- identical(na, nb)
  if (!memes_chemins) {
    for (ch in setdiff(na, nb)) ajouter(ch, fa[[ch]], NULL, NA_real_, "absente")
    for (ch in setdiff(nb, na)) ajouter(ch, NULL, fb[[ch]], NA_real_, "ajoutee")
    if (!length(setdiff(na, nb)) && !length(setdiff(nb, na)))
      ajouter("(ordre des feuilles)", NULL, NULL, NA_real_, "ordre ou doublons")
  }
  paires <- if (memes_chemins) seq_along(na) else match(intersect(na, nb), na)
  ib <- if (memes_chemins) seq_along(nb) else match(intersect(na, nb), nb)

  n_diff <- 0L; e_max <- 0; f_max <- NA_character_; m_max <- NA_character_
  for (k in seq_along(paires)) {
    a <- fa[[paires[k]]]; b <- fb[[ib[k]]]
    j <- ecart_feuille(a, b, tol, bascule)
    if (identical(j$mesure, "identique")) next
    n_diff <- n_diff + 1L
    if (!is.na(j$ecart) && j$ecart > e_max) { e_max <- j$ecart; f_max <- na[paires[k]]; m_max <- j$mesure }
    if (!isTRUE(j$conforme)) ajouter(na[paires[k]], a, b, j$ecart, j$mesure)
  }

  sa <- structure_arbre(ref); sb <- structure_arbre(obtenu)
  noeuds <- union(names(sa), names(sb))
  struct <- if (identical(sa, sb)) character(0) else
    Filter(function(n) !identical(sa[[n]], sb[[n]]), noeuds)
  if (!length(struct) && !identical(sa, sb)) struct <- "(ordre ou doublons des noeuds)"

  ecarts <- if (length(lignes)) do.call(rbind, lignes) else
    data.frame(chemin = character(0), reference = character(0), obtenu = character(0),
               ecart = numeric(0), mesure = character(0), stringsAsFactors = FALSE)
  list(conforme = !nrow(ecarts) && !length(struct), tolerance = tol,
       n_feuilles = length(fa), n_differentes = n_diff + sum(ecarts$mesure %in% c("absente", "ajoutee")),
       n_ecarts = nrow(ecarts), ecart_max = e_max, feuille_max = f_max, mesure_max = m_max,
       ecarts = ecarts, structure = struct)
}

# Resume d'une comparaison en lignes de texte (messages d'echec, synthese
# de comparer_references.R et de patcher_reference.R).
resumer_comparaison <- function(r, n_max = 10L) {
  tete <- sprintf(paste0("%s : %d feuille(s), %d non strictement identique(s), %d en ecart au seuil %g ; ",
                         "ecart maximal %s%s"),
                  if (r$conforme) "CONFORME" else "NON CONFORME",
                  r$n_feuilles, r$n_differentes, r$n_ecarts, r$tolerance,
                  formatC(r$ecart_max, format = "e", digits = 3),
                  if (is.na(r$feuille_max)) "" else sprintf(" (%s, %s)", r$mesure_max, r$feuille_max))
  det <- character(0)
  if (r$n_ecarts) {
    e <- utils::head(r$ecarts, n_max)
    det <- sprintf("%s [%s] : %s -> %s%s", e$chemin, e$mesure, substr(e$reference, 1, 40),
                   substr(e$obtenu, 1, 40),
                   ifelse(is.na(e$ecart), "", sprintf(" (ecart %s)", formatC(e$ecart, format = "e", digits = 3))))
    if (r$n_ecarts > n_max) det <- c(det, sprintf("... et %d autre(s)", r$n_ecarts - n_max))
  }
  if (length(r$structure))
    det <- c(det, paste("structure (type ou attributs) differente :",
                        paste(utils::head(r$structure, n_max), collapse = ", ")))
  c(tete, det)
}
