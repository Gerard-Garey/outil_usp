a <- commandArgs(TRUE); setwd("/home/user/outil_usp"); source("R/charger_moteur.R"); e <- charger_moteur(a[1], dans = NULL)
source("docs/revues/20261115-s1-rejeu/sondes/forge.R")
ch <- if (requireNamespace("openxlsx", quietly = TRUE)) "openxlsx" else "interne"
cas <- list(
  q6_entete_D = list(l1 = paste0(ci("A1","t"), ci("B1","xt"), ci("C1","yt"), '<c r="D1" t="s"><v>0</v></c>'), sh = "<si><t\n/>\n</si>"),
  q6_entete_B = list(l1 = paste0(ci("A1","t"), '<c r="B1" t="s"><v>0</v></c>', ci("C1","yt")), sh = "<si><t\n/>\n</si>"),
  q7_entete_B = list(l1 = paste0(ci("A1","t"), '<c r="B1" t="s"><v>0</v></c>', ci("C1","yt")), sh = "<si><t>x&#116;</t></si>"),
  q7_entete_doublon = list(l1 = paste0(ci("A1","t"), '<c r="B1" t="s"><v>0</v></c>', ci("C1","yt"), ci("D1","xt")), sh = "<si><t>x&#116;</t></si>"))
for (n in names(cas)) {
  l <- cas[[n]]$l1; l <- ligne(1, l)
  for (k in 1:8) l <- c(l, ligne(k + 1, cn(paste0("A", k + 1), k), cn(paste0("B", k + 1), LN$xt[k]), cn(paste0("C", k + 1), LN$yt[k]),
                                 if (n %in% c("q6_entete_D", "q7_entete_doublon")) cn(paste0("D", k + 1), LN$xt[k] * 2)))
  f <- forger(l, partagees = cas[[n]]$sh)
  df <- tryCatch(e$engine_lire_xlsx(f), error = function(x) x)
  if (inherits(df, "error")) { cat(n, ch, "ERREUR", substr(conditionMessage(df), 1, 150), "\n"); next }
  r <- e$engine_lire_donnees_csv(df)
  s <- if (r$ok) { z <- e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"); if (isTRUE(z$ok)) sprintf("%.10f", z$parametre$sigma_usp) else "run KO" } else paste("refus:", substr(paste(r$erreurs, collapse = " | "), 1, 160))
  cat(n, ch, "noms =", encodeString(paste(names(df), collapse = ",")), ";", s, "\n")
}
