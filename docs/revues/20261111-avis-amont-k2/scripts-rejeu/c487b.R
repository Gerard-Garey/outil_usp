source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
aff <- function(r) for (n in names(r)) { cat("  [", n, "]\n", sep=""); print(r[[n]]) }
cat("== 1f. chaines partagees : enrichie (plusieurs segments), entites numeriques/nommees\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c('<c r="A1" t="s"><v>0</v></c>','<c r="B1" t="s"><v>1</v></c>','<c r="C1" t="s"><v>2</v></c>','<c r="D1" t="s"><v>3</v></c>')),
  rowx(2, c(cn("A2",1),cn("B2",2),cn("C2",3),cn("D2",4)))))),
  shared = paste0('<si><r><t>ri</t></r><r><rPr><b/></rPr><t>ch</t></r></si>',
                  '<si><t>a&amp;b</t></si>', '<si><t>&#233;t&#xE9;</t></si>', '<si><t xml:space="preserve">un deux</t></si>'))
aff(chemins(f, function(d) names(d)))
cat("\n== 1g. ecrit par openxlsx::write.xlsx : en-tetes 'a&b', 'x<y' + une colonne texte 'Tom & Jerry'\n")
d <- data.frame(`a&b` = 1:2, `x<y` = 3:4, `deux mots` = c("Tom & Jerry","<z>"), check.names = FALSE)
f <- tempfile(fileext = ".xlsx"); openxlsx::write.xlsx(d, f)
aff(chemins(f, function(x) {print(x); NULL}))
cat("\n== 1h. ecrit par l'ecrivain interne : memes donnees\n")
f2 <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(d, f2))
aff(chemins(f2, function(x) {print(x); NULL}))
cat("\n== 1i. en-tete avec espace (check sep.names) lu par les deux chemins\n")
aff(chemins(f2, function(x) names(x)))
