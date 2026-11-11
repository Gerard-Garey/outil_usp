source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
mk <- function(decal, titre = FALSE, vide_present = FALSE) {
  hd <- 1 + decal; r <- character(0)
  if (titre) r <- c(r, rowx(1, ci("A1", "<t>Export</t>")))
  if (vide_present) for (k in setdiff(seq_len(decal), if (titre) 1L else integer(0))) r <- c(r, sprintf('<row r="%d"/>', k))
  r <- c(r, rowx(hd, c(ci(sprintf("A%d", hd), "<t>t</t>"), ci(sprintf("B%d", hd), "<t>xt</t>"), ci(sprintf("C%d", hd), "<t>yt</t>"))))
  for (k in 1:3) r <- c(r, rowx(hd + k, c(cn(sprintf("A%d", hd+k), 2000+k), cn(sprintf("B%d", hd+k), 100+k), cn(sprintf("C%d", hd+k), 90+k))))
  mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste(r, collapse = ""))))
}
for (cfg in list(c(2, FALSE, FALSE), c(2, FALSE, TRUE), c(2, TRUE, FALSE))) {
  f <- mk(as.integer(cfg[1]), as.logical(cfg[2]), as.logical(cfg[3]))
  cat(sprintf("\n== en-tete en ligne %s ; titre en A1 : %s ; <row r='k'/> vides presentes : %s\n", 1 + as.integer(cfg[1]), cfg[2], cfg[3]))
  cat("-- openxlsx entete=FALSE (skipEmptyRows=FALSE) :\n"); print(engine_lire_xlsx(f, entete = FALSE))
  cat("-- interne entete=FALSE :\n"); print(sans_ox(engine_lire_xlsx(f, entete = FALSE)))
  cat("-- openxlsx entete=TRUE : noms", names(engine_lire_xlsx(f)), " | interne : noms", names(sans_ox(engine_lire_xlsx(f))), "\n")
}
cat("\n-- openxlsx::getSheetNames / read.xlsx(rows=1:3, colNames=FALSE) pour connaitre la ligne de debut ? (cas en-tete ligne 3, rien au-dessus)\n")
f <- mk(2); print(openxlsx::read.xlsx(f, sheet = 1, colNames = FALSE, rows = 1:3, skipEmptyRows = FALSE))
print(openxlsx::read.xlsx(f, sheet = 1, colNames = FALSE, startRow = 1, skipEmptyRows = FALSE, rows = NULL, cols = NULL))
