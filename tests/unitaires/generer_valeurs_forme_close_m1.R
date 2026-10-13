###############################################################################
#  tests/unitaires/generer_valeurs_forme_close_m1.R  --  PROVENANCE DES
#  VALEURS ECRITES EN DUR DANS test_forme_close_m1.R (ISSUE #253)
#
#  OUTIL HORS CI : ce script n'est ni une batterie de tests ni un generateur
#  de references. Il n'est lance ni par la CI, ni par test_unitaires.R (nom
#  sans prefixe test_), ni par test_reproductibilite.R. R base + stats
#  (utils, livre avec R), plus le paquet Rmpfr (decision Q-E2c-5 du
#  mainteneur, 11/10/2026 : Rmpfr autorise hors CI comme reference, comme
#  tests/mesure_precision_residus_mw.R) ; sans Rmpfr, arret avec un message.
#  Il ne modifie ni R/engine.R, ni tests/reference/, ni le fichier de test :
#  sortie sur la console seulement.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/unitaires/generer_valeurs_forme_close_m1.R
#
#  Methode, INDEPENDANTE de la forme close du moteur (ni Cauchy-Binet, ni
#  Frisch et Waugh) : equations normales completes de la regression
#  ponderee, X'WX b = X'Wy, resolues par elimination de Gauss (pivot
#  partiel) en arithmetique mpfr ; (X'WX)^-1 n'est lue que par sa colonne du
#  coefficient teste (second membre e_p dans la meme elimination).
#    - Courbure (mw_test_courbure()), colonne par colonne : regresseurs
#      [1, x, x^2], x = C(i,j), y = C(i,j+1) BRUT (pas l'ecart e du moteur),
#      poids 1 / x ; SCR = somme w (y - Xb)^2, se(c) = sqrt(SCR / (n - 3)
#      [(X'WX)^-1]_33), t = c / se, n - 3 ddl.
#    - Pente intra-colonne (.mw_lm_intra()) : regresseurs = indicatrices des
#      G colonnes de res et C, y = F, poids C / sigma_j^2 ; ddl = N - G - 1.
#  Donnees et gardes du moteur : triangles construits comme dans
#  test_forme_close_m1.R ; mw_ajuster() et mw_residus(aj,
#  .mw_colonnes_degenerees(aj)) du moteur (R/engine.R de l'arbre de travail)
#  fournissent les cellules retenues, F = C(i,j+1) / C(i,j) et sigma_j
#  (flottants du moteur, sigma_j = sqrt(sigma2_j) comme dans res) ; colonnes
#  de courbure : n >= 4, hors .mw_j_exclues(aj, NULL), colonne non
#  degeneree, sd(C0) > 0, au moins trois valeurs distinctes de C(i,j) ; pente :
#  nrow(res) >= 4, sd(C) > 0, sigma_j fini et > 0. Entrees : ces flottants,
#  convertis sans perte (mpfr(x, prec) d'un double est exact) ; seuls les
#  calculs en aval sont arrondis, a 4 096 bits.
#  Controle de precision : tout est recalcule a 8 192 bits ; les 17 chiffres
#  significatifs de chaque valeur doivent etre identiques, sinon arret
#  (code 1).
#  Sortie : par valeur, la reference a 17 chiffres, la valeur en dur du test,
#  l'ecart relatif et la tolerance du test (rel = 1e-12 pour T253-1, 1e-10
#  sinon) ; a titre d'information, la valeur du moteur et son ecart.
#  Code de sortie : 1 si une valeur en dur s'ecarte de la reference de plus
#  que la tolerance de son test, ou si le controle de precision echoue ; 0
#  sinon. Un cas sans valeur en dur (courbure ou pente NULL dans CAS) est
#  affiche « a ajouter » et n'entre pas dans le code de sortie ; tous les
#  cas de CAS en ont une, y compris reserve2, ligne 0 x 1e-14 (hors tableau
#  de la specification).
###############################################################################

t_debut <- Sys.time()

if (!requireNamespace("Rmpfr", quietly = TRUE))
  stop("le paquet Rmpfr est requis par ce script hors CI (reference en precision ",
       "etendue, decision Q-E2c-5) : install.packages(\"Rmpfr\") ou paquet ",
       "systeme r-cran-rmpfr")

RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
          if (file.exists("../../R/engine.R")) "../.." else stop("lancer depuis la racine du depot")
ENG <- new.env()
sys.source(file.path(RACINE, "R", "engine.R"), envir = ENG)

# --- Triangles (constructions de test_forme_close_m1.R) -------------------------
tri253 <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
ligne253 <- function(t, i, k) { t[i + 1, ] <- t[i + 1, ] * k; t }
bornes253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e50 / max(t[1, ], na.rm = TRUE)
  t[4, ] <- t[4, ] * 1e-50 / min(t[4, ], na.rm = TRUE)
  t
})
extreme253 <- local({
  t <- tri253
  t[1, ] <- t[1, ] * 1e48 / max(t[1, ], na.rm = TRUE)
  for (i in 2:4) t[i, ] <- t[i, ] * 1e-48 / min(t[i, ], na.rm = TRUE)
  t
})

# Cas : triangle, valeurs en dur (courbure, pente ; NULL = pas de valeur),
# tolerance relative du test
CAS <- list(
  list(nom = "T253-1 reserve2", tri = tri253, rel = 1e-12,
       courbure = c(0.93422764996969232, -1.9823633206000404,
                    -9.1618120029068368, -3.462887950378827),
       pente = 0.2600197442537881),
  list(nom = "T253-2 l0 x 1e30", tri = ligne253(tri253, 0, 1e30), rel = 1e-10,
       courbure = c(-3.2321868753333782, -2.6230673521146479, -1.2246845553777297,
                    0.27555322316525688),
       pente = -0.64792170590960629),
  list(nom = "T253-2 l3 x 1e30", tri = ligne253(tri253, 3, 1e30), rel = 1e-10,
       courbure = c(-1.7637144365936694, -3.1751739033668485, -1.0848619801581147,
                    -1.9731120214984617),
       pente = 0.58992812949620965),
  list(nom = "T253-2 l0 x 1e-30", tri = ligne253(tri253, 0, 1e-30), rel = 1e-10,
       courbure = c(3.1467379665547841, 2.1589835486730493, 0.79635768376122973,
                    -0.58330789698280028),
       pente = -1.120997177810577),
  list(nom = "T253-5 bornes", tri = bornes253, rel = 1e-10,
       courbure = c(0.081519213694489751, -2.013620676168856,
                    -4.5274309238335313, -6.6723491946328828),
       pente = -0.65007141204537222),
  list(nom = "T253-5 extremes", tri = extreme253, rel = 1e-10,
       courbure = c(-4.5539052541909681, -8.7152604957341513,
                    -3.9732558970578664e+25, 0.46224878577219491),
       pente = -0.78452449405942448),
  # Hors tableau de la specification (demande d'actuary) : seul cas mesure ou
  # l'ancien moteur (lm()) rendait une pente finie et fausse (-2,566).
  list(nom = "hors spec. l0 x 1e-14", tri = ligne253(tri253, 0, 1e-14), rel = 1e-10,
       courbure = c(3.1467379665547831, 2.1589835486730452, 0.79635768376122591,
                    -0.58330789698280312),
       pente = -1.1209971778104361)
)

# --- Elimination de Gauss en mpfr -------------------------------------------------
# A : liste de p lignes (vecteurs mpfr de longueur p + q), systeme augmente
# [M | seconds membres] ; rend la liste des q solutions (vecteurs mpfr).
gauss_mpfr <- function(A, p) {
  for (k in seq_len(p)) {
    # pivot partiel, compare en mpfr (as.numeric() deborderait sur ce domaine)
    piv <- k
    for (r in k:p) if (abs(A[[r]][k]) > abs(A[[piv]][k])) piv <- r
    if (piv != k) { tmp <- A[[k]]; A[[k]] <- A[[piv]]; A[[piv]] <- tmp }
    if (A[[k]][k] == 0) stop("systeme singulier")
    if (k < p) for (r in (k + 1L):p) {
      fct <- A[[r]][k] / A[[k]][k]
      A[[r]] <- A[[r]] - fct * A[[k]]
    }
  }
  q <- length(A[[1]]) - p
  lapply(seq_len(q), function(s) {
    x <- vector("list", p)
    for (k in p:1) {
      acc <- A[[k]][p + s]
      if (k < p) for (l in (k + 1L):p) acc <- acc - A[[k]][l] * x[[l]]
      x[[k]] <- acc / A[[k]][k]
    }
    do.call(c, x)
  })
}

# Regression ponderee : X (liste de p colonnes mpfr), y, w (mpfr) ; t du
# coefficient d'indice p, a ddl donnes.
t_coef_mpfr <- function(X, y, w, ddl) {
  p <- length(X)
  A <- lapply(seq_len(p), function(a) {
    ligne <- lapply(seq_len(p), function(b) sum(w * X[[a]] * X[[b]]))
    do.call(c, c(ligne, list(sum(w * X[[a]] * y), if (a == p) y[1] * 0 + 1 else y[1] * 0)))
  })
  sol <- gauss_mpfr(A, p)
  b <- sol[[1]]; mpp <- sol[[2]][p]
  ajust <- Reduce(`+`, lapply(seq_len(p), function(a) b[a] * X[[a]]))
  scr <- sum(w * (y - ajust)^2)
  b[p] / sqrt(scr / ddl * mpp)
}

# --- References d'un triangle a une precision donnee -------------------------------
reference <- function(tri, prec) {
  M <- function(x) Rmpfr::mpfr(x, prec)
  aj <- ENG$mw_ajuster(tri)
  jd <- ENG$.mw_j_exclues(aj, NULL)
  I <- aj$I; J <- aj$J
  tc <- list(); jc <- integer(0)
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 4 || j %in% jd) next
    if (ENG$.mw_colonne_degeneree(aj, j)) stop("colonne retenue degeneree : hors champ du script")
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    if (stats::sd(C0) == 0 || length(unique(C0)) < 3) next
    x <- M(C0); n <- length(C0)
    tc[[length(tc) + 1L]] <- t_coef_mpfr(list(x * 0 + 1, x, x^2), M(C1), 1 / x, n - 3)
    jc <- c(jc, j)
  }
  res <- ENG$mw_residus(aj, ENG$.mw_colonnes_degenerees(aj))
  tp <- NULL
  if (nrow(res) >= 4 && stats::sd(res$C) != 0 && all(is.finite(res$sigma_j)) &&
      all(res$sigma_j > 0)) {
    Cm <- M(res$C); s <- M(res$sigma_j)
    gs <- sort(unique(res$j))
    X <- c(lapply(gs, function(g) M(as.numeric(res$j == g))), list(Cm))
    tp <- t_coef_mpfr(X, M(res$F), Cm / s^2, nrow(res) - length(gs) - 1L)
  }
  list(courbure = if (length(tc)) do.call(c, tc) else NULL, j = jc, pente = tp)
}

f17 <- function(v) Rmpfr::formatMpfr(v, digits = 17)

# --- Calcul ------------------------------------------------------------------------
lignes <- list(); ko_precision <- character(0); ko_dur <- character(0)
for (cas in CAS) {
  r1 <- reference(cas$tri, 4096); r2 <- reference(cas$tri, 8192)
  aj <- ENG$mw_ajuster(cas$tri)
  cb <- ENG$mw_test_courbure(aj)
  li <- ENG$.mw_lm_intra(ENG$mw_residus(aj, ENG$.mw_colonnes_degenerees(aj)))
  if (!identical(as.integer(cb$detail$j), as.integer(r1$j)))
    ko_precision <- c(ko_precision, sprintf("%s : colonnes du moteur (%s) et du script (%s)",
      cas$nom, paste(cb$detail$j, collapse = ","), paste(r1$j, collapse = ",")))
  ajoute <- function(grandeur, v1, v2, dur, moteur) {
    s1 <- f17(v1); s2 <- f17(v2)
    if (!identical(s1, s2))
      ko_precision <<- c(ko_precision, sprintf("%s %s : %s (4096) / %s (8192)",
                                               cas$nom, grandeur, s1, s2))
    # ecarts relatifs evalues en mpfr (le double le plus proche de la
    # reference n'est pas la reference)
    ecart <- function(x) as.numeric(abs(Rmpfr::mpfr(x, 4096) - v1) / abs(v1))
    ec <- if (is.null(dur)) NA_real_ else ecart(dur)
    statut <- if (is.null(dur)) "a ajouter" else if (ec <= cas$rel) "ok" else "ECART"
    if (identical(statut, "ECART"))
      ko_dur <<- c(ko_dur, sprintf("%s %s", cas$nom, grandeur))
    lignes[[length(lignes) + 1L]] <<- data.frame(
      cas = cas$nom, grandeur = grandeur, reference_17 = s1,
      en_dur = if (is.null(dur)) "-" else sprintf("%.17g", dur),
      ecart_rel = if (is.na(ec)) "-" else sprintf("%.2e", ec),
      tolerance = sprintf("%.0e", cas$rel), statut = statut,
      moteur = sprintf("%.17g", moteur),
      ecart_moteur = if (is.finite(moteur)) sprintf("%.2e", ecart(moteur)) else "-",
      stringsAsFactors = FALSE)
  }
  for (k in seq_along(r1$j))
    ajoute(sprintf("courbure j=%d", r1$j[k]), r1$courbure[k], r2$courbure[k],
           if (is.null(cas$courbure)) NULL else cas$courbure[k], cb$detail$t[k])
  ajoute("pente", r1$pente, r2$pente, cas$pente,
         if (is.null(li)) NA_real_ else unname(li[["t value"]]))
}

tab <- do.call(rbind, lignes)
options(width = 250)
cat("Rmpfr", as.character(utils::packageVersion("Rmpfr")), "-", R.version.string, "\n")
cat("Reference : equations normales, elimination de Gauss, 4096 bits (controle 8192 bits)\n\n")
print(tab, row.names = FALSE, right = FALSE)
cat("\nControle de precision (17 chiffres identiques a 4096 et 8192 bits, colonnes",
    "identiques au moteur) :", if (length(ko_precision)) "ECHEC" else "ok", "\n")
for (m in ko_precision) cat("  ", m, "\n")
cat("Valeurs en dur dans la tolerance de leur test :",
    if (length(ko_dur)) "ECHEC" else "ok", "\n")
for (m in ko_dur) cat("  ", m, "\n")
cat(sprintf("Duree : %.1f s\n", as.numeric(difftime(Sys.time(), t_debut, units = "secs"))))
if (length(ko_precision) || length(ko_dur)) quit(status = 1L)
