source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
tri <- utils::read.csv("tests/donnees/triangle_mw.csv", check.names = FALSE)  # numeriques
tri[[2]] <- NA_real_
for (avec_i in c(TRUE, FALSE)) {
  d <- tri; names(d) <- c("i", "", paste0("j", 1:7)); if (!avec_i) d <- d[, -1]
  f <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(d, f))
  cat(sprintf("\n== xlsx, %s colonne i, colonne 0 vide sans en-tete\n", if (avec_i) "avec" else "sans"))
  r <- chemins(f, function(x) { cat("   noms:", names(x), "\n"); y <- engine_lire_triangle(x); sprintf("ok=%s dim=%s | %s", y$ok, if (is.null(y$triangle)) "-" else paste(dim(y$triangle), collapse="x"), substr(paste(y$erreurs, collapse=" // "), 1, 160)) })
  print(r)
}
