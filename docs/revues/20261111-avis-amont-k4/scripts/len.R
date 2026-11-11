source(file.path(Sys.getenv("S"), "pre.R"))
D0 <- matrix(NA_real_, 8, 8); for (i in 0:7) for (j in 0:7) if (i+j<=7) D0[i+1,j+1] <- 1000*1.5^j
r <- run_engine(methode="reserve2", triangle=D0, segment=1L, annexe="II", B=99); cat("MP2 nchar:", nchar(r$validation$erreurs), "\n")
cat("US-04 nchar:", nchar(engine_motif_b_alpha(99, 0.01)), "\n")
xt <- c(100,110,125,130,145,150,165,170); yt <- c(70,80,85,95,100,102,120,118)
v <- engine_valider_serie_retenue(xt*1e-110, yt*1e-110, T=8)$validation; cat("LN-06 nchar:", nchar(v$erreurs), "\n")
cat("LN-01 nchar:", nchar(.nature_erreurs("premium", NULL)), "\n")
cat("avert volumes constants nchar:", nchar(engine_valider_donnees(rep(100,8), yt)$avertissements[1]), "\n")
tri <- .tri; t7 <- tri; r <- run_engine(methode="reserve2", triangle=tri, segment=1L, annexe="II", B=99); cat("reserve2 avertissements calcul:", length(r$validation$avertissements), "\n")
# MW avertissements de mw_valider_ajustement : triangle a colonne degeneree
Tg <- .tri; Tg[1:3, 2] <- Tg[1:3,1]*1.5 # force facteurs egaux colonne 0
v2 <- mw_valider_ajustement(mw_ajuster({x <- Tg; x[row(x)+col(x)-2L > 7] <- NA; x}), mw_msep(mw_ajuster({x <- Tg; x[row(x)+col(x)-2L > 7] <- NA; x}))$msep)
cat("mw_valider_ajustement ok=", v2$ok, " erreurs:", length(v2$erreurs), " avert:", length(v2$avertissements), "\n"); for (a in v2$avertissements) cat("  AVT(", nchar(a), "):", substr(a, 1, 200), "\n")
