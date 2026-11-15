a <- commandArgs(TRUE); setwd(a[1]); source("R/charger_moteur.R"); e <- charger_moteur(); source(file.path(a[2], "forge.R"))
sst <- c(charToRaw('<si><t>a'), as.raw(0xff), charToRaw('b</t></si><si><r><t>1</t></r><r><t>1.5</t></r></si>'))
f <- forger(serie(list("1" = '<c r="B2" t="s"><v>1</v></c>')), partagees = sst)
pile <- function() paste(vapply(sys.calls(), function(z) deparse(z[[1]])[1], ""), collapse = " > ")
r <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
  warning = function(w) { cat("AVERTISSEMENT :", conditionMessage(w), "\n  pile :", pile(), "\n"); invokeRestart("muffleWarning") },
  error = function(x) cat("ERREUR :", conditionMessage(x), "\n  pile :", pile(), "\n")), error = function(x) NULL)
if (!is.null(r)) { cat("lu : B2 =", encodeString(as.character(r$xt[1])), "\n") }
# Les controles Q-F / P2 / X1 sur cette table, isoles
sx <- e$.xlsx_texte(file.path({d <- tempfile(); utils::unzip(f, exdir = d); d}, "xl", "sharedStrings.xml"))
cat("validUTF8(table) =", validUTF8(sx), "\n")
cat("Q-F grepl :", tryCatch(grepl(paste0("<", e$XML_PREFIXE_NOM, "r[[:space:]/>]"), sx), error = function(x) paste("ERREUR", conditionMessage(x)),
                            warning = function(w) paste("AVERT", conditionMessage(w))), "\n")
