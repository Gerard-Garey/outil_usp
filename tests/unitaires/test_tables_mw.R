###############################################################################
#  tests/unitaires/test_tables_mw.R  --  STATISTIQUES MERZ-WUTHRICH DU
#                    BOOTSTRAP CONTRE LEUR ANCIENNE FORME (#239)
#
#  Depuis #239 : (a) mw_test_exposant_variance() et
#  mw_test_homogeneite_accident() recoivent les residus de Mack du contexte
#  .mw_contexte_mc() (argument res) au lieu de rappeler mw_residus() ;
#  (b) HomogF et ExpVar tirent rho et p d'un seul cor.test() (.mw_spearman()) ;
#  (c) les tables de mw_residus(), mw_test_annees_calendaires(),
#  mw_test_ordonnee_origine(), mw_test_homogeneite_f(), mw_test_courbure(),
#  mw_famille_alpha() et mw_test_exposant_variance() sont baties par colonnes
#  prealloues assemblees une fois (.mw_table()), au lieu d'un rbind() par
#  colonne. Critere de #239 : resultats IDENTIQUES au bit pres, ordre des
#  attributs compris (identical(attrib.as.set = FALSE)). La contre-implementation
#  ci-dessous est l'ancienne forme, copiee du moteur au commit daabd7a
#  (commentaires retires), evaluee dans un environnement dedie dont le parent
#  est celui du moteur : les fonctions non modifiees (mw_stat_correlation_dev(),
#  .mw_pente_intra(), .mc_evaluer()...) sont communes. Chaque fonction est
#  comparee par meme() (valeur, ou message d'erreur) et par la liste des
#  avertissements emis, sur :
#    - le triangle du cas reserve2 (tests/donnees/triangle_mw.csv), avec et
#      sans noms de lignes ;
#    - des replications du bootstrap de ce triangle et de triangles a
#      colonne degeneree, ensemble j_degeneres fige a l'observe ;
#    - Taylor & Ashe, a colonne degeneree (ta_deg) et bruitee (ta_bruit) ;
#    - les triangles minimaux 2 x 2 a 4 x 4 ;
#    - des triangles tires sous graine (3 a 12 annees, ex aequo, colonnes
#      degenerees, colonnes nulles (facteurs egaux a 1), noms de lignes
#      ordinaires, numeriques, en collision avec make.unique(), doublons).
#  Les identites des objets run_engine() des cinq cas avant / apres #239
#  (identical(attrib.as.set = FALSE)) sont mesurees hors batterie, dans le
#  compte rendu de #239 ; test_reproductibilite.R les compare aux references.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_tables_mw.R")

# --- Ancienne forme (moteur au commit daabd7a, avant #239) --------------------
ANCIEN <- new.env(parent = environment(mw_ajuster))
local({
  mw_residus <- function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    jd <- .mw_j_exclues(aj, j_degeneres)
    out <- data.frame()
    exclues <- data.frame(j = integer(0), n_facteurs = integer(0))
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 2) next
      if (!is.finite(aj$sigma2[j + 1]) || aj$sigma2[j + 1] <= 0 || j %in% jd) {
        exclues[nrow(exclues) + 1L, ] <- list(as.integer(j), length(idx))
        next
      }
      Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
      out <- rbind(out, data.frame(
        i = idx, j = j, calendrier = idx + j,
        C = Cij, F = Cij1 / Cij, f_chapeau = aj$f[j + 1],
        sigma_j = sqrt(aj$sigma2[j + 1]),
        residu = sqrt(Cij) * (Cij1 / Cij - aj$f[j + 1]) / sqrt(aj$sigma2[j + 1]),
        stringsAsFactors = FALSE))
    }
    attr(out, "colonnes_exclues") <- exclues
    out
  }

  mw_test_annees_calendaires <- function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    jd <- .mw_j_exclues(aj, j_degeneres)
    etiq <- data.frame()
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 2) next
      F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
      F <- engine_aplatir_ex_aequo(F, plancher = 0)
      md <- stats::median(F)
      lab <- if (j %in% jd) rep("*", length(F)) else
        ifelse(F > md, "L", ifelse(F < md, "S", "*"))
      etiq <- rbind(etiq, data.frame(i = idx, j = j, diag = idx + j, lab = lab,
                                     stringsAsFactors = FALSE))
    }
    etiquettes <- etiq                         # toutes les etiquettes, "*" compris
    etiq <- etiq[etiq$lab != "*", , drop = FALSE]
    if (!nrow(etiq)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_,
                                  etiquettes = etiquettes))
    agg <- lapply(split(etiq$lab, etiq$diag), function(v) {
      L <- sum(v == "L"); S <- sum(v == "S"); n <- L + S
      m <- .mack_moments_Z(n)
      c(Z = min(L, S), E = unname(m["E"]), V = unname(m["V"]), n = n)
    })
    A <- do.call(base::rbind, agg)
    A <- A[A[, "n"] >= 2, , drop = FALSE]
    if (!nrow(A)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_,
                               etiquettes = etiquettes))
    Z <- sum(A[, "Z"]); EZ <- sum(A[, "E"]); VZ <- sum(A[, "V"])
    if (!is.finite(VZ) || VZ <= 0) return(list(stat = NA_real_, p = NA_real_, Z = Z,
                                                etiquettes = etiquettes))
    st <- (Z - EZ) / sqrt(VZ)
    list(stat = st, p = .p_borne(2 * (1 - stats::pnorm(abs(st)))),
         Z = Z, E = EZ, V = VZ, detail = A, etiquettes = etiquettes)
  }

  .mw_spearman_p <- function(a, b, plancher_b = 1) {
    b <- engine_aplatir_ex_aequo(b, plancher = plancher_b)
    n <- length(a)
    exact <- n <= 9 && !anyDuplicated(a) && !anyDuplicated(b)
    p <- suppressWarnings(stats::cor.test(a, b, method = "spearman", exact = exact))$p.value
    if (!is.finite(p)) return(NA_real_)
    min(1, max(2 / factorial(n), p))
  }

  mw_test_ordonnee_origine <- function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    ex <- .mw_exclues_vide()
    jd <- .mw_j_exclues(aj, j_degeneres)
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 3) next                    # 2 parametres + 1 ddl minimum
      if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
      ex$eligibles <- ex$eligibles + 1L
      if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
      C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
      m <- try(summary(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
      if (inherits(m, "try-error") || nrow(m$coefficients) < 2) next
      det <- rbind(det, data.frame(
        j = j, n = length(idx),
        a = m$coefficients[1, 1], se_a = m$coefficients[1, 2],
        t = m$coefficients[1, 3], p = m$coefficients[1, 4],
        b = m$coefficients[2, 1], f_cl = aj$f[j + 1], stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                                exclues = ex$colonnes, eligibles = ex$eligibles))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
         t_max = det$t[which.max(abs(det$t))], j_max = det$j[which.max(abs(det$t))],
         exclues = ex$colonnes, eligibles = ex$eligibles)
  }

  mw_test_homogeneite_f <- function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    ex <- .mw_exclues_vide()
    jd <- .mw_j_exclues(aj, j_degeneres)
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 4) next
      if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
      ex$eligibles <- ex$eligibles + 1L
      if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
      F <- engine_aplatir_ex_aequo(tri[idx + 1, j + 2] / tri[idx + 1, j + 1], plancher = 0)
      ct <- suppressWarnings(stats::cor.test(F, idx, method = "spearman", exact = FALSE))
      det <- rbind(det, data.frame(j = j, n = length(idx),
        rho = unname(ct$estimate), p = .mw_spearman_p(F, idx),
        ex_aequo = anyDuplicated(F) > 0, stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                                exclues = ex$colonnes, eligibles = ex$eligibles))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
         exclues = ex$colonnes, eligibles = ex$eligibles)
  }

  mw_test_courbure <- function(aj, j_degeneres = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    ex <- .mw_exclues_vide()
    jd <- .mw_j_exclues(aj, j_degeneres)
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 4) next                    # 3 parametres + 1 ddl
      if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
      ex$eligibles <- ex$eligibles + 1L
      if (.mw_colonne_degeneree(aj, j)) return(.mw_stat_non_definie(ex))
      C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
      if (stats::sd(C0) == 0) next
      m <- try(summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0)), silent = TRUE)
      if (inherits(m, "try-error") || nrow(m$coefficients) < 3) next
      det <- rbind(det, data.frame(j = j, n = length(idx),
        c2 = m$coefficients[3, 1], t = m$coefficients[3, 3],
        p = m$coefficients[3, 4], stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                                exclues = ex$colonnes, eligibles = ex$eligibles))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
         exclues = ex$colonnes, eligibles = ex$eligibles)
  }

  mw_famille_alpha <- function(aj) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 3) next
      C0 <- tri[idx + 1, j + 1]; F <- tri[idx + 1, j + 2] / C0
      f <- vapply(c(0, 1, 2), function(a) sum(C0^a * F) / sum(C0^a), numeric(1))
      det <- rbind(det, data.frame(j = j, n = length(idx),
        f0 = f[1], f1 = f[2], f2 = f[3],
        amplitude = (max(f) - min(f)) / f[2], stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, detail = det))
    list(stat = sum(det$n * det$amplitude) / sum(det$n), detail = det)
  }

  mw_test_exposant_variance <- function(aj, j_degeneres = NULL) {
    res <- mw_residus(aj, j_degeneres)
    if (!nrow(res)) return(list(stat = NA_real_, p = NA_real_, detail = data.frame()))
    det <- data.frame()
    for (j in unique(res$j)) {
      d <- res[res$j == j, ]
      Ca <- engine_aplatir_ex_aequo(d$C, plancher = 0)
      ra <- engine_aplatir_ex_aequo(abs(d$residu))
      if (nrow(d) < 4 || stats::sd(Ca) == 0 || stats::sd(ra) == 0) next
      ct <- suppressWarnings(stats::cor.test(ra, Ca,
                                             method = "spearman", exact = FALSE))
      det <- rbind(det, data.frame(j = j, n = nrow(d),
        rho = unname(ct$estimate), p = .mw_spearman_p(ra, Ca, plancher_b = 0),
        ex_aequo = anyDuplicated(ra) > 0 || anyDuplicated(Ca) > 0,
        stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
  }

  mw_test_homogeneite_accident <- function(aj, j_degeneres = NULL) {
    res <- mw_residus(aj, j_degeneres)
    g <- factor(res$i)
    if (nlevels(g) < 3 || nrow(res) < 6)
      return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_, un_par_annee = FALSE))
    ra <- engine_aplatir_ex_aequo(res$residu)
    k <- try(stats::kruskal.test(ra, g), silent = TRUE)
    if (inherits(k, "try-error"))
      return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_, un_par_annee = FALSE))
    un <- nlevels(g) == nrow(res)
    p <- if (un) NA_real_ else .p_borne(k$p.value)
    list(stat = unname(k$statistic), p = p, ddl = unname(k$parameter), un_par_annee = un,
         tailles = as.vector(table(g)), ex_aequo = anyDuplicated(ra) > 0)
  }

  .mw_contexte_mc <- function(aj, j_degeneres = NULL) {
    jd <- .mw_j_exclues(aj, j_degeneres)
    res <- mw_residus(aj, jd)
    list(aj = aj, res = res, r = res$residu, j_degeneres = jd)
  }

  MW_CATALOGUE_MC <- list(
    Calendrier = .mc_entree(function(e) mw_test_annees_calendaires(e$aj, e$j_degeneres)$stat, "deux"),
    CorrDev    = .mc_entree(function(e) mw_stat_correlation_dev(e$aj, e$j_degeneres)$stat, "deux"),
    BP         = .mc_entree(function(e) {
      res <- e$res; r <- e$r
      if (nrow(res) > 3 && stats::sd(res$C) > 0)
        nrow(res) * summary(stats::lm(I(r^2) ~ res$C))$r.squared else NA_real_
    }, "haut"),
    Grubbs     = .mc_entree(function(e) test_grubbs(e$r)$stat, "haut"),
    DW         = .mc_entree(function(e) stat_dw(e$r), "deux"),
    Runs       = .mc_entree(function(e) test_runs(e$r)$stat, "deux"),
    PenteIntra = .mc_entree(function(e) .mw_pente_intra(e$res), "deux"),
    Origine    = .mc_entree(function(e) mw_test_ordonnee_origine(e$aj, e$j_degeneres)$stat, "haut"),
    HomogF     = .mc_entree(function(e) mw_test_homogeneite_f(e$aj, e$j_degeneres)$stat, "haut"),
    Courbure   = .mc_entree(function(e) mw_test_courbure(e$aj, e$j_degeneres)$stat, "haut"),
    Alpha      = .mc_entree(function(e) mw_famille_alpha(e$aj)$stat, "haut"),
    ExpVar     = .mc_entree(function(e) mw_test_exposant_variance(e$aj, e$j_degeneres)$stat, "haut"),
    KruskalAcc = .mc_entree(function(e) mw_test_homogeneite_accident(e$aj, e$j_degeneres)$stat, "haut")
  )

  .mw_stats <- function(aj, j_degeneres = NULL)
    .mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(aj, j_degeneres))

}, envir = ANCIEN)

# --- Outils de comparaison ----------------------------------------------------
# Valeur (ou message d'erreur) et avertissements emis, dans l'ordre.
capturer <- function(f, args) {
  av <- character(0)
  v <- withCallingHandlers(
    tryCatch(do.call(f, args), error = function(e) paste("ERREUR :", conditionMessage(e))),
    warning = function(w) { av <<- c(av, conditionMessage(w)); invokeRestart("muffleWarning") })
  list(valeur = v, avertissements = av)
}
# Identite au bit pres, ORDRE des attributs compris (attrib.as.set = FALSE) :
# identical() par defaut ne voit pas l'ordre names / class / row.names, que
# voit la comparaison aux references (structure_arbre(), outils_tests.R).
meme <- function(x, y) identical(x, y, attrib.as.set = FALSE)
# Fonctions comparees (nom dans le moteur et dans ANCIEN) ; mw_famille_alpha()
# ne prend pas j_degeneres.
FONCTIONS_JD <- c("mw_residus", "mw_test_annees_calendaires", "mw_test_ordonnee_origine",
                  "mw_test_homogeneite_f", "mw_test_courbure", "mw_test_exposant_variance",
                  "mw_test_homogeneite_accident", ".mw_contexte_mc", ".mw_stats")
# Ecarts entre les deux formes sur un triangle t, pour chaque ensemble de
# colonnes exclues de jds (NULL : calcule sur aj) : vecteur des fonctions en
# ecart, vide si tout est identique.
ecarts <- function(t, jds = list(NULL), etiquette = "") {
  aj <- tryCatch(mw_ajuster(t), error = function(e) NULL)
  if (is.null(aj)) return(character(0))
  out <- character(0)
  if (!meme(capturer(mw_famille_alpha, list(aj)), capturer(ANCIEN$mw_famille_alpha, list(aj))))
    out <- c(out, paste(etiquette, "mw_famille_alpha"))
  for (jd in jds) {
    for (f in FONCTIONS_JD)
      if (!meme(capturer(get(f), list(aj, jd)), capturer(ANCIEN[[f]], list(aj, jd))))
        out <- c(out, paste(etiquette, f, "jd =", deparse(jd)))
    # Residus transmis (argument res, #239) = residus recalcules (sauf si
    # mw_residus() echoue : noms de lignes manquants, erreur deja comparee).
    res <- tryCatch(mw_residus(aj, jd), error = function(e) NULL)
    if (!is.null(res)) for (f in c("mw_test_exposant_variance", "mw_test_homogeneite_accident"))
      if (!meme(capturer(get(f), list(aj, jd, res)), capturer(ANCIEN[[f]], list(aj, jd))))
        out <- c(out, paste(etiquette, f, "(res fourni) jd =", deparse(jd)))
  }
  out
}
resultat <- function(e) if (!length(e)) TRUE else paste(head(e, 5), collapse = " ; ")

tri_ref <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# Taylor & Ashe (1983), comme dans test_merz_wuthrich.R ; ta_deg : colonne
# j = 4 degeneree ; ta_bruit : la meme, perturbee de +/- 1e-14 en relatif.
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
ta_deg <- ta
ta_deg[1:5, 6] <- 1.05 * ta[1:5, 5]
ta_bruit <- ta_deg
ta_bruit[1:5, 6] <- ta_deg[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * 1e-14)
# Triangle a colonne j = 2 degeneree (test_merz_wuthrich.R, tri_deg).
tri_deg <- matrix(NA_real_, 6, 6)
tri_deg[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri_deg[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri_deg[3, 1:4] <- c(900, 1395, 1580, 1580)
tri_deg[4, 1:3] <- c(1200, 1980, 2210)
tri_deg[5, 1:2] <- c(1050, 1638)
tri_deg[6, 1]   <- 980

# Triangle tire sous la graine courante : n annees, facteurs decroissants
# bruites ; variantes : ex aequo (montants arrondis a la centaine), colonne
# degeneree (facteurs egaux), colonne nulle (cumuls inchanges, facteurs
# egaux a 1).
tirer_triangle <- function(n, variante = "continu") {
  t <- matrix(NA_real_, n, n)
  t[, 1] <- round(stats::rlnorm(n, log(1000), 0.3), 2)
  f <- 1 + 2 * exp(-(seq_len(n - 1)))
  for (j in seq_len(n - 1)) {
    i <- seq_len(n - j)
    t[i, j + 1] <- t[i, j] * (f[j] + stats::rnorm(length(i), 0, 0.05 * (f[j] - 1) + 0.002))
  }
  if (variante == "ex_aequo") t <- round(t, -2)
  if (n >= 4 && variante %in% c("degeneree", "nulle")) {
    j <- sample.int(n - 2, 1)
    i <- seq_len(n - j)
    t[i, j + 1] <- t[i, j] * (if (variante == "nulle") 1 else 1.1)
    for (jj in (j + 1):(n - 1)) {
      ii <- seq_len(n - jj)
      t[ii, jj + 1] <- t[ii, jj] * (f[jj] + stats::rnorm(length(ii), 0, 0.01))
    }
  }
  t[t <= 0] <- 1
  t
}

# --- Comparaisons -------------------------------------------------------------
verifier("Cas reserve2 : statistiques et tables identiques a l'ancienne forme (#239)",
         resultat(ecarts(tri_ref, list(NULL, integer(0), 4L), "reserve2")))

verifier("Cas reserve2, noms de lignes (lettres, numeros, collisions, doublons) : identiques (#239)",
         {
           noms <- list(paste0("a", 1:8), as.character(1:8), as.character(0:7),
                        c("a", "a1", "a2", "a11", "b", "a3", "a21", "a12"),
                        c("x", "x", "y", "z", "u", "v", "w", "t"),
                        c("", "", "", "", "", "", "", ""), c("", "b", "c", "d", "e", "f", "g", "h"),
                        c("", "1", "2", "11", "21", "3", "4", "5"), c("1", "11", "12", "111", "2", "21", "3", "31"),
                        c(NA, "b", "c", "d", "e", "f", "g", "h"))
           resultat(unlist(lapply(seq_along(noms), function(k) {
             t <- tri_ref; rownames(t) <- noms[[k]]
             ecarts(t, list(NULL, 4L, c(0L, 4L)), paste("noms", k))
           })))
         })

verifier("Triangles a colonne degeneree et minimaux : identiques a l'ancienne forme (#239)",
         resultat(c(ecarts(ta, list(NULL), "ta"), ecarts(ta_deg, list(NULL, integer(0)), "ta_deg"),
                    ecarts(ta_bruit, list(NULL, integer(0), 4L), "ta_bruit"),
                    ecarts(tri_deg, list(NULL, integer(0)), "tri_deg"),
                    ecarts(tri_ref[1:2, 1:2], list(NULL), "2 x 2"),
                    ecarts(tri_ref[1:3, 1:3], list(NULL), "3 x 3"),
                    ecarts(tri_ref[1:4, 1:4], list(NULL), "4 x 4"))))

# Replications du bootstrap (mw_simuler_triangle() sur le pool redresse de
# mw_bootstrap()), ensemble j_degeneres fige a l'observe, comme dans
# mw_bootstrap() : .mw_stats() et les tables de chaque replication.
verifier("Replications du bootstrap (reserve2, ta_deg, tri_deg) : identiques a l'ancienne forme (#239)",
         {
           e <- unlist(lapply(list(reserve2 = tri_ref, ta_deg = ta_deg, tri_deg = tri_deg), function(t) {
             aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
             pool <- .mw_pool_residus(aj, jd)
             tb <- engine_sous_graine(20261010, lapply(1:15, function(b) mw_simuler_triangle(aj, pool)))
             unlist(lapply(seq_along(tb), function(b) ecarts(tb[[b]], list(jd), paste("replication", b))))
           }))
           resultat(e)
         })

verifier("Triangles tires sous graine (3 a 12 annees, ex aequo, colonnes degenerees et nulles, noms) : identiques (#239)",
         {
           variantes <- c("continu", "ex_aequo", "degeneree", "nulle")
           tris <- engine_sous_graine(20261011, lapply(1:48, function(k) {
             t <- tirer_triangle(3L + (k %% 10L), variantes[(k %% 4L) + 1L])
             if (k %% 5L == 0L) rownames(t) <- sample(c(letters, paste0("a", 1:9)), nrow(t))
             t
           }))
           resultat(unlist(lapply(seq_along(tris), function(k)
             ecarts(tris[[k]], if (k %% 5L) list(NULL, integer(0)) else list(NULL, 0L, 1L),
                    paste("tirage", k)))))
         })

verifier(".mw_spearman_p() et .mw_spearman() : p identique a l'ancienne forme, rho = estimation de cor.test(exact = FALSE) (#239)",
         {
           ok <- engine_sous_graine(20261012, vapply(1:300, function(k) {
             n <- 3L + (k %% 12L)
             a <- if (k %% 3L) stats::rnorm(n) else round(stats::rnorm(n), 1)
             b <- if (k %% 2L) seq_len(n) - 1L else round(stats::rlnorm(n), 1) + 1
             pl <- if (k %% 2L) 1 else 0
             sp <- .mw_spearman(a, b, pl)
             ct <- suppressWarnings(stats::cor.test(a, engine_aplatir_ex_aequo(b, plancher = pl),
                                                    method = "spearman", exact = FALSE))
             identical(.mw_spearman_p(a, b, pl), ANCIEN$.mw_spearman_p(a, b, pl)) &&
               identical(sp$p, ANCIEN$.mw_spearman_p(a, b, pl)) &&
               identical(sp$rho, unname(ct$estimate))
           }, logical(1)))
           if (all(ok)) TRUE else paste(sum(!ok), "ecart(s)")
         })

# (a) mw_residus() appele une seule fois par evaluation du catalogue : le
# contexte .mw_contexte_mc() seulement (trois appels avant #239).
verifier("Une evaluation de .mw_stats() appelle mw_residus() une seule fois (#239)",
         {
           n <- 0L
           orig <- mw_residus
           env <- environment(mw_residus)
           assign("mw_residus", function(aj, j_degeneres = NULL) {
             n <<- n + 1L; orig(aj, j_degeneres) }, envir = env)
           tryCatch(.mw_stats(mw_ajuster(tri_ref), 4L),
                    finally = assign("mw_residus", orig, envir = env))
           if (identical(n, 1L) && identical(mw_residus, orig)) TRUE else paste("appels :", n)
         })

fin_fichier()
