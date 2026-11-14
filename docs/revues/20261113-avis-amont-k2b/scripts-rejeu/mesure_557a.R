sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib"), .libPaths()))
source("R/charger_moteur.R"); charger_moteur()
source(file.path(sp, "fab.R"))
cat("openxlsx", as.character(packageVersion("openxlsx")), " locale:", Sys.getlocale("LC_CTYPE"), "\n")
cl <- function(n) file.path(sp, "classeurs", n)
num <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
sst <- function(ref, i) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, i)
row <- function(r, ...) sprintf('<row r="%d">%s</row>', r, paste0(..., collapse = ""))

# --- Reference : classeur sain, en-tetes en chaines partagees
fab(cl("ref.xlsx"), paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), row(2, num("A2",1), num("B2",1.5), num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("ref (sain)", lire2(cl("ref.xlsx")))

## ===== POINT 1 : t="str" =====
# 1a. en-tete en t="str" (resultat de formule), valeur sans entite
fab(cl("str_entete.xlsx"), paste0(
  row(1, '<c r="A1" t="str"><f>"t"</f><v>t</v></c>', '<c r="B1" t="str"><f>"xt"</f><v>xt</v></c>', '<c r="C1" t="str"><f>"yt"</f><v>yt</v></c>'),
  row(2, num("A2",1), num("B2",1.5), num("C2",2.5)), row(3, num("A3",2), num("B3",3), num("C3",4))))
montrer("1a. t=str, en-tete sans entite", lire2(cl("str_entete.xlsx")))
# 1b. en-tete t="str" avec entite : "a&amp;b" (formule ="a&b")
fab(cl("str_entete_ent.xlsx"), paste0(
  row(1, '<c r="A1" t="str"><f>"a&amp;b"</f><v>a&amp;b</v></c>', '<c r="B1" t="str"><f>"x&lt;t"</f><v>x&lt;t</v></c>', '<c r="C1" t="str"><v>y&#233;</v></c>'),
  row(2, num("A2",1), num("B2",1.5), num("C2",2.5))))
montrer("1b. t=str, en-tete avec entites (&amp; &lt; &#233;)", lire2(cl("str_entete_ent.xlsx")))
# 1c. corps en t="str" : nombre en chaine, formule texte
fab(cl("str_corps.xlsx"), paste0(
  row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), '<c r="B2" t="str"><f>TEXT(1.5,"0.0")</f><v>1.5</v></c>', num("C2",2.5)),
  row(3, num("A3",2), '<c r="B3" t="str"><v>a&amp;b</v></c>', num("C3",4))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("1c. t=str dans le corps ('1.5' et 'a&amp;b')", lire2(cl("str_corps.xlsx")))
# 1d. t=str vide : <v></v> et <v/>
fab(cl("str_vide.xlsx"), paste0(
  row(1, sst("A1",0), sst("B1",1), sst("C1",2)),
  row(2, num("A2",1), '<c r="B2" t="str"><f>""</f><v></v></c>', num("C2",2.5)),
  row(3, num("A3",2), num("B3",3), num("C3",4))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
montrer("1d. t=str avec <v></v> vide", lire2(cl("str_vide.xlsx")))
# 1e. controle ligne 1 : ligne 1 faite uniquement de t="str" blancs ; en-tete t=str seul
fab(cl("str_ligne1_blanche.xlsx"), paste0(
  row(1, '<c r="A1" t="str"><f>" "</f><v> </v></c>', '<c r="B1" t="str"><v></v></c>'),
  row(2, num("A2",1), num("B2",2))))
montrer("1e. ligne 1 = t=str blancs", lire2(cl("str_ligne1_blanche.xlsx")))
