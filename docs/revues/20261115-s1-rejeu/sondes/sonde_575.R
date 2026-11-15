# Usage : Rscript sonde_575.R <depot> <dossier_sondes> <indice> <mode : moteur|direct> <variante : avec_rel|sans_rel>
a <- commandArgs(TRUE); setwd(a[1]); source(file.path(a[2], "forge.R"))
ind <- a[3]; mode <- a[4]
f <- forger(c(ligne(1, '<c r="A1" t="s"><v>0</v></c>'), ligne(2, sprintf('<c r="A2" t="s"><v>%s</v></c>', ind))),
            partagees = '<si><t>annee</t></si>')
if (a[5] == "sans_rel") {  # table sans relation ni type de contenu, comme une forge minimale
  d <- tempfile(); utils::unzip(f, exdir = d)
  for (p in c("[Content_Types].xml", "xl/_rels/workbook.xml.rels")) {
    x <- readLines(file.path(d, p), warn = FALSE); x <- gsub('<(Override|Relationship)[^>]*sharedStrings[^>]*/>', "", x); writeLines(x, file.path(d, p))
  }
  od <- setwd(d); unlink(f); system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")); setwd(od)
}
cat("md5 du classeur :", unname(tools::md5sum(f)), "\n")
r <- tryCatch(if (mode == "direct") openxlsx::read.xlsx(f, colNames = FALSE) else {
  source("R/charger_moteur.R"); e <- charger_moteur(); e$engine_lire_xlsx(f) },
  error = function(err) paste("ERREUR R :", conditionMessage(err)))
print(r)
