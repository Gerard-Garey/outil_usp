# Usage : Rscript sonde_574_r1_r2.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1 etape 5, lot A : regles R1 (UTF-8 valide, sans octet nul) et R2
# (commentaire, section CDATA, declaration de type de document, instruction
# de traitement) du contrat ferme du lecteur de classeur.
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de e0ce07a (git show e0ce07a:R/engine.R > fichier).
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
CAS <- c("574-5-QF", "574-5-P2", "574-5-X1", "574-5-sans-renvoi", "r1-feuille-ff", "r1-feuille-nul", "r1-feuille-tronquee",
         "r1-classeur-latin1", "r1-relations-ff", "r1-table-nul", "r1-table-fin-tronquee",
         "r2-feuille-commentaire", "r2-feuille-cdata", "r2-feuille-doctype", "r2-feuille-pi",
         "r2-table-commentaire", "r2-table-cdata", "r2-table-pi", "r2-feuille-declaration-repetee",
         "r2-decl-contournement", "r2-decl-contournement-feuille", "r2-decl-blanc-initial", "r2-decl-saut-initial",
         "r2-cible-point-commentaire", "r2-decl-qq", "r2-decl-englobante-table", "r2-decl-englobante-feuille",
         "r2-decl-valeur-fin", "temoin-decl-tab", "temoin-hors-r1-styles", "temoin-hors-r1-content-types",
         "temoin-sans-declaration", "temoin-bom", "temoin-texte-echappe", "temoin-reference")
if (length(a) < 4) {
  self <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)))
  for (c in CAS) {
    out <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(c(self, depot, sd, moteur, c)),
                                    stdout = TRUE, stderr = TRUE, timeout = 120))
    st <- attr(out, "status"); if (is.null(st)) st <- 0L
    cat(out, sep = "\n"); cat(sprintf("  [code de sortie : %d]\n\n", st))
  }
  quit(save = "no")
}
cas <- a[4]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
source(file.path(sd, "forge.R"))
chemin <- if (requireNamespace("openxlsx", quietly = TRUE))
  paste("openxlsx", as.character(packageVersion("openxlsx"))) else "interne"
cat(sprintf("[%s] chemin = %s ; moteur = %s\n", cas, chemin, basename(dirname(moteur))))
# Ajoute ou modifie des parties de l'archive par fn(dossier d'extraction).
ajouter <- function(f, fn) {
  d <- tempfile("aj_"); utils::unzip(f, exdir = d); fn(d)
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0)
  f
}
# Retouche en octets d'une partie de l'archive : la premiere occurrence de
# `motif` (texte ASCII) est remplacee par les octets `par` (raw).
retoucher <- function(f, partie, motif, par) {
  d <- tempfile("ret_"); utils::unzip(f, exdir = d)
  p <- file.path(d, partie); b <- readBin(p, "raw", file.info(p)$size)
  m <- charToRaw(motif); n <- length(m)
  k <- which(vapply(seq_len(length(b) - n + 1L), function(i) identical(b[i:(i + n - 1L)], m), logical(1)))[1L]
  stopifnot(!is.na(k))
  b <- c(b[seq_len(k - 1L)], par, b[(k + n):length(b)])
  writeBin(b, p)
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0)
  f
}
R <- function(...) c(...)
txt <- function(s) charToRaw(s)
lire_serie <- function(f) {
  w <- character(0)
  df <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
                   warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
                 error = function(err) err)
  if (length(w)) cat(sprintf("  avertissements R : %d (premier : %s)\n", length(w), substr(w[1], 1, 60)))
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s\n  message = %s\n", class(df)[1], conditionMessage(df))); return(invisible(NULL))
  }
  r <- e$engine_lire_donnees_csv(df)
  cat("  engine_lire_donnees_csv : ok =", r$ok, "\n")
  if (r$ok) cat("  xt =", format(r$xt, digits = 10), "\n") else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
b2 <- list("1" = '<c r="B2" t="s"><v>1</v></c>')
f <- switch(cas,
  "574-5-QF" = forger(serie(b2), partagees = R(txt('<si><t>a'), as.raw(0xff), txt('b</t></si><si><r><t>1</t></r><r><t>1.5</t></r></si>'))),
  "574-5-P2" = forger(serie(b2), partagees = R(txt('<si><t>a'), as.raw(0xff), txt('b</t></si><si><t>1</t><rPh sb="0" eb="1"/><r><rPr><b/></rPr><t>1.5</t></r></si>'))),
  "574-5-X1" = forger(serie(b2), partagees = R(txt('<si><t>a'), as.raw(0xff), txt('b</t></si><si><t>1</t><t>1.5</t></si>'))),
  # table invalide qu'aucune cellule ne cite : R10 ne s'applique pas
  "574-5-sans-renvoi" = forger(serie(), partagees = R(txt('<si><t>a'), as.raw(0xff), txt('b</t></si><si><r><t>1</t></r><r><t>1.5</t></r></si>'))),
  "r1-feuille-ff" = retoucher(forger(serie(extra = ci("D9", "zzz"))), "xl/worksheets/sheet1.xml", "zzz", R(txt("a"), as.raw(0xff), txt("b"))),
  "r1-feuille-nul" = retoucher(forger(serie(extra = ci("D9", "zzz"))), "xl/worksheets/sheet1.xml", "zzz", R(txt("a"), as.raw(0x00), txt("b"))),
  "r1-feuille-tronquee" = retoucher(forger(serie(extra = ci("D9", "zzz"))), "xl/worksheets/sheet1.xml", "zzz", R(txt("a"), as.raw(c(0xe2, 0x82)), txt("b"))),
  "r1-classeur-latin1" = retoucher(forger(serie()), "xl/workbook.xml", "Donnees", R(txt("Donn"), as.raw(0xe9), txt("es"))),
  "r1-relations-ff" = retoucher(forger(serie()), "xl/_rels/workbook.xml.rels", "</Relationships>",
                                R(txt('<Relationship Id="rId9" Type="http://example.org/x" Target="x'), as.raw(0xff), txt('.xml"/></Relationships>'))),
  "r1-table-nul" = forger(serie(b2), partagees = R(txt('<si><t>a'), as.raw(0x00), txt('b</t></si><si><t>11.5</t></si>'))),
  "r1-table-fin-tronquee" = forger(serie(b2), partagees = R(txt('<si><t>a</t></si><si><t>11.5</t></si>'), as.raw(0xf0))),
  "r2-feuille-commentaire" = forger(c(serie()[1:2], "<!-- note -->", serie()[3:9])),
  "r2-feuille-cdata" = forger(serie(list("1" = '<c r="B2" t="inlineStr"><is><t><![CDATA[11.5]]></t></is></c>'))),
  "r2-feuille-doctype" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<worksheet", txt('<!DOCTYPE worksheet [<!ENTITY v "11.5">]><worksheet')),
  "r2-feuille-pi" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<sheetData>", txt('<sheetData><?mso note?>')),
  "r2-table-commentaire" = forger(serie(b2), partagees = '<si><t>a</t></si><si><t>11<!-- x -->.5</t></si>'),
  "r2-table-cdata" = forger(serie(b2), partagees = '<si><t>a</t></si><si><t><![CDATA[11.5]]></t></si>'),
  "r2-table-pi" = forger(serie(b2), partagees = '<si><t>a</t></si><?x y?><si><t>11.5</t></si>'),
  "r2-feuille-declaration-repetee" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<worksheet", txt('<?xml version="1.0"?><worksheet')),
  # Lot A, reprise apres l'audit leger : declaration fermee par "??>", puis
  # commentaire et instruction de traitement plus loin (contournement de R2)
  "r2-decl-contournement" = retoucher(forger(serie(b2), partagees = '<si><t>a</t></si><si><t>11<!-- x -->.5</t></si><?z?>'),
                                      "xl/sharedStrings.xml", 'standalone="yes"?>', txt('standalone="yes"??>')),
  "r2-decl-contournement-feuille" = retoucher(retoucher(forger(serie(list("1" = '<c r="B2" t="inlineStr"><is><t>11<!-- x -->.5</t></is></c>'))),
                                      "xl/worksheets/sheet1.xml", 'standalone="yes"?>', txt('standalone="yes"??>')),
                                      "xl/worksheets/sheet1.xml", "</sheetData>", txt("</sheetData><?z?>")),
  "r2-decl-blanc-initial" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<?xml", txt(" <?xml")),
  "r2-decl-saut-initial" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<?xml", txt("\n<?xml")),
  "r2-cible-point-commentaire" = retoucher(retoucher(forger(serie()), "xl/_rels/workbook.xml.rels", 'Target="worksheets/sheet1.xml"',
                                      txt('Target="./worksheets/sheet1.xml"')), "xl/worksheets/sheet1.xml", "<sheetData>", txt("<sheetData><!--x-->")),
  # Seconde reprise : declaration hors grammaire (non fermee, englobant la
  # partie jusqu'a un "?>" final ; "?>" dans une valeur d'attribut)
  "r2-decl-englobante-table" = retoucher(forger(serie(b2), partagees = '<si><t>a</t></si><si><t>11<!-- x -->.5</t></si>?>'),
                                         "xl/sharedStrings.xml", 'standalone="yes"?>', txt('standalone="yes" ')),
  "r2-decl-englobante-feuille" = retoucher(retoucher(forger(serie(list("1" = '<c r="B2" t="inlineStr"><is><t>11<!-- x -->.5</t></is></c>'))),
                                         "xl/worksheets/sheet1.xml", 'standalone="yes"?>', txt('standalone="yes" ')),
                                         "xl/worksheets/sheet1.xml", "</sheetData>", txt("</sheetData>?>")),
  "r2-decl-valeur-fin" = retoucher(forger(serie(b2), partagees = '<si><t>a</t></si><si><t>11<!-- x -->.5</t></si>'),
                                   "xl/sharedStrings.xml", 'standalone="yes"?>', txt('standalone="y?>es"?>')),
  "r2-decl-qq" = retoucher(forger(serie(b2), partagees = '<si><t>a</t></si><si><t>11.5</t></si>'),
                               "xl/sharedStrings.xml", 'standalone="yes"?>', txt('standalone="yes"??>')),
  "temoin-decl-tab" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<?xml version", txt("<?xml\tversion")),
  # Parties hors de R1 (limite consignee, Q4) : octet 0xFF dans xl/styles.xml
  # (relation de styles ajoutee) et dans [Content_Types].xml
  "temoin-hors-r1-styles" = ajouter(forger(serie()), function(d) {
    writeBin(c(txt('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="1"><font><name val="Ca'),
               as.raw(0xff), txt('libri"/></font></fonts><cellXfs count="1"><xf numFmtId="0" fontId="0"/></cellXfs></styleSheet>')), file.path(d, "xl", "styles.xml"))
    rel <- file.path(d, "xl/_rels/workbook.xml.rels")
    writeLines(sub("</Relationships>", '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>',
                   readLines(rel, warn = FALSE)), rel) }),
  "temoin-hors-r1-content-types" = retoucher(forger(serie()), "[Content_Types].xml", "</Types>",
                                             R(txt('<Default Extension="x'), as.raw(0xff), txt('" ContentType="application/xml"/></Types>'))),
  "temoin-sans-declaration" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml",
                                        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', raw(0)),
  "temoin-bom" = retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<?xml", R(as.raw(c(0xef, 0xbb, 0xbf)), txt("<?xml"))),
  "temoin-texte-echappe" = forger(serie(extra = ci("D9", "&lt;!-- &lt;?x?&gt; &lt;![CDATA[ ]]&gt;"))),
  "temoin-reference" = forger(serie()))
lire_serie(f)
