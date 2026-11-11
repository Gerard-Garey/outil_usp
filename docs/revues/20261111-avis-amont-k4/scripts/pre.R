suppressMessages({source("R/charger_moteur.R"); m <- charger_moteur()})
attach(m, warn.conflicts = FALSE)
.ln  <- utils::read.csv("tests/donnees/donnees_ln.csv")
.tri <- local({ df <- utils::read.csv("tests/donnees/triangle_mw.csv"); mm <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(mm) <- "double"; unname(mm) })
