source("R/charger_moteur.R"); charger_moteur()
env <- environment(run_engine)
src <- readLines("R/engine.R"); a <- grep("^\\.engine_calcul_protege <- function", src); b <- a - 1L + which(src[a:length(src)] == "}")[1]; src <- src[a:b]
i <- grep("else if (length(pile)) pile[length(pile)] else NA_character_", src, fixed = TRUE)
stopifnot(length(i) == 1L)
src[i] <- sub("else if (length(pile)) pile[length(pile)] else NA_character_", "else NA_character_", src[i], fixed = TRUE)
exprs <- parse(text = src); ecp <- eval(exprs[[1]][[3]]); environment(ecp) <- env
v <- list(ok = TRUE, erreurs = character(0))
for (e in list(quote(stats::lm(y ~ x, data = data.frame(x = 1))), quote(vapply(1:2, function(i) stop("x"), 1)),
               quote(data.frame(a = 1:2, b = 1:3)), quote(usp_ajuster(c(1,2,3), "a")), quote(stop("panne simulee")))) {
  r <- eval(bquote(ecp("premium", Sys.time(), v, .(e))))
  cat(deparse(e)[1], "\n  motif :", r$validation$erreurs, "\n  origine :", r$validation$erreur_r$origine, "| pile :", paste(r$validation$erreur_r$pile, collapse = " > "), "\n")
}
