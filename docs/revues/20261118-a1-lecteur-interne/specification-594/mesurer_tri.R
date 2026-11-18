args <- commandArgs(TRUE)
source("R/charger_moteur.R"); m <- charger_moteur(dans = NULL)
avant <- m$.xlsx_controler_structure
txt <- deparse(avant, width.cutoff = 500L); k <- grep("t_is <- nm == \"t\"", txt, fixed = TRUE)
txt[k] <- "    t_is <- nm == \"t\" & pn == \"is\" & ifelse(g == \"o\", !tk %in% c(\"<t>\", \"<t xml:space=\\\"preserve\\\">\"), !grepl(\"^<t[ \\t\\r\\n]*/>$\", tk, useBytes = TRUE) & tk != \"<t xml:space=\\\"preserve\\\"/>\")"
apres <- eval(parse(text = txt)); environment(apres) <- environment(avant)
lire <- function(f, proto) { assign(".xlsx_controler_structure", if (proto) apres else avant, envir = m)
  on.exit(assign(".xlsx_controler_structure", avant, envir = m)); tryCatch(m$engine_lire_xlsx(f), error = function(e) e) }
d <- args[1]; c594 <- args[2]
po <- lire(file.path(d, "T_cellule_bordee__openpyxl.xlsx"), TRUE)
pd <- lire(file.path(d, "T_cellule_bordee__xlsxwriter_defaut.xlsx"), FALSE)
cat("triangle cellule bordee : openpyxl avant =", class(lire(file.path(d, "T_cellule_bordee__openpyxl.xlsx"), FALSE))[1], "\n")
to <- m$engine_lire_triangle(po); td <- m$engine_lire_triangle(pd)
cat("apres openpyxl : ok =", to$ok, "; == xlsxwriter defaut avant (identical) :", identical(to, td), "; j1 de i=1 :", to$triangle[1, 2], "\n")
ref <- m$engine_lire_triangle(read.csv("tests/donnees/triangle_mw.csv"))
cat("triangle == lecture du CSV :", identical(to$triangle, ref$triangle), "\n")
b <- m$engine_lire_triangle(lire(file.path(c594, "triangle/classeurs/openpyxl_triangle_note_blancs.xlsx"), TRUE))
t0 <- m$engine_lire_triangle(lire(file.path(c594, "triangle/classeurs/openpyxl_triangle_note_temoin.xlsx"), FALSE))
cat("triangle note blancs (apres) vs temoin (avant), engine_lire_triangle identical :", identical(b, t0), "\n"); cat(b$erreurs, sep = "\n")
