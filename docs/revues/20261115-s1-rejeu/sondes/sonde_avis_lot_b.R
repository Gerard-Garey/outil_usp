# Usage: Rscript m.R <moteur> <cas> ; chemin selon R_LIBS
a <- commandArgs(TRUE); moteur <- a[1]; cas <- a[2]
setwd("/home/user/outil_usp"); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
source("docs/revues/20261115-s1-rejeu/sondes/forge.R")
ch <- if (requireNamespace("openxlsx", quietly = TRUE)) "ox" else "int"
retoucher <- function(f, motif, par) {
  d <- tempfile("ret_"); utils::unzip(f, exdir = d)
  p <- file.path(d, "xl/worksheets/sheet1.xml"); s <- readChar(p, file.info(p)$size, useBytes = TRUE)
  stopifnot(grepl(motif, s, fixed = TRUE))
  writeChar(sub(motif, par, s, fixed = TRUE), p, eos = NULL, useBytes = TRUE)
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0); f }
L <- serie()
b2 <- function(x) { l <- L; l[2] <- ligne(2, cn("A2", 1), x, cn("C2", 68.97)); l }
f <- switch(cas,
  "entete-t" = retoucher(forger(L), "</sheetData>", '</sheetData><headerFooter><oddHeader>&amp;CMontant t=1</oddHeader></headerFooter>'),
  "entete-t-s" = retoucher(forger(L), "</sheetData>", '</sheetData><headerFooter><oddHeader>&amp;C t="s"</oddHeader></headerFooter>'),
  "indente-is" = forger(b2('<c r="B2" t="inlineStr">\n  <is>\n    <t>104.2</t>\n  </is>\n</c>')),
  "indente-v" = forger(b2('<c r="B2">\n  <v>104.2</v>\n</c>')),
  "t-apos" = forger(b2('<c r="B2" t=\'s\'><v>0</v></c>'), partagees = "<si><t>11.5</t></si>"),
  "ts-sans-v" = forger(b2('<c r="B2" t="s"/>'), partagees = "<si><t>11.5</t></si>"),
  "ts-sans-v-f" = forger(b2('<c r="B2" t="s"><f>A1</f></c>'), partagees = "<si><t>11.5</t></si>"),
  "tb-sans-v" = forger(b2('<c r="B2" t="b"/>')),
  "tstr-sans-v" = forger(b2('<c r="B2" t="str"><f>A1</f></c>')),
  "minuscule" = forger(b2('<c r="b2"><v>104.2</v></c>')),
  "ordre-l1" = { l <- L; l[1] <- ligne(1, ci("A1", "t"), ci("C1", "yt"), ci("B1", "xt")); forger(l) },
  "ordre-l2" = { l <- L; l[2] <- ligne(2, cn("A2", 1), cn("C2", 68.97), cn("B2", 104.2)); forger(l) },
  "ordre-rows" = { l <- L[c(1, 3, 2, 4:9)]; forger(l) },
  "ordre-row1-fin" = { l <- L[c(2:9, 1)]; forger(l) },
  "is-vide" = forger(b2('<c r="B2" t="inlineStr"><is/></c>')),
  "is-t-vide" = forger(b2('<c r="B2" t="inlineStr"><is><t/></is></c>')),
  "is-t-vide2" = forger(b2('<c r="B2" t="inlineStr"><is><t></t></is></c>')),
  "v-space" = forger(b2('<c r="B2"><v xml:space="preserve">104.2</v></c>')),
  "reference" = forger(L))
r <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f), warning = function(w) invokeRestart("muffleWarning")), error = function(z) z)
if (inherits(r, "error")) { cat(ch, cas, "ERREUR", class(r)[1], ":", substr(conditionMessage(r), 1, 300), "\n"); quit(save="no") }
d <- e$engine_lire_donnees_csv(r)
cat(ch, cas, "noms =", names(r), "; dim =", dim(r), "; ok =", d$ok, "\n")
if (d$ok) { cat("  xt =", d$xt, "\n  yt =", d$yt, "\n")
  res <- e$run_engine(xt = d$xt, yt = d$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes")
  cat("  sigma_USP =", format(res$parametre$sigma_usp, digits = 10), "\n") } else cat("  erreurs :", head(d$erreurs, 2), "\n")
