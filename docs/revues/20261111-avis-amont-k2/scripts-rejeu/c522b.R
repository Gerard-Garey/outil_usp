source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
aff <- function(r) for (n in names(r)) { cat("  [", n, "] ", sep=""); print(r[[n]]) }
res <- function(r) paste0("ok=", r$ok, " n=", r$n, " | ", paste(r$erreurs, collapse = " // "))
ser <- function(decal, style) {
  hd <- 1 + decal
  r <- character(0)
  if (style) for (k in seq_len(decal)) r <- c(r, sprintf('<row r="%d"><c r="A%d" s="1"/><c r="B%d" s="1"/><c r="C%d" s="1"/></row>', k, k, k, k))
  r <- c(r, rowx(hd, c(ci(sprintf("A%d", hd), "<t>t</t>"), ci(sprintf("B%d", hd), "<t>xt</t>"), ci(sprintf("C%d", hd), "<t>yt</t>"))))
  for (k in 1:8) r <- c(r, rowx(hd + k, c(cn(sprintf("A%d", hd+k), 2000+k), cn(sprintf("B%d", hd+k), 100+k), cn(sprintf("C%d", hd+k), 90+k))))
  paste(r, collapse = "")
}
for (decal in 1:2) {
  cat(sprintf("\n== Series, en-tete ligne %d, lignes au-dessus = cellules mises en forme sans valeur (<c s=1/>)\n", 1+decal))
  f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=ser(decal, TRUE))))
  aff(chemins(f, function(d) {cat("\n    noms:", names(d), " dim:", dim(d), "\n   "); res(engine_lire_donnees_csv(d))}))
}
# Triangle 8x8, en-tete ligne 2 / 3
tri8 <- function(decal) {
  hd <- 1 + decal; I <- 8
  r <- rowx(hd, c(ci(sprintf("A%d", hd), "<t>i</t>"), vapply(1:I, function(j) ci(sprintf("%s%d", LETTERS[j+1], hd), sprintf("<t>%d</t>", j-1)), "")))
  for (k in 1:I) r <- c(r, rowx(hd+k, c(cn(sprintf("A%d", hd+k), 2000+k), unlist(lapply(1:(I-k+1), function(j) cn(sprintf("%s%d", LETTERS[j+1], hd+k), 100*k + 10*j + j^2))))))
  paste(r, collapse = "")
}
for (decal in 1:2) {
  cat(sprintf("\n== Triangle 8x8, en-tete en ligne %d\n", 1 + decal))
  f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=tri8(decal))))
  aff(chemins(f, function(d) {cat("\n    noms:", names(d), " dim:", dim(d), "\n   "); r <- engine_lire_triangle(d); paste0("ok=", r$ok, " I=", r$I, " J=", r$J, " | ", paste(r$erreurs, collapse = " // "))}))
}
cat("\n== Caracteres de controle dans un en-tete (CSV, data.frame direct)\n")
d <- data.frame(a = 1:8, b = 1:8, c = 1:8); names(d) <- c("a\001b", "x\tt\n", "y\033[31mt")
r <- engine_lire_donnees_csv(d); print(r$erreurs); print(utils::capture.output(cat(r$erreurs, "\n")))
cat("\n== Caracteres de controle : xlsx, en-tetes ecrits par l'ecrivain interne puis lus par les deux chemins\n")
f <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(d, f))
aff(chemins(f, function(x) { r <- engine_lire_donnees_csv(x); print(sapply(names(x), function(s) paste(sprintf("%02X", as.integer(charToRaw(s))), collapse=" "))); r$erreurs }))
cat("\n== Caracteres de controle : octets binaires (fichier PNG lu comme CSV, comme l'app avec read.csv)\n")
tmp <- tempfile(fileext = ".csv"); writeBin(as.raw(c(0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a,0x00,0x00,0x00,0x0d,0x49,0x48,0x44,0x52,0x2c,0x01,0x02,0x0a,0x61,0x2c,0x62)), tmp)
dd <- tryCatch(suppressWarnings(utils::read.csv(tmp, check.names = FALSE, stringsAsFactors = FALSE)), error = function(e) conditionMessage(e))
print(dd)
if (is.data.frame(dd)) { r <- engine_lire_donnees_csv(dd); print(r$erreurs) }
