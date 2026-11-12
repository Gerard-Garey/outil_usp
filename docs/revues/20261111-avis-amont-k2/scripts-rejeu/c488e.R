suppressMessages(library(openxlsx)); cat("openxlsx", as.character(packageVersion("openxlsx")), "\n")
grille <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308, NA, 0.1+0.2, 5e-324)
exact <- function(v) if (is.na(v)) NA_character_ else { s <- sprintf("%.15g", v); if (as.double(s) != v) sprintf("%.17g", v) else s }
col <- vapply(grille, exact, ""); attr(col, "class") <- "numeric"
d <- data.frame(t = 1:8, xt = col, yt = I(col)[seq_along(col)] )
d <- data.frame(t = 1:8, xt = col); 
f <- tempfile(fileext = ".xlsx"); write.xlsx(d, f)
x <- tempfile(); unzip(f, exdir = x); s <- paste(readLines(file.path(x, "xl/worksheets/sheet1.xml"), warn = FALSE), collapse = "")
print(regmatches(s, gregexpr('<c r="B[0-9]+"[^>]*>(<v>[^<]*</v>)?', s))[[1]])
r <- read.xlsx(f, skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character(0))
cat("identical(xt) :", identical(r$xt, grille), " classe:", class(r$xt), "\n")
