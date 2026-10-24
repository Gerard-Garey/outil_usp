## Mesures de la spécification D1-Fm : lecture conjointe DW / calendaire, QQ-plot et sensibilité de √MSEP (Q-D1-Fm-3)

> *Établi par la session principale (IA)* le 23/10/2026, en commit `docs:` préparatoire avant le code de Fm, sur décision du mainteneur (Q-D1-Fm-3, E-23/10 (D1-Fm), `docs/specifications/fm-merz-wuthrich-restitution.md`). Pièce versionnée que cite la spécification (§ 0, § 1.2, § 1.3, § 2, § 3) et dont `docwriter` tirera les chiffres de `mw:m3cal`, `mw:m3dw`, `mw:m3runs` et `mw:m6sig`.

**Origine.** Scripts écrits et exécutés par `actuary-approfondi` pendant la consultation D1-Fm du 23/10/2026 (lecture seule), sur le moteur `c63d609` (`R/engine.R`, md5 `be37ca83667e896d22d2ab123e905c9c`), R 4.3.3, `LC_ALL=C.UTF-8`, depuis la racine du dépôt. Ils sont reproduits ci-dessous à la lettre, avec leurs sorties ; les md5 sont ceux des fichiers exécutés. Pour rejouer un script : le copier dans un fichier hors du dépôt et lancer `LC_ALL=C.UTF-8 Rscript <fichier>` depuis la racine.

**Sources lues par les scripts** : `tests/reference/reserve2.rds` ; le brut versionné de #309, `docs/tableaux/20261021-issue309-puissance-mw-brut.tsv` (md5 `f616a3bc2e9a0cb6ce255396b0130ba0`, contrôlé par `m_fm_b`). `m_fm_c` tire des triangles sous le modèle de Mack ajusté, graine explicite 20261023 (Mersenne-Twister, Inversion, Rejection) ; aucun autre script ne tire.

**Statut.** Constats de simulation sous un plan (`reserve2` et les plans P1 à P3 de #309), à T = 8 ; aucun théorème. Les DW centrés par diagonale ou par année de survenance sont des grandeurs de la spécification, hors moteur.

| Script (md5) | Objet | Sortie (md5) |
|---|---|---|
| `m_fm_a.R` (`555604552b9c0d883c8322772fd4d9ff`) | résidus de `reserve2` : moyennes par groupe, DW centrés, pentes du QQ (§ 1.2, 1.3, 2.1) | `m_fm_a.txt` (`11f082b229297315316bced2323f5b0b`) |
| `m_fm_b.R` (`5d933df7b282a29a52ef0ad145ba90db`) | lecture conjointe DW / calendaire / suites sur le brut de #309 (§ 1.3) | `m_fm_b.txt` (`cb90a607ac2d3f3f7b2e0725d2bcd37c`) |
| `m_fm_c.R` (`a51d83a274c564d97203c3b15fdda63f`) | simulation sous le modèle de Mack ajusté à `reserve2` : pentes, statistiques d'ordre, enveloppe, puissance (§ 2.1, 2.2) | `m_fm_c.txt` (`272529671ee73ddacd467dbc9b2b09aa`) |
| `m_fm_d.R` (`2357d6bac59a73934d80fd8fb95de864`) | sensibilité de √MSEP (#310), prototype hors moteur de T-4, leviers (§ 3) | `m_fm_d.txt` (`eb5b993037179c1c487bedc99718d994`) |

### `m_fm_a` — résidus de `reserve2` : moyennes par groupe, DW centrés, pentes du QQ (§ 1.2, 1.3, 2.1)

```r
# D1-Fm, mesure A (#312, #311) : residus de reserve2, moyennes par groupe,
# DW, pentes de QQ. Lecture seule. Usage (depuis la racine du depot) :
#   LC_ALL=C.UTF-8 Rscript <scratchpad>/fm/m_fm_a.R
suppressMessages(source("R/engine.R"))
ref <- readRDS("tests/reference/reserve2.rds")
aj <- mw_ajuster(ref$ajustement$tri)
stopifnot(identical(aj$sigma2, ref$ajustement$sigma2))
res <- mw_residus(aj); r <- res$residu; N <- length(r)
cat("N =", N, "; colonnes :", paste(table(res$j), collapse = " "), "\n")
nj <- as.numeric(table(res$j))
cat(sprintf("sum r^2 = %.12f ; sum(n_j - 1) = %d\n", sum(r^2), sum(nj - 1)))
cat(sprintf("var(r) = %.6f ; sum(n_j-1)/(N-1) = %.6f ; mean(r) = %.6f\n", var(r), sum(nj-1)/(N-1), mean(r)))
umh <- .mw_un_moins_h(aj, res); rt <- r / sqrt(umh)
cat(sprintf("redresses : var = %.6f ; mean = %.6f ; |rt| des colonnes n_j = 2 : %s\n",
            var(rt), mean(rt), paste(format(abs(rt[res$j == 5]), digits = 15), collapse = " ")))
pente_q <- function(z) { qy <- quantile(z, c(.25,.75)); diff(qy)/diff(qnorm(c(.25,.75))) }
cat(sprintf("pente par quartiles : r = %.4f ; rt = %.4f ; ref plots_data identique a qqnorm(r) : %s\n",
            pente_q(r), pente_q(rt),
            identical(ref$plots_data$qqnorm$empirique, stats::qqnorm(r, plot.it = FALSE)$y)))
# Moyennes par groupe
g <- function(v, k) { t <- tapply(v, k, mean); n <- tapply(v, k, length); data.frame(k = as.integer(names(t)), n = as.integer(n), moyenne = as.numeric(t), mediane = as.numeric(tapply(v, k, median))) }
cat("Par diagonale calendaire (k = i + j) :\n"); print(g(r, res$calendrier), digits = 4, row.names = FALSE)
cat("Par annee d'accident i :\n"); print(g(r, res$i), digits = 4, row.names = FALSE)
cat("Coherence des diagonales avec mw_calendrier_diagonales() : ")
cdg <- mw_calendrier_diagonales(mw_test_annees_calendaires(aj)); print(cdg[, c("k","n","L","S","Z","p_diag","repere")], row.names = FALSE)
# DW et DW apres retrait des moyennes de diagonale
dw <- stat_dw(r)
rc <- r - ave(r, res$calendrier)
cat(sprintf("DW(r) = %.4f ; DW(r - moyenne de diagonale) = %.4f ; DW(r - moyenne d'annee d'accident) = %.4f\n",
            dw, stat_dw(rc), stat_dw(r - ave(r, res$i))))
tb <- engine_table_tests(ref)
for (nm in c("Autocorrelation des residus (Durbin-Watson)", "Effets d'annee calendaire (test de Mack)",
             "Test des suites sur les residus de Mack"))
  with(tb[tb$test == nm, ], cat(sprintf("%s : stat %.4f, p_mc %.3f, verdict %s, p_min %s\n", nm, statistique, p_monte_carlo, verdict, format(p_min))))
```

Sortie :

```
N = 27 ; colonnes : 7 6 5 4 3 2 
sum r^2 = 21.000000000000 ; sum(n_j - 1) = 21
var(r) = 0.807455 ; sum(n_j-1)/(N-1) = 0.807692 ; mean(r) = -0.015125
redresses : var = 1.035960 ; mean = -0.014034 ; |rt| des colonnes n_j = 2 : 1 1
pente par quartiles : r = 1.1590 ; rt = 1.4155 ; ref plots_data identique a qqnorm(r) : TRUE
Par diagonale calendaire (k = i + j) :
 k n  moyenne mediane
 0 1  0.10811  0.1081
 1 2 -1.03213 -1.0321
 2 3 -1.35373 -1.3745
 3 4 -0.70681 -0.5330
 4 5  0.49849  0.5906
 5 6  1.06507  1.0524
 6 6 -0.07445  0.1015
Par annee d'accident i :
 k n moyenne mediane
 0 6 -0.5047 -0.5295
 1 6 -0.3665 -0.6498
 2 5 -0.2242 -0.4140
 3 4  0.3175  0.3402
 4 3  0.7853  0.8373
 5 2  0.9015  0.9015
 6 1  0.5111  0.5111
Coherence des diagonales avec mw_calendrier_diagonales() :  k n L S Z  p_diag repere
 1 2 0 2 0 0.50000  FALSE
 2 3 0 3 0 0.25000  FALSE
 3 4 0 4 0 0.12500  FALSE
 4 4 4 0 0 0.12500  FALSE
 5 6 6 0 0 0.03125   TRUE
 6 5 2 3 2 1.00000  FALSE
DW(r) = 1.6195 ; DW(r - moyenne de diagonale) = 1.3074 ; DW(r - moyenne d'annee d'accident) = 1.8572
Autocorrelation des residus (Durbin-Watson) : stat 1.6195, p_mc 0.032, verdict ECHEC, p_min NA
Effets d'annee calendaire (test de Mack) : stat -3.5406, p_mc 0.002, verdict ECHEC, p_min 3.814697e-06
Test des suites sur les residus de Mack : stat -0.4003, p_mc 0.374, verdict OK, p_min 3.845932e-07
```

### `m_fm_b` — lecture conjointe DW / calendaire / suites sur le brut de #309 (§ 1.3)

```r
# D1-Fm, mesure B (#312) : lecture conjointe DW / Calendrier / Runs / KruskalAcc
# sur le brut versionne de #309 (md5 f616a3bc2e9a0cb6ce255396b0130ba0).
# Usage : LC_ALL=C.UTF-8 Rscript <scratchpad>/fm/m_fm_b.R
f <- "docs/tableaux/20261021-issue309-puissance-mw-brut.tsv"
cat("md5 :", tools::md5sum(f), "\n")
d <- read.delim(f, stringsAsFactors = FALSE, na.strings = c("NA", "-"))
d <- d[d$type == "rep" & d$statut == "admis", ]
cat("cles :", paste(unique(d$cle), collapse = " "), "\n")
k <- c("Calendrier", "DW", "Runs", "KruskalAcc", "HomogF")
for (cl in c("B-P1.H0", "B-P2.H0", "B-P3.H0", "B-P1.DCAL", "B-P1.DFI", "B-P1.CAL7", "B-P1.CAL4", "B-P2.CST20")) {
  s <- d[d$cle == cl, ]; if (!nrow(s)) { cat(cl, ": absent\n"); next }
  p <- sapply(k, function(x) s[[paste0("p.", x)]])
  rj <- p < 0.10
  cat(sprintf("%-12s R = %4d | rejets 0,10 : Cal %.3f DW %.3f Runs %.3f KW %.3f HomogF %.3f | Cal&DW %.3f (indep. %.3f) ; P(DW|Cal) %.3f ; P(Cal|DW) %.3f ; Runs&DW %.3f, Runs sans DW %.3f | rho_S(p_Cal,p_DW) %.3f rho_S(p_Runs,p_DW) %.3f rho_S(p_KW,p_DW) %.3f\n",
    cl, nrow(s), mean(rj[,1]), mean(rj[,2]), mean(rj[,3]), mean(rj[,4]), mean(rj[,5]),
    mean(rj[,1] & rj[,2]), mean(rj[,1]) * mean(rj[,2]),
    mean(rj[rj[,1],2]), mean(rj[rj[,2],1]), mean(rj[,3] & rj[,2]), mean(rj[,3] & !rj[,2]),
    cor(p[,1], p[,2], method = "spearman"), cor(p[,3], p[,2], method = "spearman"),
    cor(p[,4], p[,2], method = "spearman")))
}
```

Sortie :

```
md5 : f616a3bc2e9a0cb6ce255396b0130ba0 
cles : A-A A-E A-N B-P1.CAL4 B-P1.CAL7 B-P1.CEL4 B-P1.CEL6 B-P1.CELx4 B-P1.CST10 B-P1.CST20 B-P1.DCAL B-P1.DFI B-P1.EXP0 B-P1.EXP2 B-P1.H0 B-P1.LIG B-P2.CST10 B-P2.CST20 B-P2.DFI B-P2.EXP0 B-P2.EXP2 B-P2.H0 B-P3.CST20 B-P3.DFI B-P3.H0 
B-P1.H0      R = 1000 | rejets 0,10 : Cal 0.100 DW 0.112 Runs 0.047 KW 0.098 HomogF 0.106 | Cal&DW 0.013 (indep. 0.011) ; P(DW|Cal) 0.130 ; P(Cal|DW) 0.116 ; Runs&DW 0.028, Runs sans DW 0.019 | rho_S(p_Cal,p_DW) -0.002 rho_S(p_Runs,p_DW) 0.398 rho_S(p_KW,p_DW) 0.006
B-P2.H0      R = 1000 | rejets 0,10 : Cal 0.097 DW 0.084 Runs 0.047 KW 0.099 HomogF 0.101 | Cal&DW 0.010 (indep. 0.008) ; P(DW|Cal) 0.103 ; P(Cal|DW) 0.119 ; Runs&DW 0.020, Runs sans DW 0.027 | rho_S(p_Cal,p_DW) 0.019 rho_S(p_Runs,p_DW) 0.391 rho_S(p_KW,p_DW) -0.022
B-P3.H0      R = 1000 | rejets 0,10 : Cal 0.086 DW 0.081 Runs 0.042 KW 0.101 HomogF 0.064 | Cal&DW 0.008 (indep. 0.007) ; P(DW|Cal) 0.093 ; P(Cal|DW) 0.099 ; Runs&DW 0.023, Runs sans DW 0.019 | rho_S(p_Cal,p_DW) 0.004 rho_S(p_Runs,p_DW) 0.372 rho_S(p_KW,p_DW) -0.003
B-P1.DCAL    R =  500 | rejets 0,10 : Cal 0.216 DW 0.204 Runs 0.126 KW 0.350 HomogF 0.550 | Cal&DW 0.042 (indep. 0.044) ; P(DW|Cal) 0.194 ; P(Cal|DW) 0.206 ; Runs&DW 0.080, Runs sans DW 0.046 | rho_S(p_Cal,p_DW) 0.079 rho_S(p_Runs,p_DW) 0.546 rho_S(p_KW,p_DW) 0.039
B-P1.DFI     R =  500 | rejets 0,10 : Cal 0.126 DW 0.104 Runs 0.050 KW 0.166 HomogF 0.214 | Cal&DW 0.014 (indep. 0.013) ; P(DW|Cal) 0.111 ; P(Cal|DW) 0.135 ; Runs&DW 0.022, Runs sans DW 0.028 | rho_S(p_Cal,p_DW) -0.000 rho_S(p_Runs,p_DW) 0.445 rho_S(p_KW,p_DW) -0.053
B-P1.CAL7    R =  500 | rejets 0,10 : Cal 0.380 DW 0.068 Runs 0.046 KW 0.092 HomogF 0.198 | Cal&DW 0.038 (indep. 0.026) ; P(DW|Cal) 0.100 ; P(Cal|DW) 0.559 ; Runs&DW 0.020, Runs sans DW 0.026 | rho_S(p_Cal,p_DW) -0.012 rho_S(p_Runs,p_DW) 0.289 rho_S(p_KW,p_DW) -0.005
B-P1.CAL4    R =  500 | rejets 0,10 : Cal 0.344 DW 0.122 Runs 0.046 KW 0.026 HomogF 0.026 | Cal&DW 0.048 (indep. 0.042) ; P(DW|Cal) 0.140 ; P(Cal|DW) 0.393 ; Runs&DW 0.018, Runs sans DW 0.028 | rho_S(p_Cal,p_DW) -0.075 rho_S(p_Runs,p_DW) 0.100 rho_S(p_KW,p_DW) -0.178
B-P2.CST20   R = 1000 | rejets 0,10 : Cal 0.879 DW 0.432 Runs 0.159 KW 0.999 HomogF 1.000 | Cal&DW 0.404 (indep. 0.380) ; P(DW|Cal) 0.460 ; P(Cal|DW) 0.935 ; Runs&DW 0.120, Runs sans DW 0.039 | rho_S(p_Cal,p_DW) 0.220 rho_S(p_Runs,p_DW) 0.470 rho_S(p_KW,p_DW) 0.008
```

### `m_fm_c` — simulation sous le modèle de Mack ajusté à `reserve2` : pentes, statistiques d'ordre, enveloppe, puissance (§ 2.1, 2.2)

```r
# D1-Fm, mesure C (#311, #312) : simulation sous le modele de Mack ajuste a
# reserve2, erreurs gaussiennes (et alternatives), premiere colonne fixee.
# Residus de Mack r, redresses rt = r / sqrt(1 - h). Enveloppe ponctuelle et
# simultanee par engine_enveloppe_qq() (meme algorithme que le module
# lognormal), construite sur M0 = 999 triangles H0, evaluee sur R triangles
# independants par loi d'erreurs. DW et DW centre (diagonale, annee).
# Usage : LC_ALL=C.UTF-8 Rscript <scratchpad>/fm/m_fm_c.R
suppressMessages(source("R/engine.R"))
ref <- readRDS("tests/reference/reserve2.rds")
aj <- mw_ajuster(ref$ajustement$tri)
I <- aj$I; J <- aj$J; f <- aj$f; s <- sqrt(aj$sigma2); C0 <- aj$tri[, 1]
# Generateur d'erreurs de variance 1
eps <- list(
  N   = function(n) rnorm(n),
  t3  = function(n) rt(n, 3) / sqrt(3),
  Exp = function(n) rexp(n) - 1,
  LN1 = function(n) (exp(rnorm(n)) - exp(0.5)) / sqrt((exp(1) - 1) * exp(1)))
sim_tri <- function(gen, cel = NULL) {
  tri <- matrix(NA_real_, I + 1, J + 1); tri[, 1] <- C0
  for (j in 0:(J - 1)) {
    ii <- 0:(I - j - 1); C <- tri[ii + 1, j + 1]; e <- gen(length(ii))
    if (!is.null(cel) && cel[2] == j) e[cel[1] + 1] <- e[cel[1] + 1] + cel[3]
    tri[ii + 1, j + 2] <- f[j + 1] * C + s[j + 1] * sqrt(C) * e
  }
  tri
}
resid <- function(tri) {
  out <- NULL
  for (j in 0:(J - 2)) {                       # colonnes n_j >= 2
    ii <- 0:(I - j - 1); C <- tri[ii + 1, j + 1]; C1 <- tri[ii + 1, j + 2]
    if (any(!is.finite(C)) || any(C <= 0) || any(!is.finite(C1))) return(NULL)
    fj <- sum(C1) / sum(C); s2 <- sum(C * (C1 / C - fj)^2) / (length(ii) - 1)
    r <- sqrt(C) * (C1 / C - fj) / sqrt(s2); h <- C / sum(C)
    out <- rbind(out, data.frame(i = ii, j = j, k = ii + j, r = r, rt = r / sqrt(1 - h)))
  }
  out
}
# Controle : resid() sur reserve2 = mw_residus()
r0 <- resid(aj$tri); mr <- mw_residus(aj)
cat(sprintf("controle resid() vs mw_residus() : ecart max %.2e ; rt vs .mw_un_moins_h : %.2e\n",
            max(abs(r0$r - mr$residu)), max(abs(r0$rt - mr$residu / sqrt(.mw_un_moins_h(aj, mr))))))
N <- nrow(r0); pq <- qnorm(ppoints(N))
pente_q <- function(z) { qy <- quantile(z, c(.25,.75)); unname(diff(qy)/diff(qnorm(c(.25,.75)))) }
pente_mc <- function(z) unname(coef(lm(sort(z) ~ pq))[2])
tirer <- function(R, gen, cel = NULL) {
  M <- list(r = matrix(NA, R, N), rt = matrix(NA, R, N)); dw <- matrix(NA, R, 3); b <- 0
  while (b < R) { x <- resid(sim_tri(gen, cel)); if (is.null(x)) next; b <- b + 1
    M$r[b, ] <- x$r; M$rt[b, ] <- x$rt
    dw[b, ] <- c(stat_dw(x$r), stat_dw(x$r - ave(x$r, x$k)), stat_dw(x$r - ave(x$r, x$i))) }
  list(M = M, dw = dw)
}
set.seed(20261023, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
H0 <- tirer(999, eps$N)
cat("\n== Sous H0 (gaussien), M0 = 999 ==\n")
for (v in c("r", "rt")) {
  Z <- H0$M[[v]]
  cat(sprintf("%-2s : var moyenne %.4f ; pente quartiles moyenne %.3f [q05 %.3f ; q95 %.3f] ; pente MC (lm sur quantiles normaux) moyenne %.3f [%.3f ; %.3f]\n",
    v, mean(apply(Z, 1, var)), mean(apply(Z, 1, pente_q)), quantile(apply(Z, 1, pente_q), .05), quantile(apply(Z, 1, pente_q), .95),
    mean(apply(Z, 1, pente_mc)), quantile(apply(Z, 1, pente_mc), .05), quantile(apply(Z, 1, pente_mc), .95)))
  S <- t(apply(Z, 1, sort)); es <- colMeans(S)
  cat(sprintf("   E[statistiques d'ordre] - quantile N(0,1), rangs 1, 2, 7, 14, 21, 26, 27 : %s\n",
    paste(sprintf("%+.3f", (es - pq)[c(1,2,7,14,21,26,27)]), collapse = " ")))
}
cat(sprintf("reserve2 : pente MC r %.3f, rt %.3f\n", pente_mc(r0$r), pente_mc(r0$rt)))
cat(sprintf("DW sous H0 : moyenne %.3f ; DW centre diagonale %.3f ; centre annee %.3f\n", mean(H0$dw[,1]), mean(H0$dw[,2]), mean(H0$dw[,3])))
dwo <- c(stat_dw(r0$r), stat_dw(r0$r - ave(r0$r, r0$k)), stat_dw(r0$r - ave(r0$r, r0$i)))
cat(sprintf("reserve2 : DW %.3f (P_H0(DW <= obs) = %.3f) ; centre diagonale %.3f (%.3f) ; centre annee %.3f (%.3f)\n",
  dwo[1], mean(H0$dw[,1] <= dwo[1]), dwo[2], mean(H0$dw[,2] <= dwo[2]), dwo[3], mean(H0$dw[,3] <= dwo[3])))
# Enveloppes sur H0, puis taux de sortie sur triangles independants
env <- lapply(c(r = "r", rt = "rt"), function(v) engine_enveloppe_qq(H0$M[[v]], N))
for (v in c("r", "rt")) cat(sprintf("enveloppe %s : k* = %d, taux in-sample simultane %.3f, ponctuel %.3f ; largeur simultanee rang 1 / 14 / 27 : %.2f / %.2f / %.2f\n",
  v, env[[v]]$info$k, env[[v]]$info$taux_global_simultane, env[[v]]$info$taux_global_ponctuel,
  diff(env[[v]]$bandes[1, 3:4]), diff(env[[v]]$bandes[14, 3:4]), diff(env[[v]]$bandes[27, 3:4])))
sortie <- function(Z, e) { S <- t(apply(Z, 1, sort)); b <- e$bandes
  c(sim = mean(rowSums(S < rep(b[,3], each = nrow(S)) | S > rep(b[,4], each = nrow(S))) > 0),
    ponct = mean(rowSums(S < rep(b[,1], each = nrow(S)) | S > rep(b[,2], each = nrow(S))) > 0)) }
for (v in c("r", "rt")) {
  S0 <- t(apply(rbind(r0[[v]]), 1, sort)); b <- env[[v]]$bandes
  cat(sprintf("reserve2, %s : points hors bande simultanee %d, hors ponctuelle %d\n", v,
    sum(S0 < b[,3] | S0 > b[,4]), sum(S0 < b[,1] | S0 > b[,2])))
}
R <- 2000
cat("\n== Taux de sortie (au moins un point) sur R = 2000 triangles independants ==\n")
alts <- list(H0 = list(eps$N, NULL), t3 = list(eps$t3, NULL), Exp = list(eps$Exp, NULL),
             LN1 = list(eps$LN1, NULL), CEL_4sd = list(eps$N, c(2, 1, 4)), CEL_6sd = list(eps$N, c(2, 1, 6)))
for (a in names(alts)) {
  X <- tirer(R, alts[[a]][[1]], alts[[a]][[2]])
  tr <- sortie(X$M$r, env$r); tt <- sortie(X$M$rt, env$rt)
  ic <- function(p) sprintf("[%.3f ; %.3f]", qbeta(.025, p*R, R - p*R + 1), qbeta(.975, p*R + 1, R - p*R))
  cat(sprintf("%-8s r : simultanee %.3f %s, ponctuelle %.3f | rt : simultanee %.3f %s, ponctuelle %.3f\n",
    a, tr[1], ic(tr[1]), tr[2], tt[1], ic(tt[1]), tt[2]))
}
```

Sortie :

```
controle resid() vs mw_residus() : ecart max 9.77e-15 ; rt vs .mw_un_moins_h : 1.20e-14

== Sous H0 (gaussien), M0 = 999 ==
r  : var moyenne 0.8077 ; pente quartiles moyenne 1.030 [q05 0.855 ; q95 1.185] ; pente MC (lm sur quantiles normaux) moyenne 0.884 [0.867 ; 0.896]
   E[statistiques d'ordre] - quantile N(0,1), rangs 1, 2, 7, 14, 21, 26, 27 : +0.499 +0.232 -0.032 -0.002 +0.033 -0.223 -0.491
rt : var moyenne 1.0384 ; pente quartiles moyenne 1.231 [q05 0.992 ; q95 1.419] ; pente MC (lm sur quantiles normaux) moyenne 1.000 [0.981 ; 1.014]
   E[statistiques d'ordre] - quantile N(0,1), rangs 1, 2, 7, 14, 21, 26, 27 : +0.342 +0.075 -0.189 -0.003 +0.194 -0.066 -0.333
reserve2 : pente MC r 0.877, rt 0.989
DW sous H0 : moyenne 2.351 ; DW centre diagonale 2.351 ; centre annee 2.336
reserve2 : DW 1.620 (P_H0(DW <= obs) = 0.016) ; centre diagonale 1.307 (0.000) ; centre annee 1.857 (0.085)
enveloppe r : k* = 3, taux in-sample simultane 0.079, ponctuel 0.783 ; largeur simultanee rang 1 / 14 / 27 : 1.02 / 0.83 / 1.04
enveloppe rt : k* = 3, taux in-sample simultane 0.081, ponctuel 0.765 ; largeur simultanee rang 1 / 14 / 27 : 1.05 / 0.97 / 1.06
reserve2, r : points hors bande simultanee 0, hors ponctuelle 1
reserve2, rt : points hors bande simultanee 0, hors ponctuelle 3

== Taux de sortie (au moins un point) sur R = 2000 triangles independants ==
H0       r : simultanee 0.099 [0.086 ; 0.112], ponctuelle 0.762 | rt : simultanee 0.103 [0.090 ; 0.118], ponctuelle 0.761
t3       r : simultanee 0.202 [0.185 ; 0.220], ponctuelle 0.828 | rt : simultanee 0.215 [0.198 ; 0.234], ponctuelle 0.824
Exp      r : simultanee 0.555 [0.533 ; 0.577], ponctuelle 0.958 | rt : simultanee 0.582 [0.560 ; 0.603], ponctuelle 0.955
LN1      r : simultanee 0.692 [0.671 ; 0.712], ponctuelle 0.981 | rt : simultanee 0.702 [0.681 ; 0.722], ponctuelle 0.983
CEL_4sd  r : simultanee 0.143 [0.128 ; 0.160], ponctuelle 0.829 | rt : simultanee 0.156 [0.140 ; 0.173], ponctuelle 0.826
CEL_6sd  r : simultanee 0.228 [0.210 ; 0.247], ponctuelle 0.902 | rt : simultanee 0.226 [0.207 ; 0.244], ponctuelle 0.904
```

### `m_fm_d` — sensibilité de √MSEP (#310), prototype hors moteur de T-4, leviers (§ 3)

```r
# D1-Fm, mesure D (#310, #311) : sensibilite de racine(MSEP) aux arguments du
# minimum de D(5)(d)(ii) ; prototype HORS MOTEUR du texte T-4 sur reserve2 ;
# leviers et borne des residus redresses. Lecture seule.
# Usage : LC_ALL=C.UTF-8 Rscript <scratchpad>/fm/m_fm_d.R
suppressMessages(source("R/engine.R"))
ref <- readRDS("tests/reference/reserve2.rds")
aj <- mw_ajuster(ref$ajustement$tri); J <- aj$J
ex <- mw_extrapolation_sigma2(aj)
msep_avec <- function(v) { a <- aj; a$sigma2[J] <- v; a$Q[J] <- v / a$f[J]^2; sqrt(mw_msep(a)$msep) }
regle <- sqrt(mw_msep(aj)$msep)
cat(sprintf("controle : msep_avec(regle) identique a mw_msep(aj) : %s ; sqrt(MSEP) ref %.6f, recalcule %.6f\n",
            identical(msep_avec(aj$sigma2[J]), regle), sqrt(ref$msep$msep), regle))
args <- c(ex$sigma2_Jm2, ex$sigma2_Jm3, ex$quotient)
rm <- vapply(args, function(v) if (is.na(v)) NA_real_ else msep_avec(v), numeric(1)); r0 <- msep_avec(0)
R <- aj$reserve
print(data.frame(arg = c("Jm2", "Jm3", "quotient", "zero"), sigma2 = c(args, 0), racine_msep = c(rm, r0),
                 ecart = c(rm, r0) / regle - 1, sigma_estime = c(rm, r0) / R), digits = 7)
cat(sprintf("regle %.6f ; reserve %.6f ; sigma_estime %.8f ; sigma_usp ref %.8f\n", regle, R, regle / R,
            ref$parametre$sigma_usp))
# Prototype du texte T-4 (phrase de sensibilite), meme formatage que le detail existant
noms <- c("sigma2_(J-2)", "sigma2_(J-3)", "sigma2_(J-2)^2/sigma2_(J-3)")
morceaux <- vapply(1:3, function(k) if (is.na(rm[k])) sprintf("avec %s : non defini", noms[k]) else
  sprintf("avec %s : %s (%+.1f %%)", noms[k], format(rm[k], digits = 6), 100 * (rm[k] / regle - 1)), character(1))
phrase <- paste0("Sensibilite indicative, hors regle et sans effet sur sigma_USP, de la racine de la MSEP (",
                 format(regle, digits = 6), " avec la valeur fixee par la regle) a la valeur de sigma2_(J-1) : ",
                 paste(morceaux, collapse = " ; "), ".")
contre <- if (isTRUE(aj$sigma2[J] > 0)) sprintf(paste0(
  "Sans variance sur la derniere annee de developpement (sigma2_(J-1) = 0, contrefactuel qui n'est pas ",
  "un argument du minimum) : %s (%+.1f %%)."), format(r0, digits = 6), 100 * (r0 / regle - 1)) else ""
base <- paste("Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), seconde ligne,",
              "et non estimee : la derniere annee de developpement n'a qu'un facteur individuel,",
              "sans degre de liberte ; la regle ne lit que les deux dernieres variances estimees")
d_old <- .mw_detail_extrapolation(ex)
d_new <- paste(sub("^Valeur non estimee mais extrapolee par la regle min\\(\\.\\.\\.\\) du reglement : elle ne repose que sur les dernieres colonnes estimees", base, d_old),
               ".", phrase, contre)
d_new <- sub(" \\. ", ". ", d_new)
cat("\nDETAIL PROTOTYPE (T-4) sur reserve2 :\n", d_new, "\n\n", sep = "")
# Leviers, facteur de redressement, borne |rt| <= sqrt(n_j - 1)
res <- mw_residus(aj); umh <- .mw_un_moins_h(aj, res); rt <- res$residu / sqrt(umh)
cat(sprintf("1/sqrt(1-h) : min %.4f max %.4f\n", min(1/sqrt(umh)), max(1/sqrt(umh))))
nj <- ave(res$j, res$j, FUN = length)
cat(sprintf("max |rt| / sqrt(n_j - 1) = %.6f (<= 1 attendu, algebre)\n", max(abs(rt) / sqrt(nj - 1))))
print(aggregate(cbind(max_abs_rt = abs(rt), borne = sqrt(nj - 1)) ~ res$j, FUN = max), digits = 4)
cat(sprintf("quantile N(0,1) des rangs extremes (ppoints(27)) : %.3f\n", qnorm(ppoints(27))[27]))
```

Sortie :

```
controle : msep_avec(regle) identique a mw_msep(aj) : TRUE ; sqrt(MSEP) ref 199.494435, recalcule 199.494435
       arg     sigma2 racine_msep      ecart sigma_estime
1      Jm2 0.18967366    226.4131  0.1349343   0.02476939
2      Jm3 0.09732476    199.4944  0.0000000   0.02182451
3 quotient 0.36965001    271.3051  0.3599631   0.02968053
4     zero 0.00000000    166.4795 -0.1654928   0.01821271
regle 199.494435 ; reserve 9140.843438 ; sigma_estime 0.02182451 ; sigma_usp ref 0.04977646

DETAIL PROTOTYPE (T-4) sur reserve2 :
Valeur fixee par la regle de minimum de l'annexe XVII, D(5)(d)(ii), seconde ligne, et non estimee : la derniere annee de developpement n'a qu'un facteur individuel, sans degre de liberte ; la regle ne lit que les deux dernieres variances estimees. min(sigma2_(J-2) = 0.189674 ; sigma2_(J-3) = 0.0973248 ; sigma2_(J-2)^2/sigma2_(J-3) = 0.36965) = 0.0973248, minimum atteint par sigma2_(J-3). Sensibilite indicative, hors regle et sans effet sur sigma_USP, de la racine de la MSEP (199.494 avec la valeur fixee par la regle) a la valeur de sigma2_(J-1) : avec sigma2_(J-2) : 226.413 (+13.5 %) ; avec sigma2_(J-3) : 199.494 (+0.0 %) ; avec sigma2_(J-2)^2/sigma2_(J-3) : 271.305 (+36.0 %). Sans variance sur la derniere annee de developpement (sigma2_(J-1) = 0, contrefactuel qui n'est pas un argument du minimum) : 166.48 (-16.5 %).

1/sqrt(1-h) : min 1.0710 max 1.4338
max |rt| / sqrt(n_j - 1) = 1.000000 (<= 1 attendu, algebre)
  res$j max_abs_rt borne
1     0      1.480 2.449
2     1      1.352 2.236
3     2      1.602 2.000
4     3      1.537 1.732
5     4      1.285 1.414
6     5      1.000 1.000
quantile N(0,1) des rangs extremes (ppoints(27)) : 2.085
```
