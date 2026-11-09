source("R/charger_moteur.R"); charger_moteur()
tri_ref <- local({ d <- utils::read.csv("tests/donnees/triangle_mw.csv"); m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m) })
t5 <- tri_ref[1:5, 1:5]; t5[row(t5) + col(t5) > 6] <- NA
invisible(run_engine(methode="reserve2", triangle=t5, segment=1, annexe="II", B=99))
tm <- system.time(r <- run_engine(methode="reserve2", triangle=t5, segment=1, annexe="II", B=999)); cat("t5 B=999", tm[3], "\n")
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
for (B in c(999, 599)) { tm <- system.time(r <- run_engine(xt=x, yt=y, methode="premium", segment=1, annexe="II", B=B, seed=20260831, nature_donnees="brutes"))
 e <- r$plots_data$spread_enveloppe; cat("premium B=", B, tm[3], "s B_eff=", e$B_eff, "k=", e$k, "motif=", e$motif, "\n") }
cat("sw n=8:", system.time(sw_loi_nulle(8))[3], "s; n=11 :", system.time(sw_loi_nulle(11))[3], "\n")
