# Usage : Rscript sonde.R <depot> <dossier_sondes> <cas>
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
a <- commandArgs(TRUE); depot <- a[1]; sd <- a[2]; cas <- a[3]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur()
source(file.path(sd, "forge.R"))
chemin <- if (requireNamespace("openxlsx", quietly = TRUE))
  paste("openxlsx", as.character(packageVersion("openxlsx"))) else "interne"
cat(sprintf("[%s] chemin = %s\n", cas, chemin))
essai <- function(expr) tryCatch(expr, error = function(err)
  { cat(sprintf("  ERREUR classe = %s\n  message = %s\n", paste(class(err), collapse = "/"), conditionMessage(err))); NULL })
lire_serie <- function(f) {
  df <- essai(e$engine_lire_xlsx(f)); if (is.null(df)) return(invisible(NULL))
  cat("  classes colonnes :", paste(names(df), vapply(df, function(v) class(v)[1], ""), sep = "=", collapse = " "), "\n")
  r <- e$engine_lire_donnees_csv(df)
  cat("  engine_lire_donnees_csv : ok =", r$ok, "\n")
  if (r$ok) cat("  xt =", format(r$xt, digits = 10), "\n") else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n"); invisible(r)
}
moteur <- function(r) {
  if (is.null(r) || !isTRUE(r$ok)) return(invisible(NULL))
  res <- e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes")
  cat("  run_engine : ok =", res$ok, if (isTRUE(res$ok)) sprintf(" sigma_USP = %.10f", res$parametre$sigma_usp %||% NA) else "", "\n")
  if (!isTRUE(res$ok)) print(res$validation)
  invisible(res)
}
`%||%` <- function(a, b) if (is.null(a)) b else a
switch(cas,
"574-1" = {  # <x:si> mele a des <si> : indice decale
  f <- forger(serie(list("1" = '<c r="B2" t="s"><v>0</v></c>')),
              partagees = '<x:si><x:t>9</x:t></x:si><si><t>11.5</t></si>')
  cat("  cellule B2 : t=\"s\" indice 0 ; chaine 0 = <x:si> \"9\", chaine 1 = <si> \"11.5\" ; valeur attendue (rang 0) : 9\n")
  lire_serie(f)
},
"574-2" = {  # segments <r> (avec <rPr>) puis bloc <x:rPh>
  f <- forger(serie(list("1" = '<c r="B2" t="s"><v>0</v></c>')),
              partagees = '<si><r><rPr><b/></rPr><t>1</t></r><r><t>1.5</t></r><x:rPh sb="0" eb="1"><t>7</t></x:rPh></si>')
  cat("  cellule B2 : t=\"s\" -> <r>1</r><r>1.5</r><x:rPh>7</x:rPh> ; valeur attendue : 11.5\n")
  lire_serie(f)
},
"574-3a" = , "574-3b" = {  # reference sans borne
  ref <- if (cas == "574-3a") "XFD1048576" else "A99999999999"
  l <- serie(); l <- c(l, sprintf('<row r="%s"><c r="%s"><v>1</v></c></row>', sub("^[A-Z]+", "", ref), ref))
  f <- forger(l)
  cat("  cellule supplementaire :", ref, "\n")
  t0 <- proc.time()[["elapsed"]]; lire_serie(f); cat(sprintf("  duree : %.2f s\n", proc.time()[["elapsed"]] - t0))
},
"574-4" = {  # milliers de <x:rPh> non fermes
  for (n in c(1000, 2000, 4000)) {
    blocs <- paste(rep('<x:rPh sb="0" eb="1">', n), collapse = "")
    # (a) dans la table des chaines partagees ; (b) dans une chaine en ligne
    fa <- forger(serie(list("1" = '<c r="B2" t="s"><v>0</v></c>')), partagees = paste0('<si><t>11</t>', blocs, '</si>'))
    fb <- forger(serie(list("1" = paste0('<c r="B2" t="inlineStr"><is><t>11</t>', blocs, '</is></c>'))))
    for (v in c("a_partagee", "b_en_ligne")) {
      f <- if (v == "a_partagee") fa else fb
      t0 <- proc.time()[["elapsed"]]
      df <- essai(e$engine_lire_xlsx(f))
      cat(sprintf("  n = %5d, %s : %.2f s ; B2 lu = %s\n", n, v, proc.time()[["elapsed"]] - t0,
                  if (is.null(df)) "(erreur)" else encodeString(as.character(df$xt[1]))))
    }
  }
},
"574-5" = {  # table des chaines partagees en UTF-8 invalide, forme Q-F (segments <r> sans <rPr>)
  sst <- c(charToRaw('<si><t>a'), as.raw(0xff), charToRaw('b</t></si><si><r><t>1</t></r><r><t>1.5</t></r></si>'))
  f <- forger(serie(list("1" = '<c r="B2" t="s"><v>1</v></c>')), partagees = sst)
  cat("  table : chaine 0 \"a<ff>b\" (UTF-8 invalide), chaine 1 en segments <r> \"1\" + \"1.5\" sans <rPr> (forme Q-F) ; B2 -> chaine 1 ; refus Q-F attendu\n")
  lire_serie(f)
  # Variantes P2 et X1
  for (v in list(c("P2", '<si><t>1</t><rPh sb="0" eb="1"/><r><rPr><b/></rPr><t>1.5</t></r></si>'),
                 c("X1", '<si><t>1</t><t>1.5</t></si>'))) {
    sst <- c(charToRaw('<si><t>a'), as.raw(0xff), charToRaw('b</t></si>'), charToRaw(v[2]))
    f <- forger(serie(list("1" = '<c r="B2" t="s"><v>1</v></c>')), partagees = sst)
    cat("  variante", v[1], ": refus", v[1], "attendu\n"); lire_serie(f)
  }
},
"574-m1" = {  # deux cellules de meme reference
  f <- forger(serie(list("1" = '<c r="B2"><v>104.2</v></c><c r="B2"><v>999</v></c>')))
  cat("  B2 present deux fois : 104.2 puis 999\n")
  lire_serie(f)
},
"575" = {  # indice de chaine partagee hors bornes
  f <- forger(c(ligne(1, '<c r="A1" t="s"><v>0</v></c>'), ligne(2, '<c r="A2" t="s"><v>5</v></c>')),
              partagees = '<si><t>annee</t></si>')
  cat("  table a une <si>, A2 t=\"s\" indice 5\n")
  df <- essai(e$engine_lire_xlsx(f)); str(df)
},
"579-b" = , "579-txt" = {  # colonne xt booleenne (t="b") ou en textes "TRUE"
  cel <- setNames(lapply(1:8, function(k) if (cas == "579-b") sprintf('<c r="B%d" t="b"><v>1</v></c>', k + 1)
                         else ci(paste0("B", k + 1), "TRUE")), as.character(1:8))
  f <- forger(serie(cel))
  cat("  colonne xt :", if (cas == "579-b") "cellules t=\"b\" valeur 1" else "chaines en ligne \"TRUE\"", "\n")
  moteur(lire_serie(f))
},
"579-tri" = {  # triangle 5x5, C(0,4) booleen
  tri <- matrix(c(100, 150, 175, 180, 182,
                  110, 168, 192, 198, NA,
                  115, 169, 197, NA, NA,
                  125, 185, NA, NA, NA,
                  150, NA, NA, NA, NA), 5, byrow = TRUE)
  l <- ligne(1, ci("A1", "i"), paste0(vapply(0:4, function(j) ci(paste0(LETTERS[j + 2], 1), paste0("j", j)), ""), collapse = ""))
  for (i in 0:4) {
    cel <- cn(paste0("A", i + 2), i)
    for (j in 0:4) if (!is.na(tri[i + 1, j + 1])) {
      ref <- paste0(LETTERS[j + 2], i + 2)
      cel <- c(cel, if (i == 0 && j == 4) sprintf('<c r="%s" t="b"><v>1</v></c>', ref) else cn(ref, tri[i + 1, j + 1]))
    }
    l <- c(l, ligne(i + 2, paste(cel, collapse = "")))
  }
  f <- forger(l)
  df <- essai(e$engine_lire_xlsx(f))
  if (!is.null(df)) {
    cat("  classe de j4 :", class(df$j4), "\n")
    r <- e$engine_lire_triangle(df)
    cat("  engine_lire_triangle : ok =", r$ok, if (isTRUE(r$ok)) paste(" C(0,4) =", r$triangle[1, 5]) else "", "\n")
    if (!r$ok) cat("  erreurs :", r$erreurs, sep = "\n    ")
    if (isTRUE(r$ok)) { res <- e$run_engine(methode = "reserve2", triangle = r$triangle, segment = 1, annexe = "II")
      cat("\n  run_engine reserve2 : ok =", res$ok, "\n"); if (!res$ok) print(res$validation) }
  }
},
"579-df" = {  # appel direct, data.frame a colonne logique (comme apres read.csv())
  r <- e$engine_lire_donnees_csv(data.frame(t = 1:8, xt = rep(TRUE, 8), yt = LN$yt))
  cat("  engine_lire_donnees_csv : ok =", r$ok, " xt =", r$xt, "\n"); moteur(r)
  tf <- tempfile(fileext = ".csv"); writeLines(c("t,xt,yt", sprintf("%d,TRUE,%s", 1:8, LN$yt)), tf)
  d <- read.csv(tf); cat("  read.csv() par defaut : classe de xt =", class(d$xt), "\n")
  r <- e$engine_lire_donnees_csv(d); cat("  engine_lire_donnees_csv : ok =", r$ok, " xt =", r$xt, "\n"); moteur(r)
},
"570" = {  # nom de colonne d'encodage "bytes"
  nb <- rawToChar(as.raw(c(0x61, 0xff, 0x62))); Encoding(nb) <- "bytes"
  for (v in list(c("t", "xt", "BYTES"), c("t", "xt", "yt", "BYTES"), c("BYTES", "xt", "yt"))) {
    d <- data.frame(1:5, c(100, 101, 102, 103, 104), c(50, 51, 52, 53, 54), 0)
    d <- d[seq_along(v)]; nm <- v; nm[nm == "BYTES"] <- nb; names(d) <- nm
    cat("  noms :", paste(ifelse(v == "BYTES", "<bytes a\\xffb>", v), collapse = ", "), "\n")
    r <- essai(e$engine_lire_donnees_csv(d))
    if (!is.null(r)) { cat("  ok =", r$ok, "\n"); if (!r$ok) cat("  erreurs :", r$erreurs, sep = "\n    "); cat("\n") }
  }
  # Modele : le triangle (mw_valider_triangle, #321) ; meme nom en appel direct d'engine_lire_triangle()
  d <- data.frame(i = 0:4, j0 = c(100, 110, 115, 125, 150)); names(d)[2] <- nb
  cat("  engine_lire_triangle, colonne 2 au nom bytes :\n"); r <- essai(e$engine_lire_triangle(d))
  if (!is.null(r)) cat("  ok =", r$ok, "\n  erreurs :", r$erreurs, sep = "\n    ")
},
"588" = {  # octet 0x81 declare Latin-1 (assertion #522)
  l1 <- function(b) { x <- rawToChar(as.raw(c(0x61, b, 0x62))); Encoding(x) <- "latin1"; x }
  d <- as.data.frame(matrix(1, 2, 3)); names(d) <- c(l1(0xa0), l1(0x81), l1(0xe9))
  r <- e$engine_lire_donnees_csv(d)
  obtenu <- sub("^.*Colonnes presentes : (.*)\\.$", "\\1", r$erreurs)
  cat("  obtenu  :", encodeString(obtenu, quote = '"'), "\n")
  cat("  attendu :", encodeString("a\\u00a0b, a<81>b, aéb", quote = '"'), "\n")
  cat("  identical :", identical(obtenu, "a\\u00a0b, a<81>b, aéb"), "\n")
  x <- l1(0x81); u <- enc2utf8(x)
  cat("  enc2utf8(0x81 latin1) : octets =", paste(charToRaw(u), collapse = " "), "; Encoding =", Encoding(u),
      "; validUTF8 =", validUTF8(u), "; utf8ToInt =", paste(utf8ToInt(u), collapse = " "), "\n")
  cat("  .echapper_texte :", encodeString(e$.echapper_texte(x)), "\n")
  cat("  iconv(latin1 -> UTF-8) :", paste(charToRaw(iconv(x, "latin1", "UTF-8")), collapse = " "), "\n")
  cat("  l10n_info :", paste(names(l10n_info()), unlist(l10n_info()), sep = "=", collapse = " "), "\n")
},
stop("cas inconnu"))
