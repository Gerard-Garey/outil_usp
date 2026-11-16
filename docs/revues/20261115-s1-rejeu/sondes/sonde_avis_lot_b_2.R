a <- commandArgs(TRUE); cas <- a[1]
setwd("/home/user/outil_usp"); source("R/charger_moteur.R"); e <- charger_moteur("R/engine.R", dans = NULL)
source("docs/revues/20261115-s1-rejeu/sondes/forge.R")
ch <- if (requireNamespace("openxlsx", quietly = TRUE)) "ox" else "int"
L <- serie(); ext <- function(x) c(L, sprintf('<row r="1048576">%s</row>', x))
f <- switch(cas,
  "xfd-s" = forger(ext('<c r="XFD1048576" t="s"/>'), partagees = "<si><t>11.5</t></si>"),
  "xfd-b" = forger(ext('<c r="XFD1048576" t="b"/>')),
  "xfd-str" = forger(ext('<c r="XFD1048576" t="str"/>')),
  "xfd-str-f" = forger(ext('<c r="XFD1048576" t="str"><f>A1</f></c>')),
  "xfd-is" = forger(ext('<c r="XFD1048576" t="inlineStr"/>')),
  "xfd-n-f" = forger(ext('<c r="XFD1048576"><f>A1</f></c>')),
  "xfd-e" = forger(ext('<c r="XFD1048576" t="e"/>')))
t0 <- proc.time()[[3]]
r <- tryCatch(e$engine_lire_xlsx(f), error = function(z) z)
cat(ch, cas, if (inherits(r, "error")) paste("ERREUR", class(r)[1], substr(conditionMessage(r), 1, 120)) else paste("lu", paste(dim(r), collapse = "x")), sprintf("(%.2f s)", proc.time()[[3]] - t0), "\n")
