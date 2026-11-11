suppressMessages({source("R/charger_moteur.R"); m <- charger_moteur()})
E <- environment(m$run_engine); M3 <- E$MOTIF_MC_OBS_NON_FINIE
cat("MOTIF_MC_OBS_NON_FINIE =", M3, "\n")
ln <- utils::read.csv("tests/donnees/donnees_ln.csv")
tri <- local({ df <- utils::read.csv("tests/donnees/triangle_mw.csv"); mm <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(mm) <- "double"; unname(mm) })
lister <- function(nom, r) { cat("=== ", nom, " ok =", r$ok, "\n"); if (!isTRUE(r$ok)) { print(r$validation$erreurs); return(invisible()) }
  for (l in r$tests) if (identical(l$type, "non applicable")) cat(sprintf("  [%s] R3=%s | loi=%s\n", l$test, startsWith(l$detail, M3), l$loi)) }
lister("pertes constantes", m$run_engine(xt = ln$xt, yt = rep(100, nrow(ln)), methode = "premium", nature_donnees = "nettes", segment = 1, B = 99))
lister("T = 5", m$run_engine(xt = ln$xt, yt = ln$yt, T = 5, methode = "reserve1", segment = 1, B = 99))
lister("T = 25 pi variable", { set.seed(1); x <- round(runif(25, 50, 500)); y <- x * exp(rnorm(25, -0.3, 0.2)); m$run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, B = 99) })
# triangle a colonnes degenerees : derniere colonnes avec facteurs egaux
t2 <- tri; I <- nrow(t2) - 1; for (i in 0:(I - 5)) t2[i + 1, 6:(I - i + 1)] <- t2[i + 1, 5] * cumprod(rep(1, I - i - 4))
lister("MW colonnes degenerees", m$run_engine(triangle = t2, methode = "reserve2", segment = 1, B = 99))
