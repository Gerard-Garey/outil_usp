###############################################################################
#  tests/unitaires/test_anti_bruit.R  --  TEST ANTI-BRUIT (issue #22)
#
#  Propriete (decision du mainteneur, 23/09/2026) : des donnees perturbees
#  d'un facteur (1 + 1e-12 * s), s alternant +1 / -1 (deterministe, aucun
#  tirage), donnent un objet resultat dont
#    - toutes les feuilles de type caractere sont identical() a celles du
#      calcul non perturbe ;
#    - toutes les feuilles numeriques restent sous le seuil de
#      comparer_objets() (TOLERANCE, 1e-6), apres neutraliser_instables().
#  Champs d'execution retires au prealable par nettoyer() (outils_tests.R) :
#  metadata$horodatage et metadata$duree_sec (changent a chaque appel),
#  metadata$version_R (propre a la plateforme).
#
#  Motif : le detail de la FOC imprimait un residu au bruit machine (1,1e-17
#  sous Windows, 2,5e-17 sous Linux), ce qui a rendu la CI rouge sur cette
#  seule chaine. Une chaine qui imprime un nombre sensible a l'arrondi est
#  detectee ici sur une meme machine, sans attendre la CI.
#
#  Trois methodes sur tests/donnees/, parametres de test_reproductibilite.R
#  sauf B = 199 (duree). Mordant verifie en fin de fichier : une chaine
#  bruitee et un ecart numerique reintroduits en memoire font echouer le
#  controle.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_anti_bruit.R")

# outils_tests.R dans un environnement dedie (comme test_comparateur.R) : le
# moteur qu'il charge n'atteint pas l'environnement global.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = outils_env)

B_ANTI_BRUIT <- 199

# Perturbation relative deterministe : signes alternes, dim conservee (le
# triangle reste une matrice ; les NA restent NA).
perturber <- function(x) {
  s <- rep_len(c(1, -1), length(x)); dim(s) <- dim(x)
  x * (1 + 1e-12 * s)
}

executer <- function(methode, xt = NULL, yt = NULL, triangle = NULL)
  outils_env$nettoyer(outils_env$run_engine(xt = xt, yt = yt, triangle = triangle,
                                            methode = methode, segment = 1, annexe = "II",
                                            B = B_ANTI_BRUIT))

# Controle anti-bruit : TRUE, ou un message listant les feuilles fautives.
controle_anti_bruit <- function(a, b) {
  fa <- outils_env$aplatir(a); fb <- outils_env$aplatir(b)
  if (!identical(names(fa), names(fb))) return("chemins des feuilles differents")
  car <- names(fa)[vapply(fa, is.character, logical(1)) | vapply(fb, is.character, logical(1))]
  diff_car <- car[!mapply(identical, fa[car], fb[car])]
  if (length(diff_car))
    return(paste(sprintf("%s : [%s] -> [%s]", diff_car,
                         vapply(fa[diff_car], paste, "", collapse = " "),
                         vapply(fb[diff_car], paste, "", collapse = " ")), collapse = " ; "))
  r <- outils_env$comparer_objets(outils_env$neutraliser_instables(a),
                                  outils_env$neutraliser_instables(b))
  if (!r$conforme) return(paste(outils_env$resumer_comparaison(r), collapse = " ; "))
  TRUE
}

ln  <- outils_env$.ln
tri <- outils_env$.tri
res <- list()
for (m in c("premium", "reserve1")) {
  a <- executer(m, xt = ln$xt, yt = ln$yt)
  b <- executer(m, xt = perturber(ln$xt), yt = perturber(ln$yt))
  res[[m]] <- list(a = a, b = b)
  verifier(sprintf("%s : la perturbation atteint bien les donnees du resultat", m),
           !identical(a$donnees, b$donnees))
  verifier(sprintf("%s : donnees perturbees de 1e-12 -> chaines identiques, nombres sous le seuil", m),
           controle_anti_bruit(a, b))
}
a <- executer("reserve2", triangle = tri)
b <- executer("reserve2", triangle = perturber(tri))
res$reserve2 <- list(a = a, b = b)
verifier("reserve2 : la perturbation atteint bien le triangle du resultat",
         !identical(a$triangle, b$triangle))
verifier("reserve2 : triangle perturbe de 1e-12 -> chaines identiques, nombres sous le seuil",
         controle_anti_bruit(a, b))

## --- Mordant du controle (en memoire) ----------------------------------------
# Chaine imprimant un residu au bruit machine, comme l'ancien detail de la FOC
# (valeurs mesurees sous Windows et Linux) : le controle doit echouer.
a <- res$premium$a; b <- res$premium$b
a$tests[[1]]$detail <- paste(a$tests[[1]]$detail, sprintf("FOC = %.1e", 1.1e-17))
b$tests[[1]]$detail <- paste(b$tests[[1]]$detail, sprintf("FOC = %.1e", 2.5e-17))
verifier("Mordant : une chaine imprimant un nombre au bruit machine fait echouer le controle",
         !isTRUE(controle_anti_bruit(a, b)))
# Ecart numerique au-dela du seuil 1e-6 : le controle doit echouer.
b <- res$reserve2$b
b$parametre_final$sigma_usp <- b$parametre_final$sigma_usp * (1 + 1e-5)
verifier("Mordant : un ecart relatif de 1e-5 sur sigma_usp fait echouer le controle",
         !isTRUE(controle_anti_bruit(res$reserve2$a, b)))

fin_fichier()
