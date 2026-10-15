for (jeu in c("J1","J2")) {
  d <- read.delim(sprintf("docs/tableaux/20261008-issue166-brut-%s.tsv", jeu), check.names = FALSE)
  col <- function(s) d[[grep(s, names(d), fixed = TRUE)[1]]]
  H2 <- cbind(BP = col("p_retenue:Heteroscedasticite vs volume - Breusch-Pagan studentise"),
              BP79 = col("p_retenue:Heteroscedasticite vs volume - Breusch-Pagan original"),
              White = col("p_retenue:Heteroscedasticite (forme quadratique)"),
              GQ = col("p_retenue:Egalite des variances petits vs gros volumes"),
              BF = col("p_retenue:Homogeneite des dispersions (mediane)"),
              Smirnov = col("p_retenue:Egalite des lois petits vs gros volumes"))
  H1npr <- cbind(Cst = col("p_retenue:Nullite de la constante"), RESET = col("p_retenue:RESET (forme fonctionnelle)"),
                 SpearVol = col("p_retenue:Independance ratio S/P vs volume"), SpearTps = col("p_retenue:Correlation ratio S/P vs temps"),
                 MK = col("p_retenue:Tendance monotone du ratio S/P"))
  tost <- col("p_retenue:Equivalence de la constante a zero (TOST)"); pit <- col("p_retenue:Test de Pitman sur la pente")
  aumoins <- function(m, s) mean(apply(m, 1, function(r) any(r < s, na.rm = TRUE)))
  cat(sprintf("\n== %s (n = %d, p-values retenues du moteur #166) ==\n", jeu, nrow(d)))
  cat(sprintf("H2 (6 lignes, sens ne pas rejeter) : P(>=1 ECHEC, p<0.05) = %.3f ; P(>=1 ALERTE/ECHEC, p<0.10) = %.3f ; ECHEC par ligne : %s\n",
      aumoins(H2, 0.05), aumoins(H2, 0.10), paste(sprintf("%s %.3f", colnames(H2), colMeans(H2 < 0.05, na.rm=TRUE)), collapse=", ")))
  cat(sprintf("H1 hors TOST/Pitman (5 lignes) : P(>=1 ECHEC) = %.3f ; P(>=1 ALERTE/ECHEC) = %.3f\n", aumoins(H1npr, 0.05), aumoins(H1npr, 0.10)))
  cat(sprintf("TOST : P(ECHEC, p>=0.30) = %.3f, P(ALERTE) = %.3f, P(OK) = %.3f (NA : %d) ; Pitman : P(ECHEC) = %.3f, P(OK) = %.3f (NA/diagnostic : %d)\n",
      mean(tost >= 0.30, na.rm=TRUE), mean(tost >= 0.10 & tost < 0.30, na.rm=TRUE), mean(tost < 0.10, na.rm=TRUE), sum(is.na(tost)),
      mean(pit >= 0.30, na.rm=TRUE), mean(pit < 0.10, na.rm=TRUE), sum(is.na(pit))))
  ech <- apply(H2 < 0.05, 1, any, na.rm=TRUE) | apply(H1npr < 0.05, 1, any, na.rm=TRUE) | (!is.na(tost) & tost >= 0.30) | (!is.na(pit) & pit >= 0.30)
  ech2 <- apply(H2 < 0.05, 1, any, na.rm=TRUE) | apply(H1npr < 0.05, 1, any, na.rm=TRUE) | (!is.na(pit) & pit >= 0.30)
  cat(sprintf("Familles B+C : P(>=1 ECHEC) = %.3f (TOST compris) ; %.3f (TOST exclu)\n", mean(ech), mean(ech2)))
}
