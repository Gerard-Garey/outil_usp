source("R/charger_moteur.R"); charger_moteur()
ecp <- get(".engine_calcul_protege", envir = environment(run_engine))
v <- list(ok = TRUE, erreurs = character(0))
cas <- list(
  lm = quote(ecp("premium", Sys.time(), v, stats::lm(y ~ x, data = data.frame(x = 1)))),
  vapply_anon = quote(ecp("premium", Sys.time(), v, vapply(1:2, function(i) stop("x"), 1))),
  primitive = quote(ecp("premium", Sys.time(), v, 1 + "a")),
  data_frame = quote(ecp("premium", Sys.time(), v, data.frame(a = 1:2, b = 1:3))),
  moteur = quote(ecp("premium", Sys.time(), v, usp_ajuster(c(1,2,3), "a")))
)
for (n in names(cas)) { r <- eval(cas[[n]]); cat("==", n, "\n  motif :", r$validation$erreurs, "\n  origine :", r$validation$erreur_r$origine,
  "\n  pile :", paste(r$validation$erreur_r$pile, collapse=" > "), "\n") }
# Erreur directe dans le code de l'expression, appel par une fonction du moteur simulee
f <- function() ecp("premium", Sys.time(), v, { x <- data.frame(a = 1:2, b = 1:3); x })
r <- f(); cat("== depuis un appelant\n  motif :", r$validation$erreurs, "\n")
