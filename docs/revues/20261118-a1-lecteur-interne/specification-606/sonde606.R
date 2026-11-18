# Sonde de la specification de #606 (A1, etape 1d), actuary, 18/11/2026, lecture seule.
# Usage : LC_ALL=C.UTF-8 Rscript sonde606.R <engine.R a f07e219> <charger_moteur.R> <dossier de travail>
a <- commandArgs(TRUE); moteur <- a[1]; chargeur <- a[2]; base_dir <- a[3]
dir.create(base_dir, showWarnings = FALSE, recursive = TRUE)
source(chargeur); charger_moteur(fichier = moteur)
E <- environment(run_engine)
cat("openxlsx :", requireNamespace("openxlsx", quietly = TRUE), "; md5 moteur :", tools::md5sum(moteur), "\n")
src <- readLines(moteur, warn = FALSE)
corps_fonction <- function(nom) {
  d <- grep(paste0("^", gsub(".", "\\.", nom, fixed = TRUE), " <- function"), src)[1]
  f <- d; while (!identical(src[f], "}")) f <- f + 1L
  paste(src[d:f], collapse = "\n")
}
orig <- list(lire = get("engine_lire_xlsx", E), ligne = get(".xlsx_controler_ligne_entete", E),
             contenus = get(".xlsx_controler_contenus", E))
# Prototype (i) : complement de R8 etendu au <v> des cellules t="str" (meme fonction, meme texte)
contenus_i <- function(cc) {
  contenus_avant(cc)
  ks <- which(cc$typ %in% "str" & !is.na(cc$v))
  if (length(ks))
    .xlsx_controler_references(cc$v[ks], function(i) .xlsx_citer(cc$r_brut[ks][i]), "xl/worksheets/sheet1.xml")
  invisible(NULL)
}
env_i <- new.env(parent = E); env_i$contenus_avant <- orig$contenus
environment(contenus_i) <- env_i
# Prototype (ii) : (i) + decodage du <v> t="str" par .xml_decoder() a l'assemblage et en R12
txt_lire <- corps_fonction("engine_lire_xlsx")
stopifnot(grepl('  s <- typ == "s" & !is.na(val)', txt_lire, fixed = TRUE))
txt_lire <- sub('  s <- typ == "s" & !is.na(val)',
                '  sx <- typ == "str" & !is.na(val); if (any(sx)) val[sx] <- .xml_decoder(val[sx])\n  s <- typ == "s" & !is.na(val)',
                txt_lire, fixed = TRUE)
txt_ligne <- corps_fonction(".xlsx_controler_ligne_entete")
stopifnot(grepl("texte[st] <- brut[st]", txt_ligne, fixed = TRUE))
txt_ligne <- sub("texte[st] <- brut[st]", "texte[st] <- .xml_decoder(brut[st])", txt_ligne, fixed = TRUE)
lire_ii <- eval(parse(text = sub("^engine_lire_xlsx <- ", "", txt_lire)), E)
ligne_ii <- eval(parse(text = sub("^\\.xlsx_controler_ligne_entete <- ", "", txt_ligne)), E)
mode <- function(m) {
  assign(".xlsx_controler_contenus", if (m == "avant") orig$contenus else contenus_i, envir = E)
  assign("engine_lire_xlsx", if (m == "ii") lire_ii else orig$lire, envir = E)
  assign(".xlsx_controler_ligne_entete", if (m == "ii") ligne_ii else orig$ligne, envir = E)
}
forge <- function(nom, rows) {
  df <- data.frame(t = 1:2, xt = c(1, 3), yt = c(2, 4))
  f0 <- file.path(base_dir, paste0(nom, "_0.xlsx")); mode("avant"); E$engine_ecrire_xlsx(df, f0)
  d <- file.path(base_dir, nom); unlink(d, recursive = TRUE); dir.create(d)
  utils::unzip(f0, exdir = d)
  x <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>', rows, '</sheetData></worksheet>')
  writeBin(charToRaw(enc2utf8(x)), file.path(d, "xl/worksheets/sheet1.xml"))
  f <- file.path(base_dir, paste0(nom, ".xlsx")); unlink(f)
  old <- setwd(d); on.exit(setwd(old)); utils::zip(f, list.files(".", recursive = TRUE, all.files = TRUE), flags = "-q -X")
  f
}
is <- function(r, txt) paste0('<c r="', r, '" t="inlineStr"><is><t>', txt, '</t></is></c>')
nb <- function(r, v) paste0('<c r="', r, '"><v>', v, '</v></c>')
st <- function(r, txt) paste0('<c r="', r, '" t="str"><f>A1</f><v>', txt, '</v></c>')
row <- function(n, ...) paste0('<row r="', n, '">', ..., '</row>')
cas <- list(
  F1 = c("C1 : B1 str x&#116; + D1 xt", paste0(row(1, is("A1","t"), st("B1","x&#116;"), is("C1","yt"), is("D1","xt")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), nb("D2",99)), row(3, nb("A3",2), nb("B3",13), nb("C3",4), nb("D3",98)))),
  F2 = c("C1 : B1 str x&#116; seul", paste0(row(1, is("A1","t"), st("B1","x&#116;"), is("C1","yt")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2)), row(3, nb("A3",2), nb("B3",13), nb("C3",4)))),
  F3 = c("C1 : B2 str 1&#48;4.2", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt")),
        row(2, nb("A2",1), st("B2","1&#48;4.2"), nb("C2",2)), row(3, nb("A3",2), nb("B3",13), nb("C3",4)))),
  F4 = c("B1 str xt&#9; + D1 xt (blanc, D-S1-23)", paste0(row(1, is("A1","t"), st("B1","xt&#9;"), is("C1","yt"), is("D1","xt")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), nb("D2",99)), row(3, nb("A3",2), nb("B3",13), nb("C3",4), nb("D3",98)))),
  F5 = c("B1 str x&#X74; (X majuscule)", paste0(row(1, is("A1","t"), st("B1","x&#X74;"), is("C1","yt")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2)), row(3, nb("A3",2), nb("B3",13), nb("C3",4)))),
  F6 = c("D2 str &#65; en colonne annexe", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), st("D2","&#65;")), row(3, nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a")))),
  F7 = c("entites nommees : D1 str R&amp;D, D2 str a&lt;b&gt;c", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt"), st("D1","R&amp;D")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), st("D2","a&lt;b&gt;c")), row(3, nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a")))),
  F8 = c("references admises : D2 str caf&#233;, D3 str &#38;&#0;", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), st("D2","caf&#233;")), row(3, nb("A3",2), nb("B3",13), nb("C3",4), st("D3","&#38;&#0;")))),
  F9 = c("B2 str 104.2&#160; (insecable admise)", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt")),
        row(2, nb("A2",1), st("B2","104.2&#160;"), nb("C2",2)), row(3, nb("A3",2), nb("B3",13), nb("C3",4)))),
  F10 = c("temoin : B1 str xt, B2 str 104.2", paste0(row(1, is("A1","t"), st("B1","xt"), is("C1","yt")),
        row(2, nb("A2",1), st("B2","104.2"), nb("C2",2)), row(3, nb("A3",2), nb("B3",13), nb("C3",4)))),
  F11 = c("A1 str &amp;amp;lt; en en-tete annexe ; ligne 1 sinon normale", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt"), st("D1","&amp;lt;")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), nb("D2",5)), row(3, nb("A3",2), nb("B3",13), nb("C3",4), nb("D3",6)))),
  F12 = c("meme texte en chaine en ligne (reference) : D1 R&amp;D, D2 caf&#233;", paste0(row(1, is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","R&amp;D")),
        row(2, nb("A2",1), nb("B2",11), nb("C2",2), is("D2","caf&#233;")), row(3, nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a"))))
)
resume <- function(f) {
  r <- tryCatch(E$engine_lire_xlsx(f), error = function(e) e)
  if (inherits(r, "error")) return(list(txt = paste0("REFUS lecture [", paste(class(r)[1:2], collapse = "/"), "] : ", conditionMessage(r)), df = NULL, aval = NULL))
  l <- E$engine_lire_donnees_csv(r)
  noms <- paste(encodeString(names(r), quote = '"'), collapse = ",")
  cols <- paste(vapply(names(r), function(n) paste0(n, "=", paste(encodeString(as.character(r[[n]]), quote = '"'), collapse = " ")), ""), collapse = " ; ")
  av <- if (isTRUE(l$ok)) paste0("aval ok ; xt = ", paste(l$donnees$xt %||% l$xt, collapse = " ")) else paste0("aval refus : ", paste(l$erreurs, collapse = " | "))
  list(txt = paste0("noms ", noms, " | ", cols, " | ", av), df = r, aval = l)
}
`%||%` <- function(a, b) if (is.null(a)) b else a
res <- list()
for (k in names(cas)) {
  f <- forge(k, cas[[k]][2])
  cat("\n[", k, "] ", cas[[k]][1], "\n", sep = "")
  for (m in c("avant", "i", "ii")) {
    mode(m); r <- resume(f); res[[k]][[m]] <- r
    cat("  ", m, " : ", r$txt, "\n", sep = "")
  }
  cat("  identical(i, ii) df :", identical(res[[k]]$i$df, res[[k]]$ii$df), "; identical(avant, i) df :", identical(res[[k]]$avant$df, res[[k]]$i$df), "\n")
}
# Coherence (ii) : F7/F8 lus comme le meme texte en chaine en ligne (F12)
cat("\n(ii) F7 D1/D2 vs F12 :", identical(names(res$F7$ii$df)[4], names(res$F12$ii$df)[4]), "\n")
cat("(ii) F8 D2 vs F12 D2 :", identical(res$F8$ii$df$note[1], res$F12$ii$df[[4]][1]), "\n")
mode("avant")
