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
#  .mw_courbure_colonne(), qui remplace lm() dans le moteur ; p asymptotique
#  de mw_test_annees_calendaires() et queue de l'entree Calendrier reportees
#  sous la forme de #276, queue basse : la comparaison
#  porte sur l'assemblage des tables, objet de #239 ; ensembles figes rendus
#  par le contexte dans l'element figes, forme de l'objet de
#  .mw_ensembles_figes(), et moteur appele par l'adaptateur moteur(), #278),
#  evaluee dans un
#  environnement dedie dont le parent
#  est celui du moteur : les fonctions non modifiees (mw_stat_correlation_dev(),
#  .mw_pente_intra(), .mc_evaluer()...) sont communes, de meme que la
#  statistique BP, reportee sous la forme de #301
#  (mw_test_heteroscedasticite_intra()), et la statistique de cellule
#  aberrante, reportee sous la forme de #300 (cle MinP4,
#  mw_test_cellule_aberrante(), evaluee comme observee, comme par .mw_stats()
#  du moteur par defaut). Chaque fonction est
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
#    - les triangles T1, T3, T4 et T6 a colonne non identifiable de la
#      courbure (#269, #270, #278), et les deux premieres replications de T1,
#      de T3 et de T4 (graine 20261010) sous l'ensemble des colonnes non
#      identifiables fige a l'observe ; la courbure de l'ancienne forme y est
#      une reecriture independante de la selection des colonnes (T270-7) ;
#    - la branche (b) de la courbure (#270, #278) : triangles T1b et T3b, ou
#      la colonne de l'ensemble fige est degeneree dans l'appel ;
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
    # p asymptotique reportee sous la forme de #276 (queue basse, Phi(Z*),
    # decision Q-Fd-3) : la comparaison porte sur l'assemblage des tables
    list(stat = st, p = .p_borne(stats::pnorm(st)),
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

  # Ordonnee a l'origine : reecriture independante de la selection des
  # colonnes (#273, T273-9 ; option (A) du mainteneur, 14/10/2026). L'ensemble
  # des colonnes non identifiables est recalcule ici (.jno_oracle(), predicat
  # ecrit a nouveau : n_j >= 3, hors des colonnes exclues, non degeneree, une
  # seule valeur distincte de C(i,j)), sans
  # .mw_colonnes_origine_non_identifiables() ; fourni (j_non_identifiables),
  # il est fige comme dans mw_bootstrap(). Element non_identifiables empile
  # par rbind() avant la boucle, porte par les retours NA. Colonne retenue
  # dont lm() echoue ou rend moins de deux coefficients (second volet de
  # #56, plus de next silencieux) : statistique NA, K NA.
  # Oracle commun aux deux predicats (#290) : n_j >= n_min, hors des colonnes
  # exclues, non degeneree, au plus k_max valeurs distinctes de C(i,j) ;
  # ecrit independamment de .mw_colonnes_non_identifiables().
  .jx_oracle <- function(aj, jd, n_min, k_max) {
    out <- integer(0)
    for (j in 0:(aj$J - 1)) {
      n <- aj$I - j
      if (n < n_min || j %in% jd || .mw_colonne_degeneree(aj, j)) next
      if (length(unique(aj$tri[seq_len(n), j + 1])) <= k_max) out <- c(out, as.integer(j))
    }
    out
  }
  .jno_oracle <- function(aj, jd) .jx_oracle(aj, jd, 3L, 1L)
  mw_test_ordonnee_origine <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    ex <- .mw_exclues_vide()
    jd <- .mw_j_exclues(aj, j_degeneres)
    jno <- if (is.null(j_non_identifiables)) .jno_oracle(aj, jd) else as.integer(j_non_identifiables)
    ni <- data.frame(j = integer(0), n_facteurs = integer(0))
    for (j in sort(unique(jno)))
      if (j >= 0 && j <= J - 1 && I - j >= 3 && !(j %in% jd))
        ni <- rbind(ni, data.frame(j = as.integer(j), n_facteurs = as.integer(I - j)))
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 3) next                    # 2 parametres + 1 ddl minimum
      if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
      ex$eligibles <- ex$eligibles + 1L
      if (j %in% jno) next
      if (.mw_colonne_degeneree(aj, j))
        return(c(.mw_stat_non_definie(ex), list(non_identifiables = ni)))
      C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
      m <- try(summary(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
      if (inherits(m, "try-error") || nrow(m$coefficients) < 2)
        return(c(.mw_stat_non_definie(ex), list(non_identifiables = ni)))
      det <- rbind(det, data.frame(
        j = j, n = length(idx),
        a = m$coefficients[1, 1], se_a = m$coefficients[1, 2],
        t = m$coefficients[1, 3], p = m$coefficients[1, 4],
        b = m$coefficients[2, 1], f_cl = aj$f[j + 1], stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                                exclues = ex$colonnes, eligibles = ex$eligibles,
                                non_identifiables = ni))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
         t_max = det$t[which.max(abs(det$t))], j_max = det$j[which.max(abs(det$t))],
         exclues = ex$colonnes, eligibles = ex$eligibles, non_identifiables = ni)
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

  # Courbure : reecriture independante de la selection des colonnes (#269,
  # #270, T270-7 de la specification d'E2e). L'ensemble des colonnes non
  # identifiables est recalcule ici (.jni_oracle(), predicat ecrit a nouveau :
  # n_j >= 4, hors des colonnes exclues, non degeneree, au plus deux valeurs
  # distinctes de C(i,j)), sans .mw_colonnes_courbure_non_identifiables() ;
  # fourni (j_non_identifiables), il est fige comme dans mw_bootstrap().
  # L'element non_identifiables est empile par rbind() (et non forme d'un
  # bloc comme dans le moteur), avant la boucle : il decrit l'ensemble fige et
  # est porte tel quel par les retours NA (constat 3b de l'audit de #269).
  # Colonne retenue mais non identifiable dans l'appel (second volet de #270) :
  # statistique NA, K NA. t et p par .mw_courbure_colonne() (forme close de
  # #253), commune aux deux formes.
  .jni_oracle <- function(aj, jd) .jx_oracle(aj, jd, 4L, 2L)
  mw_test_courbure <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL) {
    I <- aj$I; J <- aj$J; tri <- aj$tri
    det <- data.frame()
    ex <- .mw_exclues_vide()
    jd <- .mw_j_exclues(aj, j_degeneres)
    jni <- if (is.null(j_non_identifiables)) .jni_oracle(aj, jd) else as.integer(j_non_identifiables)
    ni <- data.frame(j = integer(0), n_facteurs = integer(0))
    for (j in sort(unique(jni)))
      if (j >= 0 && j <= J - 1 && I - j >= 4 && !(j %in% jd))
        ni <- rbind(ni, data.frame(j = as.integer(j), n_facteurs = as.integer(I - j)))
    for (j in 0:(J - 1)) {
      idx <- 0:(I - j - 1)
      if (length(idx) < 4) next                    # 3 parametres + 1 ddl
      if (j %in% jd) { ex <- .mw_exclure(ex, j, length(idx)); next }
      ex$eligibles <- ex$eligibles + 1L
      if (j %in% jni) next
      if (.mw_colonne_degeneree(aj, j))
        return(c(.mw_stat_non_definie(ex), list(non_identifiables = ni)))
      C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
      m <- .mw_courbure_colonne(C0, C1)
      if (is.null(m)) return(c(.mw_stat_non_definie(ex), list(non_identifiables = ni)))
      det <- rbind(det, data.frame(j = j, n = length(idx),
        c2 = m[["c2"]], t = m[["t"]], p = m[["p"]], stringsAsFactors = FALSE))
    }
    if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det,
                                exclues = ex$colonnes, eligibles = ex$eligibles,
                                non_identifiables = ni))
    fc <- .fisher_combine(det$p)
    list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
         exclues = ex$colonnes, eligibles = ex$eligibles, non_identifiables = ni)
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

  # Champs j_non_identifiables (#270) et j_origine_non_identifiables (#273) :
  # ensembles fournis, ou recalcules par .jni_oracle() et .jno_oracle().
  # Ensembles rendus dans l'element figes du contexte, sous la forme de
  # l'objet de .mw_ensembles_figes() (#278 : transposition de l'interface
  # seule, ensembles calcules ici comme avant).
  .mw_contexte_mc <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL,
                              j_origine_non_identifiables = NULL) {
    jd <- .mw_j_exclues(aj, j_degeneres)
    res <- mw_residus(aj, jd)
    jni <- if (is.null(j_non_identifiables)) .jni_oracle(aj, jd) else as.integer(j_non_identifiables)
    jno <- if (is.null(j_origine_non_identifiables)) .jno_oracle(aj, jd) else
      as.integer(j_origine_non_identifiables)
    list(aj = aj, res = res, r = res$residu,
         figes = list(degeneres = jd, non_identifiables = jni, origine_non_identifiables = jno))
  }

  # Calendrier en queue basse depuis #276 (decision Q-Fd-1 ; sans effet sur
  # .mw_stats(), qui ne lit que les statistiques)
  MW_CATALOGUE_MC <- list(
    Calendrier = .mc_entree(function(e) mw_test_annees_calendaires(e$aj, e$figes$degeneres)$stat, "bas"),
    CorrDev    = .mc_entree(function(e) mw_stat_correlation_dev(e$aj, e$figes$degeneres)$stat, "deux"),
    # Statistique BP remplacee par #301 (effets fixes de colonne, residus
    # redresses, colonnes n_j >= 3) : fonction commune du moteur,
    # mw_test_heteroscedasticite_intra(), comme .mw_pente_intra() ci-dessous
    # (l'objet de la comparaison est l'assemblage des tables, #239).
    BP         = .mc_entree(function(e) mw_test_heteroscedasticite_intra(e$aj, e$res)$stat, "haut"),
    # Statistique de Grubbs remplacee par #300 (cle MinP4, minimum des p de
    # Student des residus studentises externes) : fonction commune du moteur,
    # mw_test_cellule_aberrante(), evaluee comme observee, comme .mw_stats()
    # du moteur par defaut (replique = FALSE).
    MinP4      = .mc_entree(function(e) mw_test_cellule_aberrante(e$aj, e$figes$degeneres)$stat, "bas"),
    DW         = .mc_entree(function(e) stat_dw(e$r), "deux"),
    Runs       = .mc_entree(function(e) test_runs(e$r)$stat, "deux"),
    PenteIntra = .mc_entree(function(e) .mw_pente_intra(e$res), "deux"),
    Origine    = .mc_entree(function(e) mw_test_ordonnee_origine(e$aj, e$figes$degeneres,
                                                              e$figes$origine_non_identifiables)$stat, "haut"),
    HomogF     = .mc_entree(function(e) mw_test_homogeneite_f(e$aj, e$figes$degeneres)$stat, "haut"),
    Courbure   = .mc_entree(function(e) mw_test_courbure(e$aj, e$figes$degeneres,
                                                      e$figes$non_identifiables)$stat, "haut"),
    Alpha      = .mc_entree(function(e) mw_famille_alpha(e$aj)$stat, "haut"),
    ExpVar     = .mc_entree(function(e) mw_test_exposant_variance(e$aj, e$figes$degeneres)$stat, "haut"),
    KruskalAcc = .mc_entree(function(e) mw_test_homogeneite_accident(e$aj, e$figes$degeneres)$stat, "haut")
  )

  .mw_stats <- function(aj, j_degeneres = NULL, j_non_identifiables = NULL,
                        j_origine_non_identifiables = NULL)
    .mc_evaluer(MW_CATALOGUE_MC, .mw_contexte_mc(aj, j_degeneres, j_non_identifiables,
                                                 j_origine_non_identifiables))

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
# Moteur appele sous la convention (aj, jd, jni, jno) de la reecriture :
# depuis #278, .mw_contexte_mc() et .mw_stats() du moteur recoivent l'objet
# de .mw_ensembles_figes() ; jd, jni et jno (#273) (NULL : calcules sur aj
# par le moteur) y sont passes tels quels.
MOTEUR_FIGES <- list(
  .mw_contexte_mc = function(aj, jd = NULL, jni = NULL, jno = NULL)
    .mw_contexte_mc(aj, .mw_ensembles_figes(aj, jd, jni, jno)),
  .mw_stats       = function(aj, jd = NULL, jni = NULL, jno = NULL)
    .mw_stats(aj, .mw_ensembles_figes(aj, jd, jni, jno)))
moteur <- function(f) if (!is.null(MOTEUR_FIGES[[f]])) MOTEUR_FIGES[[f]] else get(f)
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
    # Filet de securite, inactif sur les jeux actuels (0 saut sur 82 ensembles,
    # mesure du 14/10/2026).
    if (any(vapply(vus, identical, logical(1), r))) next
    vus[[length(vus) + 1L]] <- r
    nouv <- lapply(stats::setNames(nm = fonctions), function(f) sans_masse(capturer(moteur(f), list(aj, jd))))
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
# Triangles a colonne non identifiable de la courbure (#269, #270 ;
# specification d'E2e, section 4) : T1, C(0..2,1) = 1000 et C(3..5,1) = 1100
# (j = 1) ; T3, C(.,0) = 320 et 350 en alternance (j = 0, colonne figee dans
# les replications) ; T6, T2 (C(0..2,2) = 1600, C(3..4,2) = 1800) et colonne
# j = 1 degeneree, C(i,1) = C(i,2) / 1,3 : sous j_degeneres = integer(0),
# retour NA a j = 1, avant la colonne non identifiable j = 2 (constat 3b).
tri_t1 <- tri_ref; tri_t1[1:6, 2] <- rep(c(1000, 1100), each = 3)
tri_t3 <- tri_ref; tri_t3[, 1] <- rep(c(320, 350), 4)
tri_t6 <- tri_ref; tri_t6[1:5, 3] <- c(1600, 1600, 1600, 1800, 1800)
tri_t6[1:6, 2] <- tri_t6[1:6, 3] / 1.3
# T4 (specification d'E2e, section 4) : C(0..5,1) = 1050, colonne j = 1
# constante (une seule valeur distincte de C(i,j)).
tri_t4 <- tri_ref; tri_t4[1:6, 2] <- 1050
# Branche (b) de la courbure (#270, correction du 14/10/2026 ; #278, etape 1
# de la branche F, reserve M2 de l'audit d'E2e) : triangles de replication
# construits a la main, ou la colonne de l'ensemble fige a l'observe devient
# degeneree. T1b : T1, colonne j = 1 degeneree, C(i,1) = C(i,2) / 1,3 pour
# i = 0..5 (T7 de T270-9) ; T3b : T3, colonne j = 0 degeneree,
# C(i,0) = C(i,1) / 1,5 pour i = 0..6. Appeles avec les ensembles figes de
# l'observe (T1 : jd = 6, jni = 1 ; T3 : jd = 6, jni = 0), ou la colonne
# n'est pas degeneree.
tri_t1b <- tri_t1; tri_t1b[1:6, 2] <- tri_t1b[1:6, 3] / 1.3
tri_t3b <- tri_t3; tri_t3b[1:7, 1] <- tri_t3b[1:7, 2] / 1.5

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

verifier("Triangles a colonne degeneree, a colonne non identifiable (T1, T3, T4, T6) et minimaux : identiques a l'ancienne forme (#239, #270, #278)",
         resultat(c(ecarts(ta_deg, list(NULL, integer(0)), "ta_deg"),
                    ecarts(ta_bruit, list(NULL, integer(0), 4L), "ta_bruit"),
                    ecarts(tri_deg, list(NULL, integer(0)), "tri_deg"),
                    ecarts(tri_t1, list(NULL, integer(0)), "T1"),
                    ecarts(tri_t3, list(NULL), "T3"),
                    ecarts(tri_t4, list(NULL), "T4"),
                    ecarts(tri_t6, list(NULL, integer(0)), "T6"),
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

# Ensemble des colonnes non identifiables de la courbure fige a l'observe
# (#270, T270-7) : les deux premieres replications de T1, de T3 et de T4
# (graine 20261010), jd et jni de l'observe transmis comme dans
# mw_bootstrap() ; la colonne j = 1 de T1 et de T4 n'a plus d'ex aequo dans
# les replications et n'est ecartee que parce qu'elle est dans l'ensemble
# fige ; la colonne figee j = 0 de T3 l'est dans les deux formes. Appels
# observes a ensemble impose : T1 sous jni = integer(0) (colonne j = 1
# retenue a deux valeurs : second volet, statistique NA) ; T6 sous
# jd = integer(0) (retour NA de la colonne degeneree j = 1, element
# non_identifiables complet, constat 3b).
FONCTIONS_JNI <- c("mw_test_courbure", ".mw_contexte_mc", ".mw_stats")
ecarts_jni <- function(aj, jd, jni, etiquette) {
  out <- character(0)
  for (f in FONCTIONS_JNI)
    if (!meme(capturer(moteur(f), list(aj, jd, jni)), capturer(ANCIEN[[f]], list(aj, jd, jni))))
      out <- c(out, paste(etiquette, f, "jd =", deparse(jd), "jni =", deparse(jni)))
  out
}
verifier("Ensemble des colonnes non identifiables fige (T1, T3, T4 : replications ; T1, T6 : ensembles imposes) : identiques a la reecriture independante (#270, T270-7, #278)",
         {
           e <- unlist(lapply(list(T1 = tri_t1, T3 = tri_t3, T4 = tri_t4), function(t) {
             aj <- mw_ajuster(t); jd <- .mw_colonnes_degenerees(aj)
             jni <- .mw_colonnes_courbure_non_identifiables(aj, jd)
             pool <- .mw_pool_residus(aj, jd)
             tb <- engine_sous_graine(20261010, lapply(1:2, function(b) mw_simuler_triangle(aj, pool)))
             c(if (!identical(jni, ANCIEN$.jni_oracle(aj, jd))) "ensemble jni",
               unlist(lapply(seq_along(tb), function(b)
                 ecarts_jni(mw_ajuster(tb[[b]]), jd, jni, paste("replication", b)))))
           }))
           a1 <- mw_ajuster(tri_t1); a6 <- mw_ajuster(tri_t6)
           na1 <- mw_test_courbure(a1, NULL, integer(0))
           na6 <- mw_test_courbure(a6, integer(0))
           resultat(c(e, ecarts_jni(a1, NULL, integer(0), "T1 observe"),
                      ecarts_jni(a6, integer(0), NULL, "T6 observe"),
                      if (!is.na(na1$stat) || !identical(na1$K, NA_integer_)) "T1 : stat ou K non NA",
                      if (!identical(na6$non_identifiables, data.frame(j = 2L, n_facteurs = 5L)))
                        "T6 : non_identifiables incomplet"))
         })

# Branche (b) de la courbure (#270, correction du 14/10/2026 ; #278, etape 1
# de la branche F) : colonne de l'ensemble fige jni, degeneree dans l'appel,
# ecartee AVANT le controle de degenerescence. T1b et T3b (en-tete des
# triangles) sous les ensembles figes de T1 et de T3, recalcules ici sur
# l'observe. Garde contre un test vide : dans chaque appel, la colonne est
# degeneree (.mw_colonne_degeneree()), dans jni, hors de jd, et la reecriture
# independante rend une statistique finie, K = 3, la colonne nommee dans
# non_identifiables : un moteur qui ferait le controle de degenerescence
# d'abord (statistique NA, K NA) s'ecarte de la reecriture (mutation mesuree
# a l'etape 1 de la branche F).
verifier("Branche (b) de la courbure : colonne de l'ensemble fige degeneree dans l'appel (T1b, T3b), identique a la reecriture independante, statistique finie (#270, #278)",
         {
           cas <- list(T1b = list(tri_t1, tri_t1b), T3b = list(tri_t3, tri_t3b))
           resultat(unlist(lapply(names(cas), function(nm) {
             ao <- mw_ajuster(cas[[nm]][[1]]); jd <- .mw_colonnes_degenerees(ao)
             jni <- ANCIEN$.jni_oracle(ao, jd)
             a <- mw_ajuster(cas[[nm]][[2]])
             o <- ANCIEN$mw_test_courbure(a, jd, jni)
             garde <- length(jni) == 1L && !(jni %in% jd) && .mw_colonne_degeneree(a, jni) &&
               is.finite(o$stat) && identical(o$K, 3L) &&
               identical(o$non_identifiables$j, jni) && !(jni %in% o$detail$j)
             c(if (!garde) paste(nm, ": cas (b) non exerce"),
               ecarts_jni(a, jd, jni, nm))
           })))
         })

# Ensemble des colonnes non identifiables de l'ordonnee a l'origine fige a
# l'observe (#273, T273-9) : reecriture independante (.jno_oracle(),
# mw_test_ordonnee_origine() et contexte de l'environnement ANCIEN) comparee
# au moteur. Cas : (i) ensembles {1} sur T4, {} sur reserve2 et T1 (deux
# valeurs distinctes en j = 1 : identifiable), {4} sur un triangle dont
# seule la colonne j = 4 (n_j = 3, hors de la courbure) est constante ;
# (ii) les deux premieres replications de T4 (graine 20261010), jd, jni et
# jno de l'observe transmis comme dans mw_bootstrap() ; (iii) T4 sous
# jno = integer(0) (colonne constante retenue : lm() a un coefficient,
# statistique NA, K NA, ancien next silencieux) ; (iv) colonne quasi
# constante C(0..5,1) = 1050 (1 + 1e-8 k) (six valeurs distinctes, hors de
# l'ensemble, lm() a un coefficient : option (A), statistique NA a l'observe).
tri_n3 <- tri_ref; tri_n3[1:3, 5] <- 2500
tri_eps <- tri_ref; tri_eps[1:6, 2] <- 1050 * (1 + 1e-8 * 0:5)
verifier("Ensemble des colonnes non identifiables de l'ordonnee fige (T4, n_j = 3, replications, ensemble impose, quasi-constante) : identique a la reecriture independante (#273, T273-9)",
         {
           att <- list(reserve2 = list(tri_ref, integer(0)), T1 = list(tri_t1, integer(0)),
                       T4 = list(tri_t4, 1L), n3 = list(tri_n3, 4L), eps = list(tri_eps, integer(0)))
           e_ens <- unlist(lapply(names(att), function(nm) {
             aj <- mw_ajuster(att[[nm]][[1]]); jd <- .mw_colonnes_degenerees(aj)
             jno <- .mw_colonnes_origine_non_identifiables(aj, jd)
             c(if (!identical(jno, att[[nm]][[2]])) paste(nm, ": ensemble", deparse(jno)),
               if (!identical(jno, ANCIEN$.jno_oracle(aj, jd))) paste(nm, ": ensemble != oracle"),
               if (!identical(.mw_ensembles_figes(aj)$origine_non_identifiables, jno))
                 paste(nm, ": element de .mw_ensembles_figes()"),
               if (nm == "n3" && length(.mw_colonnes_courbure_non_identifiables(aj, jd)))
                 "n3 : colonne n_j = 3 dans l'ensemble de la courbure",
               ecarts(att[[nm]][[1]], list(NULL), nm,
                      fonctions = c("mw_test_ordonnee_origine", ".mw_contexte_mc", ".mw_stats"),
                      alpha = FALSE))
           }))
           f4 <- c(".mw_contexte_mc", ".mw_stats")
           ecarts_jno <- function(aj, jd, jni, jno, etiquette) {
             out <- character(0)
             if (!meme(capturer(mw_test_ordonnee_origine, list(aj, jd, jno)),
                       capturer(ANCIEN$mw_test_ordonnee_origine, list(aj, jd, jno))))
               out <- c(out, paste(etiquette, "mw_test_ordonnee_origine"))
             for (f in f4)
               if (!meme(capturer(moteur(f), list(aj, jd, jni, jno)),
                         capturer(ANCIEN[[f]], list(aj, jd, jni, jno))))
                 out <- c(out, paste(etiquette, f))
             out
           }
           a4 <- mw_ajuster(tri_t4); jd4 <- .mw_colonnes_degenerees(a4)
           jni4 <- .mw_colonnes_courbure_non_identifiables(a4, jd4)
           jno4 <- .mw_colonnes_origine_non_identifiables(a4, jd4)
           pool <- .mw_pool_residus(a4, jd4)
           tb <- engine_sous_graine(20261010, lapply(1:2, function(b) mw_simuler_triangle(a4, pool)))
           e_rep <- unlist(lapply(seq_along(tb), function(b) {
             ab <- mw_ajuster(tb[[b]])
             c(if (length(unique(tb[[b]][1:6, 2])) < 2) paste("replication", b, ": colonne constante"),
               ecarts_jno(ab, jd4, jni4, jno4, paste("T4 replication", b)))
           }))
           na4 <- mw_test_ordonnee_origine(a4, jd4, integer(0))
           ae <- mw_ajuster(tri_eps); oe <- mw_test_ordonnee_origine(ae)
           resultat(c(e_ens, e_rep, ecarts_jno(a4, jd4, jni4, integer(0), "T4 jno vide"),
                      if (!identical(na4$stat, NA_real_) || !identical(na4$K, NA_integer_))
                        "T4 jno vide : stat ou K non NA",
                      if (!identical(oe$stat, NA_real_) || !identical(oe$K, NA_integer_))
                        "eps : stat ou K non NA"))
         })

# Ordre des controles de mw_test_ordonnee_origine() (#273, reprise C1 de
# l'audit de 867d65d) : colonne de l'ensemble fige jno ecartee AVANT le
# controle de degenerescence, comme pour la courbure (#270). Triangle de
# reference, colonne j = 2 degeneree (C(0..4,3) = 1,3 C(0..4,2)), appel sous
# jd = integer(0) et jno = 2 (cas d'une replication ou la colonne figee a
# l'observe devient degeneree). Valeurs mesurees : X = 14,93813, K = 4
# (colonnes 0, 1, 3, 4), 5 eligibles. Garde contre un test vide : la colonne
# est degeneree (.mw_colonne_degeneree()) ; un moteur qui ferait le controle
# de degenerescence d'abord rend la statistique NA (mutation mesuree).
tri_o2 <- tri_ref; tri_o2[1:5, 4] <- 1.3 * tri_o2[1:5, 3]
verifier("Ordonnee a l'origine : colonne de l'ensemble fige degeneree dans l'appel, ecartee avant le controle de degenerescence (X = 14,93813, K = 4), identique a la reecriture independante (#273)",
         {
           a <- mw_ajuster(tri_o2)
           o <- mw_test_ordonnee_origine(a, integer(0), 2L)
           resultat(c(
             if (!.mw_colonne_degeneree(a, 2L)) "colonne j = 2 non degeneree : cas non exerce",
             if (!is.finite(o$stat) || abs(o$stat - 14.93813) > 5e-6)
               paste("stat", format(o$stat, digits = 10)),
             if (!identical(o$K, 4L)) paste("K", deparse(o$K)),
             if (!identical(o$eligibles, 5L)) paste("eligibles", deparse(o$eligibles)),
             if (!identical(o$detail$j, c(0L, 1L, 3L, 4L))) "colonnes combinees",
             if (!identical(o$non_identifiables, data.frame(j = 2L, n_facteurs = 5L)))
               "non_identifiables",
             if (!meme(capturer(mw_test_ordonnee_origine, list(a, integer(0), 2L)),
                       capturer(ANCIEN$mw_test_ordonnee_origine, list(a, integer(0), 2L))))
               "!= reecriture independante"))
         })

# Ensembles par defaut des deux verifications de M1 (#290) : appelees seules
# (j_degeneres et ensemble fige a NULL), mw_test_ordonnee_origine() et
# mw_test_courbure() resolvent leurs ensembles par .mw_ensembles_figes(aj) :
# resultat identique (identical(), ordre des attributs compris) a l'appel qui
# leur transmet les elements de .mw_ensembles_figes(aj), et element
# non_identifiables identique a la table construite sur l'ensemble de
# .mw_ensembles_figes(aj). Cas : reserve2, T1, T3, T4, T6, n_j = 3, quasi
# constante, tri_deg, T1b, T3b, Taylor & Ashe sain et a colonne degeneree.
# Garde contre un test vide : au moins un des triangles a un ensemble non vide
# pour chacun des deux tests.
verifier("Ensembles par defaut de mw_test_ordonnee_origine() et mw_test_courbure() : identiques a .mw_ensembles_figes(aj) (#290)",
         {
           tris <- list(reserve2 = tri_ref, T1 = tri_t1, T3 = tri_t3, T4 = tri_t4, T6 = tri_t6,
                        n3 = tri_n3, eps = tri_eps, tri_deg = tri_deg, T1b = tri_t1b,
                        T3b = tri_t3b, ta = ta, ta_deg = ta_deg)
           ne <- c(origine = 0L, courbure = 0L)
           e <- unlist(lapply(names(tris), function(nm) {
             aj <- mw_ajuster(tris[[nm]]); fg <- .mw_ensembles_figes(aj)
             ne <<- ne + c(length(fg$origine_non_identifiables), length(fg$non_identifiables))
             o <- mw_test_ordonnee_origine(aj); c1 <- mw_test_courbure(aj)
             c(if (!meme(o, mw_test_ordonnee_origine(aj, fg$degeneres, fg$origine_non_identifiables)))
                 paste(nm, ": origine != appel avec les elements de .mw_ensembles_figes()"),
               if (!meme(c1, mw_test_courbure(aj, fg$degeneres, fg$non_identifiables)))
                 paste(nm, ": courbure != appel avec les elements de .mw_ensembles_figes()"),
               if (!meme(o$non_identifiables, .mw_table_non_identifiables(
                   fg$origine_non_identifiables, aj$I, aj$J, fg$degeneres, 3L)))
                 paste(nm, ": origine, table non_identifiables"),
               if (!meme(c1$non_identifiables, .mw_table_non_identifiables(
                   fg$non_identifiables, aj$I, aj$J, fg$degeneres, 4L)))
                 paste(nm, ": courbure, table non_identifiables"))
           }))
           resultat(c(e, if (any(ne == 0L)) paste("cas non exerce :", paste(names(ne)[ne == 0L], collapse = ", "))))
         })

# Clause d'exclusion du predicat unique (#290, constat mineur de l'audit) :
# sur T4, la colonne j = 1 (C(0..5,1) constant) est la seule colonne non
# identifiable de l'ordonnee a l'origine ; transmise comme colonne exclue
# (j_degeneres = 1), elle sort de l'ensemble : integer(0). Exerce la clause
# !(k %in% jd) de .mw_colonnes_non_identifiables(), que les autres cas ne
# distinguent pas (aucune colonne exclue n'y est constante). Garde contre un
# test vide : sans exclusion, l'ensemble vaut 1L.
verifier("Predicat unique des colonnes non identifiables : colonne exclue hors de l'ensemble (T4, j_degeneres = 1 : integer(0) ; sans exclusion : 1L), identique a l'oracle (#290)",
         {
           aj_t4 <- mw_ajuster(tri_t4)
           avec <- .mw_colonnes_origine_non_identifiables(aj_t4, 1L)
           sans <- .mw_colonnes_origine_non_identifiables(aj_t4, .mw_colonnes_degenerees(aj_t4))
           resultat(c(
             if (!identical(sans, 1L)) paste("sans exclusion :", deparse(sans), "(cas non exerce)"),
             if (!identical(avec, integer(0))) paste("j_degeneres = 1 :", deparse(avec)),
             if (!identical(avec, ANCIEN$.jno_oracle(aj_t4, .mw_j_exclues(aj_t4, 1L))))
               "j_degeneres = 1 : != oracle"))
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
           a <- mw_ajuster(tri_ref)
           tryCatch(.mw_stats(a, .mw_ensembles_figes(a, 4L)),
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
