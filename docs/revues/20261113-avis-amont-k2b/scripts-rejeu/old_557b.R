sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib_old"), file.path(sp, "lib"), .libPaths()))
source("R/charger_moteur.R"); charger_moteur()
source(file.path(sp, "fab.R"))
cl <- function(n) file.path(sp, "classeurs", n)
num <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
sst <- function(ref, i) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, i)
row <- function(r, ...) sprintf('<row r="%d">%s</row>', r, paste0(..., collapse = ""))
corps <- paste0(row(2, num("A2",1), num("B2",1.5), num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4)))

## 1f. colonne entiere en t="str" numerique
fab(cl("str_num.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), '<c r="B2" t="str"><v>1.5</v></c>', num("C2",2.5)),
  row(3, num("A3",2), '<c r="B3" t="str"><v>3</v></c>', num("C3",4))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("1f. colonne xt toute en t=str numerique ('1.5','3')", lire2(cl("str_num.xlsx")))

## ===== POINT 2 : rPh =====
# chaines partagees avec <rPh> : en-tete "xt" + phonetique "ZZ"
sh_rph <- c('<t>t</t>', '<t>xt</t><rPh sb="0" eb="2"><t>ZZ</t></rPh><phoneticPr fontId="1"/>', '<t>yt</t>')
fab(cl("rph_entete.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), corps), shared = sh_rph)
montrer("2a. rPh dans une chaine partagee d'en-tete (xt + rPh 'ZZ')", lire2(cl("rph_entete.xlsx")))
# rPh dans une chaine partagee d'une cellule de corps (colonne texte)
fab(cl("rph_corps.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), sst("B2",3), num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4))),
  shared = c('<t>t</t>','<t>xt</t>','<t>yt</t>','<t>abc</t><rPh sb="0" eb="3"><t>ZZ</t></rPh>'))
montrer("2b. rPh dans une chaine partagee du corps (abc + rPh 'ZZ')", lire2(cl("rph_corps.xlsx")))
# rPh dans une chaine en ligne
fab(cl("rph_inline.xlsx"), paste0(row(1, '<c r="A1" t="inlineStr"><is><t>t</t></is></c>', '<c r="B1" t="inlineStr"><is><t>xt</t><rPh sb="0" eb="2"><t>ZZ</t></rPh></is></c>', '<c r="C1" t="inlineStr"><is><t>yt</t></is></c>'), corps))
montrer("2c. rPh dans une chaine en ligne d'en-tete", lire2(cl("rph_inline.xlsx")))
# rPh : fichier ou le <t> est dans <r> + rPh
sh_rich <- c('<t>t</t>', '<r><t>x</t></r><r><t>t</t></r><rPh sb="0" eb="2"><t>ZZ</t></rPh>', '<t>yt</t>')
fab(cl("rph_rich.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), corps), shared = sh_rich)
montrer("2d. chaine partagee enrichie (<r><t>x</t></r><r><t>t</t></r>) + rPh", lire2(cl("rph_rich.xlsx")))
# <phoneticPr> sans rPh, ou rPh sans texte <t>: sans effet ? 
sh_pp <- c('<t>t</t>', '<t>xt</t><phoneticPr fontId="1"/>', '<t>yt</t>')
fab(cl("phoneticpr.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), corps), shared = sh_pp)
montrer("2e. phoneticPr seul (sans rPh)", lire2(cl("phoneticpr.xlsx")))

## ===== POINT 3 : r="" =====
fab(cl("r_vide_corps.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), '<c r=""><v>1.5</v></c>', num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("3a. r=\"\" sur une cellule du corps", lire2(cl("r_vide_corps.xlsx")))
fab(cl("r_vide_entete.xlsx"), paste0(row(1, sst("A1",0), '<c r="" t="s"><v>1</v></c>', sst("C1",2)), corps), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("3b. r=\"\" sur une cellule d'en-tete", lire2(cl("r_vide_entete.xlsx")))
fab(cl("r_vide_tout.xlsx"), paste0(row(1, '<c r="" t="s"><v>0</v></c>', '<c r="" t="s"><v>1</v></c>', '<c r="" t="s"><v>2</v></c>'),
  row(2, '<c r=""><v>1</v></c>', '<c r=""><v>1.5</v></c>', '<c r=""><v>2.5</v></c>')), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("3c. r=\"\" partout", lire2(cl("r_vide_tout.xlsx")))
fab(cl("r_sans.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), '<c><v>1.5</v></c>', num("C2",2.5))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("3d. (temoin) cellule sans attribut r : refus motive existant", lire2(cl("r_sans.xlsx")))
# r invalide autre : r="1A", r="A", r="A0", r="ZZZZ1"
for (rv in c("A", "1", "A0", "1A", "A1:B2", " A2 ")) {
  fab(cl("r_autre.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
    row(2, num("A2",1), sprintf('<c r="%s"><v>1.5</v></c>', rv), num("C2",2.5))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
  montrer(sprintf("3e. r=\"%s\" (autre forme invalide), corps B2", rv), lire2(cl("r_autre.xlsx")))
}
