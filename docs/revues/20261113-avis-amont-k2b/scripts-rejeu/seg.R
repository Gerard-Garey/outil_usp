sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib"), .libPaths()))
source("R/charger_moteur.R"); charger_moteur()
source(file.path(sp, "fab.R"))
args <- commandArgs(TRUE); rv <- args[1]; chemin_lecteur <- args[2]
num <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
sst <- function(ref, i) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, i)
row <- function(r, ...) sprintf('<row r="%d">%s</row>', r, paste0(..., collapse = ""))
f <- file.path(sp, "classeurs", paste0("seg_", chemin_lecteur, ".xlsx"))
fab(f, paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), row(2, num("A2",1), sprintf('<c r="%s"><v>1.5</v></c>', rv), num("C2",2.5))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
cat("lecteur:", chemin_lecteur, " r=", rv, "\n")
if (chemin_lecteur == "openxlsx") print(openxlsx::read.xlsx(f, sheet = 1, skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character(0), sep.names = " ")) else {
  env <- environment(engine_lire_xlsx); assign("requireNamespace", function(package, ...) FALSE, envir = env)
  print(engine_lire_xlsx(f)) }
