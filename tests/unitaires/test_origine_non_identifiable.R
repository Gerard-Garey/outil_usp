###############################################################################
#  tests/unitaires/test_origine_non_identifiable.R  --  ORDONNEE A L'ORIGINE
#             DE M1 : COLONNES NON IDENTIFIABLES FIGEES A L'OBSERVE (#273)
#
#  Forme d'actuary (commentaire 6170835485 de #273, attendus T273-1 a
#  T273-9 ; decisions D1-6 et D1-9 de la specification d'E2e transposees) et
#  option (A) du mainteneur du 14/10/2026 : colonnes a n_j >= 3, ni exclues
#  ni degenerees, a moins de deux valeurs distinctes de C(i,j) (egalite
#  exacte) : ensemble fige a l'observe (.mw_colonnes_origine_non_
#  identifiables(), element origine_non_identifiables de
#  .mw_ensembles_figes()), ecarte de la combinaison de Fisher a l'observe et
#  dans chaque replication, nomme dans le libelle par
#  .mw_phrase_origine_non_identifiable() ; plus de next silencieux : une
#  colonne retenue dont lm() rend moins de deux coefficients donne une
#  statistique NA, K NA. T273-9 (reecriture independante) est porte par
#  test_tables_mw.R ; T273-2 (six cas de reference identiques) par
#  tests/test_reproductibilite.R, dont on ne relit ici que reserve2.
#  Valeurs attendues (p_mc 0,162 sur T4, 0,289 avant ; 0,085 sur reserve2) :
#  mesure du prototype d'actuary (§ 1 du commentaire), retrouvee par le
#  moteur de #273 (compte rendu de coder).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_origine_non_identifiable.R")

.racine273 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
tri273 <- local({
  d <- utils::read.csv(file.path(.racine273, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# Triangles de la specification d'E2e (section 4) : T1 (deux valeurs
# distinctes en j = 1), T2, T3, T4 (C(0..5,1) = 1050, une seule valeur) ;
# T4d : T4 et colonne j = 2 degeneree (C(i,3) = 1,3 C(i,2), i = 0..4) ;
# T4e : C(0..5,1) = 1050 (1 + 1e-8 k), six valeurs distinctes que lm()
# ecarte (rang numerique, tolerance de qr()).
t1_273 <- local({ t <- tri273; t[1:6, 2] <- rep(c(1000, 1100), each = 3); t })
t2_273 <- local({ t <- tri273; t[1:5, 3] <- c(1600, 1600, 1600, 1800, 1800); t })
t3_273 <- local({ t <- tri273; t[, 1] <- rep(c(320, 350), 4); t })
t4_273 <- local({ t <- tri273; t[1:6, 2] <- 1050; t })
t4d_273 <- local({ t <- t4_273; t[1:5, 4] <- 1.3 * t[1:5, 3]; t })
t4e_273 <- local({ t <- tri273; t[1:6, 2] <- 1050 * (1 + 1e-8 * 0:5); t })

# Ancienne statistique de l'ordonnee (moteur a bbe3a2a, avant #273) : sans
# ensemble fige des colonnes non identifiables, colonne a moins de deux
# coefficients de lm() ecartee en silence (next). Sert a T273-5 seulement.
origine_avant <- function(aj, jd) {
  p <- numeric(0)
  for (j in 0:(aj$J - 1)) {
    idx <- 0:(aj$I - j - 1)
    if (length(idx) < 3 || j %in% jd) next
    if (.mw_colonne_degeneree(aj, j)) return(NA_real_)
    C0 <- aj$tri[idx + 1, j + 1]; C1 <- aj$tri[idx + 1, j + 2]
    m <- try(.mw_summary_lm(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 2) next
    p <- c(p, m$coefficients[1, 4])
  }
  if (!length(p)) NA_real_ else .fisher_combine(p)$stat
}
# Rejeu de la boucle de mw_bootstrap() (graine, pool, retirage de #257,
# fonctions partagees), reduit a l'ordonnee : statistique et K de chaque
# replication sous l'ensemble fige (apres) et ancienne statistique (avant).
rejeu273 <- function(t, B = 999, seed = 20260831) {
  aj <- mw_ajuster(t); fg <- .mw_ensembles_figes(aj)
  jd <- fg$degeneres; jno <- fg$origine_non_identifiables
  s <- s0 <- rep(NA_real_, B); K <- rep(NA_integer_, B)
  engine_sous_graine(seed, {
    pool <- .mw_pool_residus(aj, jd)
    n_max <- FACTEUR_B_MAX_MW * (B + 1); n_tir <- 0
    for (b in seq_len(B)) {
      tir <- .mw_tirer_triangle_valide(aj, pool, n_max - n_tir)
      n_tir <- n_tir + tir$n
      if (is.null(tb <- tir$tri)) next
      ab <- try(mw_ajuster(tb), silent = TRUE)
      if (inherits(ab, "try-error")) next
      o <- mw_test_ordonnee_origine(ab, jd, jno)
      s[b] <- o$stat; K[b] <- if (is.null(o$K)) NA_integer_ else as.integer(o$K)
      s0[b] <- origine_avant(ab, jd)
    }
  })
  obs <- mw_test_ordonnee_origine(aj)
  list(jno = jno, K_obs = obs$K, K = K, s = s, s0 = s0, obs = obs$stat,
       obs0 = origine_avant(aj, jd),
       p_mc = engine_p_mc(s, obs$stat, "haut")$p_mc,
       p_mc0 = engine_p_mc(s0, origine_avant(aj, jd), "haut")$p_mc)
}
# mw_bootstrap() de T4 a B = 999, graine 20260831, appele sous un generateur
# de l'appelant different (L'Ecuyer-CMRG, graine 7) : etat avant et apres
# conserve pour T273-8 ; etat de la session restaure en sortie.
boot_t4 <- local({
  rk0 <- RNGkind()
  s0 <- if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
    get(".Random.seed", envir = globalenv())
  on.exit({
    do.call(RNGkind, as.list(rk0))
    if (is.null(s0)) rm(".Random.seed", envir = globalenv())
    else assign(".Random.seed", s0, envir = globalenv())
  })
  RNGkind("L'Ecuyer-CMRG"); set.seed(7)
  avant <- list(kind = RNGkind(), seed = .Random.seed)
  aj <- mw_ajuster(t4_273)
  b <- mw_bootstrap(aj, B = 999, seed = 20260831)
  list(aj = aj, boot = b, avant = avant, apres = list(kind = RNGkind(), seed = .Random.seed))
})
rejeu_t4 <- rejeu273(t4_273)
# Ligne de l'ordonnee de mw_tests()
ligne_origine <- function(aj, boot)
  Filter(function(r) grepl("ordonnee a l'origine", r$test), mw_tests(aj, boot))[[1]]
base273 <- paste(
  "La regression ponderee SANS constante et de poids 1/C(i,j) a pour",
  "estimateur exactement f_j (identite de Mack, verifiee a 1e-16).",
  "Ajouter une constante fournit donc le test naturel de la",
  "proportionnalite, colonne par colonne.")
phrase273_t4 <- paste(
  "Colonne a moins de deux valeurs distinctes de C(i,j) : j = 1 (6 facteurs) ;",
  "ordonnee a l'origine non identifiable, colonne hors de la combinaison de Fisher ;",
  "K = 4 colonne(s) testee(s) sur 5 eligible(s). L'exclusion ne vaut pas preuve de proportionnalite.")
# Commentaire sans la phrase de #244 finale, si elle est posee
sans244 <- function(x) {
  s <- paste0(" ", PHRASE_VERDICT_SENSIBLE_MC)
  if (endsWith(x, s)) substr(x, 1L, nchar(x) - nchar(s)) else x
}
# Liste de controles nommes : TRUE, ou les controles en echec (comme dans
# test_forme_close_m1.R)
ok_liste <- function(r) {
  ko <- vapply(r, function(v) !isTRUE(v), logical(1))
  if (!any(ko)) TRUE else
    paste(names(r)[ko], vapply(r[ko], function(v) paste(as.character(v), collapse = " "), ""),
          sep = " : ", collapse = " ; ")
}

verifier("T273-1 : T4, mw_bootstrap() B = 999 : K = 4 a l'observe et dans les 999 replications, p_mc Origine 0,162 (0,289 avant), verdict OK ; rejeu = mw_bootstrap() (#273)",
         {
           b <- boot_t4$boot; r <- rejeu_t4
           l <- ligne_origine(boot_t4$aj, b)
           ok_liste(list(
             jno = identical(r$jno, 1L), K_obs = identical(r$K_obs, 4L),
             K4 = all(!is.na(r$K)) && all(r$K == 4L),
             B_eff = identical(b$B_effectif[["Origine"]], 999),
             p_mc = proche(b$p_mc[["Origine"]], 0.162, rel = 1e-12),
             rejeu = identical(r$p_mc, b$p_mc[["Origine"]]),
             obs = identical(b$stats_obs$Origine, r$obs),
             verdict = identical(l$verdict, "OK")))
         })
verifier("T273-2 : reserve2, ensemble fige vide, appel a ensemble vide impose identique ; reference : p_mc Origine 0,085, detail = libelle de base (#273)",
         {
           aj <- mw_ajuster(tri273); fg <- .mw_ensembles_figes(aj)
           ref <- readRDS(file.path(.racine273, "tests", "reference", "reserve2.rds"))
           k <- which(vapply(ref$tests, function(x) grepl("ordonnee a l'origine", x$test), logical(1)))
           oo <- mw_test_ordonnee_origine(aj)
           ok_liste(list(
             vide = identical(fg$origine_non_identifiables, integer(0)),
             element = identical(oo$non_identifiables, data.frame(j = integer(0), n_facteurs = integer(0))),
             phrase = identical(.mw_phrase_origine_non_identifiable(oo), ""),
             impose = identical(oo, mw_test_ordonnee_origine(aj, fg$degeneres, integer(0))),
             p_ref = proche(ref$bootstrap$p_mc[["Origine"]], 0.085, rel = 1e-12),
             detail = length(k) == 1L && identical(sans244(ref$tests[[k]]$detail), base273)))
         })
verifier("T273-3 : invariance de l'appel observe : mw_test_ordonnee_origine(aj) = appel avec l'ensemble fige calcule ; .mw_stats() de meme ; ensembles (reserve2 {}, T1 {}, T2 {}, T3 {}, T4 {1}) (#273)",
         {
           tris <- list(reserve2 = tri273, t1 = t1_273, t2 = t2_273, t3 = t3_273, t4 = t4_273)
           att <- list(reserve2 = integer(0), t1 = integer(0), t2 = integer(0), t3 = integer(0), t4 = 1L)
           ok <- vapply(names(tris), function(nm) {
             aj <- mw_ajuster(tris[[nm]]); fg <- .mw_ensembles_figes(aj)
             jno <- .mw_colonnes_origine_non_identifiables(aj, fg$degeneres)
             identical(jno, att[[nm]]) && identical(fg$origine_non_identifiables, jno) &&
               identical(jno, .mw_colonnes_origine_non_identifiables(aj)) &&
               identical(mw_test_ordonnee_origine(aj), mw_test_ordonnee_origine(aj, fg$degeneres, jno)) &&
               identical(.mw_stats(aj), .mw_stats(aj, fg)) &&
               identical(.mw_stats(aj)[["Origine"]], mw_test_ordonnee_origine(aj)$stat)
           }, logical(1))
           if (all(ok)) TRUE else paste("ecart :", paste(names(ok)[!ok], collapse = ", "))
         })
verifier("T273-4 : second volet : T4 avec un ensemble fige vide impose : stat NA, K NA, non_identifiables present (vide), fermeture Origine NA (#273)",
         {
           a4 <- mw_ajuster(t4_273); jd <- .mw_colonnes_degenerees(a4)
           o <- mw_test_ordonnee_origine(a4, jd, integer(0))
           fg <- .mw_ensembles_figes(a4, jd, NULL, integer(0))
           ok_liste(list(
             stat = identical(o$stat, NA_real_), p = identical(o$p, NA_real_),
             K = identical(o$K, NA_integer_),
             ni = identical(o$non_identifiables, data.frame(j = integer(0), n_facteurs = integer(0))),
             # colonnes parcourues jusqu'a l'arret : j = 0 et j = 1
             eligibles = identical(o$eligibles, 2L),
             fermeture = identical(MW_CATALOGUE_MC$Origine$calc(.mw_contexte_mc(a4, fg)), NA_real_)))
         })
verifier("T273-5 : sens : a tirages egaux, X* apres <= X* avant dans chaque replication, X observe inchange, p_mc apres <= p_mc avant (rejeu de l'ancienne statistique : 0,289) (#273)",
         {
           r <- rejeu_t4
           f <- is.finite(r$s) & is.finite(r$s0)
           ok_liste(list(
             finies = identical(sum(f), 999L),
             ordre = all(r$s[f] <= r$s0[f]),
             obs = identical(r$obs, r$obs0),
             p_avant = proche(r$p_mc0, 0.289, rel = 1e-12),
             p_ordre = r$p_mc <= r$p_mc0))
         })
# Trois configurations : B = 999 (graine 20260831, sous L'Ecuyer-CMRG chez
# l'appelant), B = 199 a la graine 20260831 (seul B varie), B = 199 a la
# graine 1 (seule la graine varie), cette derniere par run_engine().
verifier("T273-6 : detail : T4, phrase fixe apres le libelle de base, estimation 4 ; texte identique a B = 199 et 999 et sous deux graines ; T4d (colonne j = 2 degeneree en plus) : deux phrases, la degeneree d'abord, meme clause K = 3 sur 5 (#273)",
         {
           a4 <- boot_t4$aj
           l999 <- ligne_origine(a4, boot_t4$boot)
           l199 <- ligne_origine(a4, mw_bootstrap(a4, B = 199, seed = 20260831))
           re <- engine_table_tests(run_engine(methode = "reserve2", triangle = t4_273, segment = 1,
                                               annexe = "II", B = 199, seed = 1))
           cms <- c(l999$detail, l199$detail, re$commentaire[grepl("ordonnee a l'origine", re$test)])
           att <- paste(base273, phrase273_t4)
           ad <- mw_ajuster(t4d_273)
           ld <- ligne_origine(ad, mw_bootstrap(ad, B = 99, seed = 20260831))
           cm <- ld$detail
           p_deg <- regexpr("Colonne degeneree", cm, fixed = TRUE)
           p_ni <- regexpr("Colonne a moins de deux valeurs distinctes", cm, fixed = TRUE)
           ok_liste(list(
             trois = length(cms) == 3L,
             identiques = all(vapply(cms, sans244, "") == att),
             estim = identical(as.numeric(l999$estim), 4),
             deg_t4d = identical(.mw_ensembles_figes(ad)$degeneres, c(2L, 6L)) &&
               identical(.mw_ensembles_figes(ad)$origine_non_identifiables, 1L),
             deux = p_deg > 0 && p_ni > 0, ordre = p_deg < p_ni,
             ni = grepl("j = 1 (6 facteurs) ; ordonnee a l'origine non identifiable", cm, fixed = TRUE),
             clause = lengths(regmatches(cm, gregexpr(
               "K = 3 colonne(s) testee(s) sur 5 eligible(s).", cm, fixed = TRUE))) == 2L,
             estim_d = identical(as.numeric(ld$estim), 3)))
         })
verifier("T273-7 : colonne quasi constante (1e-8, six valeurs distinctes, lm() a un coefficient) : hors de l'ensemble (option (A)), statistique observee NA, ligne non applicable par le motif d'indisponibilite, aucun stop() (#273)",
         {
           ae <- mw_ajuster(t4e_273)
           o <- mw_test_ordonnee_origine(ae)
           r <- run_engine(methode = "reserve2", triangle = t4e_273, segment = 1, annexe = "II", B = 99)
           l <- Filter(function(x) grepl("ordonnee a l'origine", x$test), r$tests)[[1]]
           ok_liste(list(
             six = length(unique(t4e_273[1:6, 2])) == 6L,
             vide = identical(.mw_ensembles_figes(ae)$origine_non_identifiables, integer(0)),
             na = identical(o$stat, NA_real_) && identical(o$K, NA_integer_),
             ok = isTRUE(r$ok),
             motif = identical(r$bootstrap$motif_mc[["Origine"]], MOTIF_MC_OBS_NON_FINIE),
             type = identical(l$type, "non applicable") && identical(l$verdict, "INFO") &&
               is.na(l$p_retenue),
             detail = startsWith(l$detail, paste0(MOTIF_MC_OBS_NON_FINIE, " : test non applicable."))))
         })
verifier("T273-8 : T4, mw_bootstrap() sous un generateur de l'appelant different (L'Ecuyer-CMRG) : RNGkind() et .Random.seed restaures ; memes triangles simules qu'a ensemble vide impose (sigma_boot et p_mc des 12 autres statistiques identiques) (#273)",
         {
           x <- boot_t4; a4 <- x$aj
           b0 <- mw_bootstrap(a4, B = 999, seed = 20260831,
                              figes = .mw_ensembles_figes(a4, NULL, NULL, integer(0)))
           autres <- setdiff(names(x$boot$p_mc), "Origine")
           ok_liste(list(kind = identical(x$avant$kind, x$apres$kind),
                         seed = identical(x$avant$seed, x$apres$seed),
                         lecuyer = identical(x$avant$kind[1], "L'Ecuyer-CMRG"),
                         sigma = identical(x$boot$sigma_boot, b0$sigma_boot),
                         p_autres = identical(x$boot$p_mc[autres], b0$p_mc[autres]),
                         douze = length(autres) == 12L))
         })

fin_fichier()
