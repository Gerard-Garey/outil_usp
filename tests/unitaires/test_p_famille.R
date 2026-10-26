###############################################################################
#  tests/unitaires/test_p_famille.R  --  P-VALUE DE FAMILLE minP (#297)
#
#  engine_p_famille() et .engine_minp_rangs() (R/engine.R) : lecture conjointe
#  des tests d'une famille par la p minP en une etape, rangs symetriques,
#  observe compris, en arithmetique entiere (specification D1-Fk,
#  docs/specifications/fk-lecture-conjointe.md, par. 1 a 4, 9 et 10 ;
#  decisions du mainteneur du 25/10/2026, Q-D1-Fk-1 a Q-D1-Fk-7).
#  Matrices jouets : numerateurs confrontes a une ecriture independante par
#  boucles explicites (comparaisons >= et <=, sans rank()) ; identite de la p
#  de l'observe avec engine_p_mc() ; appartenance ; B effectif de famille et
#  seuil B_MIN_DEGENERESCENCE ; aucune consommation d'alea. Calcul a B = 99
#  (premium, reserve2) : lignes ajoutees apres les lignes existantes, champs
#  du par. 4.2, textes T-1 et T-2 a la lettre, bootstrap$stats_boot (par. 9).
#  Reprise du 25/10/2026 (decisions du mainteneur, recommandations
#  d'actuary-approfondi) : T-3a posee si et seulement si un membre a plus de
#  replications finies que la famille (point 1) ; familles dans l'ordre des
#  prefixes (point 2) ; membres "<test> [<mc_nom>]" dans T-1 (point 6) ;
#  T-2 et T-3a a la lettre (points 5 et 9) ; stat_nom de la ligne globale
#  (point 7) ; reference (point 8).
#  Six references versionnees : numerateurs du par. 6 (oracles du prototype
#  de la specification, annexe C), presents apres la regeneration de #297.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_p_famille.R")

## --- Ecriture independante des rangs (boucles, sans rank()) ----------------------
# Numerateurs entiers a_j(i) des items 0 (observe) a n, puis numerateur de la
# p de famille #{i : min_j a_j(i) <= min_j a_j(0)}.
naif297 <- function(S, obs, queues) {
  A <- rbind(obs, S); N <- nrow(A); k <- ncol(A)
  a <- matrix(0L, N, k)
  for (j in seq_len(k)) for (i in seq_len(N)) {
    cp <- sum(A[, j] >= A[i, j]); cm <- sum(A[, j] <= A[i, j])
    a[i, j] <- switch(queues[j], haut = cp, bas = cm, deux = min(2L * min(cp, cm), N))
  }
  m <- apply(a, 1L, min)
  list(num_obs = a[1L, ], num_m_obs = m[1L], num_p = sum(m <= m[1L]), N = N)
}

# Matrice jouet a ex aequo (valeurs entieres repetees, egalites avec
# l'observe) : 12 replications, trois statistiques, une par sens de rejet.
S297 <- cbind(a = c(3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5, 8),
              b = c(2, 7, 1, 8, 2, 8, 1, 8, 2, 8, 4, 5),
              c = c(0, 0, 1, -1, 2, -2, 0, 3, -3, 0, 1, 1))
obs297 <- c(a = 5, b = 2, c = 0)
q297 <- c(a = "haut", b = "bas", c = "deux")

verifier("#297 .engine_minp_rangs() : numerateurs entiers identiques a l'ecriture par boucles (ex aequo, trois sens)",
         {
           r <- .engine_minp_rangs(S297, obs297, q297); n <- naif297(S297, obs297, q297)
           is.integer(r$num_obs) && is.integer(r$num_p) &&
             identical(r$num_obs, n$num_obs) && identical(r$num_m_obs, n$num_m_obs) &&
             identical(r$num_p, n$num_p) && identical(r$N, 13L) && identical(r$n, 12L)
         })
verifier("#297 .engine_minp_rangs() : observe a la main (a : 7, b : 6, c : min(2 x 8, 13) = 13 ; m_obs 6)",
         {
           # a, haut, obs 5 : 1 + #{5, 9, 6, 5, 5, 8} = 7 (ex aequo compris) ;
           # b, bas, obs 2 : 1 + #{2, 1, 2, 1, 2} = 6 ; c, deux, obs 0 :
           # c+ = 1 + 9 = 10, c- = 1 + 7 = 8, min(2 x 8, 13) = 13 (plafond).
           r <- .engine_minp_rangs(S297, obs297, q297)
           identical(r$num_obs, c(7L, 6L, 13L)) && identical(r$num_m_obs, 6L)
         })
verifier("#297 bilateral : numerateur plafonne a n + 1 (observe au centre de la loi)",
         {
           S <- cbind(v = c(-2, -1, 1, 2)); r <- .engine_minp_rangs(S, 0, "deux")
           identical(r$num_obs, 5L) && identical(r$N, 5L)
         })
# Matrice jouet de 60 replications (au moins B_MIN_DEGENERESCENCE, sans quoi
# engine_p_mc() ne rend pas de p), valeurs arrondies a 0,1 : ex aequo
# nombreux, y compris avec l'observe.
set.seed(297)
B297 <- 60L
Sj <- cbind(a = round(stats::rnorm(B297), 1), b = round(stats::rnorm(B297), 1),
            c = round(stats::rnorm(B297), 1), d = round(stats::rnorm(B297), 1),
            e = round(stats::rnorm(B297), 1), f = round(stats::rnorm(B297), 1))
obsj <- c(a = 0.9, b = -0.4, c = 0.2, d = 1.5, e = 0, f = 0.3)
qj <- c(a = "haut", b = "bas", c = "deux", d = "haut", e = "haut", f = "haut")
verifier("#297 p de l'observe : a / N identique (au bit pres) a la p_mc d'engine_p_mc() pour chaque colonne (ex aequo avec l'observe compris)",
         {
           r <- .engine_minp_rangs(Sj, obsj, qj)
           any(Sj == rep(obsj, each = B297)) &&
             identical(r$num_obs, naif297(Sj, obsj, qj)$num_obs) &&
             all(vapply(seq_len(ncol(Sj)), function(j)
               identical(r$num_obs[j] / r$N, engine_p_mc(Sj[, j], obsj[[j]], qj[[j]])$p_mc), NA))
         })
verifier("#297 famille d'un seul test : p de famille = p Monte-Carlo du test (identique)",
         all(vapply(seq_len(ncol(Sj)), function(j) {
           r <- .engine_minp_rangs(Sj[, j, drop = FALSE], obsj[j], qj[j])
           identical(r$num_p / r$N, engine_p_mc(Sj[, j], obsj[[j]], qj[[j]])$p_mc)
         }, NA)))
verifier("#297 indifference a l'ordre des colonnes et des lignes de replication",
         {
           r <- .engine_minp_rangs(S297, obs297, q297)
           o <- c(3L, 1L, 2L); l <- c(12:7, 1:6)
           rc <- .engine_minp_rangs(S297[, o], obs297[o], q297[o])
           rl <- .engine_minp_rangs(S297[l, ], obs297, q297)
           identical(rc$num_p, r$num_p) && identical(rc$num_m_obs, r$num_m_obs) &&
             identical(rc$num_obs, r$num_obs[o]) && identical(rl$num_p, r$num_p) &&
             identical(rl$num_obs, r$num_obs)
         })
verifier("#297 .engine_minp_rangs() : refus d'une valeur non finie, d'un sens inconnu, d'une longueur fausse",
         leve_erreur(.engine_minp_rangs(rbind(S297, NA), obs297, q297)) &&
           leve_erreur(.engine_minp_rangs(S297, obs297, c("haut", "bas", "gauche"))) &&
           leve_erreur(.engine_minp_rangs(S297, obs297[1:2], q297)))

## --- engine_p_famille() sur lignes et bootstrap jouets --------------------------
# Catalogue jouet (sens de rejet seul) et bootstrap jouet : stats_obs,
# stats_boot (Sj, B = 60 lignes), B. Lignes : champs lus par engine_p_famille().
cat297 <- lapply(qj, function(q) list(queue = q))
boot297 <- list(stats_obs = as.list(obsj), B = B297, stats_boot = Sj)
ligne297 <- function(fam, mc, type = "test", variante = "principale", sens = "ne pas rejeter",
                     p_mc = 0.5)
  list(famille = fam, test = paste(fam, mc), type = type, variante = variante,
       sens = if (type %in% c("test", "procedure de decision")) sens else NA_character_,
       p_mc = p_mc, mc_nom = mc)
L297 <- list(
  ligne297("B. famille B", "a"), ligne297("B. famille B", "b"),
  ligne297("B. famille B", "c", type = "diagnostic"),             # diagnostic : hors famille
  ligne297("B. famille B", "d", variante = "secondaire"),         # variante secondaire : hors
  ligne297("B. famille B", "e", sens = "rejeter"),                # sens rejeter : hors
  ligne297("B. famille B", NA_character_),                        # sans mc_nom : hors
  ligne297("B. famille B", "f", p_mc = NA_real_),                 # p_mc absente : hors
  ligne297("C. famille C", "d"),                                  # famille d'un seul test
  ligne297("D. famille D", "c"), ligne297("D. famille D", "e"), ligne297("D. famille D", "c"))
fp297 <- engine_p_famille(L297, boot297, cat297)
# Liste T-1 attendue : "<test> [<mc_nom>]", test de la premiere ligne membre.
etiq297 <- function(fam, mcs) paste(sprintf("%s %s [%s]", fam, mcs, mcs), collapse = ", ")

verifier("#297 appartenance : B. = {a, b} ; C. sans ligne (un seul test) ; D. = {c, e} dedoublonnee ; globale = {a, b, d, c, e}",
         length(fp297) == 3L &&
           identical(lapply(fp297, `[[`, "membres"),
                     list(c("a", "b"), c("c", "e"), c("a", "b", "d", "c", "e"))) &&
           identical(vapply(fp297, function(f) f$args$fam, ""),
                     c("B. famille B", "D. famille D", FAMILLE_LECTURE_CONJOINTE)))
verifier("#297 p de famille = numerateur de l'ecriture independante / (B_eff + 1) ; m_obs ; err_mc binomiale",
         all(vapply(fp297, function(f) {
           cols <- f$membres
           n <- naif297(Sj[, cols, drop = FALSE], unlist(boot297$stats_obs[cols]),
                        vapply(cols, function(c) cat297[[c]]$queue, ""))
           p <- n$num_p / n$N
           identical(f$num_p, n$num_p) && identical(f$args$p_mc_ext, p) &&
             identical(f$args$stat, n$num_m_obs / n$N) &&
             identical(f$args$err_mc_ext, sqrt(p * (1 - p) / B297)) &&
             identical(f$B_eff, B297) && identical(f$args$estim, as.numeric(length(cols)))
         }, NA)))
verifier("#297 champs du par. 4.2 et textes T-1 et T-2 (membres dans l'ordre des lignes, nombre de tests)",
         {
           f <- fp297[[1]]$args; g <- fp297[[3]]$args
           identical(f$type, "diagnostic") && identical(f$base, "commun") &&
             identical(f$variante, "principale") && identical(f$fonction, "engine_p_famille") &&
             identical(f$nom, "p de famille (minP, lecture conjointe)") &&
             identical(g$nom, "p globale (minP, lecture conjointe de la batterie)") &&
             identical(f$detail, sprintf(DETAIL_P_FAMILLE, etiq297("B. famille B", c("a", "b")))) &&
             identical(fp297[[2]]$args$detail,
                       sprintf(DETAIL_P_FAMILLE, etiq297("D. famille D", c("c", "e")))) &&
             identical(g$detail, sprintf(DETAIL_P_GLOBALE, 5L)) &&
             identical(g$estim_nom, "nombre de tests") &&
             identical(f$estim_nom, "nombre de tests de la famille") &&
             identical(f$stat_nom, "plus petite p Monte-Carlo de la famille") &&
             identical(g$stat_nom, "plus petite p Monte-Carlo de la batterie") &&
             identical(f$ref, REFERENCE_P_FAMILLE) && identical(g$ref, REFERENCE_P_FAMILLE)
         })
# Textes a la lettre (reprise du 25/10/2026, points 5, 6, 8 et 9).
verifier("#297 textes a la lettre : T-2, T-3a, phrase d'introduction des membres de T-1, reference",
         identical(DETAIL_P_GLOBALE, paste0(
           "Lecture conjointe de la batterie (issue #297) : p minP en une etape sur les %d tests ",
           "des familles (tous, quelle que soit la selection de restitution), meme construction ",
           "que les lignes de famille. Elle situe la plus petite p Monte-Carlo observee dans sa loi ",
           "sous le modele ajuste, compte tenu du nombre de tests et de leur dependance. Elle porte ",
           "sur les p Monte-Carlo des tests, pas sur leurs p retenues : un verdict fonde sur une p ",
           "exacte peut ne pas s'y retrouver, et les lignes de sens rejeter, hors batterie, n'y ",
           "entrent pas. Controle du taux d'erreur de la batterie au sens faible, sous le modele ",
           "ajuste : p plug-in, non exacte. Diagnostic sans verdict : aucun verdict de ligne n'est ",
           "modifie.")) &&
           identical(PHRASE_FAMILLE_B_EFF_REDUIT, paste0(
             "Calculee sur les seules replications ou les statistiques de tous les tests de la ",
             "famille sont finies, moins nombreuses que celles d'au moins un test : la plus petite p ",
             "peut alors differer de la plus petite p Monte-Carlo affichee.")) &&
           grepl(" Tests de la famille (tous, quelle que soit la selection de restitution) : %s. Hors famille : ",
                 DETAIL_P_FAMILLE, fixed = TRUE) &&
           identical(REFERENCE_P_FAMILLE, paste0(
             "Westfall & Young (1993), minP en une etape ; Ge, Dudoit & Speed (2003), rapport ",
             "technique 633, UC Berkeley, eq. (10) ; Dwass (1957), Hope (1968)")))
verifier("#297 ordre des lignes : familles triees par prefixe (B. < C. < D. ; M1 < M2 < M3), puis la ligne globale, quel que soit l'ordre des lignes membres",
         {
           L <- list(ligne297("D. famille D", "c"), ligne297("D. famille D", "e"),
                     ligne297("B. famille B", "a"), ligne297("B. famille B", "b"),
                     ligne297("C. famille C", "d"), ligne297("C. famille C", "f"))
           Lm <- list(ligne297("M3 famille", "c"), ligne297("M3 famille", "e"),
                      ligne297("M1 famille", "a"), ligne297("M1 famille", "b"),
                      ligne297("M2 famille", "d"), ligne297("M2 famille", "f"))
           f <- engine_p_famille(L, boot297, cat297); fm <- engine_p_famille(Lm, boot297, cat297)
           identical(substr(vapply(f, function(x) x$args$fam, ""), 1L, 2L), c("B.", "C.", "D.", "LC")) &&
             identical(substr(vapply(fm, function(x) x$args$fam, ""), 1L, 2L), c("M1", "M2", "M3", "LC")) &&
             identical(f[[4]]$membres, c("c", "e", "a", "b", "d", "f"))
         })
verifier("#297 lignes de replication NA : B effectif de famille = lignes completes sur les membres ; T-3a jointe ; err_mc sur B_eff (constat C1)",
         {
           b <- boot297; b$stats_boot[c(2, 5), "a"] <- NA; b$stats_boot[7, "b"] <- NaN
           b$stats_boot[9, "d"] <- NA                      # hors famille B. : sans effet sur B.
           f <- engine_p_famille(L297, b, cat297)
           X <- b$stats_boot[-c(2, 5, 7), c("a", "b")]
           n <- naif297(X, c(0.9, -0.4), c("haut", "bas"))
           p <- n$num_p / n$N
           identical(f[[1]]$B_eff, 57L) && identical(f[[1]]$num_p, n$num_p) &&
             identical(f[[1]]$args$p_mc_ext, p) &&
             # constat C1 d'audit : denominateur B_eff de famille (57), pas B (60)
             identical(f[[1]]$args$err_mc_ext, sqrt(p * (1 - p) / 57)) &&
             !identical(f[[1]]$args$err_mc_ext, sqrt(p * (1 - p) / B297)) &&
             identical(f[[1]]$args$detail,
                       paste(sprintf(DETAIL_P_FAMILLE, etiq297("B. famille B", c("a", "b"))),
                             PHRASE_FAMILLE_B_EFF_REDUIT)) &&
             identical(f[[2]]$args$detail, sprintf(DETAIL_P_FAMILLE, etiq297("D. famille D", c("c", "e")))) &&
             identical(f[[3]]$B_eff, 56L) &&
             endsWith(f[[3]]$args$detail, PHRASE_FAMILLE_B_EFF_REDUIT)
         })
# Reprise du 25/10/2026, point 1 : T-3a posee si et seulement si au moins un
# membre a plus de replications finies que la famille, et non des que B_eff
# de famille < B. Replications manquantes sur les memes lignes pour tous les
# membres (cas du plafond du retirage Merz-Wuthrich) : B_eff < B sans T-3a,
# et la plus petite p restituee est la plus petite p_mc des membres.
pmc297 <- function(S, cols) vapply(cols, function(c) engine_p_mc(S[, c], obsj[[c]], qj[[c]])$p_mc, 0)
verifier("#297 T-3a si et seulement si un membre a plus de replications finies que la famille (cas construits)",
         {
           bc <- boot297; bc$stats_boot[c(2, 5), c("a", "b")] <- NA      # memes lignes : pas de T-3a
           bd <- boot297; bd$stats_boot[c(2, 5), "a"] <- NA; bd$stats_boot[2, "b"] <- NA  # b : 59 > 58
           fc <- engine_p_famille(L297, bc, cat297); fd <- engine_p_famille(L297, bd, cat297)
           identical(fc[[1]]$B_eff, 58L) && identical(fd[[1]]$B_eff, 58L) &&
             !grepl(PHRASE_FAMILLE_B_EFF_REDUIT, fc[[1]]$args$detail, fixed = TRUE) &&
             grepl(PHRASE_FAMILLE_B_EFF_REDUIT, fd[[1]]$args$detail, fixed = TRUE) &&
             identical(fc[[1]]$args$detail, sprintf(DETAIL_P_FAMILLE, etiq297("B. famille B", c("a", "b")))) &&
             # sans T-3a, la plus petite p est la plus petite p_mc des membres
             identical(fc[[1]]$args$stat, min(pmc297(bc$stats_boot, c("a", "b")))) &&
             # famille D. sans replication manquante, B_eff = B : pas de T-3a
             !grepl(PHRASE_FAMILLE_B_EFF_REDUIT, fc[[2]]$args$detail, fixed = TRUE)
         })
verifier("#297 sans T-3a : stat = plus petite p_mc des membres (identical), sur chaque ligne du jeu jouet",
         all(vapply(fp297, function(f)
           !grepl(PHRASE_FAMILLE_B_EFF_REDUIT, f$args$detail, fixed = TRUE) &&
             identical(f$args$stat, min(pmc297(Sj, f$membres))), NA)))
verifier("#297 seuil B_MIN_DEGENERESCENCE : B effectif de famille 49 -> aucune p (T-3b en tete, membres conserves) ; 50 -> p calculee",
         {
           b49 <- boot297; b49$stats_boot[1:11, "a"] <- NA
           b50 <- boot297; b50$stats_boot[1:10, "a"] <- NA
           f49 <- engine_p_famille(L297, b49, cat297)[[1]]
           f50 <- engine_p_famille(L297, b50, cat297)[[1]]
           identical(f49$B_eff, 49L) && is.na(f49$args$p_mc_ext) && is.na(f49$args$err_mc_ext) &&
             is.na(f49$args$stat) && is.na(f49$num_p) &&
             identical(f49$args$detail, paste(PHRASE_FAMILLE_B_EFF_INSUFFISANT,
                                              sprintf(DETAIL_P_FAMILLE,
                                                      etiq297("B. famille B", c("a", "b"))))) &&
             grepl("B_MIN_DEGENERESCENCE = 50)", PHRASE_FAMILLE_B_EFF_INSUFFISANT, fixed = TRUE) &&
             identical(f50$B_eff, 50L) && is.finite(f50$args$p_mc_ext)
         })
verifier("#297 sans stats_boot (bootstrap anterieur au champ ou fictif) : aucune ligne ; colonne absente : refus",
         identical(engine_p_famille(L297, boot297[c("stats_obs", "B")], cat297), list()) &&
           leve_erreur(engine_p_famille(L297, within(boot297, stats_boot <- stats_boot[, -1]), cat297)))
verifier("#297 statistique observee absente de stats_obs : stop() nommant la statistique (pas d'erreur opaque de vapply)",
         { nm <- colnames(Sj)[1L]
           b <- boot297; b$stats_obs[[nm]] <- NULL
           msg <- tryCatch({ engine_p_famille(L297, b, cat297); "" }, error = function(e) conditionMessage(e))
           grepl("absente(s) de stats_obs", msg, fixed = TRUE) && grepl(nm, msg, fixed = TRUE) })
verifier("#297 aucune consommation d'alea : .Random.seed inchange",
         {
           set.seed(1); s0 <- .Random.seed
           invisible(engine_p_famille(L297, boot297, cat297))
           identical(.Random.seed, s0)
         })
verifier("#297 lignes posees par add() : diagnostic INFO, sans sens ni p retenue, p dans p_mc, mc_nom NA, inoperant FALSE",
         {
           reg <- engine_registre_tests(list(p_mc = c(a = 0.5), err_mc = c(a = 0.01)), cat297, 0.10,
                                        nature_mc = "Monte-Carlo")
           for (f in fp297) do.call(reg$add, f$args)
           L <- reg$lignes()
           length(L) == 3L &&
             all(vapply(seq_along(L), function(i) {
               l <- L[[i]]; a <- fp297[[i]]$args
               identical(l$type, "diagnostic") && identical(l$verdict, "INFO") &&
                 identical(l$sens, NA_character_) && identical(l$p_retenue, NA_real_) &&
                 identical(l$nature_p, NA_character_) && identical(l$p_mc, a$p_mc_ext) &&
                 identical(l$err_mc, a$err_mc_ext) && identical(l$mc_nom, NA_character_) &&
                 identical(l$inoperant, FALSE) && identical(l$p_min_mc, NA_real_) &&
                 identical(l$detail, a$detail) && identical(l$fonction, "engine_p_famille")
             }, NA))
         })

## --- Calcul a B = 99 (premium, reserve2) -------------------------------------------
.ln297 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
.tri297 <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
res297_p <- run_engine(xt = .ln297$xt, yt = .ln297$yt, methode = "premium", segment = 1, annexe = "II",
                       nature_donnees = "brutes", B = 99)
res297_r2 <- run_engine(methode = "reserve2", triangle = .tri297, segment = 1, annexe = "II", B = 99)

# Recalcul independant, depuis les lignes existantes, stats_boot et stats_obs,
# des lignes ajoutees ; TRUE ou un message.
inv297 <- function(res, catalogue) {
  tt <- res$tests; b <- res$bootstrap
  f <- vapply(tt, function(l) l$fonction, "")
  k <- which(f == "engine_p_famille")
  if (!length(k)) return("aucune ligne de famille")
  if (!identical(k, seq.int(length(tt) - length(k) + 1L, length(tt))))
    return("lignes de famille non placees apres les lignes existantes")
  ex <- tt[-k]
  memb <- vapply(ex, function(l) identical(l$type, "test") && identical(l$variante, "principale") &&
                   identical(l$sens, "ne pas rejeter") && !is.na(l$mc_nom) && is.finite(l$p_mc), NA)
  pref <- substr(vapply(ex, function(l) l$famille, ""), 1L, 2L)
  mc <- vapply(ex, function(l) l$mc_nom, "")
  tst <- vapply(ex, function(l) l$test, "")
  attendu <- list()
  # familles dans l'ordre des prefixes (reprise du 25/10/2026, point 2)
  for (g in sort(unique(pref[memb]), method = "radix")) {
    sel <- memb & pref == g; cols <- unique(mc[sel])
    etiq <- paste(vapply(cols, function(c) sprintf("%s [%s]", tst[sel & mc == c][1L], c), ""),
                  collapse = ", ")
    if (length(cols) >= 2L)
      attendu[[length(attendu) + 1L]] <- list(g = g, cols = cols, glob = FALSE, etiq = etiq)
  }
  attendu[[length(attendu) + 1L]] <- list(g = "LC", cols = unique(mc[memb]), glob = TRUE)
  if (length(attendu) != length(k)) return("nombre de lignes de famille")
  for (i in seq_along(k)) {
    l <- tt[[k[i]]]; a <- attendu[[i]]; cols <- a$cols
    X0 <- b$stats_boot[, cols, drop = FALSE]; X <- X0[rowSums(!is.finite(X0)) == 0L, , drop = FALSE]
    t3a <- any(colSums(is.finite(X0)) > nrow(X))
    n <- naif297(X, vapply(cols, function(c) b$stats_obs[[c]], 0),
                 vapply(cols, function(c) catalogue[[c]]$queue, ""))
    p <- n$num_p / n$N
    pm <- min(vapply(ex[memb & mc %in% cols], function(x) x$p_mc, 0))
    ok <- identical(substr(l$famille, 1L, 2L), a$g) && identical(l$p_mc, p) &&
      identical(l$err_mc, sqrt(p * (1 - p) / nrow(X))) && identical(l$stat, n$num_m_obs / n$N) &&
      (t3a || identical(l$stat, pm)) && identical(l$estim, as.numeric(length(cols))) &&
      identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && identical(l$sens, NA_character_) &&
      identical(l$p_retenue, NA_real_) && identical(l$mc_nom, NA_character_) &&
      identical(l$inoperant, FALSE) &&
      identical(l$stat_nom, if (a$glob) "plus petite p Monte-Carlo de la batterie"
                            else "plus petite p Monte-Carlo de la famille") &&
      identical(l$detail, paste(c(if (a$glob) sprintf(DETAIL_P_GLOBALE, length(cols))
                                  else sprintf(DETAIL_P_FAMILLE, a$etiq),
                                  if (t3a) PHRASE_FAMILLE_B_EFF_REDUIT), collapse = " "))
    if (!ok) return(paste("ligne", a$g, "non conforme"))
  }
  TRUE
}
verifier("#297 run_engine() B = 99 (premium) : lignes de famille recalculees independamment, apres les lignes existantes, m_obs = plus petite p_mc des membres",
         isTRUE(res297_p$ok) && isTRUE(inv297(res297_p, USP_CATALOGUE_MC)))
verifier("#297 run_engine() B = 99 (reserve2) : idem, sans phrase de #204 ni de #257",
         isTRUE(res297_r2$ok) && isTRUE(inv297(res297_r2, MW_CATALOGUE_MC)))
# Regle #76 et point 6 de la reprise : les champs test des membres, imprimes
# dans T-1, ne portent aucun nombre issu du bootstrap. Mesure : a donnees
# identiques, une autre graine change les replications (p_mc des membres)
# sans changer ni la liste des membres ni les textes des lignes de famille.
res297_p2 <- run_engine(xt = .ln297$xt, yt = .ln297$yt, methode = "premium", segment = 1, annexe = "II",
                        nature_donnees = "brutes", B = 99, seed = 1L)
res297_r22 <- run_engine(methode = "reserve2", triangle = .tri297, segment = 1, annexe = "II", B = 99,
                         seed = 1L)
verifier("#297 / #76 : champs test des membres et textes des lignes de famille invariants quand la graine change (premium, reserve2), p_mc des membres changees",
         {
           fam <- function(r) Filter(function(l) identical(l$fonction, "engine_p_famille"), r$tests)
           memb <- function(r) Filter(function(l) identical(l$type, "test") &&
                                        identical(l$variante, "principale") &&
                                        identical(l$sens, "ne pas rejeter") && !is.na(l$mc_nom) &&
                                        is.finite(l$p_mc) && !identical(l$fonction, "engine_p_famille"),
                                      r$tests)
           un <- function(a, b) {
             ma <- memb(a); mb <- memb(b)
             identical(vapply(ma, `[[`, "", "test"), vapply(mb, `[[`, "", "test")) &&
               !identical(vapply(ma, `[[`, 0, "p_mc"), vapply(mb, `[[`, 0, "p_mc")) &&
               identical(vapply(fam(a), `[[`, "", "detail"), vapply(fam(b), `[[`, "", "detail")) &&
               # chaque membre d'une famille qui a sa ligne figure dans T-1
               all(vapply(ma, function(l) {
                 f <- Filter(function(x) identical(substr(x$famille, 1L, 2L), substr(l$famille, 1L, 2L)),
                             fam(a))
                 !length(f) || grepl(paste0(l$test, " [", l$mc_nom, "]"), f[[1]]$detail, fixed = TRUE)
               }, NA))
           }
           un(res297_p, res297_p2) && un(res297_r2, res297_r22)
         })
verifier("#297 bootstrap$stats_boot dernier element ; engine_p_mc() sur chaque colonne redonne p_mc, err_mc, B_effectif ; .mc_p_values() redonne p_min_mc",
         {
           ok1 <- function(b, catalogue) {
             S <- b$stats_boot
             identical(utils::tail(names(b), 1L), "stats_boot") && identical(colnames(S), names(b$p_mc)) &&
               all(vapply(colnames(S), function(j) {
                 if (!is.na(b$motif_mc[[j]])) return(TRUE)
                 o <- engine_p_mc(S[, j], b$stats_obs[[j]], catalogue[[j]]$queue)
                 identical(o$p_mc, unname(b$p_mc[[j]])) && identical(o$err_mc, unname(b$err_mc[[j]])) &&
                   identical(o$B_effectif, unname(b$B_effectif[[j]]))
               }, NA))
           }
           fit <- res297_p$ajustement
           mcp <- .mc_p_values(res297_p$bootstrap$stats_boot, unlist(res297_p$bootstrap$stats_obs),
                               USP_CATALOGUE_MC, .usp_contexte_mc(fit$x, fit$y, fit$z, fit$pi))
           ok1(res297_p$bootstrap, USP_CATALOGUE_MC) && ok1(res297_r2$bootstrap, MW_CATALOGUE_MC) &&
             identical(mcp$p_min_mc, res297_p$bootstrap$p_min_mc) &&
             identical(nrow(res297_p$bootstrap$stats_boot), 99L) &&
             identical(nrow(res297_r2$bootstrap$stats_boot), 99L)
         })
verifier("#297 engine_table_tests() : lignes de famille en INFO, fonction engine_p_famille, prefixe LC declare dans GROUPES (R/display_helpers.R)",
         {
           tb <- engine_table_tests(res297_r2)
           e <- new.env(); sys.source(file.path(RACINE, "R", "display_helpers.R"), envir = e)
           k <- tb$fonction == "engine_p_famille"
           sum(k) == 4L && all(tb$verdict[k] == "INFO") && PREFIXE_LECTURE_CONJOINTE %in% names(e$GROUPES) &&
             identical(e$groupe_de(FAMILLE_LECTURE_CONJOINTE)$cle, "LC") &&
             identical(substr(FAMILLE_LECTURE_CONJOINTE, 1L, 2L), PREFIXE_LECTURE_CONJOINTE)
         })

## --- Six references versionnees (apres la regeneration de #297) ---------------------
# Numerateurs du par. 6 de la specification (p = numerateur / 1000, B_eff de
# famille 999), oracles du prototype d_proto.R (annexe C), dans l'ordre des
# lignes ajoutees ; decomptes de lignes 52, 52 et 25.
ORACLES297 <- list(
  premium = c(B. = 950L, D. = 438L, E. = 316L, F. = 961L, LC = 131L),
  reserve1 = c(B. = 950L, D. = 438L, E. = 316L, F. = 961L, LC = 131L),
  premium_ii6 = c(B. = 950L, D. = 438L, E. = 316L, F. = 961L, LC = 131L),
  premium_net = c(B. = 950L, D. = 438L, E. = 316L, F. = 961L, LC = 131L),
  premium_interieur = c(B. = 955L, D. = 579L, E. = 423L, F. = 290L, LC = 650L),
  reserve2 = c(M1 = 23L, M2 = 471L, M3 = 8L, LC = 24L))
verifier("#297 references : lignes de famille aux numerateurs du par. 6 (sur 1000), recalcul independant, decomptes 52 / 25",
         {
           v <- vapply(names(ORACLES297), function(k) {
             f <- file.path(RACINE, "tests", "reference", paste0(k, ".rds"))
             if (!file.exists(f)) return("reference absente")
             r <- readRDS(f)
             if (is.null(r$bootstrap$stats_boot)) return("reference sans stats_boot (avant regeneration)")
             cat_mc <- if (identical(k, "reserve2")) MW_CATALOGUE_MC else USP_CATALOGUE_MC
             x <- inv297(r, cat_mc); if (!isTRUE(x)) return(x)
             l <- Filter(function(t) identical(t$fonction, "engine_p_famille"), r$tests)
             o <- ORACLES297[[k]]
             if (!identical(substr(vapply(l, function(t) t$famille, ""), 1L, 2L), names(o)))
               return("familles")
             if (!identical(vapply(l, function(t) t$p_mc, 0), unname(o) / 1000)) return("numerateurs")
             if (length(r$tests) != if (identical(k, "reserve2")) 25L else 52L) return("decompte")
             "ok"
           }, "")
           if (all(v == "ok")) TRUE else paste(names(v)[v != "ok"], v[v != "ok"], collapse = " ; ")
         })

fin_fichier()
