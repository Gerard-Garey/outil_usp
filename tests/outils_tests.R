###############################################################################
#  tests/outils_tests.R  --  OUTILS COMMUNS AUX TESTS DE NON-REGRESSION
#
#  Definit les cas de test (une methode, un jeu de donnees, des parametres) et
#  la maniere d'executer le moteur pour chacun, et le comparateur unique de
#  non-regression (comparer_objets). Source par test_reproductibilite.R,
#  generer_references.R, comparer_references.R, patcher_reference.R et
#  regenerer_et_rendre_compte.R ; source aussi par les cinq scripts de
#  mesure hors CI qui ont --ecrire (puissance_t8.R, constats_puissance_t8.R,
#  calibration_mc_t8.R, taux_franchissement_reperes.R,
#  conservatisme_interieur_t8.R), qui y trouvent la
#  garde d'ecrasement des tableaux versionnes (garde_ecrasement(), #173),
#  le commit du depot et les motifs de non-versionnement (commit_depot(),
#  motifs_non_versionnable(), #205 ; commit_depot() sert aussi a
#  balayage_echelles.R) et l'empreinte de R/engine.R sans commentaires
#  (empreinte_sans_commentaires(), #231, controle (i3) de
#  conservatisme_interieur_t8.R) ; R base uniquement (tools::md5sum() pour
#  la garde et l'empreinte).
#  Porte aussi la contre-implementation par lm() / anova() des six
#  regressions auxiliaires calculees par QR depuis #237 (contre_*(), en fin
#  de fichier), lue par tests/unitaires/test_regressions_qr.R.
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
# maximale mesuree entre le poste du mainteneur (alors plateforme de
# production des references ; depuis l'ADR 0011, les references sont
# produites par la CI, workflow references.yml) et Linux R 4.3.3 (3,508e-07
# sur bootstrap$sigma_boot). Seuil
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
# Nature des donnees de la methode du risque de primes (declaration
# obligatoire, issue #55, decision M13) : les donnees de tests/donnees/, de
# provenance non documentee, sont REPUTEES BRUTES par convention pour les cas
# premium et premium_ii6 (references inchangees) ; premium_net est le meme
# cas II-1 declare net (sigma standard = NP standard x sigma brut = 0,8 x 10 %).
CAS <- list(
  premium  = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium",
                                   segment = 1, annexe = "II", nature_donnees = "brutes"),
  reserve1 = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "reserve1",
                                   segment = 1, annexe = "II"),
  reserve2 = function() run_engine(methode = "reserve2", triangle = .tri,
                                   segment = 1, annexe = "II"),
  # Segment modifie par le reglement delegue (UE) 2019/981 (M6), bareme long
  # comme le segment 1 (annexe II, segment 6 ; issue #61) : sigma standard de
  # primes de 19 % au lieu de 10 %, memes donnees, B et graine que premium.
  premium_ii6 = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium",
                                      segment = 6, annexe = "II", nature_donnees = "brutes"),
  # Meme cas II-1 que premium, donnees declarees NETTES de reassurance
  # (annexe XVII, B(2)(d), marqueur M1 ; parametre remplace : art. 218,
  # paragraphe 1, point a) i)) : memes donnees, B et graine ; seul le sigma
  # standard du melange change (NP standard 80 %, art. 117, paragraphe 3 ;
  # issue #55). Reference creee par la CI (mode creation, M31, M30).
  premium_net = function() run_engine(xt = .ln$xt, yt = .ln$yt, methode = "premium",
                                      segment = 1, annexe = "II", nature_donnees = "nettes")
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
# l'objet resultat ; restent compares l'erreur relative de premier ordre
# sur sigma et le pas de Newton (stat du controle, erreur_sigma et
# pas_newton, en absolu de fait, |reference| < 1e-6), hessienne,
# grad_ln_sigma, pas_ecrete (issue #71, qui remplace hessien_gamma et
# pas_newton_gamma), les verdicts, les comptes de demarrages, delta et
# gamma estimes.
# n_starts_optimum_code0 (ajout du 23/09/2026, decision du mainteneur) :
# nombre de demarrages a l'optimum rendant le code 0 d'optim(), qui depend
# du chemin d'optimisation : un demarrage bascule entre les codes 0 et 52
# selon la machine (constat CI du 23/09/2026 sur acfc0c0 : 54 contre 53 sous
# perturbation de 1e-12 ; mesure locale : 52 a 54 sur 101 perturbations de
# 1e-12). Restent compares n_starts_optimum (stable, 54) et le verdict, qui
# ne demande qu'au moins un demarrage a l'optimum au code 0.
# convergence (ajout du 24/09/2026, decision du mainteneur, option (a)) : code
# de retour d'optim() du demarrage retenu, c'est-a-dire du premier demarrage
# a moins de 1e-10 de l'objectif, departage par l'ordre de la grille. Meme
# mecanisme que n_starts_optimum_code0 : il depend du chemin d'optimisation
# (mesure du 24/09/2026, Linux, R 4.3.3 : cas d'audit 176 de
# test_controles_numeriques.R, demarrage retenu au code 52 alors que 53
# demarrages a l'optimum rendent 0). Il ne decide pas du verdict (precision
# de M11) et n'est plus imprime dans le detail du controle. Le champ n'est
# neutralise que dans res$ajustement (lognormale) ; l'objet Merz-Wuthrich
# n'en comporte pas.
EXCLUS_AJUSTEMENT <- c("gradient", "gradient_projete", "n_starts_optimum_code0",
                       "convergence")

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

# Description d'un resultat ok = FALSE de run_engine() (issue #88), pour les
# messages des scripts : motifs de validation$erreurs et, pour un defaut de
# calcul intercepte par le moteur, message, appel, origine et pile de
# validation$erreur_r. Renvoie un texte de plusieurs lignes.
decrire_refus <- function(res) {
  v <- res$validation
  l <- if (length(v$erreurs)) paste0("  motif : ", v$erreurs) else "  (aucun motif)"
  er <- v$erreur_r
  if (!is.null(er))
    l <- c(l, paste0("  erreur R : ", er$message), paste0("  appel : ", er$appel),
           paste0("  origine : ", er$origine), paste0("  pile : ", paste(er$pile, collapse = " > ")))
  paste(l, collapse = "\n")
}

# Ecriture d'une reference : un seul code, partage par generer_references.R et
# regenerer_et_rendre_compte.R, pour qu'une reference regeneree par l'un ou
# l'autre soit le meme fichier (format RDS version 3). chemin : destination
# (par defaut la reference du cas ; regenerer_et_rendre_compte.R y passe un
# fichier temporaire du meme dossier pour une ecriture atomique).
ecrire_reference <- function(nom, res, chemin = chemin_reference(nom)) {
  dir.create(dirname(chemin), showWarnings = FALSE, recursive = TRUE)
  saveRDS(res, chemin, version = 3)
  invisible(chemin)
}

# ---------------------------------------------------------------------------
#  Motifs sur les chemins aplatis (patcher_reference.R --motif,
#  regenerer_et_rendre_compte.R --attendu) : une seule grammaire, celle des
#  expressions regulieres de grepl() appliquees aux chemins que produit
#  aplatir() et qu'affiche comparer_references.R.
# ---------------------------------------------------------------------------

# Extrait d'une ligne de commande les valeurs d'une option repetable
# (--motif a --motif b) ; renvoie list(valeurs, reste), reste etant les
# arguments qui ne sont ni l'option ni sa valeur, dans leur ordre.
extraire_option <- function(args, option) {
  valeurs <- character(0); reste <- character(0)
  k <- 1L
  while (k <= length(args)) {
    if (identical(args[k], option)) {
      if (k == length(args)) stop(option, " sans valeur")
      valeurs <- c(valeurs, args[k + 1L]); k <- k + 2L
    } else { reste <- c(reste, args[k]); k <- k + 1L }
  }
  list(valeurs = valeurs, reste = reste)
}

# Chemins designes par au moins un motif (aucun motif : aucun chemin).
designer <- function(cles, motifs)
  Filter(function(cle) any(vapply(motifs, grepl, logical(1), x = cle)), cles)

# ---------------------------------------------------------------------------
#  Cellules de tableau markdown : partagees par regenerer_et_rendre_compte.R
#  (tableau avant / apres, issue #64) et comparer_references.R --markdown
#  (resume du job de CI, issue #66).
# ---------------------------------------------------------------------------

# Longueur maximale d'une valeur affichee dans le tableau (caracteres).
LARGEUR_CELLULE <- 60L

# Cellule de tableau : une ligne, pas de barre verticale ni d'accent grave
# non echappes, tronquee lisiblement au-dela de largeur caracteres.
une_ligne <- function(x) trimws(gsub("[\r\n\t]+", " ", x))
echapper <- function(x) gsub("|", "\\|", gsub("`", "'", x, fixed = TRUE), fixed = TRUE)
tronquer <- function(x, largeur) {
  long <- !is.na(x) & nchar(x) > largeur
  x[long] <- sprintf("%s\u2026 (%d car.)", substr(x[long], 1L, largeur - 1L), nchar(x[long]))
  x
}
cellule <- function(x, largeur = LARGEUR_CELLULE) echapper(tronquer(une_ligne(x), largeur))

# Meme mise en forme hors tableau (ligne de liste, paragraphe), pour un texte
# place en police de code : la barre verticale n'y est pas echappee (hors
# tableau, GitHub afficherait l'antislash) ; l'accent grave, qui fermerait
# la police de code, reste remplace par une apostrophe.
texte_code <- function(x, largeur = LARGEUR_CELLULE)
  gsub("`", "'", tronquer(une_ligne(x), largeur), fixed = TRUE)

plateforme <- function() sprintf("%s, %s", R.version.string, Sys.info()[["sysname"]])

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
#                    obtenu, ecart, mesure, reference_na, obtenu_na), chemins
#                    absents compris ; reference et obtenu sont les valeurs
#                    mises en texte, ou NA et "NA" coincident : reference_na
#                    et obtenu_na les distinguent (TRUE pour une feuille
#                    valant NA, NaN exclu) ;
#   structure      : chemins des noeuds dont le type ou les attributs
#                    different (character(0) si aucun).
comparer_objets <- function(ref, obtenu, tol = TOLERANCE, bascule = TOLERANCE) {
  fa <- aplatir(ref); fb <- aplatir(obtenu)
  na <- names(fa); nb <- names(fb)
  fmt <- function(v) if (is.null(v)) "(absent)" else if (!length(v)) sprintf("%s(0)", typeof(v)) else
    paste(if (is.numeric(v)) formatC(v, digits = 10, format = "g") else as.character(v), collapse = " ")
  est_na <- function(v) is.atomic(v) && length(v) == 1L && is.na(v) && !(is.numeric(v) && is.nan(v))

  lignes <- list()
  ajouter <- function(chemin, a, b, ecart, mesure)
    lignes[[length(lignes) + 1L]] <<- data.frame(chemin = chemin, reference = fmt(a), obtenu = fmt(b),
                                                 ecart = ecart, mesure = mesure,
                                                 reference_na = est_na(a), obtenu_na = est_na(b),
                                                 stringsAsFactors = FALSE)

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
               ecart = numeric(0), mesure = character(0),
               reference_na = logical(0), obtenu_na = logical(0), stringsAsFactors = FALSE)
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

# ---------------------------------------------------------------------------
#  Commit du depot et motifs de non-versionnement des scripts de mesure hors
#  CI (issue #205). Seule definition, reprise des copies de
#  tests/puissance_t8.R, tests/constats_puissance_t8.R,
#  tests/calibration_mc_t8.R, tests/taux_franchissement_reperes.R et
#  tests/balayage_echelles.R. Les scripts dont --ecrire refuse un commit non
#  propre (tests/puissance_t8.R, tests/constats_puissance_t8.R,
#  tests/calibration_mc_t8.R, tests/taux_franchissement_reperes.R,
#  tests/conservatisme_interieur_t8.R) evaluent motifs_non_versionnable()
#  des l'analyse des options, avant tout calcul (commit et empreintes
#  courants), puis de nouveau avant d'ecrire (l'etat du depot peut changer
#  pendant le calcul).
# ---------------------------------------------------------------------------

# Commit du depot : SHA de HEAD, complete de "(arbre de travail modifie)" si
# un fichier suivi est modifie (git status --porcelain
# --untracked-files=no) et, si script est donne (chemin relatif a racine),
# de "(script non suivi)" quand "git ls-files --error-unmatch" echoue ;
# "inconnu" si git est indisponible ou si racine n'est pas dans un depot.
# script = NULL : aucune mention du suivi du script
# (tests/taux_franchissement_reperes.R, tests/balayage_echelles.R, comme
# leurs copies d'avant #205). racine et script proteges par shQuote()
# (espaces ; les copies d'avant #205 rendaient "inconnu" pour une racine
# avec espace). git : commande git (argument des tests, pour simuler git
# indisponible).
commit_depot <- function(script = NULL, racine = RACINE, git = "git") {
  g <- function(...) tryCatch(suppressWarnings(system2(git, c("-C", shQuote(racine), ...), stdout = TRUE,
                                                       stderr = FALSE)),
                              error = function(e) character(0))
  h <- g("rev-parse", "HEAD")
  if (length(h) != 1L || !grepl("^[0-9a-f]{40}$", h)) return("inconnu")
  if (length(g("status", "--porcelain", "--untracked-files=no"))) h <- paste(h, "(arbre de travail modifi\u00e9)")
  if (!is.null(script)) {
    suivi <- tryCatch(suppressWarnings(system2(git, c("--literal-pathspecs", "-C", shQuote(racine), "ls-files",
                                                      "--error-unmatch", "--", shQuote(script)),
                                               stdout = FALSE, stderr = FALSE)),
                      error = function(e) 1L)
    if (!identical(as.integer(suivi), 0L)) h <- paste(h, "(script non suivi)")
  }
  h
}

# Motifs qui interdisent --ecrire (tableau versionne) : commit non propre
# (resultat de commit_depot() qui n'est pas un SHA nu) ou code hors du depot
# (empreintes de empreintes_code() des scripts : "hors depot") ; quoi :
# "des tranches", "de la combinaison" ou "de l'execution". character(0) si
# rien ne s'y oppose.
motifs_non_versionnable <- function(commit, empreintes, quoi = "des tranches") {
  m <- character(0)
  if (!grepl("^[0-9a-f]{40}$", commit))
    m <- c(m, sprintf("commit %s \u00ab %s \u00bb (arbre de travail modifi\u00e9, script non suivi ou git indisponible)", quoi, commit))
  if (grepl("hors d\u00e9p\u00f4t", empreintes, fixed = TRUE))
    m <- c(m, sprintf("tests/outils_tests.R ou script ex\u00e9cut\u00e9s %s hors du d\u00e9p\u00f4t", quoi))
  m
}

# ---------------------------------------------------------------------------
#  Empreinte de R/engine.R sans commentaires (issue #231). Complement du md5
#  du fichier entier des empreintes_code() des scripts de mesure (copies
#  declarees dans ces scripts), qui reste cite en T0 pour la tracabilite au
#  commit : un commentaire ou une ligne vide modifies changent ce md5 sans
#  changer aucun calcul. Lue par le controle (i3) de
#  tests/conservatisme_interieur_t8.R ; testee par
#  tests/unitaires/test_empreinte_moteur.R.
#
#  Methode : md5 d'un codage canonique de l'arbre syntaxique rendu par
#  parse(fichier, keep.source = FALSE, encoding = "UTF-8"), expression de
#  premier niveau par expression de premier niveau. L'analyseur de R ecarte
#  lui-meme les commentaires, les lignes vides, l'indentation et les fins de
#  ligne (LF ou CRLF) ; l'arbre garde tout ce qui s'execute : noms (symboles),
#  appels et noms de leurs arguments, listes d'arguments formels et valeurs
#  par defaut, corps des fonctions, constantes. Le codage est ecrit ici, sans
#  deparse(), dont le texte depend de la locale (chaine "\u00e9" rendue
#  "<U+00E9>" sous LC_ALL=C, le caractere lui-meme sous C.UTF-8), ni
#  getParseData(), dont le texte remplace une chaine longue par
#  "[2000 chars quoted with ...]" (mesure sous R 4.3.3) :
#    - symbole : "s" et octets UTF-8 en hexadecimal (enc2utf8()) ;
#    - appel ("c") ou liste d'arguments formels ("p") : longueur, puis chaque
#      element sous la forme nom=code, nom en hexadecimal UTF-8, argument
#      vide (argument formel sans defaut, x[, 1]) code "m" ;
#    - constante : type, longueur, puis chaque valeur : double par ses huit
#      octets IEEE 754 (writeBin(), petit-boutiste impose, sans format
#      decimal), entier en
#      decimal, logique T/F, chaine par ses octets UTF-8 en hexadecimal
#      precedes de "x", NA code "NA" ; complexe : deux doubles ;
#    - NULL : "N".
#  Le codage n'emploie que des caracteres ASCII ; le md5 est celui de ses
#  octets (fichier temporaire ecrit par writeBin(), tools::md5sum()).
#  Consequences : une modification du code (constante, corps, nom, argument
#  par defaut, ordre des expressions) change l'empreinte ; deux ecritures
#  que l'analyseur rend identiques la laissent inchangee (1e-6 et 0.000001,
#  "\u00e9" et le caractere lui-meme dans une chaine) : c'est le code
#  analyse qui est compare, non son texte. Une constante de type inattendu
#  ou portant des attributs leve une erreur (codage incomplet refuse).
#  Locale : les chaines analysees avec encoding = "UTF-8" sont marquees
#  UTF-8 sous LC_ALL=C comme sous C.UTF-8 (meme empreinte de R/engine.R et
#  des chaines non ASCII sous les deux, mesure sous R 4.3.3) ; un nom
#  (symbole) non ASCII ne s'analyse pas sous LC_ALL=C (erreur de parse()) :
#  R/engine.R n'en a pas, ses caracteres non ASCII sont tous en commentaire.
#  Version de R : le codage ne lit que l'arbre de parse() ; mesure sous
#  R 4.3.3 seulement.
# ---------------------------------------------------------------------------

# fichier : chemin du source R (par defaut R/engine.R du depot). Renvoie le
# md5 (32 caracteres hexadecimaux) ; erreur si le fichier ne s'analyse pas.
empreinte_sans_commentaires <- function(fichier = file.path(RACINE, "R", "engine.R")) {
  hex <- function(s) paste(as.character(charToRaw(enc2utf8(s))), collapse = "")
  dbl <- function(x) vapply(x, function(v) paste(as.character(writeBin(v, raw(), size = 8L, endian = "little")),
                                                 collapse = ""), "")
  coder <- function(e) {
    if (is.null(e)) return("N")
    if (is.symbol(e)) return(paste0("s", hex(as.character(e))))
    if (is.call(e) || is.pairlist(e)) {
      l <- as.list(e)
      nm <- names(l)
      if (is.null(nm)) nm <- rep("", length(l))
      el <- vapply(seq_along(l), function(i)
        if (identical(l[[i]], quote(expr = ))) "m" else coder(l[[i]]), "")
      return(paste0(if (is.call(e)) "c" else "p", length(l), "(",
                    paste0(vapply(nm, hex, ""), "=", el, collapse = ","), ")"))
    }
    if (is.atomic(e) && is.null(attributes(e))) {
      v <- switch(typeof(e),
                  double = dbl(e),
                  integer = ifelse(is.na(e), "NA", as.character(e)),
                  logical = ifelse(is.na(e), "NA", ifelse(e, "T", "F")),
                  character = ifelse(is.na(e), "NA", paste0("x", vapply(e, hex, ""))),
                  complex = paste0(dbl(Re(e)), "i", dbl(Im(e))),
                  stop("empreinte_sans_commentaires : constante de type ", typeof(e), " non codee"))
      return(paste0(typeof(e), length(e), "(", paste(v, collapse = ","), ")"))
    }
    stop("empreinte_sans_commentaires : objet de type ", typeof(e), " non code")
  }
  ex <- parse(fichier, keep.source = FALSE, encoding = "UTF-8")
  code <- paste(vapply(ex, coder, ""), collapse = ";")
  f <- tempfile("empreinte_")
  on.exit(unlink(f), add = TRUE)
  writeBin(charToRaw(code), f)
  unname(tools::md5sum(f))
}

# ---------------------------------------------------------------------------
#  Garde d'ecrasement des tableaux versionnes (issue #173). Seul lieu de la
#  regle, appelee par les cinq scripts de mesure hors CI qui ont --ecrire
#  (tests/puissance_t8.R, tests/constats_puissance_t8.R,
#  tests/calibration_mc_t8.R, tests/taux_franchissement_reperes.R,
#  tests/conservatisme_interieur_t8.R), APRES
#  leurs gardes propres (arbre propre, motifs_non_versionnable()) et AVANT
#  toute ecriture : tous les chemins cibles d'une execution sont controles
#  d'abord, puis seulement ecrits. tests/puissance_t8.R (constat m2 d'audit
#  de #173), tests/taux_franchissement_reperes.R (cible_fichier()) et
#  tests/constats_puissance_t8.R (#205) l'appellent en outre des l'analyse
#  des options, avant tout calcul (hors --combiner : les chemins cibles y
#  sont connus), puis de nouveau avant d'ecrire ;
#  tests/conservatisme_interieur_t8.R aussi, --combiner compris (#175 : un
#  seul tableau, de nom fixe par la date du jour).
# ---------------------------------------------------------------------------

# Controle les chemins cibles de --ecrire. Statut de chaque chemin, lu par
# "git --literal-pathspecs -C racine ls-files --error-unmatch" (code 0 :
# suivi, y compris un fichier suivi supprime de l'arbre de travail ; code
# 1 : non suivi ; autre code ou git introuvable : indetermine) ; un chemin
# hors de racine est non suivi par ce depot (git n'est pas interroge).
# Refus (rien d'ecrit) :
#   - un chemin suivi, sans remplacer = TRUE ;
#   - un chemin existant au statut indetermine (git indisponible, racine hors
#     d'un depot git) : prudence, meme avec remplacer = TRUE.
# Un chemin absent ou non suivi passe (comportement inchange).
# Renvoie (invisible) un data.frame des fichiers suivis qui seront remplaces
# (remplacer = TRUE) : cible (chemin tel que passe), chemin (relatif a
# racine, separateur "/") et md5_avant (NA si le fichier suivi est absent de
# l'arbre de travail) ; zero ligne sinon. Le T0 du tableau ecrit les cite
# (ligne_remplacement()).
# quitter = TRUE (scripts) : refus par message() et quit(status = 1) ;
# quitter = FALSE (tests unitaires) : erreur de classe
# "garde_ecrasement_refus", message identique. git : commande git (argument
# des tests, pour simuler git indisponible).
garde_ecrasement <- function(chemins, remplacer = FALSE, racine = RACINE, quitter = TRUE, git = "git") {
  # separateur "/" et casse ignoree sous Windows (meme convention que
  # sous_depot() des scripts)
  norm <- function(x) {
    x <- suppressWarnings(normalizePath(x, winslash = "/", mustWork = FALSE))
    if (.Platform$OS.type == "windows") tolower(x) else x
  }
  r <- norm(racine)
  absolu <- vapply(chemins, function(f)
    paste0(suppressWarnings(normalizePath(dirname(f), winslash = "/", mustWork = FALSE)), "/", basename(f)), "")
  d <- norm(dirname(chemins))
  dans <- d == r | startsWith(d, paste0(r, "/"))
  relatif <- ifelse(dans, substring(absolu, nchar(r) + 2L), absolu)
  statut <- vapply(seq_along(chemins), function(i) {
    if (!dans[i]) return("non suivi")
    # system2() passe ses arguments au shell sans les proteger : shQuote()
    # sur la racine et le chemin (espaces, metacaracteres) ;
    # --literal-pathspecs : le chemin n'est pas lu comme un motif glob
    code <- tryCatch(suppressWarnings(system2(git, c("--literal-pathspecs", "-C", shQuote(racine), "ls-files",
                                                     "--error-unmatch", "--", shQuote(relatif[i])),
                                              stdout = FALSE, stderr = FALSE)),
                     error = function(e) NA_integer_)
    if (identical(as.integer(code), 0L)) "suivi" else if (identical(as.integer(code), 1L)) "non suivi" else "indetermine"
  }, "")
  existe <- file.exists(chemins)
  motifs <- character(0)
  if (!remplacer && any(statut == "suivi"))
    motifs <- c(motifs, paste0("fichier(s) suivi(s) par git, remplacement non demande (--remplacer) : ",
                               paste(relatif[statut == "suivi"], collapse = ", ")))
  if (any(statut == "indetermine" & existe))
    motifs <- c(motifs, paste0("fichier(s) existant(s) dont le suivi par git ne peut etre verifie ",
                               "(git indisponible ou hors d'un depot) : ",
                               paste(relatif[statut == "indetermine" & existe], collapse = ", ")))
  if (length(motifs)) {
    msg <- paste0("--ecrire refuse : ", paste(motifs, collapse = " ; "),
                  " -- aucun fichier ecrit ; --remplacer remplace un tableau suivi par git (le T0 cite le fichier",
                  " remplace et son md5 d'avant)")
    if (quitter) {
      message(msg)
      quit(status = 1L)
    }
    stop(structure(class = c("garde_ecrasement_refus", "error", "condition"),
                   list(message = msg, call = NULL)))
  }
  k <- statut == "suivi"
  invisible(data.frame(cible = chemins[k], chemin = relatif[k],
                       md5_avant = unname(ifelse(existe[k], tools::md5sum(chemins[k]), NA_character_)),
                       stringsAsFactors = FALSE))
}

# Ligne de T0 (tableau markdown "Grandeur | Valeur") qui cite le fichier
# remplace par --remplacer ; character(0) si cible n'est pas remplacee
# (remplaces NULL ou sans ligne compris).
ligne_remplacement <- function(remplaces, cible) {
  if (is.null(remplaces) || !nrow(remplaces)) return(character(0))
  r <- remplaces[remplaces$cible == cible, , drop = FALSE]
  if (!nrow(r)) return(character(0))
  sprintf("| Fichier remplac\u00e9 (--remplacer) | %s, md5 d'avant %s |", r$chemin,
          ifelse(is.na(r$md5_avant), "(absent de l'arbre de travail)", r$md5_avant))
}

# Insere des lignes a la fin du premier tableau qui suit le titre "### T0"
# d'une sortie markdown deja construite (tableaux des scripts de mesure).
inserer_t0 <- function(lignes, ajout) {
  if (!length(ajout)) return(lignes)
  i <- grep("^### T0", lignes)[1]
  if (is.na(i)) stop("inserer_t0 : titre \"### T0\" introuvable")
  t <- which(seq_along(lignes) > i & startsWith(lignes, "|"))
  if (!length(t)) stop("inserer_t0 : tableau T0 introuvable")
  fin <- t[1]
  while (fin < length(lignes) && startsWith(lignes[fin + 1L], "|")) fin <- fin + 1L
  append(lignes, ajout, after = fin)
}

# --- Contre-implementation par lm() / anova() des six regressions de #237 ----
# Corps des six fonctions du moteur avant #237 (commit 1c244f7), gardes et
# motifs compris, recopies a l'identique sous un nom propre : le moteur les
# calcule depuis #237 par QR et formes fermees (.usp_mco_qr()). Servent de
# reference independante a tests/unitaires/test_regressions_qr.R et aux
# controles du script de mesure de #229 (recommandation d'actuary Q-A1-8) ;
# a evaluer dans un environnement ou le moteur est charge (usp_volumes_constants(),
# .usp_nb_volumes_distincts(), .usp_normaliser_echelle(), usp_poids_gls(),
# .p_borne()), ce que fait ce fichier. Les avertissements de summary.lm() et
# anova.lm() (ajustement quasi parfait) y sont emis comme avant #237.
#   contre_bp79()  : test_breusch_pagan_original()
#   contre_bp()    : test_breusch_pagan()
#   contre_white() : test_white()
#   contre_bf()    : test_brown_forsythe()
#   contre_reset() : test_reset()
#   contre_lm_pondere() : .usp_lm_pondere() (summary() de lm(y ~ x, weights = w))
contre_bp79 <- function(u2, reg) {
  n <- length(u2)
  if (usp_volumes_constants(reg) || mean(u2) <= 0)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  g <- u2 / mean(u2)
  aux <- stats::lm(g ~ reg)
  if (is.na(stats::coef(aux)["reg"]))
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  sce <- sum((stats::fitted(aux) - mean(g))^2)
  LM <- 0.5 * sce
  q <- 1
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, q)), ddl = q)
}
contre_bp <- function(u2, reg) {
  if (usp_volumes_constants(reg)) return(list(stat = NA_real_, p = NA_real_))
  d <- data.frame(u2 = u2, reg = reg)
  m <- stats::lm(u2 ~ reg, data = d)
  if (is.na(stats::coef(m)["reg"])) return(list(stat = NA_real_, p = NA_real_))
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 1)))
}
contre_white <- function(u2, reg) {
  na <- function(motif) list(stat = NA_real_, p = NA_real_, non_applicable = motif)
  if (usp_volumes_constants(reg)) return(na("volumes constants"))
  k <- .usp_nb_volumes_distincts(reg)
  if (k < 3)
    return(na(sprintf(paste("moins de trois volumes distincts (k = %d) : regression",
                            "auxiliaire de White {1, x, x^2} de rang %d, test non",
                            "applicable"), k, k)))
  s <- (reg - mean(reg)) / diff(range(reg))
  u2 <- .usp_normaliser_echelle(u2)
  m <- stats::lm(u2 ~ s + I(s^2))
  if (anyNA(stats::coef(m)))
    return(na(paste("regression auxiliaire de White de rang deficient : terme ecarte",
                    "par lm() pour colinearite, test non applicable")))
  LM <- length(u2) * summary(m)$r.squared
  if (!is.finite(LM)) return(na("statistique LM non finie : test non applicable"))
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 2)), non_applicable = NA_character_)
}
contre_bf <- function(u, reg) {
  if (usp_volumes_constants(reg)) return(list(stat = NA_real_, p = NA_real_))
  g <- factor(reg > stats::median(reg))
  if (nlevels(g) < 2) return(list(stat = NA_real_, p = NA_real_))
  dev <- unlist(tapply(u, g, function(v) abs(v - stats::median(v))))
  gg <- rep(levels(g), tapply(u, g, length))
  a <- stats::anova(stats::lm(dev ~ gg))
  list(stat = a[["F value"]][1], p = .p_borne(a[["Pr(>F)"]][1]))
}
contre_reset <- function(x, y) {
  na <- function(motif) list(stat = NA_real_, p = NA_real_, non_applicable = motif)
  if (usp_volumes_constants(x)) return(na("volumes constants"))
  k <- .usp_nb_volumes_distincts(x)
  if (k < 3)
    return(na(sprintf(paste("moins de trois volumes distincts (k = %d) : regression",
                            "auxiliaire RESET {x, x^2, x^3} de rang %d, test non",
                            "applicable"), k, k)))
  s <- (x - mean(x)) / diff(range(x))
  x <- .usp_normaliser_echelle(x)
  y <- .usp_normaliser_echelle(y)
  m0 <- stats::lm(y ~ x - 1)
  m1 <- stats::lm(y ~ x + I(x * s) + I(x * s^2) - 1)
  if (is.na(stats::coef(m0)["x"]) || anyNA(stats::coef(m1)))
    return(na(paste("regression auxiliaire RESET de rang deficient : terme ecarte",
                    "par lm() pour colinearite, test non applicable")))
  a <- stats::anova(m0, m1)
  stat <- a[["F"]][2]
  if (!is.finite(stat))
    return(na("statistique F non finie : test non applicable"))
  list(stat = stat, p = .p_borne(a[["Pr(>F)"]][2]), non_applicable = NA_character_)
}
contre_lm_pondere <- function(x, y, pi) {
  w <- usp_poids_gls(x, pi)
  if (is.null(w)) return(NULL)
  summary(stats::lm(y ~ x, weights = w))
}
