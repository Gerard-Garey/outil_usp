source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
cat("== Cause : as.character() sur un double (R", R.version.string, ")\n")
print(as.character(1/3)); print(sprintf("%.17g", 1/3))
op <- options(digits = 22, scipen = 200); print(as.character(1/3)); x <- 1/3; class(x) <- "character"; print(x); options(op)
cat("-> as.character(double) donne 15 chiffres significatifs, independamment de digits ; openxlsx fait class(df[[i]]) <- 'character' (workbook_write_data.R l.146-150, openxlsx 4.2.9)\n")
grille <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1+0.2, -2/3, 123456789.123456789, 1e15+0.3, 5e-324)
xml_de <- function(f) { x <- tempfile(); utils::unzip(f, exdir = x); readLines(file.path(x, "xl/worksheets/sheet1.xml"), warn = FALSE) }
vals <- function(f) { x <- xml_de(f); regmatches(x, gregexpr("<v>[^<]*</v>", x))[[1]] }
lire_les_deux <- function(f) list(interne = sans_ox(engine_lire_xlsx(f)), openxlsx = engine_lire_xlsx(f))

cat("\n== Moyen 1 : options(digits=22) autour de write.xlsx\n")
f <- tempfile(fileext = ".xlsx"); op <- options(digits = 22); openxlsx::write.xlsx(data.frame(g = grille), f); options(op)
print(vals(f)[-1]); 
cat("\n== Moyen 2 : colonne de chaines '%.17g' avec attribut de classe 'numeric' (contournement de l'implementation)\n")
g2 <- vapply(grille, function(v) { s <- sprintf("%.15g", v); if (as.double(s) != v) s <- sprintf("%.17g", v); s }, "")
col <- g2; attr(col, "class") <- "numeric"
d2 <- data.frame(g = I(col)); d2 <- data.frame(g = col)   # data.frame() ne touche pas au storage
cat("storage:", typeof(d2$g), " class:", class(d2$g), "\n")
f2 <- tempfile(fileext = ".xlsx")
r <- tryCatch({ openxlsx::write.xlsx(d2, f2); "ecrit" }, error = function(e) paste("ERREUR:", conditionMessage(e)))
print(r)
if (r == "ecrit") {
  x <- xml_de(f2); print(regmatches(x, gregexpr("<c [^>]*><v>[^<]*</v>", x))[[1]])
  for (nm in names(lire_les_deux(f2))) { rd <- lire_les_deux(f2)[[nm]]; cat(sprintf("  lu par %-9s identical=%s classe=%s\n", nm, identical(rd$g, grille), class(rd$g))) }
}
cat("\n== Moyen 3 : writeData / createWorkbook explicites, colonne double\n")
wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, "Donnees"); openxlsx::writeData(wb, "Donnees", data.frame(g = grille))
f3 <- tempfile(fileext = ".xlsx"); openxlsx::saveWorkbook(wb, f3, overwrite = TRUE); print(vals(f3)[-1])
cat("\n== Moyen 4 : numFmt (format d'affichage) : sans effet sur <v>\n")
op <- options("openxlsx.numFmt" = "0.00000000000000000"); f4 <- tempfile(fileext = ".xlsx"); openxlsx::write.xlsx(data.frame(g = grille), f4); options(op); print(vals(f4)[-1][1:3])
cat("\n== Moyen 5 : colonne de classe 'scientific'\n")
sc <- grille; class(sc) <- "scientific"; f5 <- tempfile(fileext = ".xlsx"); openxlsx::write.xlsx(data.frame(g = sc), f5); print(vals(f5)[-1][1:3])
