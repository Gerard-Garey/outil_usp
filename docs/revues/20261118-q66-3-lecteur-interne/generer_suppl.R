# Q-66-3 : classeurs supplementaires (ecrivain interne et openxlsx::write.xlsx()),
# dont une serie de 5 000 lignes pour la mesure de duree.
# Usage (racine du depot, openxlsx installe) : Rscript generer_suppl.R <sortie>
o <- commandArgs(TRUE)[1]; dir.create(o, showWarnings = FALSE, recursive = TRUE)
source("R/charger_moteur.R"); charger_moteur()
ln <- read.csv("tests/donnees/donnees_ln.csv")
tr <- read.csv("tests/donnees/triangle_mw.csv", check.names = FALSE)
engine_ecrire_xlsx(ln, file.path(o, "interne_series.xlsx"))
engine_ecrire_xlsx(tr, file.path(o, "interne_triangle.xlsx"))
openxlsx::write.xlsx(ln, file.path(o, "openxlsx_series.xlsx"))
openxlsx::write.xlsx(tr, file.path(o, "openxlsx_triangle.xlsx"))
set.seed(1)
g <- data.frame(t = 1:5000, xt = round(rlnorm(5000, 10), 2), yt = round(rlnorm(5000, 9), 2))
engine_ecrire_xlsx(g, file.path(o, "interne_series_5000.xlsx"))
openxlsx::write.xlsx(g, file.path(o, "openxlsx_series_5000.xlsx"))
