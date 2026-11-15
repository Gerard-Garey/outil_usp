a <- commandArgs(TRUE); setwd("/home/user/outil_usp"); source("R/charger_moteur.R"); e <- charger_moteur(a[1], dans = NULL)
source("docs/revues/20261115-s1-rejeu/sondes/forge.R")
ch <- if (requireNamespace("openxlsx", quietly = TRUE)) "openxlsx" else "interne"
for (txt in c("NA", "true")) {
  f <- forger(serie(list("1" = '<c r="B2" t="s"><v>0</v></c>')), partagees = sprintf("<si><t>%s</t></si>", txt))
  df <- tryCatch(e$engine_lire_xlsx(f), error = function(x) x)
  if (inherits(df, "error")) { cat(txt, ch, "ERREUR", conditionMessage(df), "\n"); next }
  r <- e$engine_lire_donnees_csv(df)
  cat(txt, ch, "B2 =", encodeString(format(df$xt[1])), "; ok =", r$ok, ";", substr(paste(r$erreurs, collapse = " | "), 1, 200), "\n")
}
