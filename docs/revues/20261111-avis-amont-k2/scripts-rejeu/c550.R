source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
tri_csv <- utils::read.csv("tests/donnees/triangle_mw.csv", colClasses = "character", check.names = FALSE, na.strings = character(0), blank.lines.skip = FALSE)
cat("== O2 : colonnes vides a en-tete en bord (apres la derniere colonne a valeur), n = 1, 5, 6, 8 colonnes\n")
for (n in c(1, 5, 6, 8)) {
  d <- tri_csv; for (k in seq_len(n)) d[[paste0("vide", k)]] <- ""
  r <- engine_lire_triangle(d)
  cat(sprintf("n=%d : %s\n", n, paste(r$erreurs, collapse = " // ")))
}
cat("\n== O2 bis : meme chose avec la lecture d'un CSV 'series' (colonnes vides a en-tete : laissees aux controles par nom)\n")
cat("\n== O1 : mw_valider_triangle avec noms de lignes\n")
m <- as.matrix(engine_lire_triangle(tri_csv)$triangle)
cat("-- nom vide, ligne 3 (i=2)\n"); mm <- m; rownames(mm) <- c("2001","2002","", "2004","2005","2006","2007","2008")
print(mw_valider_triangle(mm)$erreurs)
cat("-- nom NA, lignes 1 et 4\n"); mm <- m; rownames(mm) <- c(NA,"2002","2003", NA,"2005","2006","2007","2008")
print(mw_valider_triangle(mm)$erreurs)
cat("-- nom 'bytes' ligne 2\n"); mm <- m; nm <- c("2001","\xe9\xe9","2003","2004","2005","2006","2007","2008"); Encoding(nm[2]) <- "bytes"; rownames(mm) <- nm
print(mw_valider_triangle(mm)$erreurs)
cat("-- doublon : lignes 2 et 5\n"); mm <- m; rownames(mm) <- c("2001","2002","2003","2004","2002","2006","2007","2008")
print(mw_valider_triangle(mm)$erreurs)
cat("-- triangle sans nom de ligne : aucun message de nom (verifie)\n"); print(mw_valider_triangle(m)$erreurs)
cat("\n== O1 : Ces messages sont-ils atteignables par engine_lire_triangle() (data.frame de lecture) ?\n")
r <- engine_lire_triangle(tri_csv); cat("rownames du triangle lu :", is.null(rownames(r$triangle)), "\n")
cat("grep des appelants de rownames dans app.R:\n"); system("grep -n 'rownames\\|dimnames' app.R | head -20")
