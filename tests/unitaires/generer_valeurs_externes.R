###############################################################################
#  tests/unitaires/generer_valeurs_externes.R  --  PROVENANCE DES VALEURS
#  DE REFERENCE ISSUES DE PAQUETS R EXTERNES
#
#  Les tests unitaires n'ont aucune dependance hors R base + stats. Certaines
#  valeurs de reference y sont donc ecrites en dur ; ce script, qui n'est PAS
#  execute par le lanceur ni par la CI, permet de les recalculer avec des
#  implementations independantes du moteur :
#    - lmtest     : dwtest (loi exacte de Durbin-Watson, algorithme de Pan),
#                   resettest, bptest ;
#    - tseries    : jarque.bera.test (runs.test n'est pas utilise : la loi
#                   du test des suites est verifiee par enumeration
#                   exhaustive dans test_lois_exactes.R) ;
#    - car        : leveneTest (centre = mediane, i.e. Brown-Forsythe) ;
#    - ChainLadder: MackChainLadder, CDR (Merz & Wuthrich 2008), GenIns ;
#    - boot       : envelope (enveloppe globale de Davison et Hinkley 1997,
#                   eq. (4.17)), sur les statistiques d'ordre de
#                   bootstrap$z_boot des references premium et
#                   premium_interieur (test_enveloppe_qq.R, issue #385).
#  Valeurs inscrites dans les tests : R 4.3.1, lmtest 0.9-40, tseries 0.10-55,
#  car 3.1-2, ChainLadder 0.2.18 ; boot 1.3.30 sous R 4.3.3 (29/10/2026)
#  (versions affichees ci-dessous). Section "Trapezes I > J" (S6, #567) :
#  CL_MSEPs lue dans l'archive CRAN ChainLadder 0.2.21 (variable
#  CHAINLADDER_ARCHIVE, md5 controle), sans copie dans le depot ; elle n'a
#  besoin ni du paquet ChainLadder installe ni des autres paquets ci-dessous
#  (hors GenIns, fourni par ChainLadder) : sur un poste qui ne les a pas,
#  l'executer seule (20/11/2026).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/unitaires/generer_valeurs_externes.R
###############################################################################

suppressMessages({
  library(lmtest); library(tseries); library(car); library(ChainLadder); library(boot)
})
for (p in c("lmtest", "tseries", "car", "ChainLadder", "boot"))
  cat(p, as.character(utils::packageVersion(p)), "\n")
options(digits = 15)

# Vecteurs de residus fictifs utilises dans les tests (T = 8)
z1 <- c(0.52, -1.31, 0.87, 1.64, -0.23, -0.95, 0.31, -0.48)
z2 <- c(1.2, 1.5, 0.9, 0.4, -0.3, -0.8, -1.1, -1.6)
z3 <- c(1, -1, 1.2, -0.8, 0.9, -1.1, 1.05, -0.9)

cat("\n# Durbin-Watson, p bilaterale exacte (Pan), regression sur la constante\n")
for (z in list(z1, z2, z3))
  print(unname(lmtest::dwtest(z ~ 1, exact = TRUE, alternative = "two.sided")$p.value))

cat("\n# Jarque-Bera (tseries)\n")
for (z in list(z1, z2)) print(unname(tseries::jarque.bera.test(z)$statistic))

ln <- utils::read.csv("tests/donnees/donnees_ln.csv")
cat("\n# RESET, y ~ x - 1, puissances 2 et 3 des valeurs ajustees (lmtest)\n")
rt <- lmtest::resettest(yt ~ xt - 1, power = 2:3, type = "fitted", data = ln)
print(unname(c(rt$statistic, rt$p.value)))

cat("\n# Brown-Forsythe = Levene centre sur la mediane (car), z1 vs x > mediane\n")
g <- factor(ln$xt > stats::median(ln$xt))
lv <- car::leveneTest(z1, g, center = stats::median)
print(unname(c(lv[1, "F value"], lv[1, "Pr(>F)"])))

cat("\n# Breusch-Pagan sur residus centres u = z1 - mean(z1) (lmtest)\n")
u <- z1 - mean(z1)
print(unname(lmtest::bptest(u ~ 1, varformula = ~ ln$xt, studentize = TRUE)$statistic))
print(unname(lmtest::bptest(u ~ 1, varformula = ~ ln$xt, studentize = FALSE)$statistic))

cat("\n# Triangle de Taylor & Ashe (1983), jeu GenIns de ChainLadder\n")
dput(unname(matrix(as.numeric(GenIns), 10, 10)))
M <- ChainLadder::MackChainLadder(GenIns, est.sigma = "Mack")
cat("\n# f_j\n");        print(unname(M$f[1:9]))
cat("\n# sigma_j^2\n");  print(unname(M$sigma^2))
cat("\n# reserve totale (IBNR)\n"); print(sum(summary(M)$ByOrigin$IBNR))
cat("\n# erreur type a un an de Merz-Wuthrich (2008), total\n")
print(utils::tail(ChainLadder::CDR(M)[["CDR(1)S.E."]], 1))

cat("\n# Enveloppe globale du QQ-plot, boot::envelope(level = c(0.90, 0.90)) (#385)\n")
cat("# k.ov[1] = k ; $overall = (sim_haut, sim_bas) ; err.ov[2] x (B_eff + 1) / B_eff\n")
cat("# = taux_global_simultane de plots_data$qq_enveloppe\n")
for (cas in c("premium", "premium_interieur")) {
  zb <- readRDS(file.path("tests", "reference", paste0(cas, ".rds")))$bootstrap$z_boot
  S <- t(apply(zb[apply(is.finite(zb), 1, all), , drop = FALSE], 1, sort))
  ev <- boot::envelope(mat = S, level = c(0.90, 0.90))
  cat(cas, ": B_eff =", nrow(S), "\n")
  cat("k.ov :"); print(ev$k.ov)
  cat("err.ov :"); print(ev$err.ov)
  cat("err.ov[2] x (B_eff + 1) / B_eff :"); print(ev$err.ov[2] * (nrow(S) + 1) / nrow(S))
}

cat("\n# Trapezes I > J (#567) : MSEP a un an de CL_MSEPs, ChainLadder 0.2.21\n")
# Valeurs de tests/unitaires/test_merz_wuthrich_trapeze.R (critere C1 de la
# specification d'actuary 2a, par. 1.3). CL_MSEPs est une fonction interne de
# ChainLadder (fichier R/MWChainLadder.R, en-tete "Author: Mario Wuthrich"),
# qui somme sur les annees I-J+1..I (convention (B)) : implementation de
# l'auteur, non formule publiee. Elle est lue dans l'archive CRAN
# ChainLadder_0.2.21.tar.gz, de md5 fixe, dont le chemin est donne par la
# variable d'environnement CHAINLADDER_ARCHIVE (decision Q-2a-5 du
# mainteneur, 20/11/2026 : aucune copie du code dans le depot) ; section
# sautee sans elle. Parametres (f_j, sigma2_j de la regle de minimum,
# Q_j = sigma2_j / f_j^2, alpha_j = C(I-j,j) / S'_j) transcrits ici
# directement de D(4)(c) et D(5)(d)(ii), sans le moteur ; estimateur direct
# de sigma2_(J-1) : premiere ligne de D(5)(d)(ii) en j = J-1.
archive_cl <- Sys.getenv("CHAINLADDER_ARCHIVE")
MD5_ARCHIVE_CL <- "2a1fc0fcc593ec99529a40399274a088"
if (!nzchar(archive_cl)) {
  cat("CHAINLADDER_ARCHIVE non renseignee : section sautee.\n")
} else {
  stopifnot(file.exists(archive_cl),
            unname(tools::md5sum(archive_cl)) == MD5_ARCHIVE_CL)
  dossier_cl <- tempfile("cl")
  utils::untar(archive_cl, files = "ChainLadder/R/MWChainLadder.R", exdir = dossier_cl)
  src_cl <- readLines(file.path(dossier_cl, "ChainLadder", "R", "MWChainLadder.R"))
  env_cl <- new.env()
  eval(parse(text = src_cl[grep("^CL_MSEPs <- function", src_cl):
                             (grep("^CDR.MackChainLadder", src_cl) - 1L)]), envir = env_cl)
  ajuster_trapeze <- function(tri) {
    I <- nrow(tri) - 1; J <- ncol(tri) - 1
    f <- s2 <- numeric(J)
    for (j in 0:(J - 1)) { r <- 0:(I - j - 1)
      f[j + 1] <- sum(tri[r + 1, j + 2]) / sum(tri[r + 1, j + 1]) }
    for (j in 0:(J - 2)) { r <- 0:(I - j - 1)
      s2[j + 1] <- sum(tri[r + 1, j + 1] * (tri[r + 1, j + 2] / tri[r + 1, j + 1] - f[j + 1])^2) /
        (I - j - 1) }
    s2[J] <- min(s2[J - 1], s2[J - 2], s2[J - 1]^2 / s2[J - 2])
    r <- 0:(I - J)
    s2d <- sum(tri[r + 1, J] * (tri[r + 1, J + 1] / tri[r + 1, J] - f[J])^2) / (I - J)
    complet <- tri
    for (i in 0:I) { d <- I - i
      if (d < J) for (j in (d + 1):J) complet[i + 1, j + 1] <- complet[i + 1, j] * f[j] }
    Sp <- vapply(0:(J - 1), function(j) sum(tri[(0:(I - j)) + 1, j + 1]), numeric(1))
    alpha <- vapply(0:(J - 1), function(j) tri[I - j + 1, j + 1], numeric(1)) / Sp
    list(complet = complet, s2_regle = s2[J], s2_direct = s2d,
         param = data.frame(f = f, sigma2 = s2, ratio = s2 / f^2, alpha = alpha))
  }
  tri_mw <- local({
    df <- utils::read.csv("tests/donnees/triangle_mw.csv")
    m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"; unname(m)
  })
  gen <- unname(matrix(as.numeric(GenIns), 10, 10))
  jeux <- list("triangle_mw 8x7" = tri_mw[, 1:7], "triangle_mw 8x6" = tri_mw[, 1:6],
               "triangle_mw 8x5" = tri_mw[, 1:5], "GenIns 10x9" = gen[, 1:9],
               "GenIns 10x7" = gen[, 1:7], "GenIns 10x5" = gen[, 1:5])
  cat("# jeu : MSEP ; reserve ; sigma2_(J-1) regle ; sigma2_(J-1) direct\n")
  for (nm in names(jeux)) {
    tri <- jeux[[nm]]; a <- ajuster_trapeze(tri)
    r <- env_cl$CL_MSEPs(a$complet, nrow(tri), ncol(tri), a$param)
    cat(nm, ":", sprintf("%.15g", c(r[nrow(tri) + 1, 2], r[nrow(tri) + 1, 1],
                                    a$s2_regle, a$s2_direct)), "\n")
  }
}
