source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
cat("avec_ox =", avec_ox, "\n")
feuille <- function(base, nom_en = c("t","xt","yt")) paste0(
  rowx(1, c(ci("A1", "<t>t</t>"), ci("B1", "<t>xt</t>"), ci("C1", "<t>yt</t>"))),
  rowx(2, c(cn("A2", 2001), cn("B2", base + 1), cn("C2", base + 2))),
  rowx(3, c(cn("A3", 2002), cn("B3", base + 3), cn("C3", base + 4))))
aff <- function(r) for (n in names(r)) { cat("  [", n, "]\n", sep=""); print(r[[n]]) }

cat("\n== 1a. Donnees en sheet2.xml (premiere feuille du workbook), Brouillon en sheet1.xml\n")
f <- mk_classeur(list(list(nom="Donnees", fichier="sheet2.xml", xml=feuille(200)),
                      list(nom="Brouillon", fichier="sheet1.xml", xml=feuille(100))))
aff(chemins(f))

cat("\n== 1b. sheet10.xml (premiere du workbook) et sheet2.xml\n")
f <- mk_classeur(list(list(nom="Donnees", fichier="sheet10.xml", xml=feuille(200)),
                      list(nom="Autre", fichier="sheet2.xml", xml=feuille(100))))
aff(chemins(f))

cat("\n== 1c. entites XML : en-tete a&amp;b, &#233; &#xE9; &lt; &quot; &apos; (inlineStr), et sharedStrings\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c(ci("A1", "<t>a&amp;b</t>"), ci("B1", "<t>&#233;t&#xE9;</t>"), ci("C1", "<t>&lt;x&gt; &quot;q&quot; &apos;a&apos;</t>"), '<c r="D1" t="s"><v>0</v></c>')),
  rowx(2, c(cn("A2", 1), cn("B2", 2), cn("C2", 3), cn("D2", 4)))))),
  shared = '<si><t>s&amp;p</t></si>')
aff(chemins(f, function(d) names(d)))

cat("\n== 1d. chaines en ligne enrichies (plusieurs segments <r><t>)\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c(ci("A1", '<r><t>x</t></r><r><t>t</t></r>'), ci("B1", '<r><rPr><b/></rPr><t>y</t></r><r><t>t</t></r>'), ci("C1", '<t>c</t>'))),
  rowx(2, c(ci("A2", '<r><t>ab</t></r><r><t>cd</t></r>'), cn("B2", 2), cn("C2", 3)))))))
aff(chemins(f, function(d) {print(d); names(d)}))

cat("\n== 1e. cellule sans attribut r (ligne 1 et 2 ; toutes sans r)\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  '<row r="1"><c t="inlineStr"><is><t>t</t></is></c><c t="inlineStr"><is><t>xt</t></is></c><c t="inlineStr"><is><t>yt</t></is></c></row>',
  '<row r="2"><c><v>2001</v></c><c><v>5</v></c><c><v>6</v></c></row>',
  '<row r="3"><c><v>2002</v></c><c><v>7</v></c><c><v>8</v></c></row>'))))
aff(chemins(f, function(d) {print(d); d}))
cat("\n== 1e'. une seule cellule sans r au milieu\n")
f <- mk_classeur(list(list(nom="D", fichier="sheet1.xml", xml=paste0(
  rowx(1, c(ci("A1", "<t>t</t>"), ci("B1", "<t>xt</t>"), ci("C1", "<t>yt</t>"))),
  rowx(2, c(cn("A2", 2001), '<c><v>5</v></c>', cn("C2", 6)))))))
aff(chemins(f, function(d) {print(d); d}))
