sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib"), .libPaths()))
source("R/charger_moteur.R"); charger_moteur()
source(file.path(sp, "fab.R"))
cl <- function(n) file.path(sp, "classeurs", n)
num <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
sst <- function(ref, i) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, i)
row <- function(r, ...) sprintf('<row r="%d">%s</row>', r, paste0(..., collapse = ""))
corps <- paste0(row(2, num("A2",1), num("B2",1.5), num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4)))
sh <- c("<t>t</t>","<t>xt</t>","<t>yt</t>")
## 3e rejoue : avertissements captures, valeur conservee
for (rv in c("A", "1", "A0", "1A", "A1:B2", " A2 ", "a2", "B2")) {
  fab(cl("r_autre.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
    row(2, num("A2",1), sprintf('<c r="%s"><v>1.5</v></c>', rv), num("C2",2.5))), shared = sh)
  montrer(sprintf("3e. r=\"%s\", cellule du corps (xt=1.5 attendu en B2)", rv), lire2(cl("r_autre.xlsx")))
}
## ===== POINT 4 : commentaire d'en-tete : chaine enrichie en ligne =====
fab(cl("inline_riche_entete.xlsx"), paste0(row(1, '<c r="A1" t="inlineStr"><is><t>t</t></is></c>',
   '<c r="B1" t="inlineStr"><is><r><t>x</t></r><r><t>t</t></r></is></c>', '<c r="C1" t="inlineStr"><is><t>yt</t></is></c>'), corps))
montrer("4a. en-tete en chaine EN LIGNE enrichie (<is><r><t>x</t></r><r><t>t</t></r></is>)", lire2(cl("inline_riche_entete.xlsx")))
fab(cl("inline_riche_corps.xlsx"), paste0(row(1, '<c r="A1" t="inlineStr"><is><t>t</t></is></c>','<c r="B1" t="inlineStr"><is><t>xt</t></is></c>', '<c r="C1" t="inlineStr"><is><t>yt</t></is></c>'),
   row(2, num("A2",1), '<c r="B2" t="inlineStr"><is><r><t>a</t></r><r><t>bc</t></r></is></c>', num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4))))
montrer("4b. corps en chaine EN LIGNE enrichie (a+bc)", lire2(cl("inline_riche_corps.xlsx")))
# chaine PARTAGEE enrichie (cas courant d'Excel) 
fab(cl("partagee_riche.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), corps), shared = c("<t>t</t>", "<r><rPr><b/></rPr><t>x</t></r><r><t>t</t></r>", "<t>yt</t>"))
montrer("4c. en-tete en chaine PARTAGEE enrichie (<r><rPr/><t>x</t></r><r><t>t</t></r>)", lire2(cl("partagee_riche.xlsx")))
# <is> avec xml:space et blancs
fab(cl("inline_preserve.xlsx"), paste0(row(1, '<c r="A1" t="inlineStr"><is><t>t</t></is></c>','<c r="B1" t="inlineStr"><is><t xml:space="preserve">xt</t></is></c>', '<c r="C1" t="inlineStr"><is><t>yt</t></is></c>'), corps))
montrer("4d. en-tete en chaine en ligne <t xml:space=\"preserve\">xt</t>", lire2(cl("inline_preserve.xlsx")))
