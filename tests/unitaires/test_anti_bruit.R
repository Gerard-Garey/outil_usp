###############################################################################
#  tests/unitaires/test_anti_bruit.R  --  TEST ANTI-BRUIT (issue #22)
#
#  Propriete (decision du mainteneur, 23/09/2026) : des donnees perturbees
#  d'un facteur (1 + 1e-12 * s), s un motif de signes +1 / -1 deterministe
#  (aucun tirage), donnent un objet resultat dont
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
#  Huit motifs de signes (revue finale d'audit, 24/09/2026). Un seul motif
#  (signes alternes) ne detectait pas un libelle imprimant le nombre de
#  demarrages a l'optimum au code 0 : ce nombre ne change que pour certains
#  motifs (audit : 54 dans 29 cas, 53 dans 9, 52 dans 2 sur 40 motifs
#  aleatoires ; mesure sur les 49 couples de motifs de Walsh ci-dessous,
#  Linux, R 4.3.3 : 14 couples le font changer, pas le motif alterne).
#  Motifs de Walsh-Hadamard, s_i = (-1)^popcount((i - 1) & k), k = 1..7,
#  construits sans generateur aleatoire : xt recoit le motif kx, yt le motif
#  ky, le triangle (indice lineaire) le motif kx. Les couples retenus
#  (MOTIFS) : le motif alterne historique (1, 1), puis une permutation de
#  ky sur kx = 1..7 choisie sur la mesure ci-dessus pour que 5 des 8 couples
#  changent ce nombre sur la plateforme de mesure (sur une autre plateforme,
#  les couples qui le changent peuvent differer ; le controle, lui, reste
#  valide). Mordant mesure hors depot : un moteur qui reimprime ce nombre
#  dans le detail echoue ici.
#
#  Trois methodes sur tests/donnees/, parametres de test_reproductibilite.R
#  sauf B = 99 (duree : huit motifs, 27 appels de run_engine()). Mordant
#  verifie en fin de fichier : une chaine bruitee et un ecart numerique
#  reintroduits en memoire font echouer le controle.
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

B_ANTI_BRUIT <- 99

# Motif de Walsh-Hadamard d'indice k (1 a 7) sur n positions : arithmetique
# entiere, sans generateur aleatoire (.Random.seed intact). k = 1 donne les
# signes alternes +1, -1, +1...
signes_walsh <- function(n, k)
  vapply(seq_len(n) - 1L,
         function(v) (-1)^sum(as.integer(intToBits(bitwAnd(v, as.integer(k))))), 1)
# Couples (kx, ky) retenus : voir l'en-tete.
MOTIFS <- list(c(1, 1), c(1, 3), c(2, 4), c(3, 7), c(4, 1), c(5, 2), c(6, 5), c(7, 6))
# Perturbation relative deterministe, dim conservee (le triangle reste une
# matrice ; les NA restent NA).
perturber <- function(x, k) {
  s <- signes_walsh(length(x), k); dim(s) <- dim(x)
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
nom_motif <- function(m) sprintf("(kx = %d, ky = %d)", m[1], m[2])
# Controle de tous les motifs contre le calcul non perturbe `a` : la
# perturbation doit atteindre le champ `champ` du resultat, et le controle
# anti-bruit passer. Renvoie le resultat du premier motif (mordant, plus
# bas) et TRUE ou la liste des motifs fautifs.
controler_motifs <- function(a, calcul, champ) {
  pb <- character(0); premier <- NULL
  for (m in MOTIFS) {
    b <- calcul(m)
    if (is.null(premier)) premier <- b
    r <- if (identical(a[[champ]], b[[champ]])) paste("la perturbation n'atteint pas", champ)
         else controle_anti_bruit(a, b)
    if (!isTRUE(r)) pb <- c(pb, paste(nom_motif(m), ":", r))
  }
  list(b = premier, verdict = if (length(pb)) paste(pb, collapse = " | ") else TRUE)
}
res <- list()
for (m in c("premium", "reserve1")) {
  a <- executer(m, xt = ln$xt, yt = ln$yt)
  cm <- controler_motifs(a, function(k)
    executer(m, xt = perturber(ln$xt, k[1]), yt = perturber(ln$yt, k[2])), "donnees")
  res[[m]] <- list(a = a, b = cm$b)
  verifier(sprintf(paste("%s : donnees perturbees de 1e-12 (%d motifs) -> perturbation visible",
                         "dans res$donnees, chaines identiques, nombres sous le seuil"),
                   m, length(MOTIFS)), cm$verdict)
}
a <- executer("reserve2", triangle = tri)
cm <- controler_motifs(a, function(k) executer("reserve2", triangle = perturber(tri, k[1])),
                       "triangle")
res$reserve2 <- list(a = a, b = cm$b)
verifier(sprintf(paste("reserve2 : triangle perturbe de 1e-12 (%d motifs) -> perturbation visible",
                       "dans res$triangle, chaines identiques, nombres sous le seuil"),
                 length(MOTIFS)), cm$verdict)

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
