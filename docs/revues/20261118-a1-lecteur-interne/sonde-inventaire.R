# Sonde de l'inventaire des ecarts (etape 1a d'A1), ecrite par actuary-approfondi le 18/11/2026.
# Usage (racine du depot, LC_ALL=C.UTF-8) : Rscript sonde-inventaire.R <dossier de travail>,
# avec R_LIBS=<bibliotheque contenant openxlsx 4.2.5.2> pour le chemin openxlsx.
source("R/charger_moteur.R"); charger_moteur()
E <- environment(run_engine)
base_dir <- commandArgs(TRUE)[1]; dir.create(base_dir, showWarnings = FALSE, recursive = TRUE)
ox <- requireNamespace("openxlsx", quietly = TRUE)
cat("openxlsx :", if (ox) as.character(packageVersion("openxlsx")) else "absent", "\n")
# Chemin interne force : requireNamespace substitue dans l'environnement du moteur
interne <- function(f) { assign("requireNamespace", function(p, ...) if (p == "openxlsx") FALSE else base::requireNamespace(p, ...), envir = E)
  on.exit(rm("requireNamespace", envir = E)); tryCatch(engine_lire_xlsx(f), error = function(e) paste("ERREUR:", conditionMessage(e))) }
viaox <- function(f) if (ox) tryCatch(engine_lire_xlsx(f), error = function(e) paste("ERREUR:", conditionMessage(e))) else "openxlsx absent"
# Classeur de base ecrit par l'ecrivain interne, puis feuille remplacee
forge <- function(nom, sheet_xml, shared = NULL, wb = NULL, rels = NULL, extra = NULL) {
  df <- data.frame(t = 1:2, xt = c(1, 3), yt = c(2, 4))
  f0 <- file.path(base_dir, paste0(nom, "_0.xlsx")); engine_ecrire_xlsx(df, f0)
  d <- file.path(base_dir, nom); unlink(d, recursive = TRUE); dir.create(d)
  utils::unzip(f0, exdir = d)
  writeBin(charToRaw(enc2utf8(sheet_xml)), file.path(d, "xl/worksheets/sheet1.xml"))
  if (!is.null(wb)) writeBin(charToRaw(wb), file.path(d, "xl/workbook.xml"))
  if (!is.null(rels)) writeBin(charToRaw(rels), file.path(d, "xl/_rels/workbook.xml.rels"))
  if (!is.null(extra)) for (k in names(extra)) { dir.create(dirname(file.path(d, k)), recursive = TRUE, showWarnings = FALSE); writeBin(charToRaw(extra[[k]]), file.path(d, k)) }
  f <- file.path(base_dir, paste0(nom, ".xlsx")); unlink(f)
  old <- setwd(d); on.exit(setwd(old)); utils::zip(f, list.files(".", recursive = TRUE, all.files = TRUE), flags = "-q -X")
  f
}
sh <- function(rows) paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>', rows, '</sheetData></worksheet>')
is <- function(r, txt) paste0('<c r="', r, '" t="inlineStr"><is><t>', txt, '</t></is></c>')
nb <- function(r, v) paste0('<c r="', r, '"><v>', v, '</v></c>')
st <- function(r, txt) paste0('<c r="', r, '" t="str"><f>A1</f><v>', txt, '</v></c>')
montre <- function(lab, f) { cat("\n[", lab, "]\n", sep = "")
  for (ch in c("interne", "openxlsx")) { r <- if (ch == "interne") interne(f) else viaox(f)
    cat(" ", ch, ": ")
    if (is.data.frame(r)) { cat("noms =", paste(sprintf("%s", encodeString(names(r), quote='"')), collapse = ","), "; classes =", paste(vapply(r, function(x) class(x)[1], ""), collapse = ","), "\n")
      for (j in seq_along(r)) cat("    ", names(r)[j], ":", paste(encodeString(as.character(r[[j]]), quote='"'), collapse = " "), "\n")
      l <- engine_lire_donnees_csv(r); cat("    aval ok =", l$ok, if (!l$ok) paste("; erreurs :", paste(l$erreurs, collapse = " | ")) else paste("; xt =", paste(l$donnees$xt %||% l$xt, collapse = " ")), "\n")
    } else cat(r, "\n") } }
`%||%` <- function(a, b) if (is.null(a)) b else a
# 1. t="str" en-tete x&#116; en B1 et xt en D1
f1 <- forge("str_ref", sh(paste0('<row r="1">', is("A1","t"), st("B1","x&#116;"), is("C1","yt"), is("D1","xt"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), nb("D2",99), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), nb("D3",98), '</row>')))
montre("t=str en-tete B1 x&#116; + D1 xt", f1)
# 1b. t="str" en-tete x&#116; seul
f1b <- forge("str_ref_seul", sh(paste0('<row r="1">', is("A1","t"), st("B1","x&#116;"), is("C1","yt"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), '</row>')))
montre("t=str en-tete B1 x&#116; seul", f1b)
# 1c. t="str" valeur 1&#48;4.2
f1c <- forge("str_val", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), '</row>',
  '<row r="2">', nb("A2",1), st("B2","1&#48;4.2"), nb("C2",2), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), '</row>')))
montre("t=str valeur B2 1&#48;4.2", f1c)
# 2. lignes vides d'un texte en ligne
f2 <- forge("lignes_vides", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), is("D2","1\n\n2"), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a"), '</row>')))
montre("texte en ligne 1<LF><LF>2 en colonne annexe", f2)
# 3. reference admise &#160; dans une valeur et entite dans une chaine en ligne
f3 <- forge("ref_admise", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","R&amp;D"), '</row>',
  '<row r="2">', nb("A2",1), is("B2","104.2&#160;"), nb("C2",2), is("D2","&#233;"), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a"), '</row>')))
montre("valeur B2 104.2&#160; en ligne ; D1 R&amp;D ; D2 &#233;", f3)
# 4. retour chariot litteral dans une chaine en ligne (#602)
f4 <- forge("crlf", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), is("D2","a\r\nb"), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), is("D3","c\rd"), '</row>')))
montre("texte en ligne a<CR><LF>b et c<CR>d (#602)", f4)
# 5. cible ./worksheets/sheet1.xml
rels0 <- readLines(unz(f1, "xl/_rels/workbook.xml.rels"), warn = FALSE)
rels5 <- sub('Target="worksheets/sheet1.xml"', 'Target="./worksheets/sheet1.xml"', paste(rels0, collapse = "\n"), fixed = TRUE)
cat("\nrelations d'origine contiennent worksheets/sheet1.xml :", grepl('Target="worksheets/sheet1.xml"', paste(rels0, collapse="\n"), fixed = TRUE), "\n")
f5 <- forge("cible_point", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), '</row>')), rels = rels5)
montre("cible ./worksheets/sheet1.xml", f5)
# 6. ecrivain interne, &,<,> et logique
f6 <- file.path(base_dir, "ecrivain.xlsx"); unlink(f6)
d6 <- data.frame(c("a<b&c", "x>y", "simple"), c(TRUE, FALSE, NA), c(1.5, 2, 3), stringsAsFactors = FALSE); names(d6) <- c("l&b", "l", "n")
engine_ecrire_xlsx(d6, f6)
cat("\n[ecrivain interne : &,<,> et logique]\n"); print(str(interne(f6))); if (ox) print(str(viaox(f6)))
# 7. <t/> en ligne et <si></si>
f7 <- forge("t_vide", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), '<c r="D2" t="inlineStr"><is><t/></is></c>', '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), is("D3","a"), '</row>')))
montre("<t/> en ligne en D2", f7)
# 8. textes true et &amp;lt;1 en chaine partagee
shs <- '<?xml version="1.0" encoding="UTF-8"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="2" uniqueCount="2"><si><t>true</t></si><si><t>&amp;lt;1</t></si></sst>'
f8 <- forge("partagees_textes", sh(paste0('<row r="1">', is("A1","t"), is("B1","xt"), is("C1","yt"), is("D1","note"), '</row>',
  '<row r="2">', nb("A2",1), nb("B2",11), nb("C2",2), '<c r="D2" t="s"><v>0</v></c>', '</row>', '<row r="3">', nb("A3",2), nb("B3",13), nb("C3",4), '<c r="D3" t="s"><v>1</v></c>', '</row>')),
  extra = list("xl/sharedStrings.xml" = shs))
montre("chaines partagees true et &amp;lt;1 (sans relation ni type de contenu declares)", f8)
