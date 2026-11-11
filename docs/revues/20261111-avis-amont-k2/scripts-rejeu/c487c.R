source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
aff <- function(r) for (n in names(r)) { cat("  [", n, "]\n", sep=""); print(r[[n]]) }
fe <- function(base) paste0(
  rowx(1, c(ci("A1", "<t>t</t>"), ci("B1", "<t>xt</t>"), ci("C1", "<t>yt</t>"))),
  rowx(2, c(cn("A2", 2001), cn("B2", base + 1), cn("C2", base + 2))))
cat("== 1j. premiere feuille du workbook = sheet2.xml, deuxieme = sheet10.xml (et sheet1.xml absent)\n")
f <- mk_classeur(list(list(nom="Premiere", fichier="sheet2.xml", xml=fe(200)),
                      list(nom="Seconde", fichier="sheet10.xml", xml=fe(100))))
aff(chemins(f))
cat("\n== 1k. workbook a 11 feuilles sheet1..sheet11, ordre du workbook inverse : la premiere du workbook est sheet11\n")
fl <- lapply(11:1, function(k) list(nom=paste0("F", k), fichier=sprintf("sheet%d.xml", k), xml=fe(1000 * k)))
f <- mk_classeur(fl)
aff(chemins(f))
cat("\n== 1l. cellules avec attributs mais sans r (<c s='0'>), ligne entiere\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c(ci("A1", "<t>t</t>"), ci("B1", "<t>xt</t>"), ci("C1", "<t>yt</t>"))),
  rowx(2, c('<c s="0"><v>2001</v></c>', cn("B2", 5), cn("C2", 6)))))))
aff(chemins(f, function(d) {print(d); NULL}))
cat("\n== 1m. une cellule sans r ni attribut (<c><v>) au milieu : valeur perdue ?\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c(ci("A1", "<t>t</t>"), ci("B1", "<t>xt</t>"), ci("C1", "<t>yt</t>"))),
  rowx(2, c(cn("A2", 2001), '<c><v>5</v></c>', cn("C2", 6)))))))
aff(chemins(f, function(d) {print(d); NULL}))
