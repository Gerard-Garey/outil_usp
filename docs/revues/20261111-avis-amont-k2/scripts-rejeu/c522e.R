source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
sonde <- function(f) tryCatch({ x <- openxlsx::read.xlsx(f, sheet = 1, rows = 1, colNames = FALSE, skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character(0)); c(nrow = nrow(x), ncol = ncol(x), val = paste(unlist(x), collapse = "|")) }, error = function(e) paste("ERREUR", conditionMessage(e)))
cas <- list(
  `en-tete en ligne 1` = mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(rowx(1, ci("A1","<t>t</t>")), rowx(2, cn("A2", 1)))))),
  `ligne 1 absente, en-tete ligne 3` = mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(rowx(3, ci("A3","<t>t</t>")), rowx(4, cn("A4", 1)))))),
  `ligne 1 mise en forme sans valeur` = mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0('<row r="1"><c r="A1" s="1"/></row>', rowx(3, ci("A3","<t>t</t>")), rowx(4, cn("A4", 1)))))),
  `ligne 1 = titre` = mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(rowx(1, ci("A1","<t>Titre</t>")), rowx(3, ci("A3","<t>t</t>")), rowx(4, cn("A4", 1)))))))
for (n in names(cas)) { cat(sprintf("%-36s sonde openxlsx rows=1 : ", n)); print(sonde(cas[[n]])) }
