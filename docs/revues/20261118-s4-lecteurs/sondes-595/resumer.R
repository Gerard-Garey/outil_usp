# Usage : Rscript resumer.R avant.txt apres.txt : tableau des sondes avant / apres
lire <- function(f) {
  l <- readLines(f); out <- list(); cle <- NULL
  for (x in l) {
    if (grepl("^\\[", x)) { cas <- sub("^\\[([^]]+)\\].*", "\\1", x); ch <- sub(".*chemin = ([a-z]+).*", "\\1", x); cle <- paste(cas, ch); out[[cle]] <- list(v = "", s = "", ok = "", m = "") ; next }
    if (is.null(cle)) next
    if (grepl("^  lu :", x)) out[[cle]]$v <- sub(".*B2 lu = ", "", x)
    if (grepl("^  run_engine", x)) { out[[cle]]$ok <- sub(".*ok = ([A-Z]+).*", "\\1", x); out[[cle]]$s <- sub(".*sigma_USP = ", "", x) }
    if (grepl("^  message = ", x)) out[[cle]]$m <- sub("^  message = (Classeur illisible : )?", "", x)
    if (grepl("code de sortie : 124", x)) out[[cle]]$m <- "BLOCAGE (code 124, timeout 20 s)"
  }
  out
}
a <- lire(commandArgs(TRUE)[1]); b <- lire(commandArgs(TRUE)[2])
court <- function(m) { m <- sub("^la partie xl/_rels/workbook.xml.rels du classeur designe la feuille lue de facon ambigue \\((.*)\\) ; l'outil.*$", "(a) \\1", m)
  m <- sub("^la partie xl/_rels/workbook.xml.rels du classeur porte une balise <Relationship> de forme non reconnue \\((balise\\(s\\) <Relationship> [0-9, ]+) :.*$", "(b) \\1", m)
  sub("cible differente pour un autre lecteur de classeur.*$", "cible differente pour un autre lecteur (a3)", m) }
fmt <- function(r) if (nzchar(r$v)) sprintf("%s ; sigma %s ; ok %s", r$v, r$s, r$ok) else court(r$m)
for (k in names(b)) cat(sprintf("| %s | %s | %s |\n", sub(" ", " | ", k), fmt(a[[k]]), fmt(b[[k]])))
