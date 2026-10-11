###############################################################################
#  tests/mesure_precision_residus_mw.R  --  PRECISION DES RESIDUS DE MACK
#  (mw_residus(), pool de .mw_pool_residus()) QUAND UNE LIGNE DOMINE SES
#  COLONNES (issue #233)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  R base + stats (utils, tools et parallel, livres avec R), plus le paquet
#  Rmpfr (decision Q-E2c-5 du mainteneur, 11/10/2026 : Rmpfr autorise hors
#  CI comme reference de ce script) ; sans Rmpfr, arret avec un message. Il
#  ne modifie ni R/engine.R ni tests/reference/. Sortie en markdown sur la
#  console ; fichiers ecrits SEULEMENT avec --ecrire. Libelles non ASCII en
#  echappements \u (fichier source ASCII).
#
#  Usage :
#      Rscript tests/mesure_precision_residus_mw.R --avant SHA
#          [--B 999] [--graine 20260831] [--coeurs N] [--sans-p]
#          [--ecrire [--remplacer]]
#  --avant SHA (obligatoire) : commit du moteur d'avant la correction, lu
#    par "git show SHA:R/engine.R" et charge dans un environnement separe ;
#    le moteur corrige est R/engine.R de l'arbre de travail, charge dans un
#    autre environnement (aucun des deux dans l'environnement global).
#  --B, --graine : bootstrap de run_engine() pour la grandeur 4.
#  --coeurs : processus de parallel::mclapply() (1 sous Windows).
#  --sans-p : omet la grandeur 4 (essai de mise au point ; refuse avec
#    --ecrire).
#  --remplacer sans --ecrire : refus d'usage (code 1), avant tout autre
#    controle.
#  --ecrire : ecrit dans docs/tableaux/ (date du jour)
#    <AAAAMMJJ>-issue233-precision-residus-mw.md et
#    <AAAAMMJJ>-issue233-precision-residus-mw-brut.tsv. --ecrire REFUSE
#    (code 1, rien d'ecrit), des l'analyse des options, avant le chargement
#    des moteurs et tout calcul, puis de nouveau avant d'ecrire (#205,
#    #173, comme tests/calibration_mc_mw_t8.R) : dossier docs/tableaux
#    absent ; commit non propre ou script non suivi
#    (motifs_non_versionnable(commit_depot())) ; code hors du depot ; garde
#    d'ecrasement garde_ecrasement() sans --remplacer. Avec --remplacer,
#    l'en-tete cite chaque fichier remplace et son md5 d'avant
#    (ligne_remplacement()). Le commit cite en tete est donc un SHA nu.
#    --ecrire refuse aussi --sans-p.
#  A FAIRE (hors du perimetre de la branche de #233, suite consignee au
#  mainteneur) : enregistrer ce script dans SCRIPTS_ECRIRE et
#  GARDES_ANTICIPEES de tests/unitaires/test_garde_ecrasement.R, qui
#  controlent ces gardes pour les huit autres scripts a --ecrire.
#
#  Grille : deux bases 8 x 8, reserve2 (tests/donnees/triangle_mw.csv) et
#  TA8 (sous-triangle 8 x 8 des huit premieres annees de survenance et de
#  developpement du triangle de Taylor & Ashe (1983), cellules i + j <= 7 ;
#  convention "ref k / TA8" de docs/specifications/e2-reduite.md, #115) ;
#  ligne dominante i dans {0, 3, 6} multipliee par D = 10^e, e dans
#  {10..17, 20, 25, 30} ; temoin : la meme ligne multipliee par 10^-e ; plus
#  chaque base non modifiee (e = 0).
#
#  Reference : Rmpfr a 256 bits. La conversion mpfr(x, 256) d'un double est
#  exacte. f_j = somme C(.,j+1) / somme C(.,j), sigma2_j (par. 5(d)(ii),
#  extrapolation de sigma2_(J-1) comprise), r_ij = sqrt(C_ij) (F_ij - f_j) /
#  sigma_j, 1 - h_ij = (S_j - C_ij) / S_j et pool redresse recentre
#  r_ij / sqrt(1 - h_ij) - moyenne, formules du moteur ; F_ij - f_j y est
#  evalue en un seul quotient (C(i,j+1) S_j - C(i,j) S'_j) / (C(i,j) S_j),
#  egal en arithmetique exacte (S'_j = somme C(.,j+1)) : les sommes et
#  produits de doubles y sont exacts a 256 bits sur cette grille, et
#  l'arrondi de la division n'est pas amplifie par une annulation.
#  Controle interne : la meme reference a 512 bits ; l'ecart (relatif pour
#  f, sigma2, r et 1 - h, absolu pour le pool) doit rester sous 1e-60,
#  sinon arret (code 1, rien d'ecrit).
#  Cellules : celles que retient mw_residus(aj, j_degeneres) du moteur
#  mesure, avec j_degeneres = .mw_colonnes_degenerees(aj) (comme
#  mw_bootstrap()) ; les deux moteurs doivent retenir les memes, sinon
#  arret.
#
#  Grandeurs, par triangle et par moteur (avant / corrige) :
#    1. erreur relative maximale des r_ij, globale et sur la ligne dominante ;
#    2. erreur absolue maximale du pool redresse recentre ;
#    3. erreur relative maximale de sigma2_j (controle ; mw_ajuster() n'est
#       pas modifie par #233) ;
#    4. moteur d'avant contre moteur corrige (e de 12 a 17 et bases non
#       modifiees) : run_engine(methode = "reserve2", segment 1, annexe II,
#       B, graine) dans chaque moteur ; p retenue, p_mc et verdict de chaque
#       ligne de mw_tests(), sigma_USP ;
#    5. les grandeurs 1 a 3 sont donnees pour les deux moteurs ;
#    6. mw_influence() : erreur relative maximale de f_sans_cellule, de
#       dfbeta_relatif et des dfbetas (cellules ou le moteur rend une valeur),
#       et nombre de dfbetas NA dans une colonne retenue a n_j >= 3, hors
#       garde "non borne" (dfbetas_non_borne = TRUE). Reference
#       Rmpfr par les formules de l'en-tete de mw_influence() :
#       f^(-i) = (S'_j - C(i,j+1)) / (S_j - C(i,j)), dfbeta_relatif =
#       (f^(-i) - f_j) / f_j, e_i = C(i,j+1) - f_j C(i,j), 1 - h_i =
#       (S_j - C(i,j)) / S_j, s2_(i) par retrait de la cellule, DFBETAS_i =
#       e_i sqrt(S_j) / (S_j (1 - h_i) s_(i)) ; differences evaluees en un
#       seul quotient comme pour F_ij - f_j (dfbeta_relatif par l'egalite
#       exacte f^(-i) - f_j = -C(i,j) (F_ij - f_j) / (S_j - C(i,j))),
#       controle 512 bits compris.
#  Statut des valeurs : CONSTAT NUMERIQUE sur des triangles construits, sans
#  portee statistique.
#  Code de sortie : 0 si les controles tiennent, 1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/mesure_precision_residus_mw.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) --------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_VALEUR <- c("--avant", "--B", "--graine", "--coeurs")
OPTIONS_DRAPEAU <- c("--ecrire", "--remplacer", "--sans-p")
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a %in% OPTIONS_VALEUR) {
      if (i == length(ARGS)) stop("option ", a, " sans valeur")
      i <- i + 2L
    } else if (a %in% OPTIONS_DRAPEAU) i <- i + 1L
    else stop("option inconnue : ", a)
  }
})
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) defaut else ARGS[i + 1L]
}
OPT_AVANT  <- lire_option("--avant", NA_character_)
B          <- as.integer(lire_option("--B", "999"))
GRAINE     <- as.integer(lire_option("--graine", "20260831"))
COEURS     <- as.integer(lire_option("--coeurs",
                as.character(if (.Platform$OS.type == "windows") 1L else
                  min(4L, max(1L, parallel::detectCores(), na.rm = TRUE)))))
ECRIRE     <- "--ecrire" %in% ARGS
REMPLACER  <- "--remplacer" %in% ARGS
SANS_P     <- "--sans-p" %in% ARGS
# Refus d'usage avant tout autre controle et tout chargement (#173).
if (REMPLACER && !ECRIRE) {
  message("--remplacer : reserve a --ecrire")
  quit(status = 1L)
}
if (is.na(OPT_AVANT)) stop("--avant SHA obligatoire (moteur d'avant la correction)")
if (is.na(B) || B < 1L || is.na(GRAINE) || is.na(COEURS) || COEURS < 1L)
  stop("--B, --graine et --coeurs : entiers positifs")
if (ECRIRE && SANS_P) stop("--ecrire refuse avec --sans-p (grandeur 4 omise)")
if (.Platform$OS.type == "windows") COEURS <- 1L

if (!requireNamespace("Rmpfr", quietly = TRUE))
  stop("le paquet Rmpfr est requis par ce script de mesure hors CI (reference en ",
       "precision etendue, #233, decision Q-E2c-5) : install.packages(\"Rmpfr\") ",
       "ou paquet systeme r-cran-rmpfr")

# --- Outils partages et moteurs ------------------------------------------------
# tests/outils_tests.R dans un environnement dedie : RACINE, commit_depot(),
# garde_ecrasement(), empreinte_sans_commentaires() ; il y charge aussi le
# moteur, que ce script n'utilise pas sous ce nom.
OT <- new.env()
sys.source(file.path(if (file.exists("tests/outils_tests.R")) "tests" else
                     if (file.exists("outils_tests.R")) "." else
                     stop("lancer depuis la racine du depot"), "outils_tests.R"), envir = OT)
RACINE <- OT$RACINE

# --- Gardes de --ecrire (#205, #173) -------------------------------------------
# Cibles fixees par la date du jour. Gardes ANTICIPEES des l'analyse des
# options, avant le chargement des deux moteurs et tout calcul : dossier
# docs/tableaux, commit propre et script suivi (motifs_non_versionnable(),
# refus sur un arbre de travail modifie ou un script non suivi), garde
# d'ecrasement ; puis gardes FINALES avant d'ecrire (l'etat du depot peut
# changer pendant le calcul). Comme tests/outils_tests.R, deja charge ici,
# ces fonctions et leur ordre suivent tests/calibration_mc_mw_t8.R.
DATE <- format(Sys.Date(), "%Y%m%d")
CIBLE_MD  <- file.path(RACINE, "docs", "tableaux", paste0(DATE, "-issue233-precision-residus-mw.md"))
CIBLE_TSV <- file.path(RACINE, "docs", "tableaux", paste0(DATE, "-issue233-precision-residus-mw-brut.tsv"))
# Empreintes du code execute : md5 de ce script et de tests/outils_tests.R ;
# "hors depot" si le script execute n'est pas celui du depot.
empreintes_code <- function() {
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  md5 <- function(x) if (!length(x) || !file.exists(x)) "absent" else unname(tools::md5sum(x))
  dans <- length(f) == 1L && identical(normalizePath(f, winslash = "/", mustWork = FALSE),
                                       normalizePath(file.path(RACINE, SCRIPT), winslash = "/", mustWork = FALSE))
  sprintf("%s %s%s ; tests/outils_tests.R %s", SCRIPT, md5(f), if (dans) "" else " (hors d\u00e9p\u00f4t)",
          md5(file.path(RACINE, "tests", "outils_tests.R")))
}
gardes_ecrire <- function(quand) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  nv <- OT$motifs_non_versionnable(OT$commit_depot(SCRIPT), empreintes_code(), quand)
  if (length(nv)) {
    message("--ecrire refuse : ", paste(nv, collapse = " ; "), " -- aucun fichier ecrit")
    quit(status = 1L)
  }
  OT$garde_ecrasement(c(CIBLE_MD, CIBLE_TSV), remplacer = REMPLACER, racine = RACINE)
}
REMPLACES <- NULL
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
git <- function(...) suppressWarnings(system2("git", c("-C", shQuote(RACINE), ...),
                                              stdout = TRUE, stderr = FALSE))
SHA_AVANT <- git("rev-parse", "--verify", "--quiet", paste0(OPT_AVANT, "^{commit}"))
if (length(SHA_AVANT) != 1L || !grepl("^[0-9a-f]{40}$", SHA_AVANT))
  stop("--avant : commit introuvable : ", OPT_AVANT)
FICHIER_AVANT <- tempfile("engine_avant_", fileext = ".R")
code_avant <- git("show", paste0(SHA_AVANT, ":R/engine.R"))
if (!length(code_avant)) stop("git show ", SHA_AVANT, ":R/engine.R a echoue")
writeLines(code_avant, FICHIER_AVANT, useBytes = TRUE)
FICHIER_APRES <- file.path(RACINE, "R", "engine.R")
MOTEURS <- list(avant = new.env(), corrige = new.env())
sys.source(FICHIER_AVANT, envir = MOTEURS$avant)
sys.source(FICHIER_APRES, envir = MOTEURS$corrige)
MD5_AVANT <- unname(tools::md5sum(FICHIER_AVANT))
MD5_APRES <- unname(tools::md5sum(FICHIER_APRES))
COMMIT <- OT$commit_depot(SCRIPT)

# --- Bases --------------------------------------------------------------------
lire_reserve2 <- function() {
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
}
# Taylor & Ashe (1983), cumules, jeu GenIns de ChainLadder (meme matrice que
# tests/unitaires/test_merz_wuthrich.R) ; TA8 : lignes et colonnes 1..8,
# cellules i + j <= 7 (indices 0).
lire_ta8 <- function() {
  ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
    1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
    1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
    2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
    2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
    3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
    3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
    3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
    3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
    3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
  m <- ta[1:8, 1:8]
  m[outer(0:7, 0:7, "+") > 7] <- NA_real_
  m
}
BASES <- list(reserve2 = lire_reserve2(), TA8 = lire_ta8())
LIGNES <- c(0L, 3L, 6L)
EXPOSANTS <- c(10:17, 20, 25, 30)
EXPOSANTS_P <- 12:17

GRILLE <- rbind(
  data.frame(base = names(BASES), ligne = NA_integer_, e = 0, signe = 1, stringsAsFactors = FALSE),
  do.call(rbind, lapply(names(BASES), function(b)
    expand.grid(base = b, ligne = LIGNES, e = EXPOSANTS, signe = c(1, -1),
                stringsAsFactors = FALSE))))
GRILLE$expo <- GRILLE$e * GRILLE$signe        # D = 10^expo
GRILLE$id <- seq_len(nrow(GRILLE))
triangle_de <- function(k) {
  t <- BASES[[GRILLE$base[k]]]
  if (!is.na(GRILLE$ligne[k])) t[GRILLE$ligne[k] + 1L, ] <- t[GRILLE$ligne[k] + 1L, ] * 10^GRILLE$expo[k]
  t
}
libelle_D <- function(k) if (GRILLE$e[k] == 0) "1" else sprintf("1e%+d", as.integer(GRILLE$expo[k]))

# --- Reference Rmpfr ------------------------------------------------------------
# cellules : data.frame (i, j) des residus retenus par le moteur.
reference <- function(tri, cellules, prec) {
  M <- function(x) Rmpfr::mpfr(x, prec)
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  f <- s2 <- vector("list", J); ecart <- vector("list", J); S <- vector("list", J)
  for (j in 0:(J - 1L)) {
    idx <- 0:(I - j - 1L)
    C0 <- M(tri[idx + 1L, j + 1L]); C1 <- M(tri[idx + 1L, j + 2L])
    S0 <- sum(C0); S1 <- sum(C1)
    f[[j + 1L]] <- S1 / S0; S[[j + 1L]] <- S0
    ecart[[j + 1L]] <- (C1 * S0 - C0 * S1) / (C0 * S0)          # F_ij - f_j
    if (j <= J - 2L && length(idx) >= 2L)
      s2[[j + 1L]] <- sum(C0 * ecart[[j + 1L]]^2) / (I - j - 1L)
  }
  # sigma2_(J-1) : min(sigma2_(J-2), sigma2_(J-3), sigma2_(J-2)^2 / sigma2_(J-3))
  if (J >= 3L) {
    a <- s2[[J - 1L]]; b <- s2[[J - 2L]]
    m <- if (a < b) a else b
    if (b > 0) { q <- a^2 / b; if (q < m) m <- q }
    s2[[J]] <- m
  }
  r <- omh <- vector("list", nrow(cellules))
  for (k in seq_len(nrow(cellules))) {
    i <- cellules$i[k]; j <- cellules$j[k]
    C0 <- M(tri[i + 1L, j + 1L])
    r[[k]] <- sqrt(C0) * ecart[[j + 1L]][i + 1L] / sqrt(s2[[j + 1L]])
    omh[[k]] <- (S[[j + 1L]] - C0) / S[[j + 1L]]
  }
  r <- do.call(c, r); omh <- do.call(c, omh)
  brut <- r / sqrt(omh)
  # Grandeur 6 : quantites de mw_influence(), toutes les cellules des
  # colonnes a n_j >= 2 (ordre de mw_influence() : j croissant, puis i).
  fs <- dr <- dfb <- list()
  for (j in 0:(J - 1L)) {
    idx <- 0:(I - j - 1L); n <- length(idx)
    if (n < 2L) next
    C0 <- M(tri[idx + 1L, j + 1L]); C1 <- M(tri[idx + 1L, j + 2L])
    S0 <- sum(C0); S1 <- sum(C1)
    e <- (C1 * S0 - C0 * S1) / S0
    for (k in seq_len(n)) {
      S0k <- S0 - C0[k]; S1k <- S1 - C1[k]
      fs[[length(fs) + 1L]] <- S1k / S0k
      # (f^(-k) - f_j) / f_j = -(C(k,j+1) S_j - C(k,j) S'_j) / ((S_j - C(k,j)) S'_j),
      # egalite exacte ; produits de doubles par une somme exacte, exacts a
      # 256 bits (le produit S'_j (S_j - C(k,j)) de deux sommes ne l'est pas)
      dr[[length(dr) + 1L]] <- -(C1[k] * S0 - C0[k] * S1) / (S0k * S1)
      dfb[[length(dfb) + 1L]] <- if (n >= 3L) {
        s2i <- sum(((C1 * S0k - C0 * S1k) / S0k)[-k]^2 / C0[-k]) / (n - 2L)
        e[k] * sqrt(S0) / (S0 * (S0k / S0) * sqrt(s2i))
      } else Rmpfr::mpfr(NA, prec)
    }
  }
  list(f = do.call(c, f), s2 = do.call(c, s2[!vapply(s2, is.null, TRUE)]),
       fs = do.call(c, fs), dr = do.call(c, dr), dfb = do.call(c, dfb),
       j_s2 = which(!vapply(s2, is.null, TRUE)) - 1L,
       r = r, omh = omh, pool = brut - sum(brut) / length(brut))
}
rel <- function(x, ref, prec = 256) {
  v <- abs(Rmpfr::mpfr(x, prec) - ref) / abs(ref)
  as.numeric(v)
}
absolu <- function(x, ref, prec = 256) as.numeric(abs(Rmpfr::mpfr(x, prec) - ref))
ecart_precisions <- function(a, b) {
  q <- function(x, y) as.numeric(max(abs(x - y) / abs(y)))
  def <- !is.na(as.numeric(b$dfb))
  max(q(a$f, b$f), q(a$s2, b$s2), q(a$r, b$r), q(a$omh, b$omh),
      as.numeric(max(abs(a$pool - b$pool))), q(a$fs, b$fs), q(a$dr, b$dr),
      q(a$dfb[def], b$dfb[def]))
}

# --- Grandeurs 1, 2, 3 et 5 -------------------------------------------------------
mesure_moteur <- function(E, tri) {
  aj <- E$mw_ajuster(tri); jd <- E$.mw_colonnes_degenerees(aj)
  res <- E$mw_residus(aj, jd)
  list(aj = aj, jd = jd, res = res, pool = E$.mw_pool_residus(aj, jd),
       inf = E$mw_influence(aj))
}
CONTROLE_MAX <- 0
mesure_precision <- function(k) {
  tri <- triangle_de(k)
  m <- lapply(MOTEURS, mesure_moteur, tri = tri)
  if (!identical(m$avant$jd, m$corrige$jd) ||
      !identical(m$avant$res[, c("i", "j")], m$corrige$res[, c("i", "j")]))
    stop("triangle ", k, " : cellules retenues differentes entre les deux moteurs")
  cel <- m$corrige$res[, c("i", "j")]
  r256 <- reference(tri, cel, 256); r512 <- reference(tri, cel, 512)
  ctl <- ecart_precisions(r256, r512)
  if (!is.finite(ctl) || ctl >= 1e-60)
    stop(sprintf("controle interne : ecart 256 / 512 bits = %g >= 1e-60 (triangle %d)", ctl, k))
  dom <- if (is.na(GRILLE$ligne[k])) rep(FALSE, nrow(cel)) else cel$i == GRILLE$ligne[k]
  out <- list(controle = ctl, n_residus = nrow(cel), n_dom = sum(dom),
              j_exclues = paste(m$corrige$jd, collapse = ","))
  for (v in names(MOTEURS)) {
    mm <- m[[v]]
    er <- rel(mm$res$residu, r256$r)
    out[[paste0("r_", v)]] <- max(er)
    out[[paste0("r_dom_", v)]] <- if (any(dom)) max(er[dom]) else NA_real_
    out[[paste0("pool_", v)]] <- max(absolu(mm$pool, r256$pool))
    out[[paste0("s2_", v)]] <- max(rel(mm$aj$sigma2[r256$j_s2 + 1L], r256$s2))
    out[[paste0("f_", v)]] <- max(rel(mm$aj$f, r256$f))
    # grandeur 6 (memes cellules et meme ordre que la reference)
    inf <- mm$inf
    if (nrow(inf) != length(r256$fs)) stop("triangle ", k, " : mw_influence() et reference de tailles differentes")
    max_def <- function(x) if (any(is.finite(x))) max(x[is.finite(x)]) else NA_real_
    out[[paste0("fs_", v)]] <- max_def(rel(inf$f_sans_cellule, r256$fs))
    out[[paste0("dr_", v)]] <- max_def(rel(inf$dfbeta_relatif, r256$dr))
    ok <- !is.na(inf$dfbetas)
    out[[paste0("dfb_", v)]] <- if (any(ok)) max_def(rel(inf$dfbetas[ok], r256$dfb[ok])) else NA_real_
    n_j <- as.vector(table(inf$j)[as.character(inf$j)])
    # NA hors de la garde "non borne" de mw_influence() (dfbetas_non_borne,
    # s2_(i) <= 1e2 eps (n - 1) sigma2_j, NA par construction)
    out[[paste0("dfb_na_", v)]] <- sum(is.na(inf$dfbetas) & n_j >= 3 & !is.na(inf$residu) &
                                         !inf$dfbetas_non_borne)
  }
  out
}

cat("Mesure de precision (grandeurs 1, 2, 3, 5, 6) :", nrow(GRILLE), "triangles\n", file = stderr())
PREC <- parallel::mclapply(GRILLE$id, function(k) tryCatch(mesure_precision(k),
                           error = function(e) structure(conditionMessage(e), class = "echec")),
                           mc.cores = COEURS, mc.preschedule = FALSE)
echecs <- vapply(PREC, function(x) inherits(x, "echec") || inherits(x, "try-error"), TRUE)
if (any(echecs)) {
  message("ARRET : ", paste(utils::head(unique(unlist(PREC[echecs])), 3), collapse = " ; "))
  quit(status = 1L)
}
CONTROLE_MAX <- max(vapply(PREC, `[[`, 0, "controle"))

# --- Grandeur 4 : moteur d'avant contre moteur corrige -----------------------------
SOUS_P <- GRILLE$id[GRILLE$e == 0 | GRILLE$e %in% EXPOSANTS_P]
lancer <- function(job) {
  k <- job$k; E <- MOTEURS[[job$v]]
  r <- suppressWarnings(E$run_engine(methode = "reserve2", triangle = triangle_de(k), segment = 1,
                                     annexe = "II", B = B, seed = GRAINE))
  if (!isTRUE(r$ok)) return(list(ok = FALSE, motif = paste(unlist(r$validation$erreurs), collapse = " ; ")))
  tb <- E$engine_table_tests(r)
  list(ok = TRUE, sigma_usp = r$parametre_final$sigma_usp,
       tb = tb[, c("famille", "test", "statistique", "p_monte_carlo", "p_retenue", "verdict")])
}
P <- NULL
if (!SANS_P) {
  jobs <- unlist(lapply(SOUS_P, function(k) list(list(k = k, v = "avant"), list(k = k, v = "corrige"))),
                 recursive = FALSE)
  cat("Grandeur 4 :", length(jobs), "appels de run_engine() (B =", B, ")\n", file = stderr())
  sorties <- parallel::mclapply(jobs, function(j) tryCatch(lancer(j),
                                error = function(e) list(ok = FALSE, motif = paste("erreur :", conditionMessage(e)))),
                                mc.cores = COEURS, mc.preschedule = FALSE)
  P <- lapply(SOUS_P, function(k) {
    a <- sorties[[which(vapply(jobs, function(j) j$k == k && j$v == "avant", TRUE))]]
    b <- sorties[[which(vapply(jobs, function(j) j$k == k && j$v == "corrige", TRUE))]]
    if (!isTRUE(a$ok) || !isTRUE(b$ok))
      return(list(k = k, ok = FALSE, motif = sprintf("avant : %s ; corrige : %s",
                                                     if (isTRUE(a$ok)) "ok" else a$motif,
                                                     if (isTRUE(b$ok)) "ok" else b$motif)))
    if (!identical(a$tb$test, b$tb$test)) stop("lignes de tests differentes (triangle ", k, ")")
    meme <- function(x, y) (is.na(x) & is.na(y)) | (!is.na(x) & !is.na(y) & x == y)
    dp <- abs(a$tb$p_retenue - b$tb$p_retenue)
    # ecart relatif si |statistique d'avant| > 1e-6, absolu sinon (convention
    # de comparer_objets(), tests/outils_tests.R)
    ds <- abs(a$tb$statistique - b$tb$statistique) /
      ifelse(abs(a$tb$statistique) > 1e-6, abs(a$tb$statistique), 1)
    chg <- which(a$tb$verdict != b$tb$verdict)
    list(k = k, ok = TRUE, n = nrow(a$tb),
         n_pmc = sum(!meme(a$tb$p_monte_carlo, b$tb$p_monte_carlo)),
         n_pret = sum(!meme(a$tb$p_retenue, b$tb$p_retenue)),
         dp_max = if (all(is.na(dp))) NA_real_ else max(dp, na.rm = TRUE),
         ds_max = if (all(is.na(ds))) NA_real_ else max(ds, na.rm = TRUE),
         n_verdicts = length(chg),
         verdicts = if (length(chg)) data.frame(test = a$tb$test[chg], avant = a$tb$verdict[chg],
                                                apres = b$tb$verdict[chg], p_avant = a$tb$p_retenue[chg],
                                                p_apres = b$tb$p_retenue[chg], stringsAsFactors = FALSE) else NULL,
         sigma_avant = a$sigma_usp, sigma_apres = b$sigma_usp,
         sigma_identique = identical(a$sigma_usp, b$sigma_usp))
  })
  names(P) <- as.character(SOUS_P)
}

# --- Sorties --------------------------------------------------------------------------
num <- function(x, d = 2) ifelse(is.na(x), "\u2014", formatC(x, format = "e", digits = d))
g <- function(k, nom) PREC[[k]][[nom]]
# Gardes finales, avant de composer l'en-tete (fichiers remplaces cites).
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))

md <- c(
  "# Pr\u00e9cision des r\u00e9sidus de Mack quand une ligne domine ses colonnes (issue #233)",
  "",
  "| Grandeur | Valeur |", "|---|---|",
  sprintf("| Date | %s |", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("| Script | `%s` |", SCRIPT),
  sprintf("| Commit | `%s` |", COMMIT),
  sprintf("| Moteur corrig\u00e9 | `R/engine.R`, md5 `%s`, empreinte sans commentaires `%s` |", MD5_APRES,
          OT$empreinte_sans_commentaires(FICHIER_APRES)),
  sprintf("| Moteur d'avant | `%s:R/engine.R`, md5 `%s` |", SHA_AVANT, MD5_AVANT),
  sprintf("| R | %s, %s |", R.version.string, Sys.info()[["sysname"]]),
  sprintf("| Rmpfr / MPFR | %s / %s |", as.character(utils::packageVersion("Rmpfr")),
          paste(as.character(Rmpfr::mpfrVersion()), collapse = " ")),
  "| R\u00e9f\u00e9rence | Rmpfr 256 bits ; contr\u00f4le 512 bits |",
  sprintf("| \u00c9cart maximal 256 / 512 bits (seuil 1e-60) | %s |", num(CONTROLE_MAX)),
  sprintf("| Grandeur 4 | %s |", if (SANS_P) "omise (--sans-p)" else
          sprintf("run_engine(methode = \"reserve2\", segment = 1, annexe = \"II\"), B = %d, graine %d, e de %d \u00e0 %d et bases non modifi\u00e9es",
                  B, GRAINE, min(EXPOSANTS_P), max(EXPOSANTS_P))),
  sprintf("| Processus | %d |", COEURS),
  OT$ligne_remplacement(REMPLACES, CIBLE_MD),
  OT$ligne_remplacement(REMPLACES, CIBLE_TSV),
  sprintf("| Dur\u00e9e | %.0f s |", duree),
  "",
  "Statut : constat num\u00e9rique sur des triangles construits, sans port\u00e9e statistique.",
  "Bases : `reserve2` (`tests/donnees/triangle_mw.csv`) et TA8 (sous-triangle 8 \u00d7 8 de Taylor & Ashe, cellules i + j \u2264 7).",
  "La ligne i est multipli\u00e9e par D ; D < 1 : t\u00e9moin. r : erreur relative maximale des r_ij (toutes cellules ; ligne dominante) ;",
  "pool : erreur absolue maximale du pool redress\u00e9 recentr\u00e9 ; \u03c3\u00b2 : erreur relative maximale de \u03c3\u00b2_j (identique dans les deux moteurs, `mw_ajuster()` inchang\u00e9e).",
  "",
  "## T1 \u2014 Erreurs \u00e0 la r\u00e9f\u00e9rence (grandeurs 1, 2, 3 et 5)",
  "",
  "| Base | Ligne | D | r avant | r corrig\u00e9 | r ligne dom. avant | r ligne dom. corrig\u00e9 | pool avant | pool corrig\u00e9 | \u03c3\u00b2 avant | \u03c3\u00b2 corrig\u00e9 |",
  "|---|---|---|---|---|---|---|---|---|---|---|")
for (k in GRILLE$id)
  md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |", GRILLE$base[k],
                      if (is.na(GRILLE$ligne[k])) "\u2014" else GRILLE$ligne[k], libelle_D(k),
                      num(g(k, "r_avant")), num(g(k, "r_corrige")), num(g(k, "r_dom_avant")),
                      num(g(k, "r_dom_corrige")), num(g(k, "pool_avant")), num(g(k, "pool_corrige")),
                      num(g(k, "s2_avant")), num(g(k, "s2_corrige"))))
mx <- function(nom, filtre = rep(TRUE, nrow(GRILLE))) max(vapply(GRILLE$id[filtre], function(k) {
  v <- g(k, nom); if (is.na(v)) -Inf else v }, 0))
md <- c(md, "", "Maxima sur la grille :", "",
        "| Grandeur | Avant | Corrig\u00e9 |", "|---|---|---|",
        sprintf("| r, toutes cellules | %s | %s |", num(mx("r_avant")), num(mx("r_corrige"))),
        sprintf("| r, ligne dominante | %s | %s |", num(mx("r_dom_avant")), num(mx("r_dom_corrige"))),
        sprintf("| pool (absolu) | %s | %s |", num(mx("pool_avant")), num(mx("pool_corrige"))),
        sprintf("| \u03c3\u00b2_j | %s | %s |", num(mx("s2_avant")), num(mx("s2_corrige"))),
        sprintf("| f_j | %s | %s |", num(mx("f_avant")), num(mx("f_corrige"))),
        sprintf("| f_sans_cellule (mw_influence()) | %s | %s |", num(mx("fs_avant")), num(mx("fs_corrige"))),
        sprintf("| dfbeta_relatif | %s | %s |", num(mx("dr_avant")), num(mx("dr_corrige"))),
        sprintf("| dfbetas (valeurs rendues) | %s | %s |", num(mx("dfb_avant")), num(mx("dfb_corrige"))),
        sprintf("| dfbetas NA (colonnes retenues, n_j \u2265 3, hors non born\u00e9s), total | %d | %d |",
                sum(vapply(PREC, `[[`, 0, "dfb_na_avant")), sum(vapply(PREC, `[[`, 0, "dfb_na_corrige"))))
md <- c(md, "", "## T4 \u2014 mw_influence() \u00e0 la r\u00e9f\u00e9rence (grandeur 6)", "",
        "Erreurs relatives maximales ; dfbetas : cellules o\u00f9 le moteur rend une valeur ; NA : dfbetas NA dans une colonne retenue \u00e0 n_j \u2265 3, hors garde \u00ab non born\u00e9 \u00bb.", "",
        "| Base | Ligne | D | f_sans avant | f_sans corrig\u00e9 | dfbeta_relatif avant | dfbeta_relatif corrig\u00e9 | dfbetas avant | dfbetas corrig\u00e9 | NA avant | NA corrig\u00e9 |",
        "|---|---|---|---|---|---|---|---|---|---|---|")
for (k in GRILLE$id)
  md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %d | %d |", GRILLE$base[k],
                      if (is.na(GRILLE$ligne[k])) "\u2014" else GRILLE$ligne[k], libelle_D(k),
                      num(g(k, "fs_avant")), num(g(k, "fs_corrige")), num(g(k, "dr_avant")),
                      num(g(k, "dr_corrige")), num(g(k, "dfb_avant")), num(g(k, "dfb_corrige")),
                      as.integer(g(k, "dfb_na_avant")), as.integer(g(k, "dfb_na_corrige"))))
if (!SANS_P) {
  md <- c(md, "", "## T2 \u2014 Moteur d'avant contre moteur corrig\u00e9 (grandeur 4)", "",
          "| Base | Ligne | D | Lignes | p_mc diff\u00e9rentes | p retenues diff\u00e9rentes | max \u0394p retenue | max \u00e9cart statistique (relatif ; absolu sous 1e-6) | Verdicts chang\u00e9s | \u03c3_USP avant | \u03c3_USP corrig\u00e9 | \u03c3_USP identique |",
          "|---|---|---|---|---|---|---|---|---|---|---|---|")
  for (p in P) {
    k <- p$k
    tete <- sprintf("| %s | %s | %s ", GRILLE$base[k], if (is.na(GRILLE$ligne[k])) "\u2014" else GRILLE$ligne[k],
                    libelle_D(k))
    md <- c(md, if (!p$ok) paste0(tete, sprintf("| refus : %s | | | | | | | | |", p$motif)) else
      paste0(tete, sprintf("| %d | %d | %d | %s | %s | %d | %.10f | %.10f | %s |", p$n, p$n_pmc, p$n_pret,
                           num(p$dp_max), num(p$ds_max), p$n_verdicts, p$sigma_avant, p$sigma_apres,
                           if (p$sigma_identique) "oui" else "non")))
  }
  chg <- Filter(function(p) isTRUE(p$ok) && p$n_verdicts > 0, P)
  md <- c(md, "", "### T3 \u2014 Verdicts chang\u00e9s", "")
  if (!length(chg)) md <- c(md, "Aucun.") else {
    md <- c(md, "| Base | Ligne | D | Test | Avant | Corrig\u00e9 | p avant | p corrig\u00e9e |", "|---|---|---|---|---|---|---|---|")
    for (p in chg) for (q in seq_len(nrow(p$verdicts)))
      md <- c(md, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |", GRILLE$base[p$k], GRILLE$ligne[p$k],
                          libelle_D(p$k), p$verdicts$test[q], p$verdicts$avant[q], p$verdicts$apres[q],
                          num(p$verdicts$p_avant[q], 4), num(p$verdicts$p_apres[q], 4)))
  }
}

# Valeurs brutes : une ligne par triangle.
brut <- do.call(rbind, lapply(GRILLE$id, function(k) {
  p <- if (!is.null(P)) P[[as.character(k)]] else NULL
  pv <- function(nom) if (is.null(p) || !isTRUE(p$ok)) NA else p[[nom]]
  data.frame(base = GRILLE$base[k], ligne = GRILLE$ligne[k], exposant = GRILLE$expo[k],
             n_residus = g(k, "n_residus"), n_ligne_dominante = g(k, "n_dom"),
             colonnes_degenerees = g(k, "j_exclues"), controle_256_512 = g(k, "controle"),
             r_avant = g(k, "r_avant"), r_corrige = g(k, "r_corrige"),
             r_dom_avant = g(k, "r_dom_avant"), r_dom_corrige = g(k, "r_dom_corrige"),
             pool_avant = g(k, "pool_avant"), pool_corrige = g(k, "pool_corrige"),
             s2_avant = g(k, "s2_avant"), s2_corrige = g(k, "s2_corrige"),
             f_avant = g(k, "f_avant"), f_corrige = g(k, "f_corrige"),
             fs_avant = g(k, "fs_avant"), fs_corrige = g(k, "fs_corrige"),
             dr_avant = g(k, "dr_avant"), dr_corrige = g(k, "dr_corrige"),
             dfb_avant = g(k, "dfb_avant"), dfb_corrige = g(k, "dfb_corrige"),
             dfb_na_avant = g(k, "dfb_na_avant"), dfb_na_corrige = g(k, "dfb_na_corrige"),
             g4_statut = if (is.null(p)) NA else if (p$ok) "ok" else p$motif,
             g4_lignes = pv("n"), g4_pmc_differentes = pv("n_pmc"), g4_pret_differentes = pv("n_pret"),
             g4_dp_max = pv("dp_max"), g4_ds_max = pv("ds_max"), g4_verdicts_changes = pv("n_verdicts"),
             g4_sigma_avant = pv("sigma_avant"), g4_sigma_corrige = pv("sigma_apres"),
             g4_sigma_identique = pv("sigma_identique"), stringsAsFactors = FALSE)
}))

ecrire_console <- function(x) writeLines(enc2utf8(x), con = stdout(), useBytes = TRUE)
ecrire_console(md)

if (ECRIRE) {
  con <- file(CIBLE_MD, open = "wb"); writeLines(enc2utf8(md), con, useBytes = TRUE); close(con)
  num17 <- vapply(brut, is.double, TRUE)
  brut_txt <- brut
  brut_txt[num17] <- lapply(brut[num17], function(v) ifelse(is.na(v), "NA", trimws(formatC(v, digits = 17, format = "g"))))
  utils::write.table(brut_txt, CIBLE_TSV, sep = "\t", quote = FALSE, row.names = FALSE, fileEncoding = "UTF-8")
  cat(sprintf("\nEcrits : %s, %s\n", CIBLE_MD, CIBLE_TSV), file = stderr())
}
quit(status = 0L)
