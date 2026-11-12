source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
grille <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, 0.1+0.2, 5e-324, -2/3, 123456789.123456789, 1e15+0.3)
d <- data.frame(g = grille)
xml_de <- function(f) { x <- tempfile(); utils::unzip(f, exdir = x); readLines(file.path(x, "xl/worksheets/sheet1.xml"), warn = FALSE) }
cat("== XML ecrit par openxlsx::write.xlsx (defaut)\n")
f <- tempfile(fileext = ".xlsx"); openxlsx::write.xlsx(d, f)
print(regmatches(xml_de(f), gregexpr("<v>[^<]*</v>", xml_de(f)))[[1]])
cat("== XML ecrit par l'ecrivain interne\n")
f2 <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(d, f2))
print(regmatches(xml_de(f2), gregexpr("<v>[^<]*</v>", xml_de(f2)))[[1]])
cat("== Roundtrip identical par colonne\n")
for (nm in c("openxlsx_ecrit", "interne_ecrit")) {
  ff <- if (nm == "openxlsx_ecrit") f else f2
  for (ch in c("interne", "openxlsx")) {
    rd <- if (ch == "interne") sans_ox(engine_lire_xlsx(ff)) else engine_lire_xlsx(ff)
    cat(sprintf("%-15s lu par %-9s : identical = %s ; ecarts relatifs max = %.3g\n", nm, ch, identical(rd$g, grille), max(abs(rd$g - grille)/abs(grille))))
    if (!identical(rd$g, grille)) cat("     non identiques :", paste(format(grille[rd$g != grille], digits=17), collapse = " ; "), "\n")
  }
}
