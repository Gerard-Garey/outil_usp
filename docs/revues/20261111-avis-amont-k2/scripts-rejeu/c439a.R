setwd("/home/user/outil_usp"); source("R/charger_moteur.R"); m <- new.env(); charger_moteur(dans = m)
noms <- ls(m, all.names = TRUE)
fn <- noms[vapply(noms, function(n) is.function(get(n, m)), NA)]
cat("objets du moteur:", length(noms), " dont fonctions:", length(fn), "\n")
for (f in c("app.R", "R/display_helpers.R")) {
  src <- readLines(f, warn = FALSE)
  # retire les commentaires entiers
  code <- sub("^\\s*#.*$", "", src); code <- sub("\\s#.*$", "", code)
  txt <- paste(code, collapse = "\n")
  cat("\n=== ", f, "\n", sep = "")
  res <- data.frame(nom = character(), appels = integer(), lignes = character(), stringsAsFactors = FALSE)
  for (n in noms) {
    pat <- paste0("(?<![A-Za-z0-9_.$@])", gsub(".", "\\.", n, fixed = TRUE), "(?![A-Za-z0-9_.])")
    hit <- which(grepl(pat, code, perl = TRUE))
    if (length(hit)) res <- rbind(res, data.frame(nom = n, appels = length(hit), lignes = paste(utils::head(hit, 8), collapse = ","), stringsAsFactors = FALSE))
  }
  res$fonction <- res$nom %in% fn
  print(res[order(res$nom), ], row.names = FALSE)
}
