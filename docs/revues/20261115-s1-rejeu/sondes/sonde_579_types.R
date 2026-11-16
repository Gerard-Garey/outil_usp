# Usage : Rscript sonde_579_types.R <depot> <dossier_sondes> [<fichier_moteur>]
# #579, decision D-S1-3 : appel direct d'engine_lire_donnees_csv() et
# d'engine_lire_triangle() avec des colonnes non numeriques (logique, Date,
# POSIXct, complexe, liste, difftime, brut ; colonne i du triangle logique,
# Date ou difftime), et temoins qui doivent rester acceptes.
# fichier_moteur : R/engine.R par defaut ; avant le correctif, la version
# extraite de ae911bd (git show ae911bd:R/engine.R > fichier).
a <- commandArgs(TRUE); depot <- a[1]; sd <- a[2]
moteur <- if (length(a) >= 3) a[3] else "R/engine.R"
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
source(file.path(sd, "forge.R"))
cat("moteur :", basename(moteur), "\n")
serie <- function(nom, df) {
  r <- tryCatch(e$engine_lire_donnees_csv(df), error = function(err) list(ok = NA, erreurs = paste("ERREUR", conditionMessage(err))))
  cat(sprintf("[%s] engine_lire_donnees_csv : ok = %s\n", nom, r$ok))
  if (isTRUE(r$ok)) {
    res <- e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes")
    cat("  run_engine : ok =", res$ok, if (isTRUE(res$ok)) sprintf(" sigma_USP = %.10f", res$parametre$sigma_usp) else "", "\n")
  } else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
serie("logique", data.frame(t = 1:8, xt = rep(TRUE, 8), yt = LN$yt))
serie("Date", data.frame(t = 1:8, xt = as.Date("2020-01-01") + 0:7, yt = LN$yt))
serie("POSIXct", data.frame(t = 1:8, xt = as.POSIXct("2020-01-01", tz = "UTC") + 86400 * (0:7), yt = LN$yt))
serie("complexe", data.frame(t = 1:8, xt = complex(real = LN$xt), yt = LN$yt))
serie("t en Date", data.frame(t = as.Date("2020-01-01") + 0:7, xt = LN$xt, yt = LN$yt))
d <- data.frame(t = 1:8, xt = LN$xt, yt = LN$yt); d$xt <- as.list(LN$xt)
serie("liste", d)
serie("difftime", data.frame(t = 1:8, xt = as.difftime(LN$xt, units = "days"), yt = LN$yt))
serie("brut", data.frame(t = 1:8, xt = as.raw(1:8), yt = LN$yt))
serie("temoin numerique", data.frame(t = 1:8, xt = LN$xt, yt = LN$yt))
serie("colonne logique supplementaire", data.frame(t = 1:8, xt = LN$xt, yt = LN$yt, drapeau = TRUE))
serie("colonne Date supplementaire", data.frame(t = 1:8, xt = LN$xt, yt = LN$yt, d = as.Date("2020-01-01") + 0:7))
tri <- data.frame(i = 0:4, j0 = c(100, 110, 115, 125, 150), j1 = c(150, 168, 169, 185, NA),
                  j2 = c(175, 192, 197, NA, NA), j3 = c(180, 198, NA, NA, NA), j4 = c(182, NA, NA, NA, NA))
triangle <- function(nom, d) {
  r <- e$engine_lire_triangle(d)
  cat(sprintf("[%s] engine_lire_triangle : ok = %s\n", nom, r$ok))
  if (!isTRUE(r$ok)) cat("  erreurs :", r$erreurs, sep = "\n    ") else cat("  C(0,4) =", r$triangle[1, 5])
  cat("\n\n")
}
triangle("triangle temoin", tri)
t2 <- tri; t2$j4 <- c(TRUE, NA, NA, NA, NA); triangle("triangle C(0,4) logique", t2)
t3 <- tri; t3$j4 <- as.Date(c("2020-01-01", NA, NA, NA, NA)); triangle("triangle C(0,4) Date", t3)
t4 <- tri; t4$i <- c(TRUE, FALSE, TRUE, FALSE, TRUE); triangle("triangle colonne i logique", t4)
t5 <- tri; t5$i <- as.Date("2020-01-01") + 0:4; triangle("triangle colonne i Date (jours consecutifs)", t5)
t6 <- tri; t6$i <- as.difftime(0:4, units = "days"); triangle("triangle colonne i difftime", t6)
