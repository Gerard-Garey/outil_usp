setwd("/home/user/outil_usp")
source("R/charger_moteur.R"); charger_moteur()
df <- utils::read.csv("tests/donnees/triangle_mw.csv"); tri <- as.matrix(df[, -1]); dimnames(tri) <- NULL
aj <- mw_ajuster(tri)
t1 <- system.time(b <- mw_bootstrap(aj, B = 999, seed = 1))[["elapsed"]]
t2 <- system.time(for (k in 1:20) mw_ajuster(tri))[["elapsed"]] / 20
t3 <- system.time(mw_tests(aj, b, 0.10))[["elapsed"]]
cat(sprintf("bootstrap B=999 : %.2f s ; mw_ajuster : %.5f s ; mw_tests : %.2f s ; R %s\n", t1, t2, t3, R.version.string))
