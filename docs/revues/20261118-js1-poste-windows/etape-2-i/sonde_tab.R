# Sonde de l'echec "tabulation et saut de ligne admis" (#580), poste Windows.
depot <- normalizePath(commandArgs(TRUE)[1], winslash = "/")  # racine du depot
source(file.path(depot, "R/charger_moteur.R")); charger_moteur(file.path(depot, "R/engine.R"))
f <- tempfile(fileext = ".xlsx")
txt <- c("a\tb", "a\nb", "c\u00e9")
latin <- iconv("caf\u00e9", "UTF-8", "latin1")
d <- data.frame(a = c(txt, latin), stringsAsFactors = FALSE)
names(d) <- "e\tn\nt\u00e9te"
engine_ecrire_xlsx(d, f)
env <- environment(run_engine)
lire <- function(avec) {
  if (!avec) {
    assign("requireNamespace", function(package, ...) FALSE, envir = env)
    on.exit(rm("requireNamespace", envir = env))
  }
  engine_lire_xlsx(f)
}
for (avec in c(TRUE, FALSE)) {
  l <- lire(avec)
  cat("chemin", if (avec) "openxlsx" else "interne", ": identical cellules =", identical(l[[1]], enc2utf8(d[[1]])), "\n")
  for (k in seq_along(l[[1]])) cat("  lu   :", deparse(l[[1]][k]), Encoding(l[[1]][k]), charToRaw(l[[1]][k]), "\n  ecrit:", deparse(enc2utf8(d[[1]])[k]), Encoding(enc2utf8(d[[1]])[k]), charToRaw(enc2utf8(d[[1]])[k]), "\n")
}
rep <- tempfile(); utils::unzip(f, exdir = rep)
xml <- rawToChar(readBin(file.path(rep, "xl", "worksheets", "sheet1.xml"), "raw", file.size(file.path(rep, "xl", "worksheets", "sheet1.xml"))))
cat("en-tete trouve :", grepl("<t>e\tn\nt\u00e9te</t>", xml, fixed = TRUE), "\n")
cat("Encoding(xml) :", Encoding(xml), "; motif :", Encoding("<t>e\tn\nt\u00e9te</t>"), "\n")
cat(substr(xml, 1, 400), "\n")
cat("avec useBytes :", grepl(enc2utf8("<t>e\tn\nt\u00e9te</t>"), xml, fixed = TRUE, useBytes = TRUE), "\n")
