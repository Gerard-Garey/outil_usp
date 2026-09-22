###############################################################################
#  tests/outils_tests.R  --  OUTILS COMMUNS AUX TESTS DE NON-REGRESSION
#
#  Definit les cas de test (une methode, un jeu de donnees, des parametres) et
#  la maniere d'executer le moteur pour chacun. Source par
#  test_reproductibilite.R et generer_references.R ; R base uniquement.
###############################################################################

# Repertoire racine du depot : les scripts peuvent etre lances depuis la
# racine ou depuis tests/.
RACINE <- if (file.exists("R/engine.R")) "." else ".."
source(file.path(RACINE, "R", "engine.R"))

DOSSIER_REF <- file.path(RACINE, "tests", "reference")

# Tolerance relative de comparaison aux references : absorbe les ecarts
# d'arrondi entre plateformes (optimiseur, bibliotheques mathematiques), mais
# detecte tout changement de methode.
TOLERANCE <- 1e-8

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
#   - issue #3 : test de centrage des residus degenere quand delta est au bord
#     de [0, 1] ; sa p-value Monte-Carlo compare du bruit d'arrondi.
INSTABLES <- list(
  list(test = "Centrage des residus standardises", mc_nom = "MeanZ", issue = 3)
)

# Remplace par NA les grandeurs instables, dans le resultat comme dans la
# reference, avant comparaison.
neutraliser_instables <- function(res) {
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
# verification qui doit porter sur l'objet ENTIER passe par all.equal() ou
# par une comparaison d'attributs dediee.
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
