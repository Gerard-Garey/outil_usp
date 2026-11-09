setwd("/home/user/outil_usp")
seq <- read.delim("/tmp/duree-ci/durees_seq.tsv", header = FALSE, col.names = c("f","d","st","charge"))
seq <- seq[grepl("^test_", seq$f) & seq$f != "test_reproductibilite", ]
seq$d <- as.numeric(seq$d)
ci <- read.delim("/tmp/duree-ci/durees_ci_1152.tsv", header = FALSE, col.names = c("f","n","d"))
fich <- sort(list.files("tests/unitaires", pattern = "^test_.*[.]R$", full.names = TRUE))
taille <- setNames(file.size(fich), sub("[.]R$", "", basename(fich)))
ordre_actuel <- names(taille)[order(-taille, names(taille))]
simuler <- function(ordre, d, n = 4) {
  fin <- rep(0, n); dernier <- character(n)
  for (f in ordre) { k <- which.min(fin); fin[k] <- fin[k] + d[[f]]; dernier[k] <- f }
  c(mural = max(fin), borne_somme = sum(d) / n, plus_long = max(d))
}
for (src in c("ci", "seq")) {
  d <- if (src == "ci") setNames(ci$d, ci$f) else setNames(seq$d, seq$f)
  d <- d[names(taille)]
  cat(sprintf("\n== durees %s (somme %.0f s)\n", src, sum(d)))
  for (n in c(2, 4, 8)) {
    a <- simuler(ordre_actuel, d, n); l <- simuler(names(sort(d, decreasing = TRUE)), d, n)
    cat(sprintf("n=%d : ordre actuel (taille) %.0f s ; LPT %.0f s ; somme/n %.0f s ; plus long %.0f s\n", n, a[1], l[1], a[2], a[3]))
  }
}
# tableau
tab <- merge(data.frame(fichier = seq$f, seq_s = round(seq$d, 1)), data.frame(fichier = ci$f, ci_par4_s = ci$d, assertions = ci$n), all = TRUE)
tab$taille_ko <- round(taille[tab$fichier] / 1024, 1)
tab$rang_lancement <- match(tab$fichier, ordre_actuel)
tab <- tab[order(-tab$ci_par4_s), ]
write.table(tab, "/tmp/duree-ci/tableau_durees.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
print(tab, row.names = FALSE)
cat("somme seq :", sum(seq$d), " somme ci :", sum(ci$d), "\n")
