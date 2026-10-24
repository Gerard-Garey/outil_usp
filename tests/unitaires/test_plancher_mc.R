###############################################################################
#  tests/unitaires/test_plancher_mc.R  --  REGLE R1 LUE SUR LA LOI BOOTSTRAP :
#                                          PLANCHER MONTE-CARLO p_min_mc (#125)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 7, tests U125-1 a U125-10 ; decisions D1-7 a D1-10 ; ADR 0003
#  annote le 12/10/2026, point 5) :
#    - champ `extremes` de .mc_entree(), extremites du support des treize
#      statistiques discretes a la configuration observee ;
#    - engine_p_mc(sim, obs, queue, extremes) rend p_min_mc =
#      (1 + N_haut)/(B_eff + 1), (1 + N_bas)/(B_eff + 1) ou
#      min(1, 2 (1 + min(N_haut, N_bas))/(B_eff + 1)) ;
#    - bootstrap$p_min_mc (dernier element), champ de ligne p_min_mc (apres
#      inoperant), colonne p_min_mc d'engine_table_tests() (apres p_min) ;
#    - branche Monte-Carlo de la regle R1 dans add() : p_min_mc seule, sans
#      marge.
#  Oracles U125-6 et U125-7 : mesures M2 de la specification (comptes aux
#  extremites des 999 replications retenues).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_plancher_mc.R")

ligne125 <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]
STAT_DISCRETES_USP <- c("Smirnov", "Runs", "MK", "SpearVol", "SpearTps", "CoxStuart", "Runsr")
STAT_DISCRETES_MW <- c("Calendrier", "CorrDev", "Runs", "HomogF", "ExpVar", "KruskalAcc")
PRE_MC <- paste("TEST INOPERANT au seuil alpha = %g : plus petite p-value Monte-Carlo",
                "atteignable sur ces replications >= alpha%s ; aucun verdict (ADR 0001).")
SUF_MC <- paste("ECHEC inatteignable : plus petite p-value Monte-Carlo atteignable sur ces",
                "replications >= alpha/2 = %g%s")

## --- U125-1 : engine_p_mc() sur vecteurs construits ------------------------------
# 90 valeurs centrales et 1..9 (B_eff = 99, denominateur 100) ; extremites
# c(1, 9). B_eff >= B_MIN_DEGENERESCENCE, sans quoi p_mc et p_min_mc sont NA.
verifier("U125-1 haut : N_haut = #{sim >= 9} = 1 -> p_min_mc = 2/100 ; bas : N_bas = 1 -> 2/100 ; deux : 2 (1 + 1)/100",
         {
           s <- c(rep(5, 90), 1:9)                   # B_eff = 99 >= B_MIN_DEGENERESCENCE
           identical(engine_p_mc(s, 5, "haut", c(1, 9))$p_min_mc, 2 / 100) &&
             identical(engine_p_mc(s, 5, "bas", c(1, 9))$p_min_mc, 2 / 100) &&
             identical(engine_p_mc(s, 5, "deux", c(1, 9))$p_min_mc, 4 / 100)
         })
verifier("U125-1 bilateral : min(N_haut, N_bas) ; borne a 1",
         {
           s <- c(rep(0, 5), rep(2, 40), 1:3, rep(4, 2))   # N_bas = 5, N_haut = 2, B_eff = 50
           identical(engine_p_mc(s, 2, "deux", c(0, 4))$p_min_mc, 2 * 3 / 51) &&
             identical(engine_p_mc(rep(c(0, 4), 30), 2, "deux", c(0, 4))$p_min_mc, 1)
         })
verifier("U125-1 tolerance TOL_DISPERSION_MC * max(1, |x|) a l'extremite : 9 - 5e-12 compte, 9 - 1e-9 non",
         {
           s <- c(rep(5, 90), 1:8, 9 - 5e-12)
           s2 <- c(rep(5, 90), 1:8, 9 - 1e-9)
           identical(engine_p_mc(s, 5, "haut", c(NA, 9))$p_min_mc, 2 / 100) &&
             identical(engine_p_mc(s2, 5, "haut", c(NA, 9))$p_min_mc, 1 / 100) &&
             identical(engine_p_mc(c(rep(5, 90), 5e-13, 1:8), 5, "bas", c(0, NA))$p_min_mc, 2 / 100) &&
             identical(engine_p_mc(c(rep(5, 90), 2e-12, 1:8), 5, "bas", c(0, NA))$p_min_mc, 1 / 100)
         })
verifier("U125-1 NA : extremes NULL, NA du cote requis, p_mc NA (statistique observee non finie, B_eff < 50)",
         {
           s <- 1:60 + 0
           is.na(engine_p_mc(s, 5, "haut")$p_min_mc) &&
             is.na(engine_p_mc(s, 5, "haut", c(1, NA))$p_min_mc) &&
             is.na(engine_p_mc(s, 5, "deux", c(1, NA))$p_min_mc) &&
             !is.na(engine_p_mc(s, 5, "bas", c(1, NA))$p_min_mc) &&
             is.na(engine_p_mc(s, NA_real_, "haut", c(1, 60))$p_min_mc) &&
             is.na(engine_p_mc(1:10 + 0, 5, "haut", c(1, 10))$p_min_mc) &&
             identical(names(engine_p_mc(s, 5, "haut")),
                       c("p_mc", "err_mc", "B_effectif", "granularite", "motif", "p_min_mc"))
         })
verifier("U125-1 p_mc >= p_min_mc >= granularite pour toute valeur observee du support (sim discrete)",
         {
           s <- engine_sous_graine(1, sample(0:6, 199, replace = TRUE) + 0)
           all(vapply(c("haut", "bas", "deux"), function(q) all(vapply(0:6, function(o) {
             r <- engine_p_mc(s, o, q, c(0, 6))
             r$p_mc >= r$p_min_mc && r$p_min_mc >= r$granularite
           }, logical(1))) &&
             # le minimum est atteint sur le support
             isTRUE(all.equal(min(vapply(0:6, function(o) engine_p_mc(s, o, q, c(0, 6))$p_mc, 1)),
                              engine_p_mc(s, 3, q, c(0, 6))$p_min_mc)), logical(1)))
         })

# Garde du constat C2 d'audit : l'extremite calculee peut differer de la
# statistique observee par un arrondi ; le comptage tolerant aux extremites
# compterait alors plus de replications que le comptage exact de p_mc. La
# statistique observee appartenant au support, p_min_mc = min(formule, p_mc).
verifier("U125-1 garde C2 : sim = 979 x 0 et 20 x (1 - 1e-15), obs = 1, extremes c(NA, 1) -> p_min_mc = p_mc = 0,001 (formule seule : 21/1000)",
         {
           r <- engine_p_mc(c(rep(0, 979), rep(1 - 1e-15, 20)), 1, "haut", c(NA, 1))
           identical(r$p_mc, 0.001) && identical(r$p_min_mc, 0.001)
         })

## --- U125-10 : refus d'extremes mal forme ----------------------------------------
verifier("U125-10 .mc_entree(extremes = non-fonction) et engine_p_mc(extremes de longueur 1) refuses",
         leve_erreur(.mc_entree(function(e) 1, "haut", extremes = c(0, 1))) &&
           leve_erreur(engine_p_mc(1:60 + 0, 5, "haut", 9)) &&
           leve_erreur(engine_p_mc(1:60 + 0, 5, "haut", c("0", "9"))))
verifier("U125-10 extremes(e) de forme fausse refuse par .mc_p_values() (nomme la statistique)",
         {
           cat_ <- list(S = .mc_entree(function(e) 1, "haut", extremes = function(e) 1))
           m <- tryCatch({ .mc_p_values(matrix(1:60 + 0, ncol = 1, dimnames = list(NULL, "S")),
                                        c(S = 5), cat_, e = list()); "" },
                         error = function(e) conditionMessage(e))
           grepl("extremes(S)", m, fixed = TRUE)
         })

## --- U125-3 : extremites par enumeration a T = 8 -----------------------------------
perms <- function(n) {
  if (n == 1L) return(matrix(1L, 1, 1))
  p <- perms(n - 1L)
  do.call(rbind, lapply(seq_len(n), function(k) cbind(k, ifelse(p >= k, p + 1L, p))))
}
P8 <- perms(8L)
verifier("U125-3 suites : 70 arrangements (n1 = n2 = 4), Z(R) min et max = .runs_extremes() ; test_runs() aux extremes au bit pres",
         {
           pos <- utils::combn(8, 4)
           R <- apply(pos, 2, function(p) { s <- rep(-1, 8); s[p] <- 1; 1 + sum(diff(s) != 0) })
           z <- c(1, 2, 3, 4, 5, 6, 7, 8)
           ex <- .runs_extremes(z)
           ncol(pos) == 70L && identical(ex, c(.runs_z(min(R), 4L, 4L), .runs_z(max(R), 4L, 4L))) &&
             identical(ex[1], test_runs(c(1, 2, 3, 4, 5, 6, 7, 8))$stat) &&
             identical(ex[2], test_runs(c(1, 8, 2, 7, 3, 6, 4, 5))$stat)
         })
verifier("U125-3 suites, effectifs desequilibres (n1 = 2, n2 = 3) : R_max = 2 min + 1 = 5 par enumeration",
         {
           pos <- utils::combn(5, 2)
           R <- apply(pos, 2, function(p) { s <- rep(-1, 5); s[p] <- 1; 1 + sum(diff(s) != 0) })
           # T = 7, deux valeurs egales a la mediane ecartees : n1 = 2, n2 = 3
           z <- c(1, 2, 3, 4, 4, 6, 7)
           ne <- .runs_effectifs(z)
           identical(unname(ne), c(2L, 3L)) && max(R) == 5 && min(R) == 2 &&
             identical(.runs_extremes(z), c(.runs_z(2, 2L, 3L), .runs_z(5, 2L, 3L)))
         })
verifier("U125-3 Mann-Kendall : 8! permutations, S dans [-28, 28] ; .mk_extremes() = Z de test_mann_kendall() aux extremes",
         {
           S <- rowSums(vapply(seq_len(7), function(i) rowSums(sign(P8[, (i + 1):8, drop = FALSE] - P8[, i])),
                               numeric(nrow(P8))))
           ex <- .mk_extremes(c(1, 2, 3, 4, 5, 6, 7, 8))
           nrow(P8) == 40320L && min(S) == -28 && max(S) == 28 &&
             identical(ex, c(test_mann_kendall(8:1 + 0, plancher = 0)$stat,
                             test_mann_kendall(1:8 + 0, plancher = 0)$stat))
         })
verifier("U125-3 Spearman : 8! permutations, S = somme d^2 dans [0, 168] = .spearman_extremes(8) ; cor.test() aux extremes",
         {
           D2 <- rowSums((P8 - matrix(1:8, nrow(P8), 8, byrow = TRUE))^2)
           s_ct <- function(b) unname(suppressWarnings(stats::cor.test(1:8, b, method = "spearman",
                                                                      exact = FALSE))$statistic)
           identical(c(min(D2), max(D2)), .spearman_extremes(8)) &&
             isTRUE(proche(s_ct(1:8), 0, abs = 1e-10)) && isTRUE(proche(s_ct(8:1), 168, rel = 1e-12))
         })
verifier("U125-3 Smirnov : C(8,4) partitions, D maximal = 1 (queue haute : seule l'extremite haute est lue)",
         {
           pos <- utils::combn(8, 4)
           D <- apply(pos, 2, function(p) unname(stats::ks.test((1:8)[p], (1:8)[-p])$statistic))
           xc <- c(50, 80, 120, 200, 300, 150, 90, 60)
           e <- .usp_contexte_mc(xc, xc * (1:8) / 10, c(-1, 0.5, 0.2, 1.1, -0.3, 0.8, -0.7, 0.1), rep(1, 8))
           ex <- USP_CATALOGUE_MC$Smirnov$extremes(e)
           ncol(pos) == 70L && max(D) == 1 && min(D) > 0 && is.na(ex[1]) && identical(ex[2], 1)
         })
verifier("U125-3 Cox-Stuart : 16 signes (n_p = 4), |K - 2| dans [0, 2] ; extremes = c(NA, n_p/2) (queue haute)",
         {
           K <- rowSums(as.matrix(expand.grid(rep(list(0:1), 4))))
           e <- .usp_contexte_mc(1:8 + 0, 1:8 + 0, rep(0, 8), rep(1, 8))
           e$r <- c(1, 3, 2, 5, 4, 7, 6, 8)                  # m = n_p = 4
           identical(range(abs(K - 2)), c(0, 2)) &&
             identical(USP_CATALOGUE_MC$CoxStuart$extremes(e), c(NA_real_, 2))
         })
verifier("U125-3 conditions : extremes NA avec ex aequo (MK, Spearman, Smirnov, Cox-Stuart) ou volumes constants (SpearVol, Smirnov)",
         {
           xc <- c(50, 80, 120, 200, 300, 150, 90, 60)
           e <- .usp_contexte_mc(xc, xc * (1:8) / 10, c(-1, 0.5, 0.2, 1.1, -0.3, 0.8, -0.7, 0.1), rep(1, 8))
           e_ea <- e; e_ea$r <- c(1, 2, 3, 4, 1, 6, 7, 8); e_ea$z <- c(1, 1, 2, 3, 4, 5, 6, 7)
           e_vc <- e; e_vc$x <- rep(100, 8)
           na2 <- function(v) identical(v, c(NA_real_, NA_real_))
           na2(USP_CATALOGUE_MC$MK$extremes(e_ea)) && na2(USP_CATALOGUE_MC$SpearTps$extremes(e_ea)) &&
             na2(USP_CATALOGUE_MC$SpearVol$extremes(e_ea)) && na2(USP_CATALOGUE_MC$Smirnov$extremes(e_ea)) &&
             na2(USP_CATALOGUE_MC$CoxStuart$extremes(e_ea)) &&
             na2(USP_CATALOGUE_MC$SpearVol$extremes(e_vc)) && na2(USP_CATALOGUE_MC$Smirnov$extremes(e_vc)) &&
             !anyNA(USP_CATALOGUE_MC$SpearVol$extremes(e)) && !is.na(USP_CATALOGUE_MC$Smirnov$extremes(e)[2])
         })
verifier("U125-3 catalogues : extremes renseignees pour les treize statistiques discretes, et elles seules",
         identical(names(Filter(function(x) !is.null(x$extremes), USP_CATALOGUE_MC)),
                   c("Smirnov", "Runs", "MK", "SpearVol", "SpearTps", "CoxStuart", "Runsr")) &&
           identical(names(Filter(function(x) !is.null(x$extremes), MW_CATALOGUE_MC)),
                     c("Calendrier", "CorrDev", "Runs", "HomogF", "ExpVar", "KruskalAcc")))
verifier("U125-3 Kruskal-Wallis : H maximal en blocs de rangs contigus (tailles 3, 2, 2 : enumeration des 210 affectations)",
         {
           g <- rep(1:3, c(3, 2, 2))
           aff <- unique(t(apply(perms(7L), 1, function(p) g[p])))
           H <- apply(aff, 1, function(a) unname(stats::kruskal.test(1:7, factor(a))$statistic))
           ka <- list(stat = 1, un_par_annee = FALSE, ex_aequo = FALSE, tailles = c(3L, 2L, 2L))
           nrow(aff) == 210L && isTRUE(proche(max(H), .mw_kruskal_extremes(ka)[2], rel = 1e-12)) &&
             is.na(.mw_kruskal_extremes(ka)[1])
         })

# Petits triangles construits (mutations survivantes, constat C1 d'audit) :
# facteurs F(i,j) = f_j (1 + 0,01 rang_j(i)), rangs fixes par colonne ; la
# statistique observee atteint l'extremite rendue par le catalogue.
tri125c <- function(rk, I) {
  t <- matrix(NA_real_, I + 1, I + 1); t[, 1] <- 100 + 10 * (0:I)
  f <- c(1.8, 1.4, 1.2, 1.1, 1.05, 1.02)
  for (j in 0:(I - 1)) {
    idx <- 0:(I - j - 1)
    t[idx + 1, j + 2] <- t[idx + 1, j + 1] * f[j + 1] * (1 + 0.01 * rk[[j + 1]])
  }
  list(I = I, J = I, tri = t)
}
verifier("U125-3 CorrDev (6 x 6) : colonnes concordantes -> stat = extremes[2] = 1 ; alternees -> stat = extremes[1] = -1",
         {
           conc <- tri125c(lapply(5:1, seq_len), 5)
           disc <- tri125c(lapply(5:1, function(n) if (n %% 2) seq_len(n) else rev(seq_len(n))), 5)
           # contexte construit a la main : ensembles figes vides, forme de l'objet de
           # .mw_ensembles_figes() (#278)
           fg0 <- list(degeneres = integer(0), non_identifiables = integer(0))
           ec <- list(aj = conc, figes = fg0); ed <- list(aj = disc, figes = fg0)
           sc <- mw_stat_correlation_dev(conc, integer(0)); sd_ <- mw_stat_correlation_dev(disc, integer(0))
           length(sc$T) == 2L && isTRUE(proche(sc$stat, MW_CATALOGUE_MC$CorrDev$extremes(ec)[2], abs = 1e-12)) &&
             isTRUE(proche(sd_$stat, MW_CATALOGUE_MC$CorrDev$extremes(ed)[1], abs = 1e-12)) &&
             identical(MW_CATALOGUE_MC$CorrDev$extremes(ec), c(-1, 1))
         })
verifier("U125-3 Calendrier (5 x 5, rangs trouves par enumeration des 288 affectations) : Z = 0 -> extremes[1] ; Z = somme floor(n_k/2) -> extremes[2]",
         {
           lo <- tri125c(list(c(1, 4, 2, 3), c(3, 1, 2), c(1, 2), 1), 4)
           hi <- tri125c(list(c(1, 2, 3, 4), c(3, 1, 2), c(2, 1), 1), 4)
           cl <- mw_test_annees_calendaires(lo, integer(0)); ch <- mw_test_annees_calendaires(hi, integer(0))
           fg0 <- list(degeneres = integer(0), non_identifiables = integer(0))       # ensembles figes vides (#278)
           xl <- MW_CATALOGUE_MC$Calendrier$extremes(list(aj = lo, figes = fg0))
           xh <- MW_CATALOGUE_MC$Calendrier$extremes(list(aj = hi, figes = fg0))
           cl$Z == 0 && ch$Z == sum(floor(ch$detail[, "n"] / 2)) &&
             identical(cl$stat, xl[1]) && identical(ch$stat, xh[2])
         })

## --- U125-4 : branche Monte-Carlo d'add() sur boot construit -----------------------
reg125 <- function(p_mc = 0.5, pmm = NA_real_, alpha = 0.10, queue = "deux", g = 2 / 1000) {
  boot <- list(p_mc = c(S = p_mc), err_mc = c(S = 0.001), granularite_stat = c(S = g),
               motif_mc = c(S = NA_character_), p_min_mc = c(S = pmm))
  engine_registre_tests(boot, list(S = .mc_entree(function(e) 1, queue)), alpha, "Monte-Carlo")
}
verifier("U125-4 p_min_mc >= alpha -> diagnostic, inoperant, prefixe exact, champ p_min_mc ; p_mc conservee",
         {
           r <- reg125(pmm = 0.149)
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 0.125,
                 effectifs = "m = 4 differences non nulles", detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "diagnostic") && isTRUE(l$inoperant) && identical(l$verdict, "INFO") &&
             is.na(l$p_retenue) && identical(l$p_mc, 0.5) && identical(l$p_min_mc, 0.149) &&
             identical(l$detail, paste(sprintf(PRE_MC, 0.1, " (m = 4 differences non nulles)"), "d."))
         })
verifier("U125-4 p_min_mc = alpha (borne incluse) -> inoperant ; meme regle en sens 'rejeter'",
         {
           r <- reg125(pmm = 0.10); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70)
           r2 <- reg125(pmm = 0.10); r2$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
                                            sens = "rejeter")
           isTRUE(r$lignes()[[1]]$inoperant) && isTRUE(r2$lignes()[[1]]$inoperant)
         })
verifier("U125-4 alpha/2 <= p_min_mc < alpha -> suffixe exact, sans 'ECHEC possible' ni mention du plancher",
         {
           r <- reg125(pmm = 0.058, g = 0.06)
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
                 effectifs = "n1 = 4, n2 = 4", detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && !l$inoperant && identical(l$verdict, "OK") &&
             identical(l$p_min_mc, 0.058) &&
             identical(l$detail, paste("d.", sprintf(SUF_MC, 0.05, " (n1 = 4, n2 = 4)"))) &&
             !grepl("ECHEC possible", l$detail, fixed = TRUE) && !grepl("plancher", l$detail, fixed = TRUE)
         })
verifier("U125-4 alpha/2 <= p_min_mc < alpha en sens 'rejeter' -> aucun texte de R1",
         {
           r <- reg125(pmm = 0.058); r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
                                           sens = "rejeter")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && identical(l$detail, "") && identical(l$p_min_mc, 0.058)
         })
verifier("U125-4 p_min_mc < alpha/2 avec p_min = 0,0571 -> test, aucun texte de R1",
         {
           r <- reg125(pmm = 0.002)
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
                 effectifs = "n1 = 4, n2 = 4", detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && !l$inoperant && identical(l$detail, "d.") && identical(l$p_min_mc, 0.002)
         })
verifier("U125-4 hors branche : p exacte finie, p_min_mc NA ou p_mc_ext -> comportement sur p_min, champ p_min_mc NA",
         {
           r <- reg125(pmm = 0.149)
           r$add("F", "a", "ref", fonction = "usp_tests", mc_nom = "S", p_ex = 0.9, p_min = 0.125)
           r$add("F", "b", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 0.03)
           r2 <- reg125(pmm = NA_real_)
           r2$add("F", "c", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70)
           r3 <- reg125(pmm = 0.149)
           r3$add("F", "d", "ref", fonction = "usp_tests", p_mc_ext = 0.5, err_mc_ext = 0.01, p_min = 0.03)
           L <- c(r$lignes(), r2$lignes(), r3$lignes())
           a <- L[[1]]; b <- L[[2]]; c2 <- L[[3]]; d <- L[[4]]
           startsWith(a$detail, "TEST INOPERANT au seuil alpha = 0.1 : p-value minimale atteignable = 0.1250") &&
             is.na(a$p_min_mc) &&
             # b : branche Monte-Carlo (p_min_mc 0,149 >= alpha), meme si p_min < alpha/2
             isTRUE(b$inoperant) && identical(b$p_min_mc, 0.149) &&
             grepl("ECHEC possible", c2$detail, fixed = TRUE) && is.na(c2$p_min_mc) &&
             identical(d$type, "test") && is.na(d$p_min_mc)
         })
verifier("U125-4 objet bootstrap sans champ p_min_mc (anterieur a #125) -> comportement sur p_min",
         {
           boot <- list(p_mc = c(S = 0.5), err_mc = c(S = 0.001), motif_mc = c(S = NA_character_))
           r <- engine_registre_tests(boot, list(S = .mc_entree(function(e) 1, "deux")), 0.10, "Monte-Carlo")
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70)
           l <- r$lignes()[[1]]
           grepl("ECHEC possible", l$detail, fixed = TRUE) && is.na(l$p_min_mc)
         })

verifier("U125-4 frontiere alpha/2 : p_min_mc = 0,05, alpha = 0,1 -> suffixe exact 'ECHEC inatteignable'",
         {
           r <- reg125(pmm = 0.05)
           r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
                 effectifs = "n1 = 4, n2 = 4", detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "test") && !l$inoperant &&
             identical(l$detail, paste("d.", sprintf(SUF_MC, 0.05, " (n1 = 4, n2 = 4)")))
         })
# Phrase de #244 dans la branche Monte-Carlo de R1 (Q2 d'actuary) : le
# plancher des seuils atteignables est p_min_mc. Scenario d'audit : suites sur
# z, statistique observee a l'extremite, p_mc = p_min_mc = 0,058, err_mc =
# 0,0106 ; alpha/2 = 0,05 <= p_min_mc n'est pas atteignable -> pas de phrase
# apres "ECHEC inatteignable". p_min_mc = 0,04 < alpha/2 -> phrase.
reg244 <- function(pmm) {
  boot <- list(p_mc = c(S = 0.058), err_mc = c(S = 0.0106), granularite_stat = c(S = 0.002),
               motif_mc = c(S = NA_character_), p_min_mc = c(S = pmm))
  r <- engine_registre_tests(boot, list(S = .mc_entree(function(e) 1, "deux")), 0.10, "Monte-Carlo")
  r$add("F", "t", "ref", fonction = "usp_tests", mc_nom = "S", p_min = 4 / 70,
        effectifs = "n1 = 4, n2 = 4", detail = "d.")
  r$lignes()[[1]]
}
verifier("U244 / U125 : p_min_mc = 0,058 -> phrase de #244 absente apres 'ECHEC inatteignable' ; p_min_mc = 0,04 -> phrase presente",
         {
           a <- reg244(0.058); b <- reg244(0.04)
           identical(a$detail, paste("d.", sprintf(SUF_MC, 0.05, " (n1 = 4, n2 = 4)"))) &&
             identical(b$detail, paste("d.", PHRASE_VERDICT_SENSIBLE_MC)) &&
             identical(a$verdict, "ALERTE") && identical(b$verdict, "ALERTE")
         })

## --- Cas de reference recalcules (B = 999, parametres de CAS) ----------------------
.ln125 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
.ln125i <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
.tri125 <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
# Capture des appels de .mc_p_values() (sim, obs, catalogue, e) par une
# copie de run_engine() dont l'environnement masque .mc_p_values() par une
# enveloppe qui appelle l'original : resultats inchanges, moteur non modifie.
env_moteur125 <- environment(run_engine)
.cap125 <- new.env(); .cap125$appels <- list()
env_cap125 <- new.env(parent = env_moteur125)
assign(".mc_p_values", function(sim, obs, catalogue, e = NULL) {
  r <- get(".mc_p_values", envir = env_moteur125)(sim, obs, catalogue, e)
  .cap125$appels[[length(.cap125$appels) + 1L]] <- list(sim = sim, obs = obs, catalogue = catalogue,
                                                        e = e, r = r)
  r
}, envir = env_cap125)
copie125 <- function(f) { environment(f) <- env_cap125; f }
for (nm in c("run_engine", ".run_engine_mw", "usp_bootstrap", "mw_bootstrap"))
  if (exists(nm, envir = env_moteur125, inherits = FALSE))
    assign(nm, copie125(get(nm, envir = env_moteur125)), envir = env_cap125)
run_cap125 <- get("run_engine", envir = env_cap125)
res_p <- run_cap125(xt = .ln125$xt, yt = .ln125$yt, methode = "premium", segment = 1, annexe = "II",
                    nature_donnees = "brutes")
res_pi <- run_cap125(xt = .ln125i$xt, yt = .ln125i$yt, methode = "premium", segment = 1, annexe = "II",
                     nature_donnees = "brutes")
res_r2 <- run_cap125(methode = "reserve2", triangle = .tri125, segment = 1, annexe = "II")
# Formule de la specification, section 1, recalculee independamment
# d'engine_p_mc() a partir des extremites du catalogue.
formule125 <- function(sim, q, ex) {
  s <- sim[is.finite(sim)]
  nh <- if (is.finite(ex[2])) sum(s >= ex[2] - TOL_DISPERSION_MC * max(1, abs(ex[2]))) else NA
  nb <- if (is.finite(ex[1])) sum(s <= ex[1] + TOL_DISPERSION_MC * max(1, abs(ex[1]))) else NA
  switch(q, haut = (1 + nh) / (length(s) + 1), bas = (1 + nb) / (length(s) + 1),
         deux = min(1, 2 * (1 + min(nh, nb)) / (length(s) + 1)))
}

verifier("U125-1 cas de reference : p_min_mc = formule de la section 1 recalculee depuis extremes (la garde C2 ne joue pas), sur chaque appel de .mc_p_values()",
         {
           ap <- .cap125$appels
           # un appel par bootstrap : premium, premium_interieur (V3b), reserve2
           ok <- vapply(ap, function(a) {
             disc <- names(Filter(function(x) !is.null(x$extremes), a$catalogue))
             all(vapply(disc, function(k) {
               attendu <- formule125(a$sim[, k], a$catalogue[[k]]$queue, a$catalogue[[k]]$extremes(a$e))
               identical(unname(a$r$p_min_mc[[k]]), attendu) && attendu <= a$r$p_mc[[k]]
             }, logical(1)))
           }, logical(1))
           length(ap) == 3L && all(ok) &&
             identical(ap[[1]]$r$p_min_mc, res_p$bootstrap$p_min_mc) &&
             identical(ap[[2]]$r$p_min_mc, res_pi$bootstrap$p_min_mc) &&
             identical(ap[[3]]$r$p_min_mc, res_r2$bootstrap$p_min_mc)
         })

## --- U125-6 : oracle premium_interieur -------------------------------------------
verifier("U125-6 premium_interieur : p_min_mc = 0,149 ; 0,058 ; 0,062 ; 0,007 ; 0,002 x 3 (comptes 148 ; 28 ; 30 ; 6 ; 0)",
         {
           b <- res_pi$bootstrap
           identical(b$p_mc_regime$variante, "V3b") &&
             all(b$B_effectif[STAT_DISCRETES_USP] == 999) &&
             isTRUE(proche(b$p_min_mc[["CoxStuart"]], (1 + 148) / 1000, rel = 1e-12)) &&
             isTRUE(proche(b$p_min_mc[["Runs"]], 2 * (1 + 28) / 1000, rel = 1e-12)) &&
             isTRUE(proche(b$p_min_mc[["Runsr"]], 2 * (1 + 30) / 1000, rel = 1e-12)) &&
             isTRUE(proche(b$p_min_mc[["Smirnov"]], (1 + 6) / 1000, rel = 1e-12)) &&
             all(vapply(c("MK", "SpearTps", "SpearVol"),
                        function(k) isTRUE(proche(b$p_min_mc[[k]], 2 / 1000, rel = 1e-12)), logical(1)))
         })
# Depuis #299, Smirnov et Spearman ratio / temps sont des diagnostics par
# decision : la branche Monte-Carlo de R1 (ligne de type test) ne s'y
# applique plus, leur champ p_min_mc vaut NA ; bootstrap$p_min_mc garde
# leurs planchers (U125-6 ci-dessus).
verifier("U125-6 premium_interieur : Cox-Stuart inoperant (prefixe Monte-Carlo) ; suites z et r 'ECHEC inatteignable' Monte-Carlo ; Smirnov, MK, Spearman sans texte de R1 (Smirnov, Spearman-temps : diagnostics, #299)",
         {
           tt <- res_pi$tests
           cs <- ligne125(tt, "Tendance par signes du ratio S/P")
           rz <- ligne125(tt, "Test des suites (aleatoire des signes)")
           rr <- ligne125(tt, "Test des suites sur ratios bruts")
           autres <- lapply(c("Tendance monotone du ratio S/P", "Independance ratio S/P vs volume"),
                            function(k) ligne125(tt, k))
           diag299 <- lapply(c("Egalite des lois petits vs gros volumes (2 ech.)",
                               "Correlation ratio S/P vs temps"), function(k) ligne125(tt, k))
           sans_r1 <- function(l) !grepl("TEST INOPERANT|ECHEC inatteignable|ECHEC possible|p_min", l$detail)
           isTRUE(cs$inoperant) && identical(cs$type, "diagnostic") &&
             startsWith(cs$detail, sprintf(PRE_MC, 0.1, " (m = 4 differences non nulles)")) &&
             all(vapply(list(rz, rr), function(l) identical(l$type, "test") &&
                          endsWith(l$detail, sprintf(SUF_MC, 0.05, " (n1 = 4, n2 = 4)")) &&
                          !grepl("ECHEC possible", l$detail, fixed = TRUE), logical(1))) &&
             all(vapply(autres, function(l) identical(l$type, "test") && sans_r1(l), logical(1))) &&
             all(vapply(diag299, function(l) identical(l$type, "diagnostic") && isFALSE(l$inoperant) &&
                          is.na(l$p_min_mc) && sans_r1(l), logical(1)))
         })

## --- U125-7 : reserve2 -------------------------------------------------------------
# Calendrier en queue basse depuis #276 (decision Q-Fd-1) : 0,002 -> 0,001.
# Depuis #312 (Q-D1-Fm-1 (B)), la ligne du test des suites est un diagnostic
# par decision, hors de la branche Monte-Carlo de R1 : son champ de ligne
# p_min_mc vaut NA (bootstrap$p_min_mc["Runs"] reste 0,002) ; cinq lignes
# portent un p_min_mc fini au lieu de six.
verifier("U125-7 reserve2 : p_min_mc = 0,002 (bilateral) et 0,001 (queue haute, queue basse de Calendrier, #276) pour les six statistiques discretes ; aucun texte de R1 ; ligne des suites (diagnostic, #312) a p_min_mc NA",
         {
           b <- res_r2$bootstrap
           pm <- b$p_min_mc
           all(b$B_effectif[STAT_DISCRETES_MW] == 999) &&
             identical(MW_CATALOGUE_MC$Calendrier$queue, "bas") &&
             all(vapply(c("CorrDev", "Runs"),
                        function(k) isTRUE(proche(pm[[k]], 2 / 1000, rel = 1e-12)), logical(1))) &&
             all(vapply(c("Calendrier", "HomogF", "ExpVar", "KruskalAcc"),
                        function(k) isTRUE(proche(pm[[k]], 1 / 1000, rel = 1e-12)), logical(1))) &&
             all(vapply(Filter(function(l) is.finite(l$p_min_mc), res_r2$tests), function(l)
               !grepl("TEST INOPERANT|ECHEC inatteignable|ECHEC possible|p_min", l$detail), logical(1))) &&
             sum(vapply(res_r2$tests, function(l) is.finite(l$p_min_mc), logical(1))) == 5L &&
             is.na(ligne125(res_r2$tests, "Test des suites sur les residus de Mack")$p_min_mc)
         })

## --- U125-2 : invariants granularite <= p_min_mc <= p_mc ---------------------------
inv125 <- function(b) {
  k <- names(b$p_min_mc)[is.finite(b$p_min_mc) & is.finite(b$p_mc[names(b$p_min_mc)])]
  length(k) > 0L && all(b$granularite_stat[k] <= b$p_min_mc[k] + 1e-15) &&
    all(b$p_min_mc[k] <= b$p_mc[k] + 1e-15)
}
xi125 <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi125 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
# Les quatre cas lognormaux premium, reserve1, premium_ii6 et premium_net
# partagent le meme bootstrap (memes xt, yt, B et graine ; usp_bootstrap() ne
# lit que l'ajustement) : res_p le represente.
verifier("U125-2 granularite_stat <= p_min_mc <= p_mc : cas de reference (premium, premium_interieur, reserve2) et J1, J2 a B = 99",
         {
           bJ1 <- usp_bootstrap(usp_ajuster(.ln125$xt, .ln125$yt), B = 99)
           bJ2 <- usp_bootstrap(usp_ajuster(xi125, yi125), B = 99)
           all(vapply(list(res_p$bootstrap, res_pi$bootstrap, res_r2$bootstrap, bJ1, bJ2), inv125, logical(1)))
         })

## --- U125-8 : champ de ligne et colonne de la table --------------------------------
verifier("U125-8 champ p_min_mc apres inoperant sur chaque ligne ; NA quand la p exacte est retenue (premium)",
         {
           ok_ordre <- all(vapply(c(res_p$tests, res_pi$tests, res_r2$tests), function(l)
             identical(utils::tail(names(l), 4), c("p_min", "fonction", "inoperant", "p_min_mc")), logical(1)))
           pex <- Filter(function(l) identical(l$nature_p, "exacte"), res_p$tests)
           ok_ordre && length(pex) > 0L && all(vapply(pex, function(l) is.na(l$p_min_mc), logical(1))) &&
             all(vapply(res_p$tests, function(l) is.na(l$p_min_mc), logical(1)))
         })
verifier("U125-8 engine_table_tests() : colonne p_min_mc juste apres p_min, alignee sur le champ ; NA pour un objet anterieur au champ",
         {
           tb <- engine_table_tests(res_pi)
           n <- names(tb)
           anc <- res_pi; anc$tests <- lapply(anc$tests, function(l) { l$p_min_mc <- NULL; l })
           match("p_min_mc", n) == match("p_min", n) + 1L &&
             identical(tb$p_min_mc, vapply(res_pi$tests, function(l) l$p_min_mc, numeric(1))) &&
             all(is.na(engine_table_tests(anc)$p_min_mc))
         })
verifier("U125-4 p exacte retenue : detail de Cox-Stuart de premium identique a la reference versionnee",
         {
           f <- file.path(RACINE, "tests", "reference", "premium.rds")
           nm <- "Tendance par signes du ratio S/P"
           file.exists(f) && identical(ligne125(res_p$tests, nm)$detail, ligne125(readRDS(f)$tests, nm)$detail) &&
             is.finite(ligne125(res_p$tests, nm)$p_exacte)
         })

## --- U125-9 : bootstrap$p_min_mc ---------------------------------------------------
verifier("U125-9 bootstrap$p_min_mc : dernier element, noms du catalogue, NA sur les statistiques continues",
         {
           ok <- function(b, cat_, disc) {
             identical(utils::tail(names(b), 1), "p_min_mc") && identical(names(b$p_min_mc), names(cat_)) &&
               all(is.na(b$p_min_mc[setdiff(names(cat_), disc)])) && all(is.finite(b$p_min_mc[disc]))
           }
           ok(res_p$bootstrap, USP_CATALOGUE_MC, STAT_DISCRETES_USP) &&
             ok(res_pi$bootstrap, USP_CATALOGUE_MC, STAT_DISCRETES_USP) &&
             ok(res_r2$bootstrap, MW_CATALOGUE_MC, STAT_DISCRETES_MW)
         })

## --- U125-5 : HomogF et ExpVar avec ex aequo ---------------------------------------
# Triangle d'essai : reserve2 dont F(1,0) = F(0,0) et F(2,1) = F(0,1)
# (meme construction que test_merz_wuthrich.R, #207) : colonnes 0 et 1 de
# HomogF avec ex aequo.
t125 <- .tri125
t125[2, 2] <- t125[2, 1] * t125[1, 2] / t125[1, 1]
t125[3, 3] <- t125[3, 2] * t125[1, 3] / t125[1, 2]
a125 <- mw_ajuster(t125)
hf125 <- mw_test_homogeneite_f(a125)
verifier("U125-5 HomogF avec ex aequo : X_max issu de la loi conditionnelle (p_j,min > 2/n_j! sur les colonnes a ex aequo)",
         {
           d <- hf125$detail
           F0 <- engine_aplatir_ex_aequo(t125[1:7, 2] / t125[1:7, 1], plancher = 0)
           pj0 <- .mw_spearman_loi_rangs(F0, 0:6)$p_min
           xm <- .mw_fisher_x_max(hf125)
           identical(d$ex_aequo, c(TRUE, TRUE, FALSE, FALSE)) &&
             identical(hf125$p_min_col[1], pj0) && pj0 > 2 / factorial(7) &&
             identical(hf125$p_min_col[3:4], 2 / factorial(c(5, 4))) &&
             is.na(xm[1]) && identical(xm[2], .fisher_combine(hf125$p_min_col)$stat) &&
             xm[2] < .fisher_combine(2 / factorial(d$n))$stat && hf125$stat <= xm[2]
         })
b125 <- mw_bootstrap(a125, B = 199)
verifier("U125-5 HomogF et ExpVar avec ex aequo : p_min_mc >= p_min ; bascule en test inoperant si p_min_mc >= alpha",
         {
           tt <- mw_tests(a125, b125, alpha = 0.10)
           l1 <- ligne125(tt, "Homogeneite de f_j entre annees de survenance")
           # alpha egal au plancher Monte-Carlo de HomogF : la regle R1 lue sur
           # p_min (6e-9) ne basculerait pas ; lue sur p_min_mc, elle bascule.
           a_inop <- unname(b125$p_min_mc[["HomogF"]])
           tt2 <- mw_tests(a125, b125, alpha = a_inop)
           l2 <- ligne125(tt2, "Homogeneite de f_j entre annees de survenance")
           l3 <- ligne125(tt, "Adequation de l'exposant de variance, colonne par colonne")
           is.finite(l1$p_min) && l1$p_min_mc >= l1$p_min && identical(l1$type, "test") &&
             is.finite(l3$p_min_mc) && l3$p_min_mc >= l3$p_min &&
             l2$p_min < a_inop && isTRUE(l2$inoperant) && identical(l2$type, "diagnostic") &&
             identical(l2$p_min_mc, a_inop) &&
             startsWith(l2$detail, sprintf(PRE_MC, a_inop, paste(
               " (colonnes n_j = 7, 6, 5, 4 ; ex aequo : loi de permutation conditionnelle",
               "aux rangs moyens, enumeree)")))
         })

verifier("#278 objet des ensembles figes : liste mal nommee ou vecteur refuses (contexte, mw_bootstrap(), mw_tests())",
         {
           mal <- list(j_degeneres = integer(0), j_non_identifiables = integer(0))
           leve_erreur(.mw_stats(a125, mal)) && leve_erreur(.mw_contexte_mc(a125, mal)) &&
             leve_erreur(.mw_stats(a125, 4L)) &&
             leve_erreur(mw_bootstrap(a125, B = 9, figes = mal)) &&
             leve_erreur(mw_tests(a125, b125, figes = mal)) &&
             identical(.mw_stats(a125), .mw_stats(a125, .mw_ensembles_figes(a125)))
         })

# Revue finale de #278, constat C1 : liste aux noms exacts mais a element
# invalide (NULL, NA, caractere, logique, non entier, negatif, hors 0..J-1,
# non fini) refusee par les trois appelants ; integer(0) et entiers portes
# par un double acceptes, a resultat identique.
verifier("#278 objet des ensembles figes : element NULL, NA, caractere, logique, non entier ou hors 0..J-1 refuse ; integer(0) accepte",
         {
           f0 <- .mw_ensembles_figes(a125)
           avec <- function(nm, v) { g <- f0; g[nm] <- list(v); g }
           nul <- list(degeneres = NULL, non_identifiables = NULL, origine_non_identifiables = NULL)
           mauvais <- list(avec("degeneres", NA_integer_), avec("non_identifiables", "1"),
                           avec("origine_non_identifiables", TRUE), avec("degeneres", 1.5),
                           avec("non_identifiables", -1L), avec("origine_non_identifiables", a125$J),
                           avec("degeneres", Inf), avec("non_identifiables", NULL), nul)
           msg <- tryCatch(.mw_contexte_mc(a125, avec("non_identifiables", NULL)),
                           error = function(e) conditionMessage(e))
           vide <- list(degeneres = integer(0), non_identifiables = integer(0),
                        origine_non_identifiables = integer(0))
           dbl <- lapply(f0, as.numeric)
           all(vapply(mauvais, function(g) leve_erreur(.mw_contexte_mc(a125, g)), logical(1))) &&
             leve_erreur(mw_bootstrap(a125, B = 9, figes = nul)) &&
             leve_erreur(mw_tests(a125, b125, figes = nul)) &&
             # borne J - 1 transmise par mw_bootstrap() et mw_tests() (aj$J)
             leve_erreur(mw_bootstrap(a125, B = 9, figes = avec("degeneres", a125$J))) &&
             leve_erreur(mw_tests(a125, b125, figes = avec("degeneres", a125$J))) &&
             grepl("element non_identifiables", msg, fixed = TRUE) &&
             !leve_erreur(.mw_stats(a125, vide)) &&
             !leve_erreur(.mw_verifier_figes(avec("degeneres", a125$J - 1L), "x", a125$J)) &&
             identical(.mw_stats(a125, dbl), .mw_stats(a125, f0))
         })

fin_fichier()
