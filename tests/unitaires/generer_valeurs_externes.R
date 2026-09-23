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
#    - ChainLadder: MackChainLadder, CDR (Merz & Wuthrich 2008), GenIns.
#  Valeurs inscrites dans les tests : R 4.3.1, lmtest 0.9-40, tseries 0.10-55,
#  car 3.1-2, ChainLadder 0.2.18 (versions affichees ci-dessous).
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/unitaires/generer_valeurs_externes.R
###############################################################################

suppressMessages({
  library(lmtest); library(tseries); library(car); library(ChainLadder)
})
for (p in c("lmtest", "tseries", "car", "ChainLadder"))
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
