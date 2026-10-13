###############################################################################
#  tests/unitaires/test_tables_mw.R  --  STATISTIQUES MERZ-WUTHRICH DU
#                    BOOTSTRAP CONTRE LEUR ANCIENNE FORME (#239)
#
#  Depuis #239 : (a) mw_test_exposant_variance() et
#  mw_test_homogeneite_accident() recoivent les residus de Mack du contexte
#  .mw_contexte_mc() (argument res) au lieu de rappeler mw_residus() ;
#  (b) HomogF et ExpVar tirent rho et p d'un seul cor.test() (.mw_spearman()),
#  sauf sur le chemin enumere avec ex aequo (n <= 9), ou cor.test() n'est
#  plus appele depuis #260 : rho y est calcule par cor(rank(a), rank(b)),
#  formule de cor.test() ;
#  (c) les tables de mw_residus(), mw_test_annees_calendaires(),
#  mw_test_ordonnee_origine(), mw_test_homogeneite_f(), mw_test_courbure(),
#  mw_famille_alpha() et mw_test_exposant_variance() sont assemblees une
#  fois (#239 : colonnes prealloues et .mw_table() ; #250 : blocs empiles par
#  l'utilitaire unique .mw_empiler(), noms de lignes par rbind() itere dans
#  .mw_noms_lignes_empilees()), au lieu d'un rbind() par colonne. Les deux
#  utilitaires sont aussi compares directement a rbind() itere, sur des blocs
#  synthetiques (fin du fichier, #250). Critere de #239 : resultats IDENTIQUES au bit pres, ordre des
#  attributs compris (identical(attrib.as.set = FALSE)). La contre-implementation
#  ci-dessous est l'ancienne forme, copiee du moteur au commit daabd7a
#  (commentaires retires ; residu de mw_residus() reporte sous la forme
#  stable de #233, .mw_ecart_facteur_stable() ; t et p du terme quadratique
#  de mw_test_courbure() reportes sous la forme close de #253,
#  .mw_courbure_colonne(), qui remplace lm() dans le moteur : la comparaison
#  porte sur l'assemblage des tables, objet de #239), evaluee dans un
#  environnement dedie dont le parent
#  est celui du moteur : les fonctions non modifiees (mw_stat_correlation_dev(),
#  .mw_pente_intra(), .mc_evaluer()...) sont communes. Chaque fonction est
#  comparee par meme() (valeur, ou message d'erreur) et par la liste des
#  avertissements emis, sur les jeux ci-dessous. Chaque cas y figure AU MOINS
#  UNE FOIS, au plus petit nombre de triangles et de replications qui le
#  couvre (allegement de #239, decision du mainteneur du 10/10/2026 : environ
#  27 s -> environ 7 s sur le poste de session ; aucun appel a run_engine()) :
#    - le triangle du cas reserve2 (tests/donnees/triangle_mw.csv), sans noms
#      de lignes (colonnes exclues : calculees, aucune, j = 4) ;
#    - le meme a dix jeux de noms de lignes (lettres, numeros, numeros
#      commencant a 0, collisions avec make.unique(), doublons, vides,
#      partiellement vides, manquant), colonnes exclues calculees, j = 4 et
#      j = 0 et 4. Seules y sont comparees les fonctions dont la sortie depend
#      des noms : mw_residus(), mw_test_annees_calendaires(),
#      mw_test_exposant_variance(), mw_test_homogeneite_accident() et
#      .mw_contexte_mc(). Les autres (mw_famille_alpha(),
#      mw_test_ordonnee_origine(), mw_test_homogeneite_f(), mw_test_courbure(),
#      .mw_stats()) rendent, dans les deux formes et pour ces trente
#      combinaisons, la valeur du triangle sans noms, sauf .mw_stats() aux
#      noms manquants, qui rend l'erreur de .mw_contexte_mc(), comparee
#      (mesure du 11/10/2026). L'ensemble complet des fonctions est compare
#      sur un jeu, le 4e (collisions avec make.unique()), sous j = 0 et 4
#      exclues ;
#    - Taylor & Ashe a colonne j = 4 degeneree (ta_deg) et bruitee a 1e-14
#      (ta_bruit), le triangle tri_deg (colonne j = 2 degeneree), colonnes
#      exclues calculees et aucune (chemin .mw_stat_non_definie()) ;
#    - les triangles minimaux 2 x 2 a 4 x 4 ;
#    - les deux premieres replications du bootstrap du cas reserve2 et de
#      tri_deg (graine 20261010) et de ta_deg (graine 20261021, choisie pour
#      couvrir en deux replications les deux cas de la colonne figee j = 4 :
#      sigma2_4 bruit d'arrondi strictement positif, 2,0e-25, colonne exclue
#      par l'ensemble fige, et non par le critere sigma2 <= 0, puis
#      sigma2_4 = 0 exactement ; sous la graine 20261010, le premier cas
#      n'apparaissait qu'a la 7e replication),
#      ensemble j_degeneres fige a l'observe ;
#    - douze triangles tires sous graine (PLAN_TIRAGES : 3 a 12 annees ;
#      continus ; ex aequo, effectifs au tirage 9, 8 annees ; colonnes
#      degenerees interieures, tirages 3, 4, 7, 9 a 12 ; colonnes nulles
#      (facteurs egaux a 1), tirages 4, 7, 9 et 11 ; noms de lignes ordinaires,
#      tirages 5, 6 et 10, colonnes exclues calculees, j = 0 et j = 1).
#  Un ensemble de colonnes exclues qui se resout au meme ensemble qu'un
#  ensemble deja compare sur le meme triangle n'est pas recalcule (ecarts()).
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
        # #233 : ecart F - f sous forme stable, reporte dans l'ancienne forme
        # (seule la valeur du residu change ; l'assemblage compare par #239
        # est inchange)
        residu = sqrt(Cij) * .mw_ecart_facteur_stable(Cij, Cij1) / sqrt(aj$sigma2[j + 1]),
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

  # Renommee par #207 : la p de Spearman de l'ancienne forme (daabd7a) n'est
  # plus celle du moteur avec ex aequo a n <= 9 ; les copies de
  # mw_test_homogeneite_f() et mw_test_exposant_variance() ci-dessous
  # appellent la .mw_spearman_p() du moteur (environnement parent), de sorte
  # que la comparaison porte sur l'assemblage des tables (#239), et cette copie
  # ne sert plus qu'a la comparaison sans ex aequo de .mw_spearman_p().
  .mw_spearman_p_daabd7a <- function(a, b, plancher_b = 1) {
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
      m <- .mw_courbure_colonne(C0, C1)
      if (is.null(m)) next
      det <- rbind(det, data.frame(j = j, n = length(idx),
        c2 = m[["c2"]], t = m[["t"]], p = m[["p"]], stringsAsFactors = FALSE))
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
# ecart, vide si tout est identique. fonctions : sous-ensemble de FONCTIONS_JD
# compare (toutes par defaut) ; alpha : comparer aussi mw_famille_alpha().
# Allegement (#239, decision du 10/10/2026) : (i) un element de jds qui se
# resout (.mw_j_exclues()) au meme ensemble qu'un element deja traite est
# saute : toutes les fonctions comparees, dans les deux formes, ne lisent
# j_degeneres qu'au travers de .mw_j_exclues(), commune aux deux formes, ou
# le transmettent a mw_residus() ; (ii) les valeurs capturees sont reutilisees :
# residus transmis = valeur capturee de mw_residus(), ancienne forme de
# mw_test_exposant_variance() et mw_test_homogeneite_accident() calculee une
# fois.
# masse_min (#207) et p_min_col (#125) : elements ajoutes au resultat de
# mw_test_homogeneite_f() et de mw_test_exposant_variance(), absents de
# l'ancienne forme ; retires avant comparaison (leur calcul est controle dans
# test_merz_wuthrich.R et test_plancher_mc.R).
sans_masse <- function(x) {
  if (is.list(x$valeur) && !is.null(x$valeur$masse_min)) x$valeur$masse_min <- NULL
  if (is.list(x$valeur) && !is.null(x$valeur$p_min_col)) x$valeur$p_min_col <- NULL
  x
}
ecarts <- function(t, jds = list(NULL), etiquette = "", fonctions = FONCTIONS_JD,
                   alpha = TRUE) {
  aj <- tryCatch(mw_ajuster(t), error = function(e) NULL)
  if (is.null(aj)) return(character(0))
  out <- character(0)
  if (alpha && !meme(capturer(mw_famille_alpha, list(aj)), capturer(ANCIEN$mw_famille_alpha, list(aj))))
    out <- c(out, paste(etiquette, "mw_famille_alpha"))
  vus <- list()
  for (jd in jds) {
    r <- .mw_j_exclues(aj, jd)
    # Filet de securite, inactif sur les jeux actuels (0 saut sur 76 ensembles).
    if (any(vapply(vus, identical, logical(1), r))) next
    vus[[length(vus) + 1L]] <- r
    nouv <- lapply(stats::setNames(nm = fonctions), function(f) sans_masse(capturer(get(f), list(aj, jd))))
    anc  <- lapply(stats::setNames(nm = fonctions), function(f) capturer(ANCIEN[[f]], list(aj, jd)))
    for (f in fonctions)
      if (!meme(nouv[[f]], anc[[f]])) out <- c(out, paste(etiquette, f, "jd =", deparse(jd)))
    # Residus transmis (argument res, #239) = residus recalcules (sauf si
    # mw_residus() echoue : noms de lignes manquants, erreur deja comparee).
    res <- nouv[["mw_residus"]]$valeur
    if (is.data.frame(res))
      for (f in intersect(c("mw_test_exposant_variance", "mw_test_homogeneite_accident"), fonctions))
        if (!meme(sans_masse(capturer(get(f), list(aj, jd, res))), anc[[f]]))
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
           # Fonctions dont la sortie depend des noms de lignes seulement (en-tete).
           sensibles <- c("mw_residus", "mw_test_annees_calendaires", "mw_test_exposant_variance",
                          "mw_test_homogeneite_accident", ".mw_contexte_mc")
           # Jeu 4 (collisions avec make.unique()) : ensemble complet des
           # fonctions, mw_famille_alpha() comprise, sous j = 0 et 4 exclues.
           complet <- 4L
           resultat(unlist(lapply(seq_along(noms), function(k) {
             t <- tri_ref; rownames(t) <- noms[[k]]
             if (k == complet)
               c(ecarts(t, list(NULL, 4L), paste("noms", k), fonctions = sensibles, alpha = FALSE),
                 ecarts(t, list(c(0L, 4L)), paste("noms", k, "(complet)")))
             else ecarts(t, list(NULL, 4L, c(0L, 4L)), paste("noms", k), fonctions = sensibles,
                         alpha = FALSE)
           })))
         })

verifier("Triangles a colonne degeneree et minimaux : identiques a l'ancienne forme (#239)",
         resultat(c(ecarts(ta_deg, list(NULL, integer(0)), "ta_deg"),
                    ecarts(ta_bruit, list(NULL, integer(0), 4L), "ta_bruit"),
                    ecarts(tri_deg, list(NULL, integer(0)), "tri_deg"),
                    ecarts(tri_ref[1:2, 1:2], list(NULL), "2 x 2"),
                    ecarts(tri_ref[1:3, 1:3], list(NULL), "3 x 3"),
                    ecarts(tri_ref[1:4, 1:4], list(NULL), "4 x 4"))))

# Replications du bootstrap (mw_simuler_triangle() sur le pool redresse de
# mw_bootstrap()), ensemble j_degeneres fige a l'observe, comme dans
# mw_bootstrap() : .mw_stats() et les tables de chaque replication.
# Graine et nombre de replications par triangle (en-tete) : premieres
# replications de la sequence tiree sous la graine du cas.
verifier("Replications du bootstrap (reserve2, ta_deg, tri_deg) : identiques a l'ancienne forme (#239)",
         {
           cas <- list(reserve2 = list(tri_ref, 20261010, 2L), ta_deg = list(ta_deg, 20261021, 2L),
                       tri_deg = list(tri_deg, 20261010, 2L))
           e <- unlist(lapply(names(cas), function(nm) {
             aj <- mw_ajuster(cas[[nm]][[1]]); jd <- .mw_colonnes_degenerees(aj)
             pool <- .mw_pool_residus(aj, jd)
             tb <- engine_sous_graine(cas[[nm]][[2]], lapply(seq_len(cas[[nm]][[3]]),
                                                       function(b) mw_simuler_triangle(aj, pool)))
             unlist(lapply(seq_along(tb), function(b)
               ecarts(tb[[b]], list(jd), paste(nm, "replication", b))))
           }))
           resultat(e)
         })

# Plan des triangles tires (en-tete) : taille, variante, noms de lignes.
PLAN_TIRAGES <- data.frame(
  n        = c(3L, 3L, 4L, 4L, 5L, 6L, 7L, 8L, 8L, 8L, 10L, 12L),
  variante = c("continu", "ex_aequo", "degeneree", "nulle", "ex_aequo", "continu",
               "nulle", "continu", "ex_aequo", "degeneree", "nulle", "degeneree"),
  noms     = c(FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE),
  stringsAsFactors = FALSE)
TIRAGES <- engine_sous_graine(20261011, lapply(seq_len(nrow(PLAN_TIRAGES)), function(k) {
  t <- tirer_triangle(PLAN_TIRAGES$n[k], PLAN_TIRAGES$variante[k])
  if (PLAN_TIRAGES$noms[k]) rownames(t) <- sample(c(letters, paste0("a", 1:9)), nrow(t))
  t
}))
verifier("Triangles tires sous graine (3 a 12 annees, ex aequo, colonnes degenerees et nulles, noms) : identiques (#239)",
         resultat(unlist(lapply(seq_along(TIRAGES), function(k)
           ecarts(TIRAGES[[k]], if (PLAN_TIRAGES$noms[k]) list(NULL, 0L, 1L) else list(NULL, integer(0)),
                  paste("tirage", k))))))

# Restreint par #207 : avec ex aequo a n <= 9, la p de .mw_spearman() suit
# la loi de permutation conditionnelle aux rangs moyens (.mw_spearman_loi_rangs()),
# et non plus l'ancienne forme ; l'identite de p a l'ancienne forme n'est
# exigee que sans ex aequo (ou a n > 9, chemin inchange), celle de rho partout.
verifier(".mw_spearman_p() et .mw_spearman() : p identique a l'ancienne forme sans ex aequo, rho = estimation de cor.test(exact = FALSE) (#239, #207)",
         {
           ok <- engine_sous_graine(20261012, vapply(1:300, function(k) {
             n <- 3L + (k %% 12L)
             a <- if (k %% 3L) stats::rnorm(n) else round(stats::rnorm(n), 1)
             b <- if (k %% 2L) seq_len(n) - 1L else round(stats::rlnorm(n), 1) + 1
             pl <- if (k %% 2L) 1 else 0
             sp <- .mw_spearman(a, b, pl)
             bp <- engine_aplatir_ex_aequo(b, plancher = pl)
             ct <- suppressWarnings(stats::cor.test(a, bp, method = "spearman", exact = FALSE))
             ea9 <- n <= 9 && (anyDuplicated(a) > 0 || anyDuplicated(bp) > 0)
             p_att <- if (ea9) .mw_spearman_loi_rangs(a, bp)$p else ANCIEN$.mw_spearman_p_daabd7a(a, b, pl)
             identical(.mw_spearman_p(a, b, pl), p_att) && identical(sp$p, p_att) &&
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

# --- .mw_empiler() et .mw_noms_lignes_empilees() contre rbind() (#250) -------
# Blocs synthetiques de tailles 1 a 4, a la forme de ceux de mw_residus()
# (colonnes entieres i et j, colonne C qui porte les noms de
# lignes) : sans noms, noms tires d'un vivier a collisions avec make.unique()
# ("a", "a1", "a11"...), doublons, vides, numeros, ou noms manquants (NA).
# Reference : l'ancienne forme, rbind() ITERE depuis data.frame() sur des
# data.frame() a trois colonnes, comparee par meme() (valeur, ou message
# d'erreur) ; .mw_noms_lignes_empilees() seule est comparee aux noms de
# lignes de cette reference.
VIVIER_NOMS <- c("a", "a1", "a2", "a11", "a12", "a21", "b", "b1", "1", "2", "11", "")
tirer_blocs <- function(k) {
  nb <- 1L + (k %% 5L)
  lapply(seq_len(nb), function(b) {
    n <- 1L + ((k + b) %% 4L)
    C <- round(stats::rlnorm(n), 3)
    type <- (k * 7L + b) %% 6L
    if (type >= 3L) names(C) <- sample(VIVIER_NOMS, n, replace = TRUE)
    if (type == 5L && k %% 11L == 0L) names(C)[1L] <- NA
    list(i = seq_len(n) - 1L, j = rep(as.integer(b), n), C = C)
  })
}
rbind_itere <- function(blocs)
  Reduce(function(table, b) rbind(table, data.frame(i = b$i, j = b$j, C = b$C,
                                                     stringsAsFactors = FALSE)),
         blocs, data.frame())
JEUX_BLOCS <- engine_sous_graine(20261111, lapply(1:400, tirer_blocs))
verifier(".mw_empiler() : table identique a rbind() itere, noms de lignes compris (#250)",
         {
           e <- which(!vapply(JEUX_BLOCS, function(bl)
             meme(capturer(.mw_empiler, list(bl, "C")), capturer(rbind_itere, list(bl))),
             logical(1)))
           if (!length(e)) TRUE else paste("jeux en ecart :", paste(head(e, 10), collapse = " "))
         })
verifier(".mw_noms_lignes_empilees() : noms de lignes de rbind() itere, NULL si automatiques (#250)",
         {
           e <- which(!vapply(JEUX_BLOCS, function(bl) {
             ref <- tryCatch(rbind_itere(bl), error = function(err) NULL)
             if (is.null(ref)) return(TRUE)   # noms manquants : erreur, comparee ci-dessus
             attendu <- if (.row_names_info(ref) > 0L) attr(ref, "row.names") else NULL
             identical(.mw_noms_lignes_empilees(lapply(bl, `[[`, "C")), attendu)
           }, logical(1)))
           if (!length(e)) TRUE else paste("jeux en ecart :", paste(head(e, 10), collapse = " "))
         })
# Pourquoi rbind() ITERE et non do.call(rbind, blocs) : make.unique() a chaque
# empilement ou une seule fois donnent des noms differents sur certains jeux
# de collisions (en-tete de .mw_noms_lignes_empilees(), moteur).
verifier("do.call(rbind, blocs) rend d'autres noms que rbind() itere sur au moins un jeu (#250)",
         {
           n <- sum(vapply(JEUX_BLOCS, function(bl) {
             a <- tryCatch(rbind_itere(bl), error = function(err) NULL)
             if (is.null(a)) return(FALSE)
             b <- do.call(rbind, lapply(bl, function(x) data.frame(i = x$i, j = x$j, C = x$C)))
             !identical(attr(a, "row.names"), attr(b, "row.names"))
           }, logical(1)))
           if (n > 0L) TRUE else "aucun ecart entre les deux formes"
         })

# --- mw_influence() et .mw_pool_residus() contre leur forme de a3d68b7 (#260) --
# Depuis #260 (points 2 et 3) : la somme des autres cellules d'une colonne est
# calculee par l'utilitaire unique .mw_sommes_autres(), partage par
# .mw_pool_residus() (une fois par colonne au lieu d'une fois par residu) et
# mw_influence() ; mw_influence() empile ses blocs par .mw_empiler() au lieu
# d'un rbind() itere. Reference : les deux fonctions copiees du moteur au
# commit a3d68b7 (commentaires retires), evaluees dans un environnement dedie
# dont le parent est celui du moteur. Critere : identite au bit pres, ordre des
# attributs compris (meme()), valeur ou message d'erreur. Jeux : le triangle
# du cas reserve2, sans noms et aux dix jeux de noms de lignes du test #239
# ci-dessus (noms manquants compris : erreur, comparee par son message) ; ce
# triangle a ligne 0 dominante (x 10^10, 10^17, 10^30) ; ta_deg, ta_bruit,
# tri_deg ; les triangles minimaux 2 x 2 a 4 x 4 ; les douze triangles tires
# (TIRAGES). Pool compare avec j_degeneres calcule (NULL) et fige a l'observe
# (.mw_colonnes_degenerees()), comme dans mw_bootstrap().
ANCIEN_A3D68B7 <- new.env(parent = environment(mw_ajuster))
local({
  .mw_pool_residus <- function(aj, j_degeneres = NULL) {
    res <- mw_residus(aj, j_degeneres)
    if (!nrow(res)) return(numeric(0))
    un_moins_h <- vapply(seq_len(nrow(res)), function(k) {
      col <- aj$tri[seq_len(aj$I - res$j[k]), res$j[k] + 1]
      sum(col[-(res$i[k] + 1)]) / sum(col)
    }, numeric(1))
    pool <- res$residu / sqrt(un_moins_h)
    pool - mean(pool)
  }
  mw_influence <- function(aj) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    jd <- .mw_j_exclues(aj, NULL)
    out <- data.frame()
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 2) next
      Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
      Sj <- sum(Cij); Sj1 <- sum(Cij1)
      h <- Cij / Sj
      S_sans <- vapply(seq_along(Cij), function(k) sum(Cij[-k]), numeric(1))
      S1_sans <- vapply(seq_along(Cij1), function(k) sum(Cij1[-k]), numeric(1))
      f_sans <- S1_sans / S_sans
      retenue <- is.finite(aj$sigma2[j + 1]) && aj$sigma2[j + 1] > 0 && !(j %in% jd)
      ecart_f <- .mw_ecart_facteur_stable(Cij, Cij1)
      resid <- if (retenue)
        sqrt(Cij) * ecart_f / sqrt(aj$sigma2[j + 1])
      else rep(NA_real_, length(idx))
      n <- length(idx)
      dfbetas <- rep(NA_real_, n)
      non_borne <- rep(FALSE, n)
      if (retenue && n >= 3) {
        e <- Cij * ecart_f
        un_moins_h <- S_sans / Sj
        s2 <- sum(e^2 / Cij) / (n - 1)
        if (is.finite(s2) && s2 > 0) {
          s2_i <- vapply(seq_len(n), function(k)
            sum(Cij[-k] * .mw_ecart_facteur_stable(Cij[-k], Cij1[-k])^2) / (n - 2),
            numeric(1))
          garde <- 1e2 * .Machine$double.eps * (n - 1) * s2
          ok <- is.finite(s2_i) & s2_i > garde
          non_borne <- is.finite(s2_i) & s2_i <= garde
          dfbetas[ok] <- e[ok] * sqrt(Sj) / (Sj * un_moins_h[ok] * sqrt(s2_i[ok]))
          dfbetas[!is.finite(dfbetas)] <- NA_real_
        }
      }
      out <- rbind(out, data.frame(
        i = idx, j = j, C = Cij, F = Cij1 / Cij,
        levier = h, seuil_levier = 2 / length(idx),
        f_chapeau = aj$f[j + 1], f_sans_cellule = f_sans,
        dfbeta_relatif = -Cij * ecart_f / S_sans / aj$f[j + 1],
        residu = resid,
        dfbetas = dfbetas, repere_dfbetas = REPERE_DFBETAS_MW / sqrt(n),
        dfbetas_non_borne = non_borne,
        stringsAsFactors = FALSE))
    }
    dfb <- out$dfbetas; rep_dfb <- out$repere_dfbetas; nb <- out$dfbetas_non_borne
    out$dfbetas <- NULL; out$repere_dfbetas <- NULL; out$dfbetas_non_borne <- NULL
    out$fort_levier <- out$levier > out$seuil_levier
    out$dfbetas <- dfb
    out$repere_dfbetas <- rep_dfb
    out$fort_dfbetas <- !is.na(out$dfbetas) & abs(out$dfbetas) > out$repere_dfbetas
    out$dfbetas_non_borne <- nb
    out
  }
}, envir = ANCIEN_A3D68B7)
# Ecarts sur un triangle t : vecteur des fonctions en ecart, vide si tout est
# identique (ajustement refuse : rien a comparer, compte a part).
ecarts_260 <- function(t, etiquette) {
  aj <- tryCatch(mw_ajuster(t), error = function(e) NULL)
  if (is.null(aj)) return(character(0))
  jd <- tryCatch(.mw_colonnes_degenerees(aj), error = function(e) NULL)
  c(if (!meme(capturer(mw_influence, list(aj)), capturer(ANCIEN_A3D68B7$mw_influence, list(aj))))
      paste(etiquette, ": mw_influence"),
    if (!meme(capturer(.mw_pool_residus, list(aj)), capturer(ANCIEN_A3D68B7$.mw_pool_residus, list(aj))))
      paste(etiquette, ": .mw_pool_residus"),
    if (!is.null(jd) && !meme(capturer(.mw_pool_residus, list(aj, jd)),
                              capturer(ANCIEN_A3D68B7$.mw_pool_residus, list(aj, jd))))
      paste(etiquette, ": .mw_pool_residus (jd fige)"))
}
verifier("mw_influence() et .mw_pool_residus() : identiques a la forme de a3d68b7, noms, cellule dominante et colonnes degenerees compris (#260)",
         {
           noms <- list(paste0("a", 1:8), as.character(1:8), as.character(0:7),
                        c("a", "a1", "a2", "a11", "b", "a3", "a21", "a12"),
                        c("x", "x", "y", "z", "u", "v", "w", "t"),
                        c("", "", "", "", "", "", "", ""), c("", "b", "c", "d", "e", "f", "g", "h"),
                        c("", "1", "2", "11", "21", "3", "4", "5"), c("1", "11", "12", "111", "2", "21", "3", "31"),
                        c(NA, "b", "c", "d", "e", "f", "g", "h"))
           jeux <- c(list(reserve2 = tri_ref),
                     stats::setNames(lapply(noms, function(nm) { t <- tri_ref; rownames(t) <- nm; t }),
                                     paste("noms", seq_along(noms))),
                     stats::setNames(lapply(c(10, 17, 30), function(e) { t <- tri_ref; t[1, ] <- t[1, ] * 10^e; t }),
                                     paste("ligne 0 x 10 ^", c(10, 17, 30))),
                     list(ta_deg = ta_deg, ta_bruit = ta_bruit, tri_deg = tri_deg,
                          "2 x 2" = tri_ref[1:2, 1:2], "3 x 3" = tri_ref[1:3, 1:3], "4 x 4" = tri_ref[1:4, 1:4]),
                     stats::setNames(TIRAGES, paste("tirage", seq_along(TIRAGES))))
           resultat(unlist(lapply(names(jeux), function(nm) ecarts_260(jeux[[nm]], nm))))
         })

fin_fichier()
