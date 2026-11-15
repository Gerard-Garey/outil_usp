a <- commandArgs(TRUE); depot <- a[1]; sd <- a[2]; cas <- a[3]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur()
source(file.path(sd, "forge.R"))
ch <- if (requireNamespace("openxlsx", quietly = TRUE)) paste("openxlsx", packageVersion("openxlsx")) else "interne"
cat(sprintf("[%s] %s\n", cas, ch))
essai <- function(expr) tryCatch(expr, error = function(err) { cat("  ERREUR", class(err)[1], ":", conditionMessage(err), "\n"); NULL })
lire <- function(f) {
  t0 <- proc.time()[["elapsed"]]
  df <- essai(e$engine_lire_xlsx(f)); cat(sprintf("  duree lecture %.2f s\n", proc.time()[["elapsed"]] - t0))
  if (is.null(df)) return(invisible(NULL))
  cat("  dim", dim(df), "; classes", paste(names(df)[1:min(3,ncol(df))], vapply(df[1:min(3,ncol(df))], function(v) class(v)[1], ""), sep = "=", collapse = " "), "\n")
  if ("xt" %in% names(df)) cat("  xt[1] =", encodeString(as.character(df$xt[1])), "\n")
  r <- e$engine_lire_donnees_csv(df); cat("  lire_donnees ok =", r$ok, if (r$ok) paste("xt1 =", r$xt[1]) else r$erreurs, "\n")
}
cel <- function(x) list("1" = x)
switch(cas,
 e = lire(forger(serie(cel('<c r="B2" t="e"><v>#N/A</v></c>')))),
 d = lire(forger(serie(cel('<c r="B2" t="d"><v>2020-01-01T00:00:00</v></c>')))),
 str = lire(forger(serie(cel('<c r="B2" t="str"><f>"12"&amp;".5"</f><v>12.5</v></c>')))),
 x = lire(forger(serie(cel('<c r="B2" t="x"><v>5</v></c>')))),
 b2 = lire(forger(serie(cel('<c r="B2" t="b"><v>2</v></c>')))),
 hex = lire(forger(serie(cel('<c r="B2"><v>0x10</v></c>')))),
 inf = lire(forger(serie(cel('<c r="B2"><v>INF</v></c>')))),
 blanc = lire(forger(serie(cel('<c r="B2"><v> 5</v></c>')))),
 ent = lire(forger(serie(cel('<c r="B2"><v>&#49;5</v></c>')))),
 vide_xfd = lire(forger(serie(extra = '</row><row r="1048576"><c r="XFD1048576" s="1"/>'))),
 vide_1e6 = lire(forger(serie(extra = '</row><row r="100000"><c r="J100000" s="1"/>'))),
 vide_1e7 = lire(forger(serie(extra = '</row><row r="100000"><c r="CV100000" s="1"/>'))),
 val_1e7 = lire(forger(serie(extra = '</row><row r="100000"><c r="CV100000"><v>1</v></c>'))),
 val_1e6 = lire(forger(serie(extra = '</row><row r="100000"><c r="J100000"><v>1</v></c>'))),
 rph = lire(forger(serie(cel('<c r="B2" t="s"><v>0</v></c>')), partagees = '<si><r><rPr><b/></rPr><t>1</t></r><r><t>1.5</t></r><rPh sb="0" eb="1"><t>7</t></rPh></si>')),
 xrph_t = lire(forger(serie(cel('<c r="B2" t="s"><v>0</v></c>')), partagees = '<si><t>11.5</t><x:rPh sb="0" eb="1"><t>7</t></x:rPh></si>')),
 xall = lire(forger(serie(cel('<c r="B2" t="s"><v>0</v></c>')), partagees = '<x:si><x:t>11.5</x:t></x:si>')),
 is_s = lire(forger(serie(cel('<c r="B2" t="s"><is><t>11.5</t></is></c>')), partagees = '<si><t>9</t></si>')),
 n_is = lire(forger(serie(cel('<c r="B2"><is><t>11.5</t></is></c>')))),
 rowr = lire(forger(serie(cel('<c r="B5"><v>777</v></c>')))),
 direct = {
   yt <- LN$yt
   print(e$engine_valider_donnees(rep(TRUE, 8), yt)$erreurs)
   r <- essai(e$run_engine(xt = rep(TRUE, 8), yt = yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"))
   if (!is.null(r)) { cat("  run_engine logique ok =", r$ok, "\n"); if (!r$ok) print(r$validation$erreurs) else cat("  sigma", r$parametre$sigma_usp, "\n") }
   tri <- matrix(TRUE, 5, 5); tri[row(tri) + col(tri) > 6] <- NA
   print(e$mw_valider_triangle(tri)$erreurs)
   r <- essai(e$run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II"))
   if (!is.null(r)) { cat("  run_engine reserve2 logique ok =", r$ok, "\n"); print(r$validation$erreurs) }
 },
 b570 = {
   nb <- rawToChar(as.raw(c(0x61, 0xff, 0x62))); Encoding(nb) <- "bytes"
   d <- data.frame(0, 0:4, c(100, 110, 115, 125, 150)); names(d) <- c(nb, "i", "j0")
   r <- essai(e$engine_lire_triangle(d)); if (!is.null(r)) cat("  triangle, bytes en col 1 : ok =", r$ok, r$erreurs, sep = "\n  ")
   d <- data.frame(c(100, 110, 115, 125, 150)); names(d) <- nb
   r <- essai(e$engine_lire_triangle(d)); if (!is.null(r)) cat("  triangle, seule col bytes : ok =", r$ok, r$erreurs, sep = "\n  ")
   d <- data.frame(1:8, LN$xt, LN$yt, 0); names(d) <- c("t", nb, "xt", "yt")
   r <- essai(e$engine_lire_donnees_csv(d)); if (!is.null(r)) cat("  serie t, bytes, xt, yt : ok =", r$ok, "\n")
 },
 apres579 = {
   env <- environment(e$run_engine)
   assign(".en_numerique", function(v) { if (is.factor(v)) v <- as.character(v)
     if (is.character(v)) return(env$.cellules_en_nombre(env$.nettoyer_cellules(v)))
     if (is.logical(v)) return(rep(NA_real_, length(v)))
     suppressWarnings(as.numeric(v)) }, envir = env)
   r <- e$engine_lire_donnees_csv(data.frame(t = 1:8, xt = rep(TRUE, 8), yt = LN$yt)); cat("  df logique :", r$ok, r$erreurs, "\n")
   r <- e$engine_lire_donnees_csv(data.frame(t = 1:8, xt = c(LN$xt[1:7], NA), yt = LN$yt)); cat("  df xt NA final numerique :", r$ok, r$erreurs, "\n")
   r <- e$engine_lire_donnees_csv(data.frame(t = 1:8, xt = LN$xt, yt = LN$yt, z = NA)); cat("  df colonne logique NA en plus :", r$ok, "\n")
   r <- e$engine_lire_donnees_csv(data.frame(t = 1:8, xt = LN$xt, yt = LN$yt, z = TRUE)); cat("  df colonne logique TRUE en plus :", r$ok, "\n")
   r <- e$engine_lire_donnees_csv(data.frame(t = c(1:7, NA), xt = c(LN$xt[1:7], NA), yt = c(LN$yt[1:7], NA))); cat("  derniere ligne NA :", r$ok, r$erreurs, "\n")
   d <- data.frame(t = 1:8, xt = LN$xt, yt = LN$yt, w = NA); d$w <- NA
   tri <- data.frame(i = 0:4, j0 = c(100,110,115,125,150), j1 = c(150,168,169,185,NA), j2 = c(175,192,197,NA,NA), j3 = c(180,198,NA,NA,NA), j4 = c(TRUE,NA,NA,NA,NA))
   r <- e$engine_lire_triangle(tri); cat("  triangle C(0,4) logique :", r$ok, r$erreurs, "\n")
   tri$j4 <- NA; r <- e$engine_lire_triangle(tri); cat("  triangle j4 logique NA :", r$ok, r$erreurs, "\n")
 },
 stop("?"))
g <- gc(); cat(sprintf("  memoire max (Ncells+Vcells) : %.0f Mo\n", sum(g[, 6])))
