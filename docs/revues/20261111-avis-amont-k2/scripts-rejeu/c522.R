source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
aff <- function(r) for (n in names(r)) { cat("  [", n, "] ", sep=""); print(r[[n]]) }
ser <- function(decal, titre = FALSE) {
  # en-tete en ligne 1+decal ; lignes au-dessus absentes, ou une ligne titre en A1
  hd <- 1 + decal
  r <- character(0)
  if (titre && decal >= 1) r <- c(r, rowx(1, ci("A1", "<t>Export ACME</t>")))
  r <- c(r, rowx(hd, c(ci(sprintf("A%d", hd), "<t>t</t>"), ci(sprintf("B%d", hd), "<t>xt</t>"), ci(sprintf("C%d", hd), "<t>yt</t>"))))
  for (k in 1:8) r <- c(r, rowx(hd + k, c(cn(sprintf("A%d", hd+k), 2000+k), cn(sprintf("B%d", hd+k), 100+k), cn(sprintf("C%d", hd+k), 90+k))))
  paste(r, collapse = "")
}
res <- function(r) paste0("ok=", r$ok, " n=", r$n, " | ", paste(r$erreurs, collapse = " // "))
for (decal in 1:2) for (titre in c(FALSE, TRUE)) {
  cat(sprintf("\n== Series, en-tete en ligne %d, ligne(s) au-dessus: %s\n", 1 + decal, if (titre) "titre en A1 (+ vides)" else "absentes (vides)"))
  f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=ser(decal, titre))))
  aff(chemins(f, function(d) {cat("\n    noms:", names(d), " dim:", dim(d), "\n   "); res(engine_lire_donnees_csv(d))}))
}
# Triangle 4x4 en-tete ligne 2 / 3
tri <- function(decal) {
  hd <- 1 + decal
  r <- rowx(hd, c(ci(sprintf("A%d", hd), "<t>i</t>"), paste0(vapply(1:4, function(j) ci(sprintf("%s%d", LETTERS[j+1], hd), sprintf("<t>%d</t>", j-1)), ""), collapse = "")))
  M <- cbind(c(100,110,120,130), c(150,165,180,NA), c(170,190,NA,NA), c(175,NA,NA,NA))
  for (k in 1:4) r <- c(r, rowx(hd+k, c(cn(sprintf("A%d", hd+k), 2000+k), unlist(lapply(1:4, function(j) if (!is.na(M[k,j])) cn(sprintf("%s%d", LETTERS[j+1], hd+k), M[k,j]))))))
  paste(r, collapse = "")
}
for (decal in 1:2) {
  cat(sprintf("\n== Triangle, en-tete en ligne %d\n", 1 + decal))
  f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=tri(decal))))
  aff(chemins(f, function(d) {cat("\n    noms:", names(d), " dim:", dim(d), "\n   "); r <- engine_lire_triangle(d); paste0("ok=", r$ok, " | ", paste(r$erreurs, collapse = " // "))}))
}
